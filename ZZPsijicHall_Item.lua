local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Item = {}
local Item = ZZPsijicHall.Item

local Cartesian = ZZPsijicHall.Cartesian
local Polar     = ZZPsijicHall.Polar

function Item:FromFurnitureId(furniture_id)
    local o = { furniture_id = furniture_id }

                        -- Why fuss with lazy-loading cache code?
                        -- For a scan that you run once and then
                        -- never again? YAGNI. Just fetch all the
                        -- fields now and stop worrying about it.
    local r = { GetPlacedHousingFurnitureInfo(o.furniture_id) }
    o.item_name             = r[1]
    o.texture_name          = r[2]
    o.furniture_data_id     = r[3]

    r = { HousingEditorGetFurnitureWorldPosition(o.furniture_id) }
    o.x = r[1]
    o.y = r[2]
    o.z = r[3]
    self.cartesian = Cartesian:New(self.x, self.z)

    r = { HousingEditorGetFurnitureOrientation(o.furniture_id) }
    o.rotation_rads = r[2]

    setmetatable(o, self)
    self.__index = self
    return o
end

-- GetPlacedHousingFurnitureInfo ---------------------------------------------

function Item:ItemName()
    return self.item_name
end

function Item:FurnitureDataId()
    return self.furniture_data_id
end

-- HousingEditorGetFuritureWorldPosition -------------------------------------

function Item:PolarCoords(origin)
    local dx = origin.x - self:Cartesian().x
    local dz = origin.z - self:Cartesian().z
    local r  = math.sqrt(dx*dx + dz+dz)
    local theta_rads = math.atan2(dz, dx)
    local theta_degs = ZZPsijicHall.rad2deg()

    local polar = ZZPsijicHall.Polar:New(r, theta_rads, origin.x, origin.z)
    return polar
end

-- Writing to output ---------------------------------------------------------
--
-- Lossy. Just dumping to savedvariables so that I can do math later.
--
function Item:ToStorage()
    local function sint(i) return string.format("%d", i) end
    local function sflo(f) return string.format("%5.2f", f) end

    local rotation_degs = ZZPsijicHall.rad2deg(self.rotation_rads)
    rotation_degs = ZZPsijicHall.round(rotation_degs)

    local store = {
          Id64ToString(self:FurnitureDataId())
        , sint(self.x)
        , sint(self.z)
        , sint(self.y)
        , sint(rotation_degs)
        , self:ItemName()
    }
    return table.concat(store, " ")
end
