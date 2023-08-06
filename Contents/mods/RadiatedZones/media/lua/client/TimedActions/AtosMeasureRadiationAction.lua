---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Wesley.
--- DateTime: 29/07/2023 15:55
---

require "TimedActions/ISBaseTimedAction"

AtosIsMeasureRadiationAction = ISBaseTimedAction:derive("AtosIsMeasureRadiationAction");
local AtosClient = AtosRadiatedZones.Client

function AtosIsMeasureRadiationAction:isValid() -- Check if the action can be done
    return true;
end

function AtosIsMeasureRadiationAction:update() -- Trigger every game update when the action is perform

end

function AtosIsMeasureRadiationAction:start() -- Trigger when the action start
    self:setOverrideHandModels(nil, self.item);
    self:setActionAnim("MedicalCheck")
end

function AtosIsMeasureRadiationAction:stop() -- Trigger if the action is cancel

    ISBaseTimedAction.stop(self);
end

function AtosIsMeasureRadiationAction:perform() -- Trigger when the action is complete
    self.character:Say("My radiation level is: " .. math.floor(AtosClient:getRadiation()) .. " RADS")
    ISBaseTimedAction.perform(self);
end

function AtosIsMeasureRadiationAction:new(character, item) -- What to call in you code
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.item = item
    o.character = character;
    o.maxTime = 500; -- Time take by the action
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    return o;
end