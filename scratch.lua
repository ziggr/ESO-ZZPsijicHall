dofile("ZZPsijicHall_Define.lua")
dofile("ZZPsijicHall_Coord.lua")
dofile("ZZPsijicHall_Geometry.lua")

local Cartesian = ZZPsijicHall.Cartesian
local Line      = ZZPsijicHall.Line
local Polar     = ZZPsijicHall.Polar

-- ZZPsijicHall.Line.Test_Intersect()

-- Origin for current platform arc:
-- origin: 79536,63171
-- radius: 3633


POINTS = {
  Cartesian:New(82526, 65237)
, Cartesian:New(82985, 64317)
, Cartesian:New(83168, 63305)
, Cartesian:New(83060, 62282)
, Cartesian:New(82671, 61330)
, Cartesian:New(81190, 59932)
, Cartesian:New(82030, 60525)
, Cartesian:New(80218, 59597)
}

                        -- Test geometry functions. Are we calculating
                        -- a useful origin and radius for a circle drawn
                        -- through our platforms?

local function SectOne(i1,i2,i3,i4)
    local pt        = { POINTS[i1], POINTS[i2], POINTS[i3], POINTS[i4] }
    local intersect = Line.Intersect( Line:Bisect(pt[1], pt[2])
                                    , Line:Bisect(pt[3], pt[4]) )

    local origin    = intersect
    print(string.format("origin: %s", origin:ToString()))
    for i,p in ipairs(pt) do
        local pol = Polar:FromCartesian(p, intersect)
        print(string.format("cart:%s polar:%s",p:ToString(), pol:ToString()))
    end
end

SectOne(1,2,3,4)
