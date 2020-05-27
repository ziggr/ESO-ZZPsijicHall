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

function ZZPsijicHall.round(x)

end

function ZZPsijicHall.CartesianToPolar( x, z, origin_x, origin_z )
    local dx        = x - origin_x
    local dz        = z - origin_z
    local radius    = math.sqrt(dx^2 + dz^2)
    local theta     = math.atan2(dz, dx)
    return { radius = r, theta = theta }
end

function ZZPsijicHall.PolarToCartesian( radius, theta, origin_x, origin_z )
    local dx = radius * math.cos(theta)
    local dy = radius * math.sin(theta)

function Polar:New()
    local o = { r = nil, theta = nil}

    setmetatable(o, self)
    self.__index = self
    return o
end

function Polar:FromCartesian(cartesian, origin)
