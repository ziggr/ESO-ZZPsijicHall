function deg2rad(deg)
    return deg * math.pi / 180
end

function rad2deg(rad)
    return rad * 180 / math.pi
end

function round(x, to_what)
    to_what = to_what or 10
    local boosted = x / to_what
    local trunced = 0
    if x < 0 then
        boosted = boosted - 0.5
        trunced = math.ceil(boosted)
    else
        boosted = boosted + 0.5
        trunced = math.floor(boosted)
    end
    return trunced * to_what
end

local radius = 1.0

for theta_deg = 0,360,5 do
    local theta_rad = deg2rad(theta_deg)

    local x = math.cos(theta_rad) * radius
    local y = math.sin(theta_rad) * radius

    local q_rad = math.atan2(y,x)
    if q_rad < 0 then
        q_rad = q_rad + 2 * math.pi
    end

    local q_deg = rad2deg(q_rad)

    local s = string.format("%3d %4.2f  xy %5.2f %5.2f  atan %5.2f %3d"
                    , theta_deg
                    , theta_rad
                    , x
                    , y
                    , q_rad
                    , round(q_deg, 5) )
    print(s)
end
