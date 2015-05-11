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
class 'DutyOnV'(Object)

-- CTor
function DutyOnV:__init()
	self._type		= "DutyOnV"
	self.active		= true
	self.jobs		= {}
	self.delays		= {}
	self.activeJob	= nil
	self.menu		= nil
	
	-- Delays
	self.delays['lastEventHandling']	= 0
	self.delays['lastActiveEvent'] 		= 0
	self.delays['lastRandomEvent'] 		= 0
	
	-- Init Menu
	self:CreateMenu()
end

-- Terminate
function DutyOnV:Terminate()
	
end

function DutyOnV:IsActive()
	return self.active
end

-- Loop Function
function DutyOnV:OnLoop()

	self:UpdateMenuOptions()
	self.menu:Update()
	if IsKeyDown(DutyConfig.Core.KeyDefToggleActivate) then
		if self.menu:IsClosed() then
			self.menu:Open()
		else
			self.menu:Close()
		end
	end
	
	-- Check if the script is activated
	if self:IsActive() then
		
		-- Minimum delay of 1 second between event handling
		if self.delays['lastEventHandling'] < game.GetTime() then
			self.delays['lastEventHandling'] = game.GetTime() + 1000
			
			-- Active Events
			self:ExecuteActive(false)
			
			-- Random Events
			self:ExecuteRandom(false)
		end
		
		-- Tick
		for _,job in pairs(self.jobs) do
			job:Tick()
		end
	end
end

function DutyOnV:ExecuteActive(skipDelay)
	if self.activeJob ~= nil then
		if (skipDelay or self.delays['lastActiveEvent'] < game.GetTime()) and self.activeJob:CheckPlayerRequirements() and self.activeJob:CanExecuteActiveEvents() then
			-- Try to create an active event
			if self.activeJob:CreateActiveEvent() then
				self.delays['lastActiveEvent'] = game.GetTime() + (DutyConfig.Core.MinDelayActiveEvents * 1000)
			end
		end
	end
end

function DutyOnV:ExecuteRandom(skipDelay)
	local job = self.jobs[math.random(#self.jobs)]
	if (skipDelay or self.delays['lastRandomEvent'] < game.GetTime()) and job:CanExecuteRandomEvents() then
		if job:CreateRandomEvent() then
			self.delays['lastRandomEvent'] = game.GetTime() + (DutyConfig.Core.MinDelayRandomEvents * 1000)
		end
	end
end

function DutyOnV:CreateMenu()
	self.menu = gui.DutyMenu(self, {
		Title = "DutyOnV - Select Job",		-- title of the menu
		x = 0.03, 							-- x-coordinate, 0.0 = left, 1.0 = right
		y = 0.02, 							-- y-coordinate, 0.0 = top, 1.0 = bottom
		Width = 0.23, 						-- width of the whole menu
		TitleHeight = 0.05, 				-- height of the title box
		OptionHeight = 0.03, 				-- height of an option
		CanBeClosed = true 					-- allow close
	})
	
	self.menu:Close()
end

function DutyOnV:UpdateMenuOptions()
	-- Clear
	self.menu:ClearOptions()
	-- Populate Jobs
	if self:IsActive() then
		self.menu:AddOption("Disable Plugin", "OnMenuCallback", 0)
		
		-- Job Listening just when plugin is active
		for i,job in pairs(self.jobs) do
			if job:IsOnDuty() then
				self.menu:AddOption(job:GetName().." [Active]", "OnMenuCallback", i)
			else
				self.menu:AddOption(job:GetName(), "OnMenuCallback", i)
			end
		end
	else
		self.menu:AddOption("Enable Plugin", "OnMenuCallback", 0)
	end
	
end

function DutyOnV:OnMenuCallback(menu, option)
	DutyUtils.Debug("selected option...", option)
	
	if option == 0 then
		self.active	= not self.active
		
		if self:IsActive() then
			DutyUtils.NotifyAboveMap("<C=BLUE>DutyOnV</C> Activated.")
		else
			DutyUtils.NotifyAboveMap("<C=BLUE>DutyOnV</C> Disabled.")
			
			-- Disable all jobs
			for i,job in pairs(self.jobs) do
				job:SetOnDuty(false)
			end
		end
	else
		for i,job in pairs(self.jobs) do
			if i == option then
				job:SetOnDuty(not job:IsOnDuty())
				if job:IsOnDuty() then
					DutyUtils.NotifyAboveMap("You're on duty as: "..job:GetName())
					menu:Close()
				else
					DutyUtils.NotifyAboveMap("You're no longer on duty as: "..job:GetName())
				end
			else
				job:SetOnDuty(false)
			end
		end
	end
end

function DutyOnV:LoadJob(name)
	local classname = DutyUtils.GetClassName(name)
	
	DutyUtils.Debug("Loading job "..classname)
	
	local job = _G[classname]()
	table.insert(self.jobs, job)
end
