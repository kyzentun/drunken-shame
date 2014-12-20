GAMESTATE:Reset()
local last_input_time= GetTimeSinceStart()
local instructions= false
PREFSMAN:SetPreference("ComboContinuesBetweenSongs", true)
if confetti_config:get_data().perm_on then
	activate_confetti("perm", true)
end
GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")

local function move_instructions(amount)
	instructions:stoptweening()
	instructions:linear(.25)
	instructions:addy(amount)
end

local function go_to_pick()
	local pn= player_config:get_data().player_number
	GAMESTATE:JoinInput(pn)
	GAMESTATE:LoadProfiles()
	load_player(pn)
	trans_new_screen("ScreenDrunkenPick")
end

local function input(event)
	last_input_time= GetTimeSinceStart()
	if event.type == "InputEventType_Release" then return end
	if not event.PlayerNumber then return end
	if event.GameButton:find("Up") or event.button:find("Up") then
		move_instructions(32)
	elseif event.GameButton:find("Down") or event.button:find("Down") then
		move_instructions(-32)
	elseif event.GameButton == "Start" then
		go_to_pick()
	end
end

local function update()
	if GetTimeSinceStart() - last_input_time > 15 then
		go_to_pick()
	end
end

return Def.ActorFrame{
	Def.ActorFrame{
		Name= "Akari", OnCommand= function(self)
			self:SetUpdateFunction(update)
			SCREENMAN:GetTopScreen():AddInputCallback(input)
		end
	},
	Def.BitmapText{
		Name= "Yui", Font= "Common Normal", InitCommand= function(self)
			instructions= self
			local text= "lol, you deleted the readme"
			local read_fname= THEME:GetCurrentThemeDirectory() .. "README.md"
			if FILEMAN:DoesFileExist(read_fname) then
				local readme= RageFileUtil.CreateRageFile()
				if readme:Open(read_fname, 1) then
					text= readme:Read()
				else
					text= "lol, couldn't read the readme"
				end
			end
			self:xy(_screen.cx, 20)
			self:vertalign(top)
			self:wrapwidthpixels(_screen.w - 32)
			self:vertspacing(-8)
			self:settext(text)
			color_text(self)
		end
	}
}
