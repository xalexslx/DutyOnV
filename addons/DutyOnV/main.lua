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

-- Core
include("core/DutyOnV.lua")
include("core/DutyMenu.lua")
include("core/DutyUtils.lua")
include("core/DutyJob.lua")

-- Configuration
include("config/DutyOnV.lua")

-- Jobs
local jobList = DutyUtils:LoadJobs()

-- Run function
function DutyOnVST:Run()
	-- Create object
	local duty = DutyOnV()
	-- Load Jobs
	for _,job_name in pairs(jobList) do
		duty:LoadJob(job_name)
	end
	-- Script Loop
	while self:IsRunning() do
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
	self:Reset()
end
 
-- Register Thread
DutyOnVST:Register()
