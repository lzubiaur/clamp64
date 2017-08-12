local Game = require 'common.game'
local Entity = require 'entities.base.entity'
local Play = require 'gamestates.play'

local Win = Game:addState('Win')

function Win:enteredState(score)
  Log.debug('Entered state Win')
  -- Beholder.trigger('Win')
  Log.info('Score:',score.new,'old:',score.old,'diamonds:',score.diamonds)
  self.hud:gotoState('Win',score)
end

function Win:exitedState()
  self:collectGarbage()
end

function Win:update(dt)
  -- Only update HUD
  self.hud:update(dt)
end

-- Disable touch controls (e.g. moving player) but still call
-- normal touches (e.g. HUD)
function Win:pressed(x,y)
  Game.pressed(self,x,y)
end

function Win:released(x,y)
  Game.released(self,x,y)
end

function Win:keypressed(key, scancode, isrepeat)
  if key == 'space' or key == 'escape' then
    Beholder.trigger('NextLevel')
  end
end

return Win
