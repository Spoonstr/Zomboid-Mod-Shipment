BuySupplyMenu = ISPanel:derive("BuySupplyMenu")

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

function BuySupplyMenu:initialise()
    ISPanel.initialise(self)

   self.label = ISLabel:new(
    100, 0,          -- x, y position
    20,              -- height (not important for most cases)
    "Hello World",   -- text
    1, 1, 1, 1,      -- color (r, g, b, a)
    UIFont.Title,
    true             -- outline
)
    self.label:initialise()
    self.label:instantiate()
    self:addChild(self.label)


    self.button = ISButton:new(
        (self.width - 120) / 2,
        30,
        120,
        30,
        "Buy",
        self,
        self.onClick
    )

    self.button:initialise()
    self.button:instantiate()

    self.button.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0}

    self:addChild(self.button)
end


function BuySupplyMenu:render()
    self:drawRect(
        0, 0,
        self.width, self.height,
        0,
        0.1, 0.1, 0.1
    )
end

UIInstance = nil

function TriggerUI()
    if UIInstance then
        UIInstance:removeFromUIManager()
        UIInstance = nil
        return
    end

    UIInstance = BuySupplyMenu:new()
    UIInstance:initialise()
    UIInstance:addToUIManager()
end

function BuySupplyMenu:onClick()
    print("Buy clicked")
end


Events.OnKeyPressed.Add(function(key)
    if key == Keyboard.KEY_F then
        print('trigger')
    end
end)


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





local function addOption(player, context, worldObjects)
    context:addOption(
        "Buy Supply Bag",
        worldObjects,
        function()
            if hasCurrency(100) then
                doPayment(100)
                getPlayer():getInventory():AddItem("Base.Supply_Bag")
                print("Purchase Successful")
            else
                print('Puchase Failed')
            end
        end
    )
    context:addOption(
        "Control UI",
        worldObjects,
        function()
            print("Openning UI")
            TriggerUI()
        end
)

end

Events.OnFillWorldObjectContextMenu.Add(addOption)