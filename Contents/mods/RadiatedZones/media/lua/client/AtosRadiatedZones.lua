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


local zones

local AtosClient = AtosRadiatedZones.Client
local AtosShared = AtosRadiatedZones.Shared

local function onClothingUpdated(player)
	--print("clothing update")
	AtosClient:setGeigerAndProtectMoodle()
end

local function onGameStart()
	local player = getPlayer()

	--if client is online send request to server
	if isClient() then
		print("requesting zones")
		sendClientCommand("Atos", "RequestAllZones", {
			player = player
		});
	else
		--If client is offline, manually read the file
		print("reading zones file cuz offline")
		zones = AtosShared:readZonesFile()

	end

	AtosClient:setGeigerAndProtectMoodle()
end

local function OnCreatePlayer(playerIndex, player)
	print("new player created")
	local spawnWithGeigerTeller = SandboxVars.RadiatedZones.SpawnWithGeigerTeller
	if spawnWithGeigerTeller == true then
		player:getInventory():AddItem("RadiatedZones.GeigerTeller")
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

	--Check if player is protected by pills
	checkIfPlayerProtectedByPills()

	--If player is wearing gaskmask
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
	print("Day is over. The dice has been rolled: " .. chance)


	if AtosClient:getRadiationCured() == true or currentRadiation < 450 then
		AtosClient:setRadiation(currentRadiation / 1.2)
		return
	end

	if currentRadiation >= 1000 then
		dieChance = 10 --5%
		cureChance = 20 --10%
		burnChance = 50 --30%
	end

	if AtosClient:getHasLuckySodaUsage() then
		print("player drank lucky soda. Chances has been altered.")
		dieChance = -1 --0%
		cureChance = 60--50%
		burnChance = 10--10%
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
	local player = getPlayer()
	--Check for pills


	--If zones are empty
	--sendClientCommand only works on multiplayer
	--For some reason the sendClientCommand doesnt work on onGameStart()
	if zones == nil then
		if(isClient()) then
			sendClientCommand("Atos", "RequestAllZones", {
				player = player
			});
		else
			zones = AtosShared:readZonesFile()
		end
	else
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

		--if not isInZone then
		--	player:Say("Radiation not detected!")
		--elseif isInZone then
		--	player:Say("Radiation detected!")
		--end

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

    AtosClient:validateZone()
end


function AtosClient:validateZone()
	local player = getPlayer()
	-- Check if the player is in the radiation zone
	if isInZone then

		--Check if its the first time that the player has entered the zone.
		--To prevent a loop
		if not hasEnteredZone then

			if AtosClient:isGeigerEquipped(player) then
				player:Say("Radiation detected!")
			end
			hasEnteredZone = true
			AtosClient:setGeigerAndProtectMoodle()
		end

		local playerIsProtectedByClothingType = AtosClient:playerIsProtectedByClothingType(player)

		if playerIsProtectedByClothingType == "HazmatSuit" or playerIsProtectedByClothingType == "GasMask"  then
			print("player is wearing hazmat or gasmask protection")
		elseif playerIsProtectedByClothingType == "LightMask" then
			print("player is wearing light mask protection like dustmask")
		else
			print("player is not wearing protection")
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
		local radiationValues = AtosClient.clothingRadiation[playerWearClothingType]
		if radiationValues then
			if playerIsProtectedByPills then
				--print(radiationValues.withPills)
				playerRadiation = playerRadiation + radiationValues.withPills
				--print(playerRadiation)

			else
				print(radiationValues.noPills)
				playerRadiation = playerRadiation + radiationValues.noPills
				print(playerRadiation)



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
		setSickness(75)

	elseif playerRadiation > 300 then
		setSickness(50)
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
Events.OnCreatePlayer.Add(OnCreatePlayer)

