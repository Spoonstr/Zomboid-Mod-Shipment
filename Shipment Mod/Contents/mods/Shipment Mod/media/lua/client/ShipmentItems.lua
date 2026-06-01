print("Mod Running")

local original_isValid = ISInventoryTransferAction.isValid

function ISInventoryTransferAction:isValid()

    local item = self.item
    local dest = self.destContainer

    if item and item:getFullType() == "Base.Supply_Bag" then
        if not dest then
            return false
        end

        local theType = dest:getType()
        -- allow ground + player inventory + trunks
        if theType ~= "TruckBed" and theType ~= "floor" and theType ~= "none" then
            return false
        end
    end

    return original_isValid(self)
end

