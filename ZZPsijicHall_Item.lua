local ZZPsijicHall = _G["ZZPsijicHall"]
ZZPsijicHall.Item = {}
local Item = ZZPsijicHall.Item

function Item:FromFurnitureId(furniture_id)
    local o = { furniture_id = furniture_id }

    setmetatable(o, self)
    self.__index = self
    return o
end

-- GetPlacedHousingFurnitureInfo ---------------------------------------------

function Item:LazyGetPlacedHousingFurnitureInfo()
    if not self.item_name then
        local r = { GetPlacedHousingFurnitureInfo(self.furniture_id) }
        self.item_name             = r[1]
        self.texture_name          = r[2]
        self.furniture_data_id     = r[3]
    end
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
    if not self.x then
    r = { HousingEditorGetFurnitureWorldPosition(self.furniture_id) }
    self.cartesian.x = r[1]
    self.cartesian.y = r[2]
    self.cartesian.z = r[3]

    r = { HousingEditorGetFurnitureOrientation(self.furniture_id) }
    self.rotation = r[2] / math.pi * 180
end

function Item:CartesianCoords()
    Item:LazyHousingEditorGetFurnitureWorldPosition()
    return self.cartesian
end

function Item:PolarCoords(origin)
    if not self.polar then
        local dx = origin.x - self:Cartesian().x
        local dz = origin.z - self:Cartesian().z
        local r  = math.sqrt(dx*dx + dz+dz)
        local
    end
    return self.polar
end
