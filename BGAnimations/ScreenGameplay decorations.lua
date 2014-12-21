local pn= GAMESTATE:GetEnabledPlayers()[1]
local conf= player_config:get_data(pn_to_profile_slot(pn))
local prefoptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
local poptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Song")
local coptions= GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Current")
local pstats= STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local screen_gameplay= false
local bpm_disp= false
local speed_disp= false
local tilt_disp= false
local mini_disp= false
prefoptions:FailSetting("FailType_Off")
poptions:FailSetting("FailType_Off")
coptions:FailSetting("FailType_Off")
local transing_out= false
local function trans(sn)
	transing_out= true
	trans_new_screen(sn)
end

local function calc_approach(amount)
	-- arrive at new value in .01 seconds
	return math.abs(amount * 10)
end

local function update_speed()
	speed_disp:settext("Speed: " ..conf.speed_mod.type .. conf.speed_mod.speed)
end

local function round_speed(speed)
	local dig= 0
	if conf.speed_mod.type == "X" then dig= 2 end
	return math.round(speed, dig)
end

local function apply_mod(func, amount, approach)
	poptions[func](poptions, amount, approach)
	prefoptions[func](prefoptions, amount, approach)
end

local function adjust_speed(amount, ops)
	if conf.speed_mod.type == "X" then
		amount= amount * .01
	end
	if conf.speed_mod.speed + amount > 0 then
		conf.speed_mod.speed= round_speed(conf.speed_mod.speed + amount)
	end
	update_speed()
	local approach= calc_approach(amount)
	if conf.speed_mod.type == "M" then
		apply_mod("MMod", conf.speed_mod.speed, approach)
	elseif conf.speed_mod.type == "C" then
		apply_mod("CMod", conf.speed_mod.speed, approach)
	else
		apply_mod("XMod", conf.speed_mod.speed, approach)
	end
end

local function adjust_tilt(amount)
	conf.tilt= math.round(conf.tilt + amount, 2)
	tilt_disp:settext("Tilt: " .. conf.tilt)
	apply_mod("Tilt", conf.tilt, calc_approach(amount))
end

local function adjust_mini(amount)
	conf.mini= math.round(conf.mini + amount, 2)
	mini_disp:settext("Mini: " .. conf.mini)
	apply_mod("Mini", conf.mini, calc_approach(amount))
end

local function input(event)
	if event.type == "InputEventType_Release" then return end
	local dev_button= event.DeviceInput.button
	if not conf.special_keys_on then
		if dev_button == conf.keys.toggle_keys then
			conf.special_keys_on= true
		end
	else
		if dev_button == conf.keys.toggle_keys then
			conf.special_keys_on= false
		elseif dev_button == conf.keys.save_exit then
			break_requested= false
			trans("ScreenProfileSave")
		elseif dev_button == conf.keys.take_break then
			break_requested= true
			trans("ScreenProfileSave")
		elseif dev_button == conf.keys.easier then
			drunk_players[pn].last_score= 0
			trans("ScreenDrunkenPick")
		elseif dev_button == conf.keys.same then
			drunk_players[pn].last_score=
				(conf.easier_threshold + conf.harder_threshold) / 2
			trans("ScreenDrunkenPick")
		elseif dev_button == conf.keys.harder then
			drunk_players[pn].last_score= 1
			trans("ScreenDrunkenPick")
		elseif dev_button == conf.keys.change_speed_type then
			if conf.speed_mod.type == "M" then
				conf.speed_mod.type= "C"
				poptions:CMod(conf.speed_mod.speed)
				coptions:CMod(conf.speed_mod.speed)
			elseif conf.speed_mod.type == "C" then
				local bpm= screen_gameplay:GetTrueBPS(pn) * 60
				conf.speed_mod.type= "X"
				conf.speed_mod.speed= round_speed(conf.speed_mod.speed / bpm)
				poptions:XMod(conf.speed_mod.speed)
				coptions:XMod(conf.speed_mod.speed)
			else
				local bpm= screen_gameplay:GetTrueBPS(pn) * 60
				conf.speed_mod.type= "M"
				conf.speed_mod.speed= round_speed(conf.speed_mod.speed * bpm)
				poptions:MMod(conf.speed_mod.speed)
				coptions:MMod(conf.speed_mod.speed)
			end
			update_speed()
		elseif dev_button == conf.keys.speed.small[1] then
			adjust_speed(-5)
		elseif dev_button == conf.keys.speed.small[2] then
			adjust_speed(5)
		elseif dev_button == conf.keys.speed.big[1] then
			adjust_speed(-100)
		elseif dev_button == conf.keys.speed.big[2] then
			adjust_speed(100)
		elseif dev_button == conf.keys.tilt.small[1] then
			adjust_tilt(-.1)
		elseif dev_button == conf.keys.tilt.small[2] then
			adjust_tilt(.1)
		elseif dev_button == conf.keys.tilt.big[1] then
			adjust_tilt(-1)
		elseif dev_button == conf.keys.tilt.big[2] then
			adjust_tilt(1)
		elseif dev_button == conf.keys.mini.small[1] then
			adjust_mini(-.1)
		elseif dev_button == conf.keys.mini.small[2] then
			adjust_mini(.1)
		elseif dev_button == conf.keys.mini.big[1] then
			adjust_mini(-1)
		elseif dev_button == conf.keys.mini.big[2] then
			adjust_mini(1)
		end
	end
end

local function update(self)
	bpm_disp:settext("BPM: " .. math.round(screen_gameplay:GetTrueBPS(pn) * 60))
	if not transing_out then
		drunk_players[pn].last_score= pstats:GetActualDancePoints() /
			pstats:GetPossibleDancePoints()
	end
end

return Def.ActorFrame{
	Def.ActorFrame{
		Name= "Kaede", OnCommand= function(self)
			screen_gameplay= SCREENMAN:GetTopScreen()
			screen_gameplay:AddInputCallback(input)
			adjust_speed(0)
			adjust_tilt(0)
			adjust_mini(0)
			self:SetUpdateFunction(update)
		end
	},
	Def.BitmapText{
		Name= "Himawari", Font= "Common Normal", InitCommand= function(self)
			bpm_disp= self
			self:xy(_screen.cx, 20)
			color_text(self)
		end
	},
	Def.BitmapText{
		Name= "Sakurako", Font= "Common Normal", InitCommand= function(self)
			mini_disp= self
			self:xy(_screen.cx*.5, 20)
			color_text(self)
		end
	},
	Def.BitmapText{
		Name= "Ayano", Font= "Common Normal", InitCommand= function(self)
			tilt_disp= self
			self:xy(_screen.cx*1.5, 20)
			color_text(self)
		end
	},
	Def.BitmapText{
		Name= "Chizuru", Font= "Common Normal", InitCommand= function(self)
			speed_disp= self
			self:xy(_screen.cx, 44)
			color_text(self)
		end
	},
	Def.BitmapText{
		Name= "Akane", Font= "Common Normal", InitCommand= function(self)
			self:xy(_screen.cx, _screen.h - 20)
			self:settext("NPS: " .. math.round(drunk_players[pn].last_nps, 2))
			color_text(self)
		end
	},
}
