local ZZPsijicHall      = _G["ZZPsijicHall"]
ZZPsijicHall.name       = "ZZPsijicHall"
ZZPsijicHall.saved_var_version = 2
ZZPsijicHall.default    = {}

local Cartesian = ZZPsijicHall.Cartesian
local Item      = ZZPsijicHall.Item
local Log       = ZZPsijicHall.Log
local Polar     = ZZPsijicHall.Polar

function ZZPsijicHall.ErrorIfNotHome()
    local okay = {
        [HOUSE_ID_LINCHAL_MANOR               or 46] = 1
    ,   [HOUSE_ID_COLDHARBOUR_SURREAL_ESTATE  or 47] = 1
    ,   [HOUSE_ID_GRAND_PSIJIC_VILLA          or 62] = 1
    }
    local house_id = GetCurrentZoneHouseId()
    if not okay[house_id] then
        d("ZZCraftoriumLayout: not in one of Zig's big crafting houses. Exiting.")
        return true
    end
    return false
end

-- Fetch Inventory Data from the server ------------------------------------------
--
-- Write to savedVariables so that we can see furniture unique_id

function ZZPsijicHall.ScanNow()
    if ZZPsijicHall.ErrorIfNotHome() then return end

    local furn_list         = {}
    local furn_list_out     = {}
    local seen_ct           = 0
    local unique_id_to_item = {}
    local furniture_id      = GetNextPlacedHousingFurnitureId(nil)
    local loop_limit        = 1000 -- avoid infinite loops in case GNPHFI() surprises us
    while furniture_id and 0 < loop_limit do
        local item          = ZZPsijicHall.Item:FromFurnitureId(furniture_id)
        if ZZPsijicHall.IsInteresting(item) then
            table.insert(furn_list, item)
            table.insert(furn_list_out, item:ToStorage())
            unique_id_to_item[item.unique_id] = item
        end
        furniture_id        = GetNextPlacedHousingFurnitureId(furniture_id)
        loop_limit          = loop_limit - 1
        seen_ct             = seen_ct + 1
    end

    ZZPsijicHall.furn_list                = furn_list
    ZZPsijicHall.unique_id_to_item        = unique_id_to_item
    ZZPsijicHall.saved_vars.furn_list_out = furn_list_out
    -- ZZPsijicHall.Log.Info(
    --           "Scanning done. %d furnishings scanned, %d interesting ones."
    --         , seen_ct
    --         , #furn_list )
end

function ZZPsijicHall.IsInteresting(item)
    local want = { "Jewelry Crafting Station"
                 , "Blacksmithing Station"
                 , "Clothing Station"
                 , "Woodworking Station"
                 -- , "Breton Sconce, Torch"
                 -- , "Common Lantern, Hanging"
                 , "Alinor Floor, Ballroom Timeworn"
                 }
    for _, s in ipairs(want) do
        if string.find(item:ItemName(), s) then return true end
    end
    return false
end

-- move furniture ------------------------------------------------------------

function ZZPsijicHall.MoveList(move_list)
    ZZPsijicHall.move_queue = move_list
    ZZPsijicHall.MoveSome()
end

function ZZPsijicHall.MoveSome()
    local MAX_MOVES_PER_CHUNK = 10
    local SLEEP_PER_CHUNK     = 200 -- ms

    for i = 1,MAX_MOVES_PER_CHUNK do
        local item = table.remove(ZZPsijicHall.move_queue)
        if not item then
            Log.Info("Done")
            return
        end

        ZZPsijicHall.MaybeMove(item)
    end

    zo_callLater(ZZPsijicHall.MoveSome, SLEEP_PER_CHUNK)
end

-- close enough, don't waste time moving.
local function equ(a,b)
    return math.abs(a-b) < ZZPsijicHall.deg2rad(2)
end

function ZZPsijicHall.MaybeMove(item)
    if          (item.x == item.want.x)
            and (item.z == item.want.z)
            and (item.y == item.want.y)
            and (   (not ZZPsijicHall.force_rotation)
                 or equ(item.rotation_rads, item.want.rotation_rads)) then
        Log.Info( "Skipping: already in position x:%d,z:%d  %s"
                , item.x
                , item.z
                , item:ItemName())
        return
    end
    ZZPsijicHall.MoveItem(item)
end

local HR = {
  [HOUSING_REQUEST_RESULT_ALREADY_APPLYING_TEMPLATE           ] = "ALREADY_APPLYING_TEMPLATE"
, [HOUSING_REQUEST_RESULT_ALREADY_BEING_MOVED                 ] = "ALREADY_BEING_MOVED"
, [HOUSING_REQUEST_RESULT_ALREADY_SET_TO_MODE                 ] = "ALREADY_SET_TO_MODE"
, [HOUSING_REQUEST_RESULT_FURNITURE_ALREADY_SELECTED          ] = "FURNITURE_ALREADY_SELECTED"
, [HOUSING_REQUEST_RESULT_HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT ] = "HIGH_IMPACT_COLLECTIBLE_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_HIGH_IMPACT_ITEM_PLACE_LIMIT        ] = "HIGH_IMPACT_ITEM_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_HOME_SHOW_NOT_ENOUGH_PLACED         ] = "HOME_SHOW_NOT_ENOUGH_PLACED"
, [HOUSING_REQUEST_RESULT_INCORRECT_MODE                      ] = "INCORRECT_MODE"
, [HOUSING_REQUEST_RESULT_INVALID_TEMPLATE                    ] = "INVALID_TEMPLATE"
, [HOUSING_REQUEST_RESULT_INVENTORY_REMOVE_FAILED             ] = "INVENTORY_REMOVE_FAILED"
, [HOUSING_REQUEST_RESULT_IN_COMBAT                           ] = "IN_COMBAT"
, [HOUSING_REQUEST_RESULT_IN_SAFE_ZONE                        ] = "IN_SAFE_ZONE"
, [HOUSING_REQUEST_RESULT_IS_DEAD                             ] = "IS_DEAD"
, [HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED                  ] = "ITEM_REMOVE_FAILED"
, [HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED_INVENTORY_FULL   ] = "ITEM_REMOVE_FAILED_INVENTORY_FULL"
, [HOUSING_REQUEST_RESULT_ITEM_STOLEN                         ] = "ITEM_STOLEN"
, [HOUSING_REQUEST_RESULT_LISTED                              ] = "LISTED"
, [HOUSING_REQUEST_RESULT_LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT  ] = "LOW_IMPACT_COLLECTIBLE_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_LOW_IMPACT_ITEM_PLACE_LIMIT         ] = "LOW_IMPACT_ITEM_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_MOVE_FAILED                         ] = "MOVE_FAILED"
, [HOUSING_REQUEST_RESULT_NOT_HOME_SHOW                       ] = "NOT_HOME_SHOW"
, [HOUSING_REQUEST_RESULT_NOT_IN_HOUSE                        ] = "NOT_IN_HOUSE"
, [HOUSING_REQUEST_RESULT_NO_DUPLICATES                       ] = "NO_DUPLICATES"
, [HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE                   ] = "NO_SUCH_FURNITURE"
, [HOUSING_REQUEST_RESULT_PERMISSION_FAILED                   ] = "PERMISSION_FAILED"
, [HOUSING_REQUEST_RESULT_PERSONAL_TEMP_ITEM_PLACE_LIMIT      ] = "PERSONAL_TEMP_ITEM_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_PLACE_FAILED                        ] = "PLACE_FAILED"
, [HOUSING_REQUEST_RESULT_REMOVE_FAILED                       ] = "REMOVE_FAILED"
, [HOUSING_REQUEST_RESULT_REQUEST_IN_PROGRESS                 ] = "REQUEST_IN_PROGRESS"
, [HOUSING_REQUEST_RESULT_SET_STATE_FAILED                    ] = "SET_STATE_FAILED"
, [HOUSING_REQUEST_RESULT_SUCCESS                             ] = "SUCCESS"
, [HOUSING_REQUEST_RESULT_TOTAL_TEMP_ITEM_PLACE_LIMIT         ] = "TOTAL_TEMP_ITEM_PLACE_LIMIT"
, [HOUSING_REQUEST_RESULT_UNKNOWN_FAILURE                     ] = "UNKNOWN_FAILURE"
}

function ZZPsijicHall.MoveItem(item)
    local r = HousingEditorRequestChangePositionAndOrientation(
                      item.furniture_id
                    , item.want.x
                    , item.want.y
                    , item.want.z
                    , 0        -- pitch
                    , (item.want.rotation_rads or 0)
                    , 0        -- roll
                    )
    item.moved = { code      = r
                 , code_text = HR[r] or tostring(r)
                 }
end


-- from http://lua-users.org/wiki/SplitJoin
local function split(str,pat)
  local tbl={}
  str:gsub(pat,function(x) tbl[#tbl+1]=x end)
  return tbl
end


-- Use positions from script/parser ------------------------------------------

local function id4(unique_id)
    return unique_id:sub(#unique_id - 3)
end

local MOVED_INDEX = 0
local function next_moved_index()
    MOVED_INDEX = 1 + MOVED_INDEX
    return MOVED_INDEX
end


function ZZPsijicHall.MaybeMoveOne2(args)
    local item = ZZPsijicHall.unique_id_to_item[args.unique_id]
    if not item then
        Log.Error( "missing furniture unique_id:'%s'  %s %d"
                      , args.unique_id, args.station
                      , args.station_index or 0)
        return
    end
    if item.moved then
        Log.Error( "furniture moved twice: %s"
                 , Id64ToString(args.unique_id))
        return
    end

                        -- Already in position? Nothing to do.
    if      args.x == item.x
        and args.z == item.z
        and args.y == item.y
        and ((not ZZPsijicHall.force_rotation) or equ(args.rotation, item.rotation))
        then

        ZZPsijicHall.skip_run_ct = 1 + (ZZPsijicHall.skip_run_ct or 0)
        local msg = string.format("|c999999Skipping: already in position x:%d,z:%d  id:%s %s|r"
            , item.x
            , item.z
            , id4(Id64ToString(item.unique_id))
            , item.item_name
            )
        if ZZPsijicHall.skip_run_ct < 3 then
            d(msg)
        elseif ZZPsijicHall.skip_run_ct == 3 then
            d("|c999999...|r")
        end
        item.moved = "skipped"
        item.moved_index = next_moved_index()
        return
    end
    ZZPsijicHall.skip_run_ct = 0

    args.item = item
    table.insert(ZZPsijicHall.move_queue, args)
end

local white = "|cFFFFFF"
local grey  = "|c999999"

local function numstr(a,b)
    local color = white
    local diff = math.abs(a-b)
    if (diff < 2) then color = grey end
    return color .. string.format("%d",a) ..grey
         , color .. string.format("%d",b) ..grey
end
local function numstrdeg(a,b)
    if a < 0 then a = a + 360 end
    if b < 0 then b = b + 360 end
    return numstr(a,b)
end

function ZZPsijicHall.MoveOne(args)
    local r = HousingEditorRequestChangePositionAndOrientation(
                      args.item.furniture_id
                    , args.x
                    , args.y
                    , args.z
                    , 0        -- pitch
                    , (args.rotation or 0) * math.pi / 180
                    , 0        -- roll
                    )
    args.item.moved = "moved"
    args.item.moved_index = next_moved_index()
    local result_text = HR[r] or tostring(r)

    local fmt = grey.."Moving from x:%s,z:%s,y:%s,rot:%s ->"
                              .." x:%s,z:%s,y:%s,rot:%s result:%s %s"

    local x1  , x2   = numstr   (args.item.x            , args.x            )
    local z1  , z2   = numstr   (args.item.z            , args.z            )
    local y1  , y2   = numstr   (args.item.y            , args.y            )
    local rot1, rot2 = numstrdeg(args.item.rotation or 0, args.rotation or 0)
    local msg = string.format(fmt
                    , x1, z1, y1, rot1
                    , x2, z2, y2, rot2
                    , tostring(result_text)
                    , args.item.item_name
                    )
    d(msg)
end

-- Moving too many items at once gets you insta-kicked for message spam.
-- Call this with a delay between bursts.
function ZZPsijicHall.MoveQueued()
    if #ZZPsijicHall.move_queue <= 0 then
        ZZPsijicHall.MoveDone()
        return
    end
    local tail = table.remove(ZZPsijicHall.move_queue, #ZZPsijicHall.move_queue)
    ZZPsijicHall.MoveOne(tail)
    zo_callLater(ZZPsijicHall.MoveQueued, 200)
end

function ZZPsijicHall.MoveAll2()
    if ZZPsijicHall.ErrorIfNotHome() then return end
    ZZPsijicHall.skip_run_ct = 0
    ZZPsijicHall.move_queue = {}

                        -- Scan first to gather each existing furniture's
                        -- unique_id. There is no string-to-id64 conversion,
                        -- so we have to go from i64->string and then build
                        -- a lookup table.
    ZZPsijicHall.ScanNow()

local ENOUGH = 2000
    for _,row in ipairs(ZZPsijicHall.POSITION) do
ENOUGH = ENOUGH - 1
if ENOUGH <= 0 then break end
        local w = split(row,"%S+")
        local args = {
                     ['unique_id'    ] =          w[1]
                   , ['x'            ] = tonumber(w[2])
                   , ['z'            ] = tonumber(w[3])
                   , ['y'            ] = tonumber(w[4])
                   , ['rotation'     ] = tonumber(w[5])
                   , ['station'      ] =          w[6]
                   , ['station_index'] = tonumber(w[7])
                   }
        ZZPsijicHall.MaybeMoveOne2(args)
    end
    ZZPsijicHall.MoveQueued()
end

function ZZPsijicHall.MoveDone()
                        -- Collect unmoved items into another saved_variables
                        -- bucket for later movement
    local unmoved = {}
    local moved = {}
    for unique_id, item in pairs(ZZPsijicHall.unique_id_to_item) do
        if not item.moved then
            table.insert(unmoved, item)
        else
            table.insert(moved, item)
        end
    end
    table.sort(unmoved, function(a,b) return a.item_name < b.item_name end )
    table.sort(  moved, function(a,b)
                            if a.item_name == b.item_name then
                                return a.moved_index < b.moved_index
                            end
                            return a.item_name < b.item_name
                        end )
    local unmoved_flat = {}
    local   moved_flat = {}
    for _,item in ipairs(unmoved) do
        table.insert(unmoved_flat, item:ToTextLine())
    end
    for _,item in ipairs(moved) do
        table.insert(moved_flat, item:ToTextLine())
    end
    ZZPsijicHall.saved_vars.unmoved = unmoved_flat
    ZZPsijicHall.saved_vars.moved   = moved_flat
end


-- Slash Commands ------------------------------------------------------------

function ZZPsijicHall.RegisterSlashCommands()
    local lsc = LibSlashCommander
    local cmd = lsc:Register( "/ps"
                            , function(arg) ZZPsijicHall.SlashCommand(arg) end
                            , "Zig's Psijic Manor tools")

    local sub_scan = cmd:RegisterSubCommand()
    sub_scan:AddAlias("scan")
    sub_scan:SetCallback(function() ZZPsijicHall.SlashCommand("scan") end)
    sub_scan:SetDescription("scan furnishings for crafting stations and platforms")

    local sub_plat = cmd:RegisterSubCommand()
    sub_plat:AddAlias("plat")
    sub_plat:SetCallback(function() ZZPsijicHall.SlashCommand("plat") end)
    sub_plat:SetDescription("move platforms")

    local sub_tune = cmd:RegisterSubCommand()
    sub_tune:AddAlias("tune")
    sub_tune:SetCallback(function() ZZPsijicHall.SlashCommand("tune") end)
    sub_tune:SetDescription("move attuned stations")
end

function ZZPsijicHall.SlashCommand(arg1)
    if arg1:lower() == "scan" then
        ZZPsijicHall.ScanNow()
    elseif arg1:lower() == "plat" then
        ZZPsijicHall.ScanNow()
        local move_list = ZZPsijicHall.CalcPlatforms()
        ZZPsijicHall.MoveList(move_list)
    elseif arg1:lower() == "tune" then
        ZZPsijicHall.ScanNow()
        local move_list = ZZPsijicHall.CalcAttunedStations()
        ZZPsijicHall.move_list = move_list
        ZZPsijicHall.MoveList(move_list)
    end
end

-- Init ----------------------------------------------------------------------

function ZZPsijicHall.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZPsijicHall.name then return end
    ZZPsijicHall:Initialize()
end

function ZZPsijicHall:Initialize()

    self.saved_vars = ZO_SavedVars:NewAccountWide(
                              "ZZPsijicHallVars"
                            , self.saved_var_version
                            , nil
                            , self.default
                            )

    self.RegisterSlashCommands()
end

-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZPsijicHall.name
                              , EVENT_ADD_ON_LOADED
                              , ZZPsijicHall.OnAddOnLoaded
                              )
