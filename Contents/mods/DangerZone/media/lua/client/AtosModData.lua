---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Wesley.
--- DateTime: 13/07/2023 20:18
---
local AtosClient = AtosDangerZones.Client

function AtosClient:getIsProtectedByPills()
    local modData = getPlayer():getModData()
    if modData.isProtectedByPills == nil then
        modData.isProtectedByPills = false
    end
    return modData.isProtectedByPills
end

function AtosClient:setIsProtectedByPills(value)
    local modData = getPlayer():getModData()
    modData.isProtectedByPills = value
end

function AtosClient:getIsProtectedByPillsSince()
    local modData = getPlayer():getModData()
    if modData.isProtectedByPillsSince == nil then
        modData.isProtectedByPills = 0
    end
    return modData.isProtectedByPillsSince
end

function AtosClient:setIsProtectedByPillsSince(worldAge)
    local modData = getPlayer():getModData()
    modData.isProtectedByPillsSince = worldAge
end

function AtosClient:getRadiation()
    local modData = getPlayer():getModData()
    if modData.radiation == nil then
        modData.radiation = 1
    end
    return modData.radiation
end

function AtosClient:setRadiation(value)
    local modData = getPlayer():getModData()
    modData.radiation = value
end