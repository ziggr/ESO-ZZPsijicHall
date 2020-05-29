local ZZPsijicHall = _G["ZZPsijicHall"]

local Log = ZZPsijicHall.Log
local Cartesian = ZZPsijicHall.Cartesian
local Polar = ZZPsijicHall.Polar


-- Return a list of Item/Cartesian/rotation rows
-- for where platforms should go.
function ZZPsijicHall.CalcPlatforms()
    -- 0. Must have previously run ScanNow() to collect list of furniture.

    -- 1. Collect a list of all available platforms.
    --    These are any platforms already placed somewhere in the house.
    --    Don't go digging through inventory to get more or whatever, that
    --    just gets complicated. If you want to make a platform available
    --    to this script, you need to place it somewhere, anywhere, in
    --    the house.
    local item_list = {}
    for _,item in ipairs(ZZPsijicHall.furn_list) do
        if string.find(item:ItemName(), "Alinor Floor, Ballroom Timeworn") then
            table.insert(item_list, item)
        end
    end

    -- 2. First arc
    -- Think in polar coords for this kind of radial work.
    local deg2rad    = ZZPsijicHall.deg2rad  -- for less typing
    local round      = ZZPsijicHall.round    -- for less typing
    local move_list  = {}
    local want_ct    = 8 -- how many platforms in this arc?
    local want_y     = 10617
    local origin     = Cartesian:New(79536, 63171)   -- cm
    local radius     = 3633      -- cm
    local arc_begin  = 35        -- degrees
    local arc_end    = -80       -- degrees
    local rot_offset = 0
    local step       = (arc_end - arc_begin) / (want_ct - 1)

                        -- Raise/lower overlapping platforms to reduce
                        -- z-fighting flicker.
    local z_fight    = 0
    local function next_z_fight(z_fight)
        if z_fight == 0 then return 1 else return 0 end
    end

    for theta = arc_begin, arc_end, step do
        local dx  = math.cos(deg2rad(theta)) * radius
        local dz  = math.sin(deg2rad(theta)) * radius
        local rot = theta + rot_offset
        z_fight = next_z_fight(z_fight)
        local item = table.remove(item_list)
        if not item then
            Log.Error("Not enough platforms.")
            return nil
        end

        item.want               = Cartesian:New( round(origin.x + dx)
                                               , round(origin.z + dz) )
        item.want.y             = want_y + z_fight
        item.want.rotation_rads = ZZPsijicHall.deg2rad(90 - theta + rot_offset)
        table.insert(move_list, item)
    end

    return move_list
end
