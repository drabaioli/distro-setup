require 'cairo'

-- Dark translucent rounded panels behind the text: {y_top, height}, relative to the conky window.
local panels = {
    {0, 150},
    {166, 150},
}
local radius = 18

function conky_draw_panels()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    local w = conky_window.width
    for _, p in ipairs(panels) do
        local y, h = p[1], p[2]
        cairo_new_sub_path(cr)
        cairo_arc(cr, w - radius, y + radius, radius, -math.pi / 2, 0)
        cairo_arc(cr, w - radius, y + h - radius, radius, 0, math.pi / 2)
        cairo_arc(cr, radius, y + h - radius, radius, math.pi / 2, math.pi)
        cairo_arc(cr, radius, y + radius, radius, math.pi, 3 * math.pi / 2)
        cairo_close_path(cr)
        cairo_set_source_rgba(cr, 0.05, 0.05, 0.08, 0.55)
        cairo_fill(cr)
    end
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
