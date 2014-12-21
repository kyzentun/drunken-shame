return Def.ActorFrame{
	Def.Actor{
		Name= "Tomoko", StartTransitioningCommand= function(self)
			local scr= SCREENMAN:GetTopScreen()
			scr:xy(_screen.cx, _screen.cy)
			scr:zoom(0)
			scr:linear(4)
			scr:zoom(1)
			scr:xy(0, 0)
			self:sleep(4)
		end
	}
}
