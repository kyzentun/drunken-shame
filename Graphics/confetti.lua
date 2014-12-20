return Def.ActorFrame{
	Def.Quad{
		Name= "part", InitCommand= cmd(setsize, confetti_size(), confetti_size())
	},
	Name= "confetti", InitCommand= cmd(visible, false),
	TriggerCommand= function(self)
		self:stoptweening()
		self:hibernate(confetti_hibernate())
		self:queuecommand("Fall")
	end,
	HideCommand= cmd(visible, false),
	FallCommand= function(self)
		self:stoptweening()
		self:visible(true)
		self:xy(confetti_x(), confetti_fall_start())
		self:linear(confetti_fall_time())
		self:y(confetti_fall_end())
		local part= self:GetChild("part")
		part:setsize(confetti_size(), confetti_size())
		self:diffuse(confetti_color())
		self:spin()
		self:effectmagnitude(confetti_spin(), confetti_spin(), confetti_spin())
		if confetti_refall() then
			self:queuecommand("Fall")
		else
			self:queuecommand("Hide")
		end
	end
}
