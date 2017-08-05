-- play.lua

local Game   = require 'common.game'
local Player = require 'entities.player'
local Enemy = require 'entities.enemy'
local Polygon = require 'entities.polygon'
local Tail = require 'entities.tail'
local Checkpoint = require 'common.checkpoint'
local Segment = require 'entities.segment'
local Laser = require 'entities.laser'

local Play = Game:addState('Play')

function Play:enteredState()
  Log.info('Entered state Play')

  self.state.lives = 3
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

  self.tilesheetGrid = Anim8.newGrid(10,10,Assets.img.tilesheet:getDimensions())

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

  self.checkpoint = Checkpoint:new(self.world)
end

function Play:createEventHandlers()
  Beholder.group(self,function()
    Beholder.observe('GameOver',function() self:onGameOver() end)
    Beholder.observe('ResetLevel',function() self:onResetLevel() end)
    Beholder.observe('GotoMainMenu',function() self:onGotoMainMenu() end)
    Beholder.observe('WinLevel',function() self:onWinLevel() end)
    Beholder.observe('entered',function(polygon,x,y)
      local tail = Tail:new(self.world,x,y)
      tail.isInvincible = self.player.isInvincible
    end)
    Beholder.observe('lose',function()
      Log.debug('Lives',self.state.lives)
      self.state.lives = self.state.lives - 1
      if self.state.lives < 1 then
        Beholder.trigger('GameOver')
        return
      end
      local x,y = self.checkpoint:getLastPosition()
      self:createPlayer(x,y)
      self.player:gotoState('Blink')
      Beholder.trigger('start')
    end)
    self.completed = 0
    local area = 0
    Beholder.observe('area',function(value)
      area = area - value
      self.completed = math.abs(area / game.totalArea) / .4
      Beholder.trigger('progress',self.completed)
      Log.info('Progress',self.completed)
      if self.completed >= 1 then
        self:pushState('Win')
      end
    end)
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

function Play:createPlayer(x,y)
  self.player = Player:new(self.world,x,y)
  self.follow = self.player
end

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
    for i=1,#p do Lume.push(t,p[i].x,p[i].y) end
    return t
  end

  self.totalArea = 0
  local layer = map['objects']
  for _,obj in pairs(layer) do
    Log.debug(obj.type)
    if obj.type == 'polygon' then
      local p = Polygon:new(self.world,nil,unpack(polygonToPoints(obj.polygon)))
      self.totalArea = self.totalArea + p.shape.area
    elseif obj.type == 'player' then
      self:createPlayer(obj.x,obj.y)
    elseif obj.type == 'enemy' then
      Enemy:new(self.world,obj.x,obj.y)
    elseif obj.type == 'laser' then
      Laser:new(self.world,obj.x,obj.y)
    end
  end
  Log.info('Total area',self.totalArea)

  local w,h = map.tilewidth * map.width, map.tileheight * map.height

  -- Create the world's bounds
  local edge = Segment:new(self.world,0,0,w,0,.1)
  edge.isBoundEdge = true
  edge = Segment:new(self.world,w,0,w,h,.1)
  edge.isBoundEdge = true
  edge = Segment:new(self.world,w,h,0,h,.1)
  edge.isBoundEdge = true
  edge = Segment:new(self.world,0,h,0,0,.1)
  edge.isBoundEdge = true

  return map,w,h
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
