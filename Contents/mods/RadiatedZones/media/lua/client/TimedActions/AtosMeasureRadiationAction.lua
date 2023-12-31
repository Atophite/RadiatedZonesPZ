---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 29/07/2023 15:55
---

require "TimedActions/ISBaseTimedAction"

AtosIsMeasureRadiationAction = ISBaseTimedAction:derive("AtosIsMeasureRadiationAction");
local AtosClient = AtosRadiatedZones.Client

function AtosIsMeasureRadiationAction:isValid() -- Check if the action can be done
    local currentUseDelta = self.item:getUsedDelta()
    if currentUseDelta <= 0 then
        self.character:Say(getText("ContextMenu_out_of_battery"))
        return false
    end

    return true;
end

function AtosIsMeasureRadiationAction:update() -- Trigger every game update when the action is perform
    self.item:setJobDelta(self:getJobDelta());
end

function AtosIsMeasureRadiationAction:start() -- Trigger when the action start
    self.item:setJobType(getText("ContextMenu_measure_radiation"));
    self.item:setJobDelta(0.0);
    self:setOverrideHandModels(nil, self.item);
    self:setActionAnim("MedicalCheck")
end

function AtosIsMeasureRadiationAction:stop() -- Trigger if the action is cancel
    self.item:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function AtosIsMeasureRadiationAction:perform() -- Trigger when the action is complete
    self.item:setJobDelta(0.0);
    self.character:Say(getText("ContextMenu_measure_body_radiation") .. math.floor(AtosClient:getRadiation()) .. " RADS")
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