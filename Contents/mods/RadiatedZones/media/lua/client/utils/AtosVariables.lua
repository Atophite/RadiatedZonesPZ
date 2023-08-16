---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 15/08/2023 17:08
---

local AtosClient = AtosRadiatedZones.Client


-- Contants for clothing types
local LIGHTMASK = "LightMask"
local GASMASK = "GasMask"
local HAZMAT = "HazmatSuit"
local CLOTHMASK = "ClothMask"

AtosClient.protectionTypeMap = {
    ["Hat_DustMask"] = LIGHTMASK,
    ["Hat_SurgicalMask_Green"] = LIGHTMASK,
    ["Hat_SurgicalMask_Blue"] = LIGHTMASK,
    ["Hat_BandanaMaskTINT"] = CLOTHMASK,
    ["Hat_BandanaMask"] = CLOTHMASK,
    ["ImprovisedMask"] = CLOTHMASK,
    ["Hat_GasMask"] = GASMASK,
    ["HazmatSuit"] = HAZMAT,
}

-- Constants for radiation multipliers OBSOLETE FOR NOW
local BASE_MULTIPLIER = 1.10
local PILL_PROTECTION_MULTIPLIER = 1.05

-- Define radiation values for each clothing type
AtosClient.clothingRadiation = {
    ["Nothing"] = { noPills = 6.5, withPills = 5.0},
    ["ClothMask"] = { noPills = 5.5, withPills = 4.5 },
    ["LightMask"] = { noPills = 4.0, withPills = 3.25 },
    ["GasMask"] = { noPills = 1.5, withPills = 0.75 },
    ["HazmatSuit"] = { noPills = 0, withPills = 0 }
}