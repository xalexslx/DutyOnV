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

class 'DutyMenu'(GUISimpleMenu)

-- CTor
function DutyMenu:__init()
	GUISimpleMenu.__init(self)
end

function DutyMenu:ClearOptions()
	self.Options = {}
end

function DutyMenu:SetTitle(title)
	self.Title = title
end

-- Update
function DutyMenu:Update()
	-- Closed-Check
	if self.Closed then
		return
	end
	
	--
	local x, y = self.x, self.y
	local title_color = Color(0,0,0)
	local option_color = Color(0,0,0,150)
	local option_color_selected = Color(0,0,0,190)
	
	-- Title
	gui.DrawRect(x, y, self.Width, self.TitleHeight, title_color)
	gui.DrawText(x + 0.003, y + 0.003, self.Title, {
		TextScale = 0.8
	})
	y = y + self.TitleHeight	

	-- Objects
	for k,v in pairs(self.Options) do		
		if k == self.ActiveIndex then
			gui.DrawRect(x, y, self.Width, self.OptionHeight, option_color_selected)
			gui.DrawText(x + 0.002, y, v.Text, {
				TextScale = 0.6
			})
		else
			gui.DrawRect(x, y, self.Width, self.OptionHeight, option_color)
			gui.DrawText(x + 0.002, y, v.Text, {
				TextScale = 0.5
			})
		end
		
		y = y + self.OptionHeight
	end
	
	-- Controls
	self:UpdateControls()
end

-- CTor
function gui.DutyMenu(thread, settings)
	local data = DutyMenu()
	
	-- Settings
	data.Thread = thread
	data.Title = settings.Title or "Simple Menu"
	data.x = settings.x or 0
	data.y = settings.y or 0
	data.Width = settings.Width or 0.2
	data.OptionHeight = settings.OptionHeight or 0.03
	data.TitleHeight = settings.TitleHeight or 0.05
	data.CanBeClosed = settings.CanBeClosed or true
	data.Closed = settings.IsOpen or true
	
	return data
end
