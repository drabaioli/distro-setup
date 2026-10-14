require 'cairo'

-- Accent bars: {y_top, height, r, g, b}, relative to the conky window.
local bars = {
    {21, 97, 0.761, 0.176, 0.290},
    {151, 75, 0.969, 0.682, 0.231},
}

function conky_draw_bars()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    for _, b in ipairs(bars) do
        cairo_set_source_rgba(cr, b[3], b[4], b[5], 1)
        cairo_rectangle(cr, 422, b[1], 12, b[2])
        cairo_fill(cr)
    end
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
