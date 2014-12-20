local stepstype= GAMESTATE:GetCurrentStyle(pn):GetStepsType()
local pn= GAMESTATE:GetEnabledPlayers()[1]

if not drunk_all_songs then
	drunk_all_songs= SONGMAN:GetAllSongs()
	drunk_min_nps= 20
	drunk_max_nps= 0
	for i, song in ipairs(drunk_all_songs) do
		local steps= song:GetStepsByStepsType(stepstype)
		local song_len= song:GetLastSecond() - song:GetFirstSecond()
		for i, shart in ipairs(steps) do
			local nps= calc_nps(pn, song_len, shart)
			drunk_min_nps= math.min(drunk_min_nps, nps)
			drunk_max_nps= math.max(drunk_max_nps, nps)
		end
	end
end

-- ScreenGameplay will crash if you run out of stage tokens.  Songs can cost
-- up to three tokens.
GAMESTATE:AddStageToPlayer(pn)
GAMESTATE:AddStageToPlayer(pn)
GAMESTATE:AddStageToPlayer(pn)

local num_songs= #drunk_all_songs
local last_score= drunk_players[pn].last_score
local last_nps= drunk_players[pn].last_nps
local conf= player_config:get_data(pn_to_profile_slot(pn))

local last_nps_for_easier= math.max(last_nps, drunk_min_nps + 1)
local last_nps_for_harder= math.min(last_nps, drunk_max_nps - 1)

local function easier_picker(nps)
	return nps <= last_nps_for_easier and nps >= last_nps_for_easier - 2
end

local function harder_picker(nps)
	return nps >= last_nps_for_harder and nps <= last_nps_for_harder + 2
end

local function similar_picker(nps)
	return nps >= last_nps - 1 and nps <= last_nps + 1
end

local picker= similar_picker
if last_score <= conf.easier_threshold then picker= easier_picker
elseif last_score >= conf.harder_threshold then picker= harder_picker
end

local function try_song(song)
	if not song then return false end
	local steps= song:GetStepsByStepsType(stepstype)
	local song_len= song:GetLastSecond() - song:GetFirstSecond()
	for i, shart in ipairs(steps) do
		local nps= calc_nps(pn, song_len, shart)
		if picker(nps) then
			return shart, nps
		end
	end
	return false
end

local tries= 0
local tries_text= false
local matched= false
local function update(self)
	local tick_start= GetTimeSinceStart()
	while not matched and GetTimeSinceStart() - tick_start < .02 do
		local song= drunk_all_songs[math.random(1, num_songs)]
		local steps, nps= try_song(song)
		if steps then
			drunk_players[pn].last_nps= nps
			GAMESTATE:SetCurrentSong(song)
			GAMESTATE:SetCurrentSteps(pn, steps)
			matched= true
			trans_new_screen("ScreenGameplay")
		end
		tries= tries + 1
	end
	tries_text:settext(tries)
	if tries > num_songs then
		local cant= "Can't find a song within the allowed nps range: " ..
			last_nps - 1 .. ", " .. last_nps + 1
		lua.ReportScriptError(cant)
		tries_text:settext(cant)
		trans_new_screen("ScreenExit")
	end
end

return Def.ActorFrame{
	Def.ActorFrame{
		Name= "Kyouko", OnCommand= function(self)
			self:SetUpdateFunction(update)
		end,
		Def.BitmapText{
			Name= "Chinatsu", Font= "Common Normal", InitCommand= function(self)
				tries_text= self
				color_text(self)
				self:xy(_screen.cx, _screen.cy)
			end
		}
	}
}
