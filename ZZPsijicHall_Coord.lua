local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Polar      = {}
ZZPsijicHall.Cartesian  = {}
local Polar     = ZZPsijicHall.Polar
local Cartesian = ZZPsijicHall.Cartesian

function ZZPsijicHall.deg2rad(deg)
    return deg * math.pi / 180
end

function ZZPsijicHall.rad2deg(rad)
    return rad * 180 / math.pi
end

function ZZPsijicHall.round(x, to_what)
    to_what = to_what or 1
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

function ZZPsijicHall.CartesianToPolar( x, z, origin_x, origin_z )
    local dx            = x - origin_x
    local dz            = z - origin_z
    local radius        = math.sqrt(dx^2 + dz^2)
    local theta_rads    = math.atan2(dz, dx)
    return { radius = r, theta_rads = theta_rads }
end

function ZZPsijicHall.PolarToCartesian( radius, theta_rads, origin_x, origin_z )
    local dx = radius * math.cos(theta_rads)
    local dz = radius * math.sin(theta_rads)
    local x  = origin_x + dx
    local z  = origin_z + dz

    return { x = ZZPsijicHall.round(x)
           , z = ZZPsijicHall.round(z)
           }
end

-- Polar ---------------------------------------------------------------------

function Polar:New(r, theta_rads)
    local o = { r = r, theta_rads = theta_rads}

    setmetatable(o, self)
    self.__index = self
    return o
end

function Polar:FromCartesian(cartesian, origin)
    local p = ZZPsijicHall.CartesianToPolar(
                                  cartesian.x
                                , cartesian.z
                                , origin_x
                                , origin_z
                                )
    return Polar:New(p.r, p.theta_rads)
end



-- Cartesian -----------------------------------------------------------------

function Cartesian:New(x, z)
    local o = { x = x, z = z }

    setmetatable(o, self)
    self.__index = self
    return o
end

function Cartesian:FromPolar(polar, origin)
    local c = ZZPsijicHall.PolarToCartesian(
                                  polar.radius
                                , polar.theta_rads
                                , origin.x
                                , origin.z
                                )
    return Cartesian:New(c.x, c.z)
end
