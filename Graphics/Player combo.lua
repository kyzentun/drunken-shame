local c
local player = Var "Player"
local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt")
local Pulse = THEME:GetMetric("Combo", "PulseCommand")
local PulseLabel = THEME:GetMetric("Combo", "PulseLabelCommand")

local NumberMinZoom = THEME:GetMetric("Combo", "NumberMinZoom")
local NumberMaxZoom = THEME:GetMetric("Combo", "NumberMaxZoom")
local NumberMaxZoomAt = THEME:GetMetric("Combo", "NumberMaxZoomAt")

local LabelMinZoom = THEME:GetMetric("Combo", "LabelMinZoom")
local LabelMaxZoom = THEME:GetMetric("Combo", "LabelMaxZoom")

local prev_combo= -1
local confetti_conf= confetti_config:get_data()

local t = Def.ActorFrame {
	InitCommand=cmd(vertalign,bottom),
	LoadFont( "Combo", "numbers" ) .. {
		Name="Number",
		OnCommand = THEME:GetMetric("Combo", "NumberOnCommand")
	},
	LoadFont("Common Normal") .. {
		Name="Label",
		OnCommand = THEME:GetMetric("Combo", "LabelOnCommand")
	},
	
	InitCommand = function(self)
		c = self:GetChildren()
		c.Number:visible(false)
		c.Label:visible(false)
	end,
	TwentyFiveMilestoneCommand=function(self,parent)
		(cmd(skewy,-0.125;decelerate,0.325;skewy,0))(self)
	end,
	ToastyAchievedMessageCommand=function(self,params)
		if params.PlayerNumber == player then
			(cmd(thump,2;effectclock,'beat'))(self)
		end
	end,
	ComboCommand=function(self, param)
		-- confetti logic
		if confetti_conf.combo_reward > 0 then
			if prev_combo == -1 then
				prev_combo= math.floor((param.Combo or 0) /
						confetti_conf.combo_reward) * confetti_conf.combo_reward
			end
			if param.Combo then
				if param.Combo >= prev_combo + confetti_conf.combo_reward then
					prev_combo= math.floor(param.Combo / confetti_conf.combo_reward) *
						confetti_conf.combo_reward
					activate_confetti("combo", true, player)
				end
			else
				prev_combo= 0
			end
		end
		local iCombo = param.Misses or param.Combo
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false)
			c.Label:visible(false)
			return
		end

		local labeltext = ""
		if param.Combo then
			labeltext = "COMBO"
-- 			c.Number:playcommand("Reset")
		else
			labeltext = "MISSES"
-- 			c.Number:playcommand("Miss")
		end
		c.Label:settext( labeltext )
		c.Label:visible(false)

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom )
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom )
		
		param.LabelZoom = scale( iCombo, 0, NumberMaxZoomAt, LabelMinZoom, LabelMaxZoom )
		param.LabelZoom = clamp( param.LabelZoom, LabelMinZoom, LabelMaxZoom )
		
		c.Number:visible(true)
		c.Label:visible(true)
		c.Number:settext( string.format("%i", iCombo) )
		-- FullCombo Rewards
		if param.FullComboW1 then
			c.Number:diffuse(color("#00aeef"))
			c.Number:glowshift()
		elseif param.FullComboW2 then
			c.Number:diffuse(color("#fff568"))
			c.Number:glowshift()
		elseif param.FullComboW3 then
			c.Number:diffuse(color("#a4ff00"))
			c.Number:stopeffect()
		elseif param.Combo then
			c.Number:diffuse(Color("White"))
-- 			c.Number:diffuse(PlayerColor(player))
			c.Number:stopeffect()
			c.Label:diffuse(Color("White"))
			c.Label:diffusebottomedge(color("0.5,0.5,0.5,1"))
		else
			c.Number:diffuse(color("#ff0000"))
			c.Number:stopeffect()
			c.Label:diffuse(Color("Red"))
			c.Label:diffusebottomedge(color("0.5,0,0,1"))
		end
		-- Pulse
		Pulse( c.Number, param )
		PulseLabel( c.Label, param )
	end
}

return t
