
coordinates = {}

function test()
	print("test")
end

function printCors()

   for playerIndex = 0, getNumActivePlayers() -1 do
      local player = getSpecificPlayer(playerIndex)
      -- print(inspect(getmetatable(player)))
      print(player:getUsername() .. " X: " .. player:getLx() .. " Y: " .. player:getLy() .. " Z: " .. player:getLz())
   end
end

function printTable(table)
   print(dump(table))

end

function readCorsFile()
   --sendClientCommand("Test", "ReadCorsFile", {
   --
   --});

   --[0-9]
   local zone = {}
   coordinates = {}
   local counter = 1;
   local x
   local y
   local reader = getModFileReader("DangerZone", "media/coordinates.txt", true)
   if reader then
      local line = reader:readLine()
      line = reader:readLine()
      print(line)
      while line do
         for w in string.gmatch(line, "%d+") do
            print(w)
            if counter == 1 then
               x = tonumber(w)
            end

            if counter == 2 then
               y = tonumber(w)
            end
            counter = counter + 1
            if counter == 3 then
               counter = 1
               table.insert(zone, {x,y})
            end
         end

         table.insert(coordinates, zone)
         zone = {}
         line = reader:readLine()
      end
      reader:close();

   end
   print(printTable(coordinates))
   for i, zone in ipairs(coordinates) do
       print("zone " .. i)
      print(zone)
      printTable(zone)
   end

end

function playerIsProtected(player)
   local items = player:getWornItems()


   for count = 1, items:size() - 1 do
      if items:getItemByIndex(count):getClothingItemName() == "HazmatSuit" then
         --print(items:getItemByIndex(count):getClothingItemName())
         return true
      end
   end
   return false
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function tableLength(T)
   local count = 0
   for k, v in pairs(T) do
      count = count + 1
   end
   return count
end
