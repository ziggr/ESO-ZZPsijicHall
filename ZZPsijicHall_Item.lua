local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Item = {}
local Item = ZZPsijicHall.Item

local Cartesian = ZZPsijicHall.Cartesian
local Polar     = ZZPsijicHall.Polar

function Item:FromFurnitureId(furniture_id)
    local o = { furniture_id = furniture_id }

    setmetatable(o, self)
    self.__index = self
    return o
end

-- GetPlacedHousingFurnitureInfo ---------------------------------------------

function Item:LazyGetPlacedHousingFurnitureInfo()
    if self.item_name then return end

    local r = { GetPlacedHousingFurnitureInfo(self.furniture_id) }
    self.item_name             = r[1]
    self.texture_name          = r[2]
    self.furniture_data_id     = r[3]
end

function Item:ItemName()
    self:LazyGetPlacedHousingFurnitureInfo()
    return self.item_name
end

function Item:FurnitureDataId()
    self:LazyGetPlacedHousingFurnitureInfo()
    return self.furniture_data_id
end

-- HousingEditorGetFuritureWorldPosition -------------------------------------

function Item:LazyHousingEditorGetFurnitureWorldPosition()
    if self.x then return end

    r = { HousingEditorGetFurnitureWorldPosition(self.furniture_id) }
    self.x = r[1]
    self.y = r[2]
    self.z = r[3]

    r = { HousingEditorGetFurnitureOrientation(self.furniture_id) }
    self.rotation_rads = r[2]
end

function Item:CartesianCoords()
    if not self.cartesian then
        Item:LazyHousingEditorGetFurnitureWorldPosition()
        self.cartesian = Cartesian:New(self.x, self.z)
    end
    return self.cartesian
end

function Item:PolarCoords(origin)
    if not self.polar then
        local dx = origin.x - self:Cartesian().x
        local dz = origin.z - self:Cartesian().z
        local r  = math.sqrt(dx*dx + dz+dz)
        local theta_rads = math.atan2(dz, dx)
        local theta_degs = ZZPsijicHall.rad2deg()
    end
    return self.polar
end
