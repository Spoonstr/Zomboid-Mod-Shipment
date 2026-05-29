print("Mod Running")

local original_isValid = ISInventoryTransferAction.isValid

function ISInventoryTransferAction:isValid()

    local item = self.item
    local dest = self.destContainer

    if item and item:getFullType() == "Base.Supply_Bag" then

        -- IMPORTANT: allow intermediate/null steps
        if not dest then
            return original_isValid(self)
        end

        local type = dest:getType()
        print('Current Type: ',type)
        -- only block if it's NOT allowed
        if type ~= "TruckBed" and type ~= "Floor" and type ~= "Inventory" then
            return false
        end
    end

    return original_isValid(self)
end