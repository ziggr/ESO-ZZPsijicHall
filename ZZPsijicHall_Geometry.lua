local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Line = {}
local Line = ZZPsijicHall.Line
local Cartesian = ZZPsijicHall.Cartesian
                        -- Infinity, aka 1/0, aka math.huge.
                        -- Used as a slope for vertical lines.
                        -- NOT equal to negative infinity.
local INFINITY = math.huge

-- Line ----------------------------------------------------------------------
--
-- Defined by two points on the line.
-- We usually treat this line as stretching to infinity, past the above
-- two points. They're _points_, not _endpoints_.
--
-- Originally this was defined by "m" and "b" from the classic geometric
-- formula for a line:
--
--      z = m * x + b
--
-- m = slope: z per x
-- b = z-offset where line crosses z-axis at x=0
--
-- But no, this formula cannot express a straight vertical line.
-- So back to storing two Cartesian points and live-calculating
-- m Slope() and b ZIntercept() from those points.
--
function Line:FromPoints(pt1, pt2)
    local o = { pt1 = pt1, pt2 = pt2 }

    setmetatable(o, self)
    self.__index = self
    return o
end

-- Return a new Line that runs through the two given points.
function Line:Bisect(pt1, pt2)
                        -- Find midpoint between two points.
                        -- New bisector line runs through that midpoint.
    local midpoint      = Cartesian:New( ( pt1.x + pt2.x ) / 2
                                       , ( pt1.z + pt2.z ) / 2 )

                        -- Slope m is change in z over change in x.
    local bisect_pt2 = {}
    local dz = pt2.z - pt1.z
    local dx = pt2.x - pt1.x
    if dx == 0 then
                        -- Watch out for horizontal/vertical lines where
                        -- slopes are zero or infinite.
                        -- Bisecting a vertical (dx == 0) line
                        -- produces a horizontal bisector: z never changes.
        bisect_pt2.x = midpoint.x + 1
        bisect_pt2.z = midpoint.z
    elseif dz == 0 then
                        -- Bisecting a horizontal (dz == 0) line
                        -- produces a vertical bisector: x never changes.
        bisect_pt2.x = midpoint.x
        bisect_pt2.z = midpoint.z + 1
    else
                        -- General bisector is the negated inverse slope
                        -- of the original segment, offset to run through
                        -- the midpoint.
        local m        = dz / dx
        local bisect_m = -1/m

                        -- Z-axis offset.
                        --
                        -- z = m * x + b
                        --                  Move m*x to other side to
                        --                  isolate b:
                        -- z - m * x = b
                        --
                        --                  Plug in known values from
                        --                  any point:
        local b = midpoint.z - bisect_m * midpoint.x

        bisect_pt2.x = 0
        bisect_pt2.z = b
    end

    return Line:FromPoints( midpoint
                          , Cartesian:New(bisect_pt2.x, bisect_pt2.z)
                          )
end

-- AKA "m" in classic "z = mx + b" line formula.
function Line:Slope()
    local dz = self.pt2.z - self.pt1.z
    local dx = self.pt2.x - self.pt1.x
                        -- Standardize on positive infinity for vertical lines.
                        -- Avoid "-inf" which will make it harder to detect
                        -- parallel lines later.
    if dx == 0 then return INFINITY end

    return dz / dx
end

-- AKA "b" in classic "z = mx + b" line formula.
function Line:ZIntercept()
                        -- Vertical lines never intersect the z-axis
                        -- or infinitely overlap.
    local dx = self.pt2.x - self.pt1.x
    if dx == 0 then return nil end

    local b = self.pt1.z - self:Slope() * self.pt1.x
    return b
end

-- Given two infinite lines, return where they intersect, if they do.
-- Or nil, if they are parallel (or identical).
function Line.Intersect(line1, line2)
                        -- Parallel lines never intersect, or infinitely
                        -- overlap.
    if line1:Slope() == line2:Slope() then return nil end

                        -- If either line is vertical, plug its x into the
                        -- other line's formula to find the intersection.
    if line1:Slope() == INFINITY then
        local x = line1.pt1.x
        local z = line2:Slope() * x + line2:ZIntercept()
        return Cartesian:New(x, z)
    elseif line2:Slope() == INFINITY then
        local x = line2.pt1.x
        local z = line1:Slope() * x + line1:ZIntercept()
        return Cartesian:New(x, z)
    end

                        -- Intersect point will have the same z = mx * b
                        -- for both lines.
                        --
                        -- First find the matching x:
                        --
                        -- z = m1x + b1  == m2x + b2
                        --
                        -- Unite and isolate x terms:
                        --
                        --     m1x - m2x == b2 - b1
                        --
                        --   x(m1  - m2) == b2 - b1
                        --
                        --   x           == (b2 - b1)/(m1 - m2)
    local b1 = line1:ZIntercept()
    local b2 = line2:ZIntercept()
    local m1 = line1:Slope()
    local m2 = line2:Slope()
    local x  = (b2 - b1) / (m1 - m2)
                        -- Now that we have the intersect's x,
                        -- use that x to find the intersect's z.
    local z  = m1 * x + b1
    print(string.format("Line 1: %s  %s  m=%f  b=%f"
                        , line1.pt1:ToString(), line1.pt2:ToString()
                        , line1:Slope(), line1:ZIntercept()
                        ))
    print(string.format("Line 2: %s  %s  m=%f  b=%f"
                        , line2.pt1:ToString(), line2.pt2:ToString()
                        , line2:Slope(), line2:ZIntercept()
                        ))
    print(string.format("x:%f =(b2:%f-b1:%f)/(m1:%f-m2:%f)"
                        , x, b2, b1, m1, m2))
    print(string.format("z:%f =(m1:%f * x:%f + b1:%f", z, m1, x, b1))
    return Cartesian:New(x, z)
end

function Line.TestOne_Intersect(x1, z1, x2, z2, x3, z3, x4, z4, expect_x, expect_z, name)
    if not name then
        name = string.format( "(%d,%d %d,%d) (%d,%d %d,%d)"
                            , x1, z1, x2, z2, x3, z3, x4, z4
                            )
    end

    local line1 = Line:FromPoints(Cartesian:New(x1, z1), Cartesian:New(x2, z2))
    local line2 = Line:FromPoints(Cartesian:New(x3, z3), Cartesian:New(x4, z4))
    local got   = Line.Intersect(line1, line2)

    if not got then
        if not expect_x then
            print(string.format( "ok expect:nil got nil  %s"
                               , name
                               ))
            return true
        else
            print(string.format( "mismatch expect:%d,%d got nil  %s"
                               , expect_x, expect_z
                               , name
                               ))
            return false
        end
    end

    if got.x == expect_x and got.z == expect_z then
        print(string.format( "ok expect:%d,%d got %d,%d  %s"
                           , expect_x, expect_z
                           , got.x, got.z
                           , name
                           ))

        return true
    end


    print(string.format( "Mismatch expect:%d,%d got %d,%d  %s"
                       , expect_x, expect_z
                       , got.x, got.z
                       , name
                       ))
    return false
end

function Line.Test_Intersect()
    local t = Line.TestOne_Intersect

    t(0,0,  2,2,  0,2,  2,0,  1,1)

    t(1,0,  1,1,  2,0,  2,1,  nil)  -- parallel vertical
    t(1,0,  1,1,  2,1,  2,0,  nil)

    t(0,1,  1,1,  2,2,  3,2,  nil)  -- parallel horizontal


end
