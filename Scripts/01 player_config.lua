local default_config= {
	speed_mod= {type= "M", speed=800},
	tilt= 1.5,
	mini= 0,
	special_keys_on= true,
	keys= {
		speed= {small= {"DeviceButton_g", "DeviceButton_h"},
						big= {"DeviceButton_f", "DeviceButton_j"}},
		tilt= {small= {"DeviceButton_v", "DeviceButton_n"},
						big= {"DeviceButton_c", "DeviceButton_m"}},
		mini= {small= {"DeviceButton_t", "DeviceButton_y"},
						big= {"DeviceButton_unused", "DeviceButton_unused"}},
		change_speed_type= "DeviceButton_b",
		save_exit= "DeviceButton_1",
		toggle_keys= "DeviceButton_=",
	},
	player_number= PLAYER_1,
	last_nps= 4,
	last_score= .95,
	easier_threshold= .9,
	harder_threshold= .98,
	style= "",
	message= "Kyzentun's a lazy fuck, so if you're editing Save/drunken_config.lua, only player_number is really used.",
}

player_config= create_setting("Drunken config", "drunken_config.lua", default_config, -1)
player_config:load()
player_config:set_dirty()
player_config:save()

drunk_players= {}

local slot_conversion= {
	[PLAYER_1]= "ProfileSlot_Player1", [PLAYER_2]= "ProfileSlot_Player2",}
function pn_to_profile_slot(pn)
	return slot_conversion[pn] or "ProfileSlot_Invalid"
end

function calc_nps(pn, song_len, steps)
	local radar= steps:GetRadarValues(pn)
	local notes= radar:GetValue("RadarCategory_TapsAndHolds") +
		radar:GetValue("RadarCategory_Jumps") +
		radar:GetValue("RadarCategory_Hands")
	return notes / song_len
end

function load_player(pn)
	player_config:load(pn_to_profile_slot(pn))
	local conf= player_config:get_data(pn_to_profile_slot(pn))
	local styles= GAMEMAN:GetStylesForGame(GAMESTATE:GetCurrentGame():GetName())
	local found_style= false
	local first_compat= false
	for i, style in ipairs(styles) do
		if not first_compat and style:GetStyleType() == "StyleType_OnePlayerOneSide" then
			first_compat= style
		end
		if style:GetStyleType():find("OnePlayer")
		and style:GetName() == conf.style then
			found_style= style
		end
	end
	if not found_style then found_style= first_compat end
	GAMESTATE:SetCurrentStyle(found_style, pn)
	conf.style= found_style:GetName()
	local profile= PROFILEMAN:GetProfile(pn)
	drunk_players[pn]= {
		last_score= conf.last_score,
		last_nps= conf.last_nps}
	if profile then
		drunk_players[pn].proguid= profile:GetGUID()
	end
end

function SaveProfileCustom(profile, dir)
	local pn= false
	for i, drunkard in pairs(drunk_players) do
		if drunkard.proguid == profile:GetGUID() then pn= i end
	end
	if pn then
		local slot= pn_to_profile_slot(pn)
		player_config:get_data(slot).last_score= drunk_players[pn].last_score
		player_config:get_data(slot).last_nps= drunk_players[pn].last_nps
		player_config:set_dirty(slot)
		player_config:save(slot)
	end
end
