-- level.lua

local Game = require 'common.game'
local Play = require 'gamestates.play'
-- local Follow = require 'entities.follow'
local HUD = require 'common.hud'

local Level = Game:addState('Level')

function Level:enteredState()
  Log.info('Entered state "Level"')
  self.swallowTouch = false

  self.hud = HUD:new(self.world)
  self:createCamera(conf.width,conf.height,0,0,0,0,conf.squareSize)

  self:newBackground()
  self:createBasicHandlers()
end

function Level:exitedState()
  -- Just in case Level is popped up but Play is
  -- not exited (and Beholder.reset is not called)
  Beholder.stopObserving(self)
end

function Level:loadWorld()
  local filename = string.format('resources/maps/map%02d.lua',self.state.csi)

  local data,len = assert(love.filesystem.read('resources/puzzles.ser'))
  return assert(Binser.deserialize(data))
end

function Level:savePuzzleState()
  Beholder.trigger('SaveState')
  -- XXX write game state now or when the game quits?
  self:writeGameState()
end

function Level:drawAfterCamera()
  self.hud:draw()
end

function Level:onGotoMainMenu()
  self:gotoState('Start')
end

function Level:onResetLevel()
  self:resetCurrentLevelState()
  self:gotoState('Play')
end

function Level:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    Beholder.trigger('GotoMainMenu')
  elseif key == 'r' then
    Beholder.trigger('ResetGame')
  elseif key == 'p' then
    -- self:pushState('Paused')
  end
  if conf.build == 'debug' then
    if key == 'd' then
      self:pushState('Debug')
    end
  end
end

return Level
