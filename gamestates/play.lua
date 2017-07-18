-- play.lua

local Game   = require 'common.game'
local Player = require 'entities.player'
local Enemy = require 'entities.enemy'
local Polygon = require 'entities.polygon'
local HUD = require 'common.hud'

local Play = Game:addState('Play')

function Play:enteredState()
  Log.info('Entered state Play')

  self.swallowTouch = false

  -- Must clear the timer on entering the scene or old timer from previous
  -- state might still be running
  Timer.clear()

  -- Create the physics world
  self:createWorld()

  self.parallax = Parallax(conf.width,conf.height, {offsetX = 0, offsetY = 0})
  self.parallax:addLayer('layer1',1,{ relativeScale = 0.4 })
  self.parallax:addLayer('layer2',1,{ relativeScale = 0.8 })
  -- self.parallax:setTranslation(px,py)

  self:createCamera()
  self:createBasicHandlers()

  self.hud = HUD:new()

  Player:new(self.world,100,100)
  Enemy:new(self.world,400,200)
  Polygon:new(self.world,{},200,200,300,200,300,300,200,300)

end

function Play:createBasicHandlers()
  Beholder.group(self,function()
    Beholder.observe('GameOver',function() self:onGameOver() end)
    Beholder.observe('ResetLevel',function() self:onResetLevel() end)
    Beholder.observe('GotoMainMenu',function() self:onGotoMainMenu() end)
    Beholder.observe('WinLevel',function() self:onWinLevel() end)
    -- Observe all events (for debug purpose)
    if conf.build == 'debug' then
      -- Beholder.observe(function(...) Log.debug('Event triggered > ',...) end)
    end
  end)
end

function Play:exitedState()
  Log.info('Exited state Play')
  -- self.music:stop()
  -- No need to call stopObserving since we reset the event system
  -- Beholder.stopObserving(self)
  Beholder.reset()
  Timer.clear()
  collectgarbage('collect')
  Log.debug('Memory usage:',collectgarbage("count")/1024)
end

-- function Play:pausedState()
--   Log.info('Paused state "Play"')
-- end
--
-- function Play:continuedState()
--   Log.info('Continued state "Play"')
-- end
--
-- function Play:pushedState()
--   Log.info('Pushed state "Play"')
-- end
--
-- function Play:poppedState()
--   Log.info('Popped state "Play"')
-- end
--
-- Must return the world size (w,h)
function Play:loadWorld()
  local filename = string.format('resources/maps/map%02d.lua',self.state.csi)
  Log.info('Loading map',filename)

  -- Load a map exported to Lua from Tiled.
  -- STI provides a bump plugin but since we don't use tiles we'll use a
  -- custom loader
  local map = STI(filename)

  -- Add your custom loading tasks or use the Bump plugin
  -- ...

  -- Get player's position from the map
  local x = map.properties.px and map.properties.px or 0
  local y = map.properties.py and map.properties.py or 0
  x,y = map:convertTileToPixel(x,y)

  -- Create the player entity
  self.player = Player:new(self.world, x,y)

  -- Get world map size
  return map.tilewidth * map.width, map.tileheight * map.height
end

function Play:drawParallax()
  self.parallax:push('layer1')
    -- Draw parallax layer1
  self.parallax:pop()
  self.parallax:push('layer2')
    -- Draw parallax layer2
  self.parallax:pop()
end

function Play:drawAfterCamera()
  self.hud:draw()
end

-- Event handlers

function Play:onGotoMainMenu()
  self:gotoState('Start')
end

function Play:onResetLevel()
  self:gotoState('Play')
end

function Play:onGameOver()
  self:pushState('GameplayOut')
end

function Play:onWinLevel()
  self:pushState('Win')
end

function Play:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    Beholder.trigger('GotoMainMenu')
  elseif key == 'r' then
    Beholder.trigger('ResetGame')
  elseif key == 'p' then
    self:pushState('Paused')
  elseif key == 'right' then
    Beholder.trigger('right')
  elseif key == 'left' then
    Beholder.trigger('left')
  elseif key == 'up' then
    Beholder.trigger('up')
  elseif key == 'down' then
    Beholder.trigger('down')
  end
  if conf.build == 'debug' then
    if key == 'd' then
      self:pushState('Debug')
    end
  end
end

return Play
