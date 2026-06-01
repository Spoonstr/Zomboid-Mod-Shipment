local ShipmentUI = require("ShipmentUI")

local ShipmentTest = require('ShipmentTest')

local function addOption(player, context, worldObjects)
--------------------------------------------------- ADMIN CREATE SHIPMENT FACILITY ---------------------------------------------------
    local main = context:addOption("[ADMIN]Create Shipment Facility")
    local sub = ISContextMenu:getNew(context)
    context:addSubMenu(main, sub)

    sub:addOption("Create Buy Shipment Facility", nil, function()
            local square = getPlayer():getSquare()
            local obj = IsoObject.new(square, "location_business_distillery_01_1", false)

            obj:getModData().BuyShipmentFacility = true
            square:AddTileObject(obj)
            obj:transmitCompleteItemToServer()
    end)

    sub:addOption("Create Sell Shipment Facility", nil, function()
            local square = getPlayer():getSquare()
            local obj = IsoObject.new(square, "location_business_distillery_01_0", false)

            obj:getModData().SellShipmentFacility = true
            square:AddTileObject(obj)
            obj:transmitCompleteItemToServer()
    end)
--------------------------------------------------- INTERACT WITH SELL/BUY SHIPMENT FACILITY ---------------------------------------------------
    for _, obj in ipairs(worldObjects) do
        if obj:getModData().SellShipmentFacility then

            context:addOption(
                "Open Sell Shipment Facility",
                worldObjects,
                function()
                    ShipmentTest.BuySell = 'Sell'
                    ShipmentUI.TriggerUI()
                end
            )

            break
        end

        if obj:getModData().BuyShipmentFacility then

            context:addOption(
                "Open Buy Shipment Facility",
                worldObjects,
                function()
                    ShipmentTest.BuySell = 'Buy'
                    ShipmentUI.TriggerUI()
                end
            )

            break
        end
    end

end

Events.OnFillWorldObjectContextMenu.Add(addOption)