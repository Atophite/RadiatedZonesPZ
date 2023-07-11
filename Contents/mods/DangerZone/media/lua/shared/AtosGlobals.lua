---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Wesley.
--- DateTime: 04/10/2022 22:39
---

AtosDangerZones = {
    Settings = { }, -- configuration options
    Client = { -- client side functions and data
        Events = { }, -- client event hooks
    },
    Server = { -- server side functions and data
        Events = { }, -- server event hooks
    },
    Shared = { },
}

local AtosShared = AtosDangerZones.Shared

function AtosShared:readZonesFile()
    local zone = {}
    local zones = {}
    local counter = 1;
    local x
    local y
    local reader = getModFileReader("DangerZone", "media/coordinates.txt", false)

    if reader then
        local line = reader:readLine()
        line = reader:readLine()
        while line do
            print(line)
            for number in string.gmatch(line, "%d+") do
                print(number)
                if counter == 1 then
                    x = tonumber(number)
                end

                if counter == 2 then
                    y = tonumber(number)
                end

                counter = counter + 1

                if counter == 3 then
                    counter = 1
                    table.insert(zone, {x,y})
                end
            end

            if zone[1] and zone[2] ~= nill then
                table.insert(zones, zone)
                zone = {}
            end

            line = reader:readLine()
        end
        reader:close();

    else
        print("coordinates.txt NOT FOUND! Make an empty text file with the name coordinates.txt")
        print("file needs to contain: ")
        print("{Lowest point of X, Highest point of X}, {Lowest point of Z, highest point of Z}")

    end
    --for i, z in ipairs(zones) do
    --    print("zone " .. i)
    --    --print(zone)
    --    AtosClient:printTable(z)
    --end

    return zones
end