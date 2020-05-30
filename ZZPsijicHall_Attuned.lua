local ZZPsijicHall = _G["ZZPsijicHall"]

local Log = ZZPsijicHall.Log
local Cartesian = ZZPsijicHall.Cartesian
local Polar = ZZPsijicHall.Polar

if not ZZ then
    ZZ = { R = 4800
         , O = { x = 79680, z = 62940 }
         , A = { 39, -81 }
         , Y = 10620
         }
end


function ZZPsijicHall.CalcAttunedStations()
    -- 0. Must have called ScanNow() already to have built our furniture list.

    -- 1. Sort attuned stations into separate lists by type, so that we can
    --    later give each type of station the care it requires.
    --    Then within each list, sort by alpha name so that we can
    --    place them alphabetically and thus make it easier to find
    --    on the factory floor.
    local CRAFTING_TYPE_STRING_LIST = { "Blacksmithing Station"
                                      , "Clothing Station"
                                      , "Jewelry Crafting Station"
                                      , "Woodworking Station"
                                      }
                        -- crafting_index 1 2 3 4 matches above
                        -- CRAFTING_TYPE_STRING_LIST
    local attuned_by_crafting_type = { {}, {}, {}, {} }
    local args_by_crafting_type = {
        { radius_offset = 0           -- BS
        , rot_offset    = 0
        }
    ,   { radius_offset = 175         -- CL
        , rot_offset    = 0
        }
    ,   { radius_offset = 400         -- JW
        , rot_offset    = 0
        }
    ,   { radius_offset = 650         -- WW
        , rot_offset    = 0
        }
    }

    for _,item in ipairs(ZZPsijicHall.furn_list) do
        for crafting_index,str in ipairs(CRAFTING_TYPE_STRING_LIST) do
            if string.find(item:ItemName(), str) then
                table.insert(attuned_by_crafting_type[crafting_index], item)
            end
        end
    end
    for crafting_index, item_list in ipairs(attuned_by_crafting_type) do
        table.sort(item_list, function(a,b) return a:ItemName() < b:ItemName() end )
    end

    -- 2-N arcs of attuned crafting tables.
    local move_list = {}
    local function one_arc(args)
        for crafting_index, offsets in ipairs(args_by_crafting_type) do
            args.radius      = args.radius_orig     + offsets.radius_offset
            args.rot_offset  = args.rot_offset_orig + offsets.rot_offset
            args.item_list   = attuned_by_crafting_type[crafting_index]
            args.debug_name  = args.debug_name_orig .. tostring(crafting_index)
            local ml = ZZPsijicHall.CalcArc(args)
            ZZPsijicHall.table_iappend(move_list, ml)
        end
    end

    -- 2. First arc.
    local args = {
        want_ct         = 3
    ,   want_y          = 10620
    ,   origin          = Cartesian:New(79680, 62940)   -- cm
    ,   radius_orig     = 3700                          -- cm
    ,   arc_begin       = 39                            -- degrees
    ,   arc_end         = -81                           -- degrees
    ,   rot_offset_orig = 90                            -- degrees
    ,   debug_name_orig = "attuned 1."
    }
    one_arc(args)

    return move_list
end
