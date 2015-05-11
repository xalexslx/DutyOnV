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

blipListener = {}
blipListener.entityList = {}


function blipListener.AddEntity(entity)
	table.insert(blipListener.entityList, entity)
end

function blipListener.Tick()
	local index	= 1 
	local size	= #blipListener.entityList
	
	while index <= size do
	
		local entity = blipListener.entityList[index]
		local delete = false
		
		if entity:Exists() and entity:GetBlip() and entity:GetBlip():Exists() then
			
			-- Dead Ped
			if entity:IsPed() and Ped(entity.ID):IsDead() then
				entity:GetBlip():Delete()
				delete = true
			end
			
		else
			delete = true
		end
	
		if delete then
			blipListener.entityList[index]	= blipListener.entityList[size] 
			blipListener.entityList[size]	= nil 
			size = size - 1 
		else
			index = index + 1
		end
	end
end

function Blip:SetBlipColour(i)
	self:_CheckExists()
	natives.UI.SET_BLIP_COLOUR(self.ID, i)
end

