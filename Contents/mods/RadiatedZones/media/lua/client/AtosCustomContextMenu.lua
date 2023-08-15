---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Wesley.
--- DateTime: 29/07/2023 15:31
---
local AtosClient = AtosRadiatedZones.Client

local function doMenu(player, context, items)
    for i, v in ipairs(items) do
        local item = v;
        if not instanceof(v, "InventoryItem") then
            item = v.items[1];
        end

        if item:getType() then
            if item:getType() == "GeigerTeller" then
                if item:getUsedDelta() > 0 then
                    context:addOption(getText("ContextMenu_measure_radiation"), item, measureRadiation, player);
                    context:addOption(getText("ContextMenu_check_geiger"), item, lookAtGeiger, player);
                end
            elseif item:getType() == "Hat_GasMask" then
                context:addOption(getText("Check Gas Mask Filter"), item, checkGasMaskFilter, player);
            end
        end
    end
end

function takeIodinePill(item, player)
    local playerObj = getSpecificPlayer(player);
    ISTimedActionQueue.add(AtosTakeIodinePill:new(playerObj, item))
end

function measureRadiation(item, player)
    local playerObj = getSpecificPlayer(player);
    ISTimedActionQueue.add(AtosIsMeasureRadiationAction:new(playerObj, item))
end

function lookAtGeiger(item, player)
    local playerObj = getSpecificPlayer(player);
    ISTimedActionQueue.add(AtosIsCheckGeigerAction:new(playerObj, item))
end

function checkGasMaskFilter(item, player)
    local playerObj = getSpecificPlayer(player);

    local usedDelta = AtosClient:getUsedDelta(item)

    if usedDelta <= 0 then
        playerObj:Say("The quality of the filter is EMPTY")
    elseif usedDelta < 25 then
        playerObj:Say("The quality of the filter is BAD")
    elseif usedDelta < 65 then
        playerObj:Say("The quality of the filter is MEDIUM")
    elseif usedDelta >= 65 then
        playerObj:Say("The quality of the filter is GOOD")

    end

end


-- OVERRIDE
ISInventoryPaneContextMenu.wearItem = function(item, player)
    -- if clothing isn't in main inventory, put it there first.
    local playerObj = getSpecificPlayer(player);
    -- This stuff was removed in that it forced the first optional clothing option when trying to wear clothing items with multiple options.
    -- It seems to work fine as intended without it.
    -- wear the clothe
    -- if item:getClothingItemExtraOption() and item:getClothingItemExtra() and item:getClothingItemExtra():get(0) then
    -- ISInventoryPaneContextMenu.onClothingItemExtra(item, item:getClothingItemExtra():get(0), playerObj);
    -- else
    ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item);
    print(item:getName())
    if item:getClothingItemName() == "HazmatSuit" then
        ISTimedActionQueue.add(ISWearClothing:new(playerObj, item, 1000));
    else
        ISTimedActionQueue.add(ISWearClothing:new(playerObj, item, 50));
    end
    -- end

end

-- OVERRIDE
ISInventoryPaneContextMenu.unequipItem = function(item, player)
    if not getSpecificPlayer(player):isEquipped(item) then return end
    if item ~= nil and item:getType() == "CandleLit" then item = ISInventoryPaneContextMenu.litCandleExtinguish(item, player) end
    if item:getClothingItemName() == "HazmatSuit" then
        ISTimedActionQueue.add(ISUnequipAction:new(getSpecificPlayer(player), item, 500));
    else
        ISTimedActionQueue.add(ISUnequipAction:new(getSpecificPlayer(player), item, 50));
    end
end

-- The link to the right-click menu event
Events.OnFillInventoryObjectContextMenu.Add(doMenu);
