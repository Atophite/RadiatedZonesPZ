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

function AtosClient:printCors()

   for playerIndex = 0, getNumActivePlayers() -1 do
      local player = getSpecificPlayer(playerIndex)
      print(player:getUsername() .. " X: " .. player:getLx() .. " Y: " .. player:getLy() .. " Z: " .. player:getLz())
   end
end

function AtosClient:printTable(table)
   print(AtosClient:dump(table))

end

local function getHandItem(equippedItem)
   if equippedItem ~= nil then
      if equippedItem:getName() == "Geiger Teller" and
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

   if getHandItem(primaryEquippedItem) or getHandItem(secondaryEquippedItem) then
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

function AtosClient:getTime()
   print(GameTime:getInstance():getHour())
end

function test(player)
   local items = player:getWornItems()

   for count = 1, items:size() - 1 do
      if items:getItemByIndex(count):getClothingItemName() == "HazmatSuit" then
         print(tostring(items:getItemByIndex(count):isVanilla()))
         print(items:getItemByIndex(count):getModData())
      end
   end

end

function AtosClient:isPlayerProtected(player)
   local items = player:getWornItems()

   for count = 1, items:size() - 1 do
      if items:getItemByIndex(count):getClothingItemName() == "HazmatSuit" then
         SpeedFramework.SetPlayerSpeed(player, 0.7)
         if items:getItemByIndex(count):getHolesNumber() < 1 then
            return true
         end
         return false
      else
         SpeedFramework.SetPlayerSpeed(player, nil)
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
