---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Atophite.
--- DateTime: 04/10/2022 19:23
---
---


if isServer() and not isClient() then
	return
end

local geigerSound = nil
--Is radiation detected by the geiger teller
local isRadiationDetected = false
local isInZone = false
local isProtected = false --OBSOLETE
local hasGeiger = false
local hasEnteredZone = false


local zones = nil

local AtosClient = AtosRadiatedZones.Client
local AtosShared = AtosRadiatedZones.Shared
local AtosConstants = AtosRadiatedZones.Constants

local function onClothingUpdated(player)
	--print("clothing update")
	AtosClient:setGeigerAndProtectMoodle()
end

local function onGameStart()
	local player = getPlayer()

	--This isnt even working lol
	--if client is online send request to server
	if isClient() then
		print("requesting zones 1")
		sendClientCommand("Atos", "RequestAllZones", {
			player = player
		});
	else
		--If client is offline, manually read the file
		print("reading zones file from client side cuz offline")
		zones = AtosShared:readZonesFile()

	end

	AtosClient:setGeigerAndProtectMoodle()
end

local function OnCreateLivingCharacter(playerOrSurvivor, survivordesc)
	print("new player created")
	local spawnWithGeigerTeller = SandboxVars.RadiatedZones.SpawnWithGeigerTeller
	if spawnWithGeigerTeller == true then
		playerOrSurvivor:getInventory():AddItem("RadiatedZones.GeigerTeller")
	end
end

local function onConnected()
	print("Connected to server")
end

local function OnGameBoot()
	print("game is booted!")
end

local function setBurnDamage()
	local bodyParts = getPlayer():getBodyDamage():getBodyParts()

	if bodyParts:size() > 0 then -- Check if the array is not empty
		local randomIndex = ZombRand(bodyParts:size())
		local randomBodyPart = bodyParts:get(randomIndex)

		randomBodyPart:setBurned()

	else
		-- Handle the case where the array is empty
		print("No body parts available.")
	end
end

local function checkIfPlayerProtectedByPills()
	--Check if player is protected by Iodine
	if AtosClient:getIsProtectedByPills() then
		local pillTotalDuration = 5 -- 5 hours
		local pillLowDuration = 4
		local currentWorldHour = GameTime:getInstance():getWorldAgeHours()

		if currentWorldHour - AtosClient:getIsProtectedByPillsSince() >= pillTotalDuration then
			AtosClient:setIsProtectedByPills(false)
			AtosClient:setIodineMoodle(0.5)--float
			print("The effects of the Iodine Pills has fallen off")
		elseif currentWorldHour - AtosClient:getIsProtectedByPillsSince() >= pillLowDuration then
			AtosClient:setIodineMoodle(0.2)--float
		else
			AtosClient:setIodineMoodle(1.0)--float
		end
	end
end

local function EveryTenMinutes()

	local player = getPlayer()

	AtosClient:validateZoneWithCivGeiger(player)

	--Check if player is protected by pills
	checkIfPlayerProtectedByPills()

	--If player is wearing gasmask
	AtosClient:useGasMask(player)

end


local function EveryDays()
	-- Check if player is cured

	local modData = getPlayer():getModData()
	local chance = ZombRand(100) -- Generates a random number between 0 and 100
	local dieChance = -1
	local cureChance = 30
	local burnChance = 50
	local currentRadiation = AtosClient:getRadiation()
	local hasLuckySodaUsage = AtosClient:getHasLuckySodaUsage()
	print("Day is over. The dice has been rolled: " .. chance)


	if AtosClient:getRadiationCured() == true or currentRadiation < 300 then
		if hasLuckySodaUsage then
			AtosClient:setRadiation(currentRadiation / 1.4)
			--When day is over lucky soda wears out
			AtosClient:setHasLuckySodaUsage(false)
		else
			AtosClient:setRadiation(currentRadiation / 1.2)
		end

		--Stop the function since it doesn't needs to go further.
		return
	end

	if currentRadiation >= 1000 then
		dieChance = 5 --5%
		cureChance = 15 --10%
		burnChance = 50 --35%
	end

	if AtosClient:getHasLuckySodaUsage() then
		print("player drank lucky soda. Chances has been altered.")
		dieChance = -1 --0%
		burnChance = 10--10%
		cureChance = 60--50%
		AtosClient:setRadiation(currentRadiation / 1.4)
		--When day is over lucky soda wears out
		AtosClient:setHasLuckySodaUsage(false)
	end


	if AtosClient:getRadiationCured() == false then
		local player = getPlayer()
		if chance <= dieChance then
			print("Player will die from radiation")
			player:getBodyDamage():setFoodSicknessLevel(100)
			--player:Kill(player)

		elseif chance <= cureChance then
			AtosClient:setRadiationCured(true)
			player:getBodyDamage():setFakeInfectionLevel(0)
			print("radiation is cured")
		elseif chance <= burnChance and currentRadiation >= 1000 then
			print("Burn damage")

		else
			print("radiation is not cured")
		end

	end
end

local function everyOneMinute()

	--If zones are empty
	--sendClientCommand only works on multiplayer
	--Wish it was working on onConnected/onGameStart
	if zones == nil then
		if(isClient()) then
			print("Requesting zones 2")
			sendClientCommand("Atos", "RequestAllZones", {
				player = player
			});
		else
			zones = AtosShared:readZonesFile()
		end
	else
		--Loop through the zones and check if player is in the zone
		AtosClient:loopZones()
	end

	AtosClient:calculateRadiation()
end



function AtosClient:setGeigerAndProtectMoodle()
	local player = getPlayer()
	--https://zomboid-javadoc.com/41.65/zombie/characters/ILuaGameCharacterClothing.html

	--Check if player equipped a geiger when clothing is updated
	--Also checks if the player already has the geiger equipped.
	if AtosClient:isGeigerEquipped(player) and not hasGeiger then
		hasGeiger = true


	elseif not AtosClient:isGeigerEquipped(player) then
		hasGeiger = false
	end

	local playerIsProtectedByClothingType = AtosClient:playerIsProtectedByClothingType(player)

	--TODO optimize
	if playerIsProtectedByClothingType == "HazmatSuit"  then
		isProtected = true
		AtosClient:setHazmatMoodle(1.0)
		AtosClient:setGasMaskMoodle(0.5)
		AtosClient:setLightMaskMoodle(0.5)
	elseif playerIsProtectedByClothingType == "GasMask" then
		isProtected = true
		AtosClient:setGasMaskMoodle(1.0)
		AtosClient:setHazmatMoodle(0.5)
		AtosClient:setLightMaskMoodle(0.5)
	elseif playerIsProtectedByClothingType == "LightMask" or playerIsProtectedByClothingType == "ClothMask" then
		isProtected = true
		AtosClient:setLightMaskMoodle(1.0)
		AtosClient:setGasMaskMoodle(0.5)
		AtosClient:setHazmatMoodle(0.5)
	else
		isProtected = false
		AtosClient:setHazmatMoodle(0.5)
		AtosClient:setGasMaskMoodle(0.5)
		AtosClient:setLightMaskMoodle(0.5)
	end
end


function AtosClient:loopZones()

	local player = getPlayer()
    local playerX, playerY = player:getX(), player:getY()
    isInZone = false

    for i, zone in ipairs(zones) do
        local zoneXMin, zoneXMax = zone[1][1], zone[1][2]
        local zoneYMin, zoneYMax = zone[2][1], zone[2][2]

        if playerX > zoneXMin and playerX < zoneXMax and playerY > zoneYMin and playerY < zoneYMax then
            isInZone = true
            break  -- No need to check further if the player is already in a zone
        end
    end

    AtosClient:validateZoneWithGeiger(player)
end


function AtosClient:validateZoneWithGeiger(player)
	-- Check if the player is in the radiation zone
	if isInZone then

		--Check if its the first time that the player has entered the zone.
		--To prevent a loop
		if not hasEnteredZone then

			if AtosClient:isGeigerEquipped(player) then
				player:Say("Radiation detected!")
			end
			hasEnteredZone = true
			--AtosClient:setGeigerAndProtectMoodle()
			print("player entered zone")

			---- ----------------------DEBUG SHIT ------------------------
			--local playerIsProtectedByClothingType = AtosClient:playerIsProtectedByClothingType(player)
			--if playerIsProtectedByClothingType == "HazmatSuit"   then
			--	print("player is wearing hazmat protection")
			--elseif playerIsProtectedByClothingType == "GasMask" then
			--	print("player is wearing gasmask protection")
			--elseif playerIsProtectedByClothingType == "LightMask"  then
			--	print("player is wearing light mask protection like dustmask")
			--
			--elseif playerIsProtectedByClothingType == "ClothMask"  then
			--	print("player is wearing cloth mask protection like improvised cloth mask")
			--else
			--	print("player is not wearing protection")
			--end
		end


		--If the player has a geiger the player can detect the radiation
		if AtosClient:isGeigerEquipped(player) then
			isRadiationDetected = true
			AtosClient:playSound()
		else
			isRadiationDetected = false
			AtosClient:stopSound()
		end
	else
		--Check if its the first time that the player has left the zone.
		--To prevent a loop
		if hasEnteredZone then
			print("player has left the radiated zone")
			AtosClient:stopSound()
			--Send message to server that player left zone.
			if AtosClient:isGeigerEquipped(player) then
				player:Say("Radiation not detected!")
			end

			hasEnteredZone = false
		end
	end
end

function AtosClient:validateZoneWithCivGeiger()
	local player = getPlayer()
	-- Check if the player is in the radiation zone
	if isInZone then

		--Check if its the first time that the player has entered the zone.
		--To prevent a loop
		if not hasEnteredZone then

			if AtosClient:isCivGeigerEquipped(player) and AtosClient:isGeigerEquipped(player) == false then
				player:Say("Radiation detected!")
			end
			hasEnteredZone = true
			--AtosClient:setGeigerAndProtectMoodle()

			---- ----------------------DEBUG SHIT ------------------------
			--	local playerIsProtectedByClothingType = AtosClient:playerIsProtectedByClothingType(player)
			--	if playerIsProtectedByClothingType == "HazmatSuit"   then
			--		print("player is wearing hazmat protection")
			--	elseif playerIsProtectedByClothingType == "GasMask" then
			--		print("player is wearing gasmask protection")
			--	elseif playerIsProtectedByClothingType == "LightMask"  then
			--		print("player is wearing light mask protection like dustmask")
			--
			--	elseif playerIsProtectedByClothingType == "ClothMask"  then
			--		print("player is wearing cloth mask protection like improvised cloth mask")
			--	else
			--		print("player is not wearing protection")
			--	end
		end


		--If the player has a geiger the player can detect the radiation
		if AtosClient:isCivGeigerEquipped(player) then
			isRadiationDetected = true
			AtosClient:playSound()
		else
			isRadiationDetected = false
			AtosClient:stopSound()
		end
	else
		--Check if its the first time that the player has left the zone.
		--To prevent a loop
		if hasEnteredZone then
			print("player has left the radiated zone")
			AtosClient:stopSound()
			--Send message to server that player left zone.
			if AtosClient:isGeigerEquipped(player) then
				player:Say("Radiation not detected!")
			end

			hasEnteredZone = false
		end
	end
end

function AtosClient:calculateRadiation()
	local player = getPlayer()

	local playerRadiation = AtosClient:getRadiation()
	local playerWearClothingType = AtosClient:playerIsProtectedByClothingType(player)
	local playerIsProtectedByPills = AtosClient:getIsProtectedByPills()


	local function setSickness(sicknessLevel)
		player:getBodyDamage():setFakeInfectionLevel(sicknessLevel)
	end

	if isInZone then

		-- Calculate player radiation based on clothing type
		local radiationValues = AtosConstants.clothingRadiation[playerWearClothingType]
		if radiationValues then
			if playerIsProtectedByPills then
				--print(radiationValues.withPills)
				playerRadiation = playerRadiation + radiationValues.withPills
				--print(playerRadiation)

			else
				--print(radiationValues.noPills)
				playerRadiation = playerRadiation + radiationValues.noPills
				--print(playerRadiation)

			end
		end

		if AtosClient:getRadiationCured() == true then
			AtosClient:setRadiationCured(false)
		end
	end


	if(playerRadiation > 2000) then

		--When player reaches 2000 RADS, player will die
		player:getBodyDamage():setFoodSicknessLevel(100)

	elseif playerRadiation > 1000 then
		setSickness(50)

	elseif playerRadiation > 300 then
		setSickness(25)
	else
		setSickness(0)

	end

	AtosClient:setRadiation(playerRadiation)
end

function AtosClient:setZones(paramZones)
	zones = paramZones
end

function AtosClient:playSound()
	local player = getPlayer()
	if geigerSound == nil then
		geigerSound = player:playSoundLocal("Geiger")
	elseif geigerSound ~= nil and not player:getEmitter():isPlaying("Geiger") and AtosClient:isGeigerEquipped(player) == true then
		geigerSound = player:playSoundLocal("Geiger")

	end
end

function AtosClient:stopSound()
	local player = getPlayer()
	if geigerSound ~= nil and isRadiationDetected or not hasGeiger then
		player:getEmitter():stopSoundByName("Geiger")

		geigerSound = nil
	end
end

function AtosClient:getIsInZone()
	return isInZone
end


Events.OnClothingUpdated.Add(onClothingUpdated)
Events.OnGameStart.Add(onGameStart)
Events.EveryOneMinute.Add(everyOneMinute)
Events.OnConnected.Add(onConnected)
Events.OnGameBoot.Add(OnGameBoot)
Events.EveryDays.Add(EveryDays)
Events.EveryTenMinutes.Add(EveryTenMinutes)
Events.OnCreateLivingCharacter.Add(OnCreateLivingCharacter)

