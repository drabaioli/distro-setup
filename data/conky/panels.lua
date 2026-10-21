require 'cairo'

local W = 520
local SANS, ICONS = 'Ubuntu', 'JetBrainsMono Nerd Font'
local FG, DIM = {0.95, 0.96, 1}, {0.52, 0.58, 0.74}
local ACCENT = {0.10, 0.33, 0.72}
local PAD, RADIUS = 32, 22
local TOP = PAD - 13  -- 13px = gap between baseline and cap height of the 24px headings

local function icon(code) return utf8.char(code) end

-- WMO weather code -> {nerd font glyph, description}
local function wx(code)
    code = tonumber(code) or -1
    if code == 0 then return icon(0xe30d), 'Clear' end
    if code <= 2 then return icon(0xe302), 'Partly cloudy' end
    if code == 3 then return icon(0xe312), 'Overcast' end
    if code <= 48 then return icon(0xe313), 'Fog' end
    if code <= 57 then return icon(0xe31b), 'Drizzle' end
    if code <= 67 then return icon(0xe318), 'Rain' end
    if code <= 77 then return icon(0xe31a), 'Snow' end
    if code <= 82 then return icon(0xe319), 'Showers' end
    if code <= 86 then return icon(0xe31a), 'Snow showers' end
    if code >= 95 then return icon(0xe31d), 'Thunderstorm' end
    return icon(0xe312), '--'
end

local function pkg_temp()
    for i = 0, 9 do
        local t = io.open('/sys/class/thermal/thermal_zone' .. i .. '/type')
        if t then
            local kind = t:read('*l'); t:close()
            if kind == 'x86_pkg_temp' then
                local f = io.open('/sys/class/thermal/thermal_zone' .. i .. '/temp')
                if f then local v = tonumber(f:read('*l')); f:close(); return v and v / 1000 end
            end
        end
    end
end

local function text(cr, s, x, y, size, font, color, align, weight)
    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, weight or CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, size)
    local ext = cairo_text_extents_t:create()
    cairo_text_extents(cr, s, ext)
    if align == 'center' then x = x - (ext.width / 2 + ext.x_bearing)
    elseif align == 'right' then x = x - (ext.width + ext.x_bearing) end
    cairo_set_source_rgba(cr, color[1], color[2], color[3], color[4] or 1)
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, s)
end

local function line(cr, x1, y1, x2, y2)
    cairo_set_source_rgba(cr, 0.5, 0.6, 0.85, 0.35)
    cairo_set_line_width(cr, 1)
    cairo_move_to(cr, x1, y1)
    cairo_line_to(cr, x2, y2)
    cairo_stroke(cr)
end

local function bar(cr, x, y, w, frac, color)
    frac = math.max(0, math.min(1, frac))
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr, 6)
    cairo_set_source_rgba(cr, 1, 1, 1, 0.14)
    cairo_move_to(cr, x, y); cairo_line_to(cr, x + w, y); cairo_stroke(cr)
    if frac > 0 then
        cairo_set_source_rgba(cr, color[1], color[2], color[3], 1)
        cairo_move_to(cr, x, y); cairo_line_to(cr, x + w * frac, y); cairo_stroke(cr)
    end
end

local function heat(frac)  -- blue -> amber -> red
    if frac < 0.6 then return ACCENT end
    if frac < 0.85 then return {0.88, 0.52, 0.08} end
    return {0.82, 0.18, 0.28}
end

local function num(s) return tonumber(conky_parse(s)) or 0 end

function conky_draw_widget()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- Dark navy panel behind everything
    local pw, ph = conky_window.width, conky_window.height
    cairo_new_sub_path(cr)
    cairo_arc(cr, pw - RADIUS, RADIUS, RADIUS, -math.pi / 2, 0)
    cairo_arc(cr, pw - RADIUS, ph - RADIUS, RADIUS, 0, math.pi / 2)
    cairo_arc(cr, RADIUS, ph - RADIUS, RADIUS, math.pi / 2, math.pi)
    cairo_arc(cr, RADIUS, RADIUS, RADIUS, math.pi, 3 * math.pi / 2)
    cairo_close_path(cr)
    cairo_set_source_rgba(cr, 0.01, 0.02, 0.07, 0.45)
    cairo_fill(cr)
    cairo_translate(cr, PAD, TOP)

    -- Clock
    text(cr, 'Today', 0, 30, 24, SANS .. ' Light', DIM)
    text(cr, os.date('%H:%M'), 105, 120, 84, SANS .. ' Light', FG, 'center')
    text(cr, os.date('%A, %d %B'), 105, 160, 20, SANS .. ' Light', DIM, 'center')
    line(cr, 262, 6, 262, 176)

    -- System bars
    text(cr, 'System', 290, 30, 24, SANS .. ' Light', DIM)
    local temp = pkg_temp()
    local down = num('${downspeedf eth0}')
    local iface = conky_parse('${gw_iface}')
    if iface ~= '' then down = num('${downspeedf ' .. iface .. '}') end
    local rows = {
        {0xf2db, num('${cpu cpu0}') / 100, string.format('%d%%', num('${cpu cpu0}'))},
        {0xf035b, num('${memperc}') / 100, string.format('%d%%', num('${memperc}'))},
        {0xf0a0, num('${fs_used_perc /}') / 100, string.format('%d%%', num('${fs_used_perc /}'))},
        {0xf2c9, (temp or 0) / 100, temp and string.format('%d°', temp) or '--'},
        {0xf063, math.sqrt(down / 12288), string.format('%.1fM', down / 1024)},
    }
    for i, r in ipairs(rows) do
        local y = 62 + (i - 1) * 28
        text(cr, icon(r[1]), 290, y + 6, 16, ICONS, DIM)
        bar(cr, 322, y, 130, r[2], heat(r[2]))
        text(cr, r[3], W, y + 6, 15, SANS, FG, 'right')
    end

    -- Weather
    line(cr, 0, 206, W, 206)
    local f = {}
    for v in (conky_parse('${execi 900 ~/.config/conky/weather.sh}') .. '|'):gmatch('([^|]*)|') do f[#f + 1] = v end
    if #f >= 16 then
        local glyph, desc = wx(f[1])
        text(cr, glyph, 0, 290, 54, ICONS, ACCENT)
        text(cr, f[2] .. '°', 102, 270, 44, SANS .. ' Light', FG)
        text(cr, desc, 104, 296, 16, SANS, DIM)
        text(cr, icon(0xf062), 104, 320, 13, ICONS, DIM)
        text(cr, f[3] .. '°', 122, 320, 16, SANS, FG)
        text(cr, icon(0xf063), 164, 320, 13, ICONS, DIM)
        text(cr, f[4] .. '°', 182, 320, 16, SANS, FG)
        for i = 0, 2 do
            local cx = 300 + i * 92
            local b = 5 + i * 4
            text(cr, f[b], cx, 240, 16, SANS, DIM, 'center')
            text(cr, (wx(f[b + 1])), cx, 285, 32, ICONS, ACCENT, 'center')
            text(cr, f[b + 2] .. '° / ' .. f[b + 3] .. '°', cx, 316, 15, SANS, FG, 'center')
        end
    else
        text(cr, 'Weather unavailable', 0, 270, 18, SANS, DIM)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
