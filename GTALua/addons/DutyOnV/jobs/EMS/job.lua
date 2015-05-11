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
class 'Ems'(DutyJob)

-- CTor
function Ems:__init()
	DutyJob.__init(self)
	self._type		= "Ems"
	self.name		= "Paramedic"
end

-- Ems:CheckPlayerRequirements()
-- 
-- This method is called to check if the player has all requirements to receive
-- an active event (eg. Ems call, fire event, ems call, garbage truck, etc).
-- 
-- Good examples of checking on this method is checking if the player meet
-- requirements such as specific model/vehicle/etc.
--
-- Return true or false according to your custom rules.
-- 
function Ems:CheckPlayerRequirements()
	return true
end

-- Ems:SetOnDuty(flag)
-- 
-- This method is called when the player changed the 'on duty' state.
-- 
function Ems:SetOnDuty(flag)
	self.onDuty = flag
end

-- Ems:CanExecuteRandomEvents()
-- 
-- This method is called to check if your job want to dispatch active events.
-- Active events are events which player normally needs to act on them, like
-- Ems calls, etc.
--
-- Return true or false according to your custom rules.
-- 
function Ems:CanExecuteActiveEvents()
	return self.onDuty
end

-- Ems:CreateActiveEvent()
-- 
-- This method is called when the user wants a new active event to be created.
-- 
-- Return true if your job created an event, false otherwise.
-- 
function Ems:CreateActiveEvent()
	return true
end

-- Ems:CanExecuteRandomEvents()
-- 
-- This method is called to check if your job want to dispatch random world events.
-- The difference between this and CheckPlayerRequirements() is that you doesn't
-- need to be 'on duty' to see any random event such as peds being robbed or cars
-- crashing, etc.
--
-- Return true or false according to your custom rules.
-- 
function Ems:CanExecuteRandomEvents()
	return true
end

-- Ems:CreateRandomEvent()
-- 
-- This method is called when the user wants a new random event to be created.
--
-- Return true if your job created an event, false otherwise.
-- 
function Ems:CreateRandomEvent()
	return false
end

-- Ems:Tick()
-- 
-- This method is always executed every tick. Use this method to check the current
-- state of your previously created active or random events.
-- 
function Ems:Tick()
	
end

-- Ems:Terminate()
-- 
-- This method is called right before all scripts get killed. Please cleanup everything.
-- 
function Ems:Terminate()
	DutyJob:Terminate()
end
