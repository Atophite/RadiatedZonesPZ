---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 04/10/2022 19:23
---
---

if isServer() and not isClient() then
   return
end

local AtosClient = AtosRadiatedZones.Client
local AtosConstants = AtosRadiatedZones.Constants

function AtosClient:printCors()

   for playerIndex = 0, getNumActivePlayers() -1 do
      local player = getSpecificPlayer(playerIndex)
      print(player:getUsername() .. " X: " .. player:getLx() .. " Y: " .. player:getLy() .. " Z: " .. player:getLz())
   end
end

function AtosClient:printTable(table)
   print(AtosClient:dump(table))

end

local function getGeigerTellerFromHand(equippedItem)
   if equippedItem ~= nil then
      if equippedItem:getName() == "Geiger Teller" and
              equippedItem:getModName() == "Radiated Zones" and
              equippedItem:isActivated() then
         return true

      end
   end
end

local function getCivGeigerTellerFromHand(equippedItem)
   if equippedItem ~= nil then
      if equippedItem:getType() == "CivGeigerTeller" and
              equippedItem:getModName() == "Radiated Zones" and
              equippedItem:isActivated() then
         return true

      end
   end
end

function AtosClient:isGeigerEquipped(player)
   local attachedItems = player:getAttachedItems()
   local primaryEquippedItem = player:getPrimaryHandItem()
   local secondaryEquippedItem = player:getSecondaryHandItem()
   local currentUseDelta

   if getGeigerTellerFromHand(primaryEquippedItem) or getGeigerTellerFromHand(secondaryEquippedItem) then
      return true
   end


   for count = 0, attachedItems:size() - 1 do
      if attachedItems:getItemByIndex(count):getName() == "Geiger Teller"
         and attachedItems:getItemByIndex(count):isActivated()
         and attachedItems:getItemByIndex(count):getUsedDelta() > 0
      then
            return true
      end
   end
   return false
end

function AtosClient:isCivGeigerEquipped(player)
   local primaryEquippedItem = player:getPrimaryHandItem()
   local secondaryEquippedItem = player:getSecondaryHandItem()
   local currentUseDelta

   if getCivGeigerTellerFromHand(primaryEquippedItem) or getCivGeigerTellerFromHand(secondaryEquippedItem) then
      print("civ geiger is equpped")
      return true
   end

   return false
end

function AtosClient:getTime()
   print(GameTime:getInstance():getHour())
end

function test(player)
   local items = player:getWornItems()

   for count = 1, items:size() - 1 do
      print(items:getItemByIndex(count):getClothingItemName())
      if items:getItemByIndex(count):getClothingItemName() == "HazmatSuit" then
         print(tostring(items:getItemByIndex(count):isVanilla()))
         print(items:getItemByIndex(count):getModData())
      end
   end

end

function AtosClient:playerIsProtectedByClothingType(player)
   local items = player:getWornItems()
   local isSpeedFrameworkActivated = getActivatedMods():contains("SpeedFramework")

   for count = 0, items:size() - 1  do
      local clothingItem = items:getItemByIndex(count)
      local clothingItemType = clothingItem:getType()
      local protectionTypeByMap = AtosConstants.protectionTypeMap[clothingItemType]

      --print(items:getItemByIndex(count):getClothingItemName())
      if protectionTypeByMap == "HazmatSuit" then

         if isSpeedFrameworkActivated then
            SpeedFramework.SetPlayerSpeed(player, 0.7)
         end

         if clothingItem:getHolesNumber() < 1
         and clothingItem:getCurrentCondition() > 0 then
            return protectionTypeByMap
         end

      elseif protectionTypeByMap == "GasMask" then
         if clothingItem:getCondition() > 0 then
            return protectionTypeByMap
         end

      elseif protectionTypeByMap == "LightMask" or protectionTypeByMap == "ClothMask"  then
         return protectionTypeByMap
      end

   end

   if isSpeedFrameworkActivated then
      SpeedFramework.SetPlayerSpeed(player, nil)
   end
   return "Nothing"

end

function AtosClient:useGasMask(player)
   local items = player:getWornItems()

   for count = 1, items:size() - 1 do
      local item = items:getItemByIndex(count)

      if item and item:getType() == "Hat_GasMask" then
         --local currentUseDelta = AtosClient:getUsedDelta(item)
         local currentCondition = item:getCondition()
         --max item condition = 10
         -- For some fucking reason the argument in setCondition function is not a float but a int. So I have to improvise.
         local usage = 1


         if AtosClient:getFilterTicks(item) >= 4 then
            print("gasmask condition: " .. item:getCondition())
            if currentCondition <= 0 then
               item:setCondition(0)
            else
               item:setCondition(currentCondition - usage)
            end
            --When item gasmask reached 4 ticks, reset the ticks
            AtosClient:resetFilterTicks(item)
         else
            --Add one tick
            AtosClient:addFilterTicks(item, 1)
         end

      end

   end

end

function AtosClient:dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. AtosClient:dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function AtosClient:tableLength(T)
   local count = 0
   for k, v in pairs(T) do
      count = count + 1
   end
   return count
end
