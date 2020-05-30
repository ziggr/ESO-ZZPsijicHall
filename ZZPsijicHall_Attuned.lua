local ZZPsijicHall = _G["ZZPsijicHall"]

local Log = ZZPsijicHall.Log
local Cartesian = ZZPsijicHall.Cartesian
local Polar = ZZPsijicHall.Polar

if not ZZ then
    ZZ = {}
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
    ,   { radius_offset = 165         -- CL
        , rot_offset    = 0
        }
    ,   { radius_offset = 380         -- JW
        , rot_offset    = 0
        }
    ,   { radius_offset = 630         -- WW
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
            ZZ.args = args -- zum Debuggen
            ZZPsijicHall.table_iappend(move_list, ml)
        end
    end

    -- 2. First arc: patio on house side of collonade.
    --    8 sets down, 51 to go.
    --
    --    Plenty more room to widen arc_begin/arc_end, but it's also nice
    --    visually to limit the stations to the collodade's own
    --    -100 to 60 degree arc.
    --
    --    want_y: the patio here is lumpy and many stations end up floating
    --            or buried. Will have to hand-fix them after running this.
    --
    --    Stations per arc degree: at a radius of 950, the BS stations still
    --    work at ~15° step. It's a bit tight and cluttered, but oh well.
    --
    --    Probably want to split this arc into two bits to clear a walkway
    --    to the center. arcs = [60,-5] and [-35,-100], 4 sets each side.
    --
    local args = {
        want_ct         = 3 --4
    ,   want_y          = 10672
    ,   origin          = Cartesian:New(79680, 62940)   -- cm
    ,   radius_orig     =  950                  -- cm
    ,   arc_begin       =   60                  -- degrees
    ,   arc_end         =   -5                  -- degrees
    ,   rot_offset_orig =   90                  -- degrees
    ,   debug_name_orig = "attuned 2a."
    }
-- one_arc(args)
    args.arc_begin = -35
    args.arc_end   = -100
    args.debug_name_orig = "attuned 2b."
-- one_arc(args)

    -- 3. Second arc: within the collonade itself.
    --    +18 stations.
    --    26 down, 33 to go.
    --
    --    Must split into two arcs to leave room for the entrance portal.
    --    arcs = [60,0] [-40,-100]
    --
    --    7.5° step works here. So 9 stations per 60°
    --
    args = {
        want_ct         = 3 --9
    ,   want_y          = 10660
    ,   origin          = Cartesian:New(79680, 62940)   -- cm
    ,   radius_orig     = ZZ.R or 2200                  -- cm
    ,   arc_begin       = ZZ.A or   60                  -- degrees
    ,   arc_end         = ZZ.B or    0                  -- degrees
    ,   rot_offset_orig = 90                            -- degrees
    ,   debug_name_orig = "attuned 3a."
    }
-- one_arc(args)
    args.radius_orig    = 2100
    args.arc_begin      =  -40
    args.arc_end        = -100
    args.debug_name_orig = "attuned 3b."
-- one_arc(args)

    -- 4. Third arc: on platforms just outside collonade
    --    27 stations.
    --    53 down, 6 to go.
    --
    --    5° step works here. So 27 stations per 130°
    --
    args = {
        want_ct         = 3 --9
    ,   want_y          = 10621
    ,   origin          = Cartesian:New(79680, 62940)   -- cm
    ,   radius_orig     = ZZ.R or 3300                  -- cm
    ,   arc_begin       = ZZ.A or   45                  -- degrees
    ,   arc_end         = ZZ.B or  -87                  -- degrees
    ,   rot_offset_orig = 90                            -- degrees
    ,   debug_name_orig = "attuned 4."
    }
    -- one_arc(args)

    -- 5. Fourth arc: on platforms outside collonade near water
    --    30 stations.
    --    53 down, 6 to go.
    --
    --    4° step works here. So 30 stations per 120°
    --
    args = {
        want_ct         = 3 --9
    ,   want_y          = 10621
    ,   origin          = Cartesian:New(79680, 62940)   -- cm
    ,   radius_orig     = ZZ.R or 4500                  -- cm
    ,   arc_begin       = ZZ.A or   40                  -- degrees
    ,   arc_end         = ZZ.B or  -82                  -- degrees
    ,   rot_offset_orig = 90                            -- degrees
    ,   debug_name_orig = "attuned 5."
    }
    one_arc(args)

    return move_list
end
