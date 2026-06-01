local ShipmentMoneyHandler = {}
local ShipmentTest = require('ShipmentTest')


--------------------------------------------------- GET MONEY COUNT ---------------------------------------------------
local function getMoneyCountIncludingWallets(container)
    local sum = 0
    local itemsList = container:getItems()
    for i = 0, itemsList:size()-1 do
        local item = itemsList:get(i)
        if ProjectRP.Client.Money.WalletTypes[item:getType()] then
            sum = item:getModData().moneyCount and sum + item:getModData().moneyCount or sum
        else
            sum = ProjectRP.Client.Money.Values[item:getType()] and sum + ProjectRP.Client.Money.Values[item:getType()].v or sum
		end
    end
    return sum
end



--------------------------------------------------- HAS CURRENCY ---------------------------------------------------
local function hasCurrency(price)
    return getMoneyCountIncludingWallets(getPlayer():getInventory()) >= price
end



--------------------------------------------------- DO PAYMENT ---------------------------------------------------
function doPayment(price)
  local inventory = getPlayer():getInventory()
  if ProjectRP and ProjectRP.Client and ProjectRP.Client.Money then
    -- this algorithm is a fucking monster
    local sum = 0

    local walletTypes = {['Wallet']=true, ['Wallet2']=true, ['Wallet3']=true, ['Wallet4']=true}
    for walletType,_ in pairs(walletTypes) do
      local wallets = inventory:getAllType(walletType)
      for i = 0, wallets:size() -1 do
        local wallet = wallets:get(i)
        if wallet:getModData() then
          local walletMoney = wallet:getModData().moneyCount or 0
          local remaining = price - sum
          
          if walletMoney >= remaining then
            wallet:getModData().moneyCount = walletMoney - remaining
            ProjectRP.Client.Money.syncWallet(wallet)
            sum = price
          else
            sum = sum + walletMoney
            wallet:getModData().moneyCount = 0
            ProjectRP.Client.Money.syncWallet(wallet)
          end
        end
      end
    end

    if sum < price then
      for k,v in pairs(ProjectRP.Client.Money.Values) do
        if sum >= price then break end
        local items = inventory:getAllType(k)
        for i = 0, items:size() - 1 do
          if sum >= price then break end
          sum = sum + v.v
          local item = items:get(i)
          inventory:Remove(item)
          if sum > price then
            ProjectRP.Client.Money.ATM.withdrawalMoney(getPlayer(), sum - price)
          end
        end
      end
    end
    -- Let Money system handle rounding
  else
    local items = inventory:FindAndReturn(SandboxVars.PlayerShops.CurrencyItem, price)
    for i = 0, items:size() - 1 do
      local item = items:get(i)
      inventory:Remove(item)
    end
  end
end


--------------------------------------------------- END ---------------------------------------------------
function BuySupplyItem()
    print("Starting Supply Facility Buying Process")
    if hasCurrency(100) then
        doPayment(100)
        getPlayer():getInventory():AddItem("Base.Supply_Bag")
        print("Purchase Successful")
    else
        print('Puchase Failed')
    end
end

function SellSupplyItem()
    print('SellSupplyItem Function Executed')
    local inventory = getPlayer():getInventory()
    local item = inventory:FindAndReturn("Base.Supply_Bag")

    if item then
        inventory:Remove(item)
        inventory:AddItem('PRP.100Dollar')
        inventory:AddItem('PRP.50Dollar')
        print("Selling Supply Bag")
    else
        print("Doesn't have a Supply Bag")
    end
end

function ShipmentMoneyHandler.BuySellClick()
  print('ShipmentMoneyHandler Line 111 Status: ', status)
    if ShipmentTest.BuySell == "Buy" then
        BuySupplyItem()
    elseif ShipmentTest.BuySell == "Sell" then
        SellSupplyItem()
    else
        print('Error')
        return
    end
end
return ShipmentMoneyHandler