-- play.lua

local Game   = require 'common.game'
local Player = require 'entities.player'
local Enemy = require 'entities.enemy'
local Polygon = require 'entities.polygon'
local Tail = require 'entities.tail'

local Play = Game:addState('Play')

function Play:enteredState()
  Log.info('Entered state Play')

  self.swallowTouch = false

  -- Must clear the timer on entering the scene or old timer from previous
  -- state might still be running
  Timer.clear()

  if not self.music then
    self.music = love.audio.newSource('resources/music/dream_candy.xm','stream')
    love.audio.play(self.music)
  end

  self:createHUD()
  -- Create the physics world
  self:createWorld()

  local map,w,h = self:loadWorldMap()
  self.map = map

  self.parallax = Parallax(w,w, {offsetX = 0, offsetY = 0})
  self.parallax:addLayer('layer1',1,{ relativeScale = .4 })
  self.parallax:addLayer('layer2',1,{ relativeScale = .6 })
  -- self.parallax:setTranslation(px,py)
  self.stars = self:createStars(w,h)
  self.stars2 = self:createStars(w,h)

  self:createCamera(w,h)
  self:createEventHandlers()
end

function Play:createEventHandlers()
  Beholder.group(self,function()
    -- Beholder.observe('GameOver',function() self:onGameOver() end)
    Beholder.observe('ResetLevel',function() self:onResetLevel() end)
    Beholder.observe('GotoMainMenu',function() self:onGotoMainMenu() end)
    Beholder.observe('WinLevel',function() self:onWinLevel() end)
    Beholder.observe('entered',function(polygon,x,y)
      Tail:new(self.world,x,y)
    end)
    -- Observe all events (for debug purpose)
    if conf.build == 'debug' then
      -- Beholder.observe(function(...) Log.debug('Event triggered > ',...) end)
    end
  end)
end

function Play:createStars(w,h)
  local t = {}
  local rand = love.math.random
  for i=1,(w*h)/100 do
    table.insert(t,rand(w))
    table.insert(t,rand(h))
  end
  return t
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
function Play:loadWorldMap()
  local filename = string.format('resources/maps/map%02d.lua',self.state.csi)
  Log.info('Loading map',filename)

  -- Load a map exported to Lua from Tiled.
  -- STI provides a bump plugin but since we don't use tiles we'll use a
  -- custom loader
  local map = STI(filename)

  local polygonToPoints = function(p)
    local t = {}
    for i=1,#p do
      table.insert(t,p[i].x)
      table.insert(t,p[i].y)
    end
    return t
  end

  local layer = map['objects']
  for _,obj in pairs(layer) do
    Log.debug(obj.type)
    if obj.type == 'polygon' then
      Polygon:new(self.world,nil,unpack(polygonToPoints(obj.polygon)))
    elseif obj.type == 'player' then
      self.player = Player:new(self.world,obj.x,obj.y)
      self.follow = self.player
    elseif obj.type == 'enemy' then
      Enemy:new(self.world,obj.x,obj.y)
    end
  end

  -- Get player's position from the map
  -- local x = map.properties.px and map.properties.px or 0
  -- local y = map.properties.py and map.properties.py or 0
  -- x,y = map:convertTileToPixel(x,y)
  --
  -- -- Create the player entity
  -- self.player = Player:new(self.world, x,y)
  -- self.follow = self.player

  return map,map.tilewidth * map.width, map.tileheight * map.height
end

function Play:drawBeforeCamera()
  self:drawParallax()
end

function Play:stencil(l,t,w,h)
  local items,len = self.world:queryRect(l,t,w,h,function(item)
    return item.class.name == 'Polygon'
  end)
  for i=1,len do
    local tri = love.math.triangulate(items[i].shape:unpack())
    for i=1,#tri do
      g.polygon('fill',tri[i])
    end
  end
end

function Play:drawEntities(l,t,w,h)
  g.stencil(function() self:stencil(l,t,w,h) end,'replace',1)
  g.setStencilTest('greater',0)
  -- self.map:draw()
  -- self.map:drawTileLayer('tiles')
  g.setColor(255,255,255,255)
  self.map.layers.tiles:draw()
  g.setStencilTest()
  Game.drawEntities(self,l,t,w,h)
end

function Play:drawParallax()
  self.parallax:push('layer1')
    g.setColor(0,255,255,60)
    g.points(self.stars)
  self.parallax:pop()
  self.parallax:push('layer2')
    g.setColor(0,255,255,128)
    g.points(self.stars2)
  self.parallax:pop()
end

-- Event handlers

function Play:onGotoMainMenu()
  self:gotoState('Start')
end

function Play:onResetLevel()
  self:gotoState('Play')
end

function Play:onGameOver()
  self:pushState('GameOver')
end

function Play:onWinLevel()
  self:pushState('Win')
end

function Play:pressed(x,y)
  self._p = Vector(x,y)
  Game.pressed(self,x,y)
end

function Play:moved(x,y,dx,dy)
  Game.moved(self,x,y,dx,dy)
end

function Play:released(x,y)
  local p = self._p
  p = (Vector(x,y) - p):normalized()
  local ax,ay = math.abs(p.x),math.abs(p.y)
  if p.x > 0 and ax > ay then
    Beholder.trigger('right')
  elseif p.x < 0 and ax > ay then
    Beholder.trigger('left')
  elseif p.y > 0 and ay > ax then
    Beholder.trigger('down')
  else
    Beholder.trigger('up')
  end
  Game.released(self,x,y)
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
