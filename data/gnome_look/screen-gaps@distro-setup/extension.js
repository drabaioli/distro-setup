'use strict';

const { Meta, St } = imports.gi;
const Main = imports.ui.main;

const GAP = 10;

// Mirrors the side detection in GNOME Shell's LayoutManager._updateRegions().
function strutSide(x1, y1, x2, y2, m) {
    if (x1 <= m.x && x2 >= m.x + m.width)
        return y1 <= m.y ? Meta.Side.TOP : y2 >= m.y + m.height ? Meta.Side.BOTTOM : null;
    if (y1 <= m.y && y2 >= m.y + m.height)
        return x1 <= m.x ? Meta.Side.LEFT : x2 >= m.x + m.width ? Meta.Side.RIGHT : null;
    if (x1 <= m.x)
        return Meta.Side.LEFT;
    if (y1 <= m.y)
        return Meta.Side.TOP;
    if (x2 >= m.x + m.width)
        return Meta.Side.RIGHT;
    if (y2 >= m.y + m.height)
        return Meta.Side.BOTTOM;
    return null;
}

class ScreenGaps {
    enable() {
        this._struts = [];
        this._monitorsChangedId = Main.layoutManager.connect('monitors-changed',
            () => this._rebuild());
        this._workareasChangedId = global.display.connect('workareas-changed',
            () => this._update());
        this._rebuild();
    }

    disable() {
        Main.layoutManager.disconnect(this._monitorsChangedId);
        global.display.disconnect(this._workareasChangedId);
        this._destroyStruts();
    }

    _destroyStruts() {
        for (const s of this._struts)
            s.actor.destroy();
        this._struts = [];
    }

    _rebuild() {
        this._destroyStruts();
        for (const monitor of Main.layoutManager.monitors) {
            for (const side of [Meta.Side.TOP, Meta.Side.BOTTOM, Meta.Side.LEFT, Meta.Side.RIGHT]) {
                const actor = new St.Widget({ reactive: false, opacity: 0 });
                Main.layoutManager.addChrome(actor, {
                    affectsStruts: true,
                    affectsInputRegion: false,
                });
                this._struts.push({ actor, monitor, side });
            }
        }
        this._update();
    }

    // Thickness of the struts other chrome (top bar, a fixed dock, ...) reserves on each side.
    _otherStruts(monitor) {
        const ours = this._struts.map(s => s.actor);
        const extent = { [Meta.Side.TOP]: 0, [Meta.Side.BOTTOM]: 0, [Meta.Side.LEFT]: 0, [Meta.Side.RIGHT]: 0 };
        for (const data of Main.layoutManager._trackedActors) {
            if (!data.affectsStruts || ours.includes(data.actor))
                continue;
            if (Main.layoutManager.findMonitorForActor(data.actor) !== monitor)
                continue;
            const [x, y] = data.actor.get_transformed_position();
            const [w, h] = data.actor.get_transformed_size();
            const x1 = Math.round(x), y1 = Math.round(y);
            const x2 = x1 + Math.round(w), y2 = y1 + Math.round(h);
            switch (strutSide(x1, y1, x2, y2, monitor)) {
            case Meta.Side.TOP: extent[Meta.Side.TOP] = Math.max(extent[Meta.Side.TOP], y2 - monitor.y); break;
            case Meta.Side.BOTTOM: extent[Meta.Side.BOTTOM] = Math.max(extent[Meta.Side.BOTTOM], monitor.y + monitor.height - y1); break;
            case Meta.Side.LEFT: extent[Meta.Side.LEFT] = Math.max(extent[Meta.Side.LEFT], x2 - monitor.x); break;
            case Meta.Side.RIGHT: extent[Meta.Side.RIGHT] = Math.max(extent[Meta.Side.RIGHT], monitor.x + monitor.width - x1); break;
            }
        }
        return extent;
    }

    _update() {
        const extents = new Map();
        for (const { actor, monitor, side } of this._struts) {
            if (!extents.has(monitor))
                extents.set(monitor, this._otherStruts(monitor));
            const t = extents.get(monitor)[side] + GAP;
            const m = monitor;
            let box;
            switch (side) {
            case Meta.Side.TOP: box = [m.x, m.y, m.width, t]; break;
            case Meta.Side.BOTTOM: box = [m.x, m.y + m.height - t, m.width, t]; break;
            case Meta.Side.LEFT: box = [m.x, m.y, t, m.height]; break;
            case Meta.Side.RIGHT: box = [m.x + m.width - t, m.y, t, m.height]; break;
            }
            const [x, y, w, h] = box;
            if (actor.x !== x || actor.y !== y || actor.width !== w || actor.height !== h) {
                actor.set_position(x, y);
                actor.set_size(w, h);
            }
        }
    }
}

function init() {
    return new ScreenGaps();
}
