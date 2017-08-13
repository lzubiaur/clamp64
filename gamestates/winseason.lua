local Game   = require 'common.game'

local WinSeason = Game:addState('WinSeason')

function WinSeason:enteredState()
  Log.info('Entered state WinSeason')
  self.hud:gotoState('WinSeason')
end

function WinSeason:update(dt)
  -- Only update HUD
  self.hud:update(dt)
end

-- Disable touch controls (e.g. moving player) but still call
-- normal touches (e.g. HUD)
function WinSeason:pressed(x,y)
  Game.pressed(self,x,y)
end

function WinSeason:released(x,y)
  Game.released(self,x,y)
end

function WinSeason:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    self:gotoState('Start')
  end
end

return WinSeason
