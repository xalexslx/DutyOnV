--
-- Copyright 2015 Alexandre Leites. All rights reserved.
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--      http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

-- Class
class 'Police'(DutyJob)

-- State enumerator
local STATE_NONE, STATE_SELECT_OUTFIT, STATE_SELECT_PARTNER, STATE_SELECT_VEHICLE, STATE_READY = 0, 1, 2, 3, 4

local POLICE_OUTFITS = {
	['S_F_Y_Cop_01']			= 'Male - Cop',
	['S_M_Y_HWayCop_01']		= 'Male - Highway Cop',
	['S_M_Y_Sheriff_01']		= 'Male - Sheriff',
	['S_M_M_CIASEC_01']			= 'Male - IAA',
	['S_M_M_FIBOffice_01']		= 'Male - FIB 1',
	['S_M_M_FIBOffice_02']		= 'Male - FIB 2',
	['S_F_Y_Cop_01']			= 'Female - Cop',
	['S_F_Y_Sheriff_01']		= 'Female - Sheriff',
	['IG_Michelle']				= 'Female - Michelle',
}

local POLICE_VEHICLES = {
	['Police Cruiser']				= VEHICLE_POLICE,
	['Police Buffalo']				= VEHICLE_POLICE2,
	['Police Interceptor']			= VEHICLE_POLICE3,
	['Police Cruiser (Undercover)']	= VEHICLE_POLICE4,
	['Police Bike']					= VEHICLE_POLICEB,
	['Police Rancher (Snow)']		= VEHICLE_POLICEOLD1,
	['Police Esperanto (Snow)']		= VEHICLE_POLICEOLD2,
	['Police TransportVan']			= VEHICLE_POLICET,
	--['Police Helicopter']			= VEHICLE_POLMAV,
}

-- CTor
function Police:__init()
	DutyJob.__init(self)
	self._type				= "Police"
	self.name				= "Police Officer"
	self.state				= STATE_NONE
	self.partner			= nil
	self.menus				= {}
	self.callOutIndex		= 0
	self.callOutVars		= {}
	self.group_hashes		= {}
	
	-- Attackers hash
	self.group_hashes['playerHate'] = Ped.AddRelationshipGroup("DutyPolice_PlayerHate")
	natives.PED.SET_RELATIONSHIP_BETWEEN_GROUPS(1, self.group_hashes['playerHate'], 0x6F0783F5)
	natives.PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, 0x6F0783F5, self.group_hashes['playerHate'])
	
	-- Menus
	self:CreateMenus()
end

function Police:CreateMenus()
	-- Outfit menu
	self.menus['outfits']	= gui.DutyMenu(self, {
		Title = "Select Outfit",			-- title of the menu
		x = 0.03, 							-- x-coordinate, 0.0 = left, 1.0 = right
		y = 0.02, 							-- y-coordinate, 0.0 = top, 1.0 = bottom
		Width = 0.23, 						-- width of the whole menu
		TitleHeight = 0.05, 				-- height of the title box
		OptionHeight = 0.03, 				-- height of an option
		CanBeClosed = false 				-- allow close
	})
	
	-- Outfits
	for k,v in pairs(POLICE_OUTFITS) do
		self.menus['outfits']:AddOption(v, "OnSelectOutfit", k)
	end
	
	-- Partner
	self.menus['partners']	= gui.DutyMenu(self, {
		Title = "Select Partner",			-- title of the menu
		x = 0.03, 							-- x-coordinate, 0.0 = left, 1.0 = right
		y = 0.02, 							-- y-coordinate, 0.0 = top, 1.0 = bottom
		Width = 0.23, 						-- width of the whole menu
		TitleHeight = 0.05, 				-- height of the title box
		OptionHeight = 0.03, 				-- height of an option
		CanBeClosed = false 				-- allow close
	})
	
	-- Partners
	self.menus['partners']:AddOption("No Partner", "OnSelectOutfit", 0)
	for k,v in pairs(POLICE_OUTFITS) do
		self.menus['partners']:AddOption(v, "OnSelectOutfit", k)
	end
	
	-- Vehicle Menu
	self.menus['vehicles']	= gui.DutyMenu(self, {
		Title = "Select Vehicle",			-- title of the menu
		x = 0.03, 							-- x-coordinate, 0.0 = left, 1.0 = right
		y = 0.02, 							-- y-coordinate, 0.0 = top, 1.0 = bottom
		Width = 0.23, 						-- width of the whole menu
		TitleHeight = 0.05, 				-- height of the title box
		OptionHeight = 0.03, 				-- height of an option
		CanBeClosed = false 				-- allow close
	})
	
	-- Vehicles
	self.menus['vehicles']:AddOption("On Foot", "OnSelectVehicle", 0)
	for k,v in pairs(POLICE_VEHICLES) do
		self.menus['vehicles']:AddOption(k, "OnSelectVehicle", v)
	end
	
	-- Close Menus
	for _,menu in pairs(self.menus) do
		menu:Close()
	end
end

-- Police:CheckPlayerRequirements()
-- 
-- This method is called to check if the player has all requirements to receive
-- an active event (eg. police call, fire event, ems call, garbage truck, etc).
-- 
-- Good examples of checking on this method is checking if the player met all
-- requirements such as specific model/vehicle/etc.
--
-- Return true or false according to your custom rules.
-- 
function Police:CheckPlayerRequirements()
	-- Player is not on duty
	if not self:IsOnDuty() then return false end
	
	-- Player didn't select his/her outfit and vehicle
	if self.state ~= STATE_READY then return false end
	
	-- Requirements met
	return true
end

-- Police:SetOnDuty(flag)
-- 
-- This method is called when the player changed the 'on duty' state.
-- 
function Police:SetOnDuty(flag)
	self.onDuty = flag
	
	if self:IsOnDuty() then
		self.state = STATE_SELECT_OUTFIT
	else
		self.state = STATE_NONE
	end
end

-- Police:CanExecuteRandomEvents()
-- 
-- This method is called to check if your job want to dispatch active events.
-- Active events are events which player normally needs to act on them, like
-- police calls, etc.
--
-- Return true or false according to your custom rules.
-- 
function Police:CanExecuteActiveEvents()
	-- Player didn't select his/her outfit and vehicle
	if not self:IsOnDuty() or self.state ~= STATE_READY then return false end
	
	-- Callout already running
	if self.callOutIndex ~= 0 then return false end
	
	return true
end

-- Police:CreateActiveEvent()
-- 
-- This method is called when the user wants a new active event to be created.
-- 
-- Return true if your job created an event, false otherwise.
-- 
function Police:CreateActiveEvent()
	
	local player = LocalPlayer()
	
	-- Create a logic to randomize available callouts
	if math.random(100) < 10 then
		-- 10% chance of creating a callout
		
	end
	
	return false
end

-- Police:CanExecuteRandomEvents()
-- 
-- This method is called to check if your job want to dispatch random world events.
-- The difference between this and CheckPlayerRequirements() is that you doesn't
-- need to be 'on duty' to see any random event such as peds being robbed or cars
-- crashing, etc.
--
-- Return true or false according to your custom rules.
-- 
function Police:CanExecuteRandomEvents()
	-- Player didn't select his/her outfit and vehicle
	if not self:IsOnDuty() or self.state ~= STATE_READY then return false end
	
	return true
end

-- Police:CreateRandomEvent()
-- 
-- This method is called when the user wants a new random event to be created.
--
-- Return true if your job created an event, false otherwise.
-- 
function Police:CreateRandomEvent()
	
	local player = LocalPlayer()
	
	--if math.random(100) < 25 then
	
	if not player:IsInVehicle() and self:IsOnDuty() and self.state == STATE_READY then
		local nearby_peds 	= player:GetNearbyPeds(30)
		
		if table.getn(nearby_peds) > 0 then
			local attacker	= nearby_peds[math.random(table.getn(nearby_peds))]
			if (self.partner == nil or attacker.ID ~= self.partner.ID) and not attacker:IsInVehicle() then
				-- Attack player
				DutyUtils.Debug("Attacking... ", attacker.ID)
				
				self:SetupAttacker(attacker)
				
				attacker:AllowWeaponSwitching(true)
				attacker:DelayedGiveWeapon("WEAPON_PISTOL", 0)
				AI.ClearTasks(attacker.ID)
				natives.AI.TASK_COMBAT_PED(attacker.ID, player.ID, 0, 16)
				
				return true
			end
		end
	end
	--end
	
	return false
end

-- Police:Tick()
-- 
-- This method is always executed every tick. Use this method to check the current
-- state of your previously created active or random events.
-- 
function Police:Tick()
	
	-- Menu Updates
	for _,menu in pairs(self.menus) do
		menu:Update()
	end
	
	-- Is Player ready?
	if self.state == STATE_SELECT_OUTFIT then
		self:OpenMenu('outfits')
	elseif self.state == STATE_SELECT_PARTNER then
		self:OpenMenu('partners')
	elseif self.state == STATE_SELECT_VEHICLE then
		self:OpenMenu('vehicles')
	elseif self.state == STATE_READY then
		
	end
end

-- Police:Terminate()
-- 
-- This method is called right before all scripts get killed. Please cleanup everything.
-- 
function Police:Terminate()
	DutyJob:Terminate()
end

function Police:OpenMenu(menuid)
	-- Close all menus
	for _,menu in pairs(self.menus) do
		menu:Close()
	end

	self.menus[menuid]:Open()
end

function Police:OnSelectOutfit(menu, model)
	
	-- Partner skip
	if model == 0 then
		if self.state == STATE_SELECT_PARTNER then
			self.state 		= STATE_SELECT_VEHICLE
		end
		
		return
	end
	
	-- Model hash
	local model_hash = natives.GAMEPLAY.GET_HASH_KEY(model)
	if natives.STREAMING.IS_MODEL_IN_CDIMAGE(model_hash) and natives.STREAMING.IS_MODEL_VALID(model_hash) then
	
		-- Request Model
		streaming.RequestModel(model_hash)
		
		-- Change outfit or create partner
		if self.state == STATE_SELECT_OUTFIT then
			-- Change player model
			LocalPlayer():SetModel(model_hash)
			
			self:SetupPlayer(LocalPlayer())
			
			self:OpenMenu('partners')
			
			self.state 		= STATE_SELECT_PARTNER
		elseif self.state == STATE_SELECT_PARTNER then
			-- Create partner
			self.partner	= game.CreatePed(model_hash, LocalPlayer():GetOffsetVector(0,2,0))
			
			self:OpenMenu('vehicles')
			
			self:SetupPartner(self.partner)
			
			self.state 		= STATE_SELECT_VEHICLE
		end
		
		-- Release Model
		streaming.ReleaseModel(model_hash)
	else
		DutyUtils.Debug("Not a valid model: ", model)
	end
end

function Police:OnSelectVehicle(menu, model)
	-- State machine
	self.state 		= STATE_READY
	self.menus['vehicles']:Close()
	
	if model == 0 then
		return
	end
	
	-- Position
	local vehicle_pos = LocalPlayer():GetOffsetVector(0,5,0)
	
	-- Request Model
	streaming.RequestModel(model)
	
	game.CreateVehicle(model, vehicle_pos)
	
	-- Release Model
	streaming.ReleaseModel(model)
end

function Police:SetupPlayer(player)
	-- Give weapons
	player:AllowWeaponSwitching(true)
	player:DelayedGiveWeapon("WEAPON_PISTOL", 1000)
	
	-- Clear wanted level
	player:ClearWantedLevel()
	
	-- Set player as a police officer
	natives.PLAYER.SET_POLICE_IGNORE_PLAYER(player.PlayerID, true)
	natives.PLAYER.SET_MAX_WANTED_LEVEL(0)
	natives.PED.SET_PED_AS_COP(player.PlayerID, true)
end

function Police:SetupPartner(ped)
	ped:AllowWeaponSwitching(true)
	ped:DelayedGiveWeapon("WEAPON_PISTOL", 1000)
	
	-- Group Member / Bodyguard
	ped:AddGroupMember(LocalPlayer())
end


function Police:SetupAttacker(ped)
	-- Block temporary events
	natives.AI.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped.ID, true)
	
	-- Set relationship
	ped:SetRelationshipGroupHash(self.group_hashes['playerHate'])
	
	-- Combat attributes
	natives.PED.SET_PED_FLEE_ATTRIBUTES(ped.ID, 0, false)
	natives.PED.SET_PED_COMBAT_ATTRIBUTES(ped.ID, 17, true)
	
	ped:AttachBlip():SetBlipColour(1)
end