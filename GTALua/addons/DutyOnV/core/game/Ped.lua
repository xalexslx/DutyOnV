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


function Ped.AddRelationshipGroup(name)
	local group_hash_mb = CMemoryBlock(4)
	local group_hash	= 0
	
	natives.PED.ADD_RELATIONSHIP_GROUP(name, group_hash_mb)
	
	group_hash = group_hash_mb:ReadDWORD32(0)
	group_hash_mb:Release()
	
	return group_hash
end

function Ped:SetRelationshipGroupHash(hash)
	self:_CheckExists()
	natives.PED.SET_PED_RELATIONSHIP_GROUP_HASH(self.ID, hash)
end
