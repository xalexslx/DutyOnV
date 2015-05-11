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

DutyUtils = {}

function DutyUtils.Debug(text, ...)
	local args = {...}
	if DutyConfig.Core.DebugMessagesEnabled then
		print(text, unpack(args))
	end
end

function DutyUtils.ParseColorCode(text)
	return string.gsub(text, "<C=([A-Z_]+)>(.*)</C>","<C>~HUD_COLOUR_%1~</C>%2<C>~HUD_COLOUR_WHITE~</C>")
end

function DutyUtils.NotifyAboveMap(text, display_time)
	natives.UI._0x202709F4C58A0424("STRING")
	natives.UI._ADD_TEXT_COMPONENT_STRING(DutyUtils.ParseColorCode(text))
	natives.UI._0x2ED7843F8F801023(display_time or 2000, true)
end

function DutyUtils.GetClassName(name)
	-- Capitalise the first letter of each word
	local function tchelper(first, rest)
		return first:upper()..rest:lower()
	end
	
	return string.gsub(name, "(%a)([%w']*)", tchelper):gsub('%W','')
end

function DutyUtils.LoadJobs()
	local success, dir_list, _file_list = file.FindFiles("GTALua/addons/DutyOnV/jobs/*")
	local jobList = {}
	if not success then
		print("Failed to get directory list for GTALua/addons/DutyOnV/jobs/")
		print("Unable to load jobs!")
		return jobList
	else
		for _,dir in pairs(dir_list) do
			if dir:sub(1,1) == "_" then
				-- Nothing
			else
				table.insert(jobList, dir)
				include("../jobs/"..dir.."/job.lua")
			end
		end
		return jobList
	end
end

