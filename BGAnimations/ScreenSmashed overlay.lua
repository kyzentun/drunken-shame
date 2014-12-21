local pn= GAMESTATE:GetEnabledPlayers()[1]
local conf= player_config:get_data(pn_to_profile_slot(pn))
local screen_start= GetTimeSinceStart()

local function input(event)
	if event.type == "InputEventType_Release" then return end
	if event.GameButton == "Start"
	and GetTimeSinceStart() - screen_start > 15 then
		drunk_players[pn].last_score=
			(conf.easier_threshold + conf.harder_threshold) / 2
		trans_new_screen("ScreenDrunkenPick")
	end
end

local sober_text= false
local function update(self)
	sober_text:distort(math.sin(GetTimeSinceStart() % (math.pi*2)))
end

return Def.ActorFrame{
	Def.ActorFrame{
		Name= "Matsumoto", OnCommand= function(self)
			self:SetUpdateFunction(update)
			SCREENMAN:GetTopScreen():AddInputCallback(input)
		end,
		Def.BitmapText{
			Name= "NishiGaki", Font= "Common Normal", InitCommand= function(self)
				sober_text= self
				self:xy(_screen.cx, _screen.cy)
				self:settext("Sobering up....")
				color_text(self)
			end
}}}
