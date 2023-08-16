---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 04/10/2022 19:23
---
---
if isServer() and not isClient() then
    print("Im a server")
    return
end

local AtosClient = AtosRadiatedZones.Client

--Listen to server commands
local function OnServerCommand(module, command, arguments)
    print("Getting server command")
    --AtosClient:setZones(arguments.zones)

    if module == "Atos" and command == "GetAllZones" then
        print("Getting all zones")
        print(arguments.zones)
        if arguments.zones then
            AtosClient:setZones(arguments.zones)
        end
    end

end

Events.OnServerCommand.Add(OnServerCommand)