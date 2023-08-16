---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 13/07/2023 20:18
---
local AtosClient = AtosRadiatedZones.Client

local function getPlayerModData()
    if getPlayer():getModData().RadiatedZones == nil then
        getPlayer():getModData().RadiatedZones = {}
    end
    return getPlayer():getModData().RadiatedZones
end

function AtosClient:getIsProtectedByPills()
    local modData = getPlayerModData()
    if modData.isProtectedByPills == nil then
        modData.isProtectedByPills = false
    end
    return modData.isProtectedByPills
end

function AtosClient:setIsProtectedByPills(value)
    local modData = getPlayerModData()
    modData.isProtectedByPills = value
end

function AtosClient:getIsProtectedByPillsSince()
    local modData = getPlayerModData()
    if modData.isProtectedByPillsSince == nil then
        modData.isProtectedByPillsSince = 0
    end
    return modData.isProtectedByPillsSince
end

function AtosClient:setIsProtectedByPillsSince(worldAge)
    local modData = getPlayerModData()
    modData.isProtectedByPillsSince = worldAge
end

function AtosClient:getRadiation()
    local modData = getPlayerModData()
    if modData.radiation == nil then
        modData.radiation = 1
    end
    return modData.radiation
end

function AtosClient:setRadiation(value)
    local modData = getPlayerModData()
    modData.radiation = value
end

function AtosClient:getRadiationCured()
    local modData = getPlayerModData()
    if modData.radiationCured == nil then
        modData.radiationCured = true
    end
    return modData.radiationCured
end

function AtosClient:setRadiationCured(value)
    local modData = getPlayerModData()
    modData.radiationCured = value
end

function AtosClient:getHasLuckySodaUsage()
    local modData = getPlayerModData()
    if modData.hasLuckySodaUsage == nil then
        modData.hasLuckySodaUsage = false
    end
    return modData.hasLuckySodaUsage
end

function AtosClient:setHasLuckySodaUsage(value)
    local modData = getPlayerModData()
    modData.hasLuckySodaUsage = value
end




-- ITEMS -----------------------------------------------------------
function AtosClient:getUsedDelta(item)
    randomUsedDelta = ZombRand(100)
    if item:getModData().usedFilterDelta == nil then
        item:getModData().usedFilterDelta = randomUsedDelta
        return item:getModData().usedFilterDelta
    end

    return item:getModData().usedFilterDelta

end

function AtosClient:setUsedDelta(item, usedDelta)
    item:getModData().usedFilterDelta = usedDelta
end



