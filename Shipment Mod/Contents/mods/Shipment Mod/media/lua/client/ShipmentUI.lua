BuySupplyMenu = ISPanel:derive("BuySupplyMenu")
local ShipmentMoneyHandler = require("ShipmentMoneyHandler")
local ShipmentUI = {}

local ShipmentTest = require('ShipmentTest')




--------------------------------------------------- UI CONTAINER ---------------------------------------------------
function BuySupplyMenu:new()
    local width = 400
    local height = 500

    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.moveWithMouse = true

    return o
end

--------------------------------------------------- UI SETUP ---------------------------------------------------
function BuySupplyMenu:initialise()
    ISPanel.initialise(self)

-- SHIPMENT FACILITY TITLE
   self.label = ISLabel:new(
    55, 20,          -- x, y position
    20,              -- height (not important for most cases)
    "Shipment Facility",   -- text
    1, 1, 1, 1,      -- color (r, g, b, a)
    UIFont.Title,
    true             -- outline
)
self.label:initialise()
self.label:instantiate()
self:addChild(self.label)

-- SUPPLY BAG TEXT UI
   self.label = ISLabel:new(
    150, 70,          -- x, y position
    20,              -- height (not important for most cases)
    "Supply Bag",   -- text
    1, 1, 1, 1,      -- color (r, g, b, a)
    UIFont.Large,
    true             -- outline
)
self.label:initialise()
self.label:instantiate()
self:addChild(self.label)

-- BUY SUPPLY BAG BUTTON
    self.BuySupplyBag = ISButton:new(
        (self.width - 120) / 2, -- x
        100, -- z
        120, -- Height
        30, -- Width
        ShipmentTest.BuySell, -- Text
        nil,
        ShipmentMoneyHandler.BuySellClick -- Trigger on Press
    )
    self.BuySupplyBag:initialise()
    self.BuySupplyBag:instantiate()
    self:addChild(self.BuySupplyBag)

-- CLOSE SHIPMENT FACILITY MENU
    self.ExitSupplyFacility = ISButton:new(
        0,
        0,
        30,
        30,
        "x",
        self,
        self.CloseUI
    )
    self.ExitSupplyFacility:initialise()
    self.ExitSupplyFacility:instantiate()

    self.ExitSupplyFacility.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0}

    self:addChild(self.ExitSupplyFacility)
end


function BuySupplyMenu:render()
    self:drawRect(
        0, 0,
        self.width, self.height,
        0,
        0.1, 0.1, 0.1
    )
end

--------------------------------------------------- OPEN AND CLOSE UI ---------------------------------------------------
ShipmentUI.UIInstance = nil

function ShipmentUI.TriggerUI()
    if ShipmentUI.UIInstance then
        ShipmentUI.UIInstance:removeFromUIManager()
        ShipmentUI.UIInstance = nil
        return
    end
    ShipmentUI.UIInstance = BuySupplyMenu:new()
    ShipmentUI.UIInstance:initialise()
    ShipmentUI.UIInstance:addToUIManager()
end

--------------------------------------------------- BUTTON TRIGGERS ---------------------------------------------------
function BuySupplyMenu:CloseUI()
    if ShipmentUI.UIInstance then
        ShipmentUI.UIInstance:removeFromUIManager()
        ShipmentUI.UIInstance = nil
    end
end

return ShipmentUI