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

-- Random
math.randomseed(os.time())

-- Create a ScriptThread
DutyOnVST = ScriptThread("DutyOnV")

-- GTALua extension
include("core/game/Blip.lua")
include("core/game/Ped.lua")

-- Core
include("core/DutyOnV.lua")
include("core/DutyMenu.lua")
include("core/DutyUtils.lua")
include("core/DutyJob.lua")

-- Configuration
include("config/DutyOnV.lua")

-- Jobs
local jobList 	= DutyUtils:LoadJobs()
local duty		= nil

-- Run function
function DutyOnVST:Run()
	-- Create object
	duty = DutyOnV()
	-- Load Jobs
	for _,job_name in pairs(jobList) do
		duty:LoadJob(job_name)
	end
	-- Script Loop
	while self:IsRunning() do
		-- Entity checking
		blipListener.Tick()
		-- Run DutyOnV loop
		duty:OnLoop()
		-- Wait
		self:Wait(0)
	end
	-- Destroy
	duty:Terminate()
	duty = nil
end

-- OnError
function DutyOnVST:OnError()
	print("Oh no! DutyOnV caused an error!")
	self:Kill()
end
 
-- Register Thread
DutyOnVST:Register()


-- DutyConsole
DutyConsole = {}

function DutyConsole.RandomEventCommand(...)
	if duty ~= nil then
		print("Executing random event...")
		duty:ExecuteRandom(true)
		print("")
	end
end
console.RegisterCommand("duty_event_random", DutyConsole.RandomEventCommand)
