'use strict';

const { Clutter, GObject, Shell, St } = imports.gi;
const Main = imports.ui.main;

const SIGMA = 30;
const BRIGHTNESS = 0.9;
const CORNER_RADIUS = 10; // keep in sync with .popup-menu-content in the theme

// Clips its actor to a rounded rectangle covering the whole actor.
const RoundedMaskEffect = GObject.registerClass(
class RoundedMaskEffect extends Clutter.ShaderEffect {
    _init(radius) {
        super._init({ shader_type: Clutter.ShaderType.FRAGMENT_SHADER });
        this._radius = radius;
        this.set_shader_source(`
            uniform sampler2D tex;
            uniform float width;
            uniform float height;
            uniform float radius;
            void main() {
                vec2 uv = cogl_tex_coord_in[0].xy;
                vec2 size = vec2(width, height);
                vec2 half_size = size / 2.0;
                vec2 q = abs(uv * size - half_size) - half_size + radius;
                float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
                cogl_color_out = texture2D(tex, uv) * clamp(0.5 - d, 0.0, 1.0);
            }`);
    }

    vfunc_paint_target(node, paintContext) {
        const actor = this.get_actor();
        this.set_uniform_value('tex', 0);
        // Integer-valued JS numbers would be passed as GLSL ints; the 1e-6
        // offset keeps them floats.
        this.set_uniform_value('width', actor.width + 1e-6);
        this.set_uniform_value('height', actor.height + 1e-6);
        this.set_uniform_value('radius', this._radius + 1e-6);
        super.vfunc_paint_target(node, paintContext);
    }
});

// A blurred, rounded copy of everything behind a menu. It is a sibling placed
// right below the menu in the UI group: clones of the background and window
// groups (so open windows are included, not just the wallpaper) are blurred
// as an actor and then clipped to the menu's rounded shape. Blurring what is
// behind the menu with Shell.BlurMode.BACKGROUND would give square corners.
class MenuBlur {
    constructor(menu) {
        this._menu = menu;
        this._host = null;
        this._ids = [
            menu.connect('open-state-changed', (_m, open) => this._onOpenState(open)),
            menu.connect('destroy', () => this.destroy()),
        ];
    }

    destroy() {
        if (this._menu) {
            this._ids.forEach(id => this._menu.disconnect(id));
            this._ids = [];
        }
        this._destroyHost();
        this._menu = null;
    }

    _onOpenState(open) {
        if (open && !this._host)
            this._createHost();
        if (!this._host)
            return;
        if (open)
            this._cloneWindows();
        this._host.visible = open;
    }

    _createHost() {
        const box = this._menu.actor;
        const bin = box.bin;
        if (!bin || !box.get_parent())
            return;

        const host = new Clutter.Actor({
            clip_to_allocation: true,
            reactive: false,
        });

        // Everything the menu covers, drawn at stage coordinates; the layer
        // is shifted so that the stage origin matches the host's origin.
        this._layer = new Clutter.Actor();
        this._layer.add_child(new Clutter.Clone({
            source: Main.layoutManager._backgroundGroup,
            width: global.stage.width,
            height: global.stage.height,
        }));
        host.add_child(this._layer);
        this._windowClones = [];

        // Both effects need the actor's own size; masking is outermost so
        // the blur still sees the clones.
        host.add_effect(new RoundedMaskEffect(CORNER_RADIUS));
        host.add_effect(new Shell.BlurEffect({
            name: 'menu-blur',
            sigma: SIGMA,
            brightness: BRIGHTNESS,
            mode: Shell.BlurMode.ACTOR,
        }));

        box.get_parent().insert_child_below(host, box);
        this._host = host;

        // Place the host over the menu's content, keep the clones aligned
        // with the stage, and follow the menu while it moves and fades.
        const sync = () => {
            const [x, y] = bin.get_transformed_position();
            const [w, h] = bin.get_transformed_size();
            if (![x, y, w, h].every(isFinite))
                return;
            host.set_position(x, y);
            host.set_size(w, h);
            this._layer.set_position(-x, -y);
        };
        this._hostIds = [
            [bin, bin.connect('notify::allocation', sync)],
            [box, box.connect('notify::allocation', sync)],
            [box, box.connect('notify::translation-y', sync)],
            [box, box.connect('notify::scale-y', sync)],
            [box, box.connect('notify::opacity', () => (host.opacity = box.opacity))],
            [box, box.connect('notify::visible', () => (host.visible = box.visible))],
        ];
        host.opacity = box.opacity;
        sync();
    }

    // Windows are cloned one by one: a clone of the whole window group does
    // not draw them. Rebuilt on each open since the stack changes.
    _cloneWindows() {
        this._windowClones.forEach(c => c.destroy());
        this._windowClones = global.get_window_actors()
            .filter(actor => actor.visible && actor.mapped)
            .map(actor => {
                const clone = new Clutter.Clone({ source: actor });
                clone.set_position(actor.x, actor.y);
                this._layer.add_child(clone);
                return clone;
            });
    }

    _destroyHost() {
        if (!this._host)
            return;
        this._hostIds.forEach(([obj, id]) => obj.disconnect(id));
        this._host.destroy();
        this._host = null;
    }
}

class Extension {
    enable() {
        this._blurs = new Map();
        const manager = Main.panel.menuManager;

        this._origAddMenu = manager.addMenu;
        const self = this;
        manager.addMenu = function (menu, position) {
            self._track(menu);
            return self._origAddMenu.call(this, menu, position);
        };
        manager._menus.forEach(entry => this._track(entry.menu || entry));
    }

    disable() {
        Main.panel.menuManager.addMenu = this._origAddMenu;
        this._blurs.forEach(blur => blur.destroy());
        this._blurs = null;
    }

    _track(menu) {
        if (!this._blurs.has(menu))
            this._blurs.set(menu, new MenuBlur(menu));
    }
}

function init() {
    return new Extension();
}
