local ZZPsijicHall = _G["ZZPsijicHall"]

local Log = ZZPsijicHall.Log
local Cartesian = ZZPsijicHall.Cartesian
local Polar = ZZPsijicHall.Polar

ZZ = nil
if not ZZ then
    ZZ = { R = 3600
         , O = { x = 79680, z = 62940 }
         , A = { 39, -81 }
         , Y = 10620
         }
end

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
    local args = {
        want_ct     = 8
    ,   want_y      = ZZ.Y or 10620
    ,   origin      = ZZ.O or Cartesian:New(79680, 62940)   -- cm
    ,   radius      = ZZ.R or 3600                          -- cm
    ,   arc_begin   = ZZ.A[1] or 39        -- degrees
    ,   arc_end     = ZZ.A[2] or -81       -- degrees
    ,   rot_offset  = 0                    -- degrees
    ,   item_list   = item_list
    ,   debug_name  = "platform 1"
    }

    return ZZPsijicHall.CalcArc(args)
end

function ZZPsijicHall.CalcArc(args)
                        -- Think in polar coords for this kind of radial work.

    local deg2rad    = ZZPsijicHall.deg2rad  -- for less typing
    local round      = ZZPsijicHall.round    -- for less typing
    local move_list  = {}
    local step       = (args.arc_end - args.arc_begin) / (args.want_ct - 1)

                        -- Raise/lower overlapping platforms to reduce
                        -- z-fighting flicker.
    local z_fight    = 0
    local function next_z_fight(z_fight)
        if z_fight == 0 then return 1 else return 0 end
    end

    for theta = args.arc_begin, args.arc_end, step do
        local dx  = math.cos(deg2rad(theta)) * args.radius
        local dz  = math.sin(deg2rad(theta)) * args.radius
        local rot = theta + args.rot_offset
        z_fight = next_z_fight(z_fight)
        local item = table.remove(args.item_list)
        if not item then
            Log.Error( "Not enough items. Wanted %d got %d: %s"
                     , args.want_ct
                     , #move_list )
            return nil
        end

        item.want               = Cartesian:New( round(args.origin.x + dx)
                                               , round(args.origin.z + dz) )
        item.want.y             = args.want_y + z_fight
        item.want.rotation_rads = ZZPsijicHall.deg2rad(90 - theta + args.rot_offset)
        table.insert(move_list, item)
    end

    return move_list

end
