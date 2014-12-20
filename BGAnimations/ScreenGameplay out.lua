return Def.ActorFrame{
	Def.Actor{
		Name= "Mari", StartTransitioningCommand= function(self)
			local scr= SCREENMAN:GetTopScreen()
			scr:linear(4)
			scr:zoom(0)
			self:sleep(4)
		end
	}
}
