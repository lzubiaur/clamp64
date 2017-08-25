-- play.lua

local Game   = require 'common.game'
local Player = require 'entities.player'
local Enemy = require 'entities.enemy'
local Polygon = require 'entities.polygon'
local Tail = require 'entities.tail'
local Checkpoint = require 'common.checkpoint'
local Segment = require 'entities.segment'
local Laser = require 'entities.laser'
local Xup = require 'entities.xup'
local Cannon = require 'entities.cannon'
local Barrier = require 'entities.barrier'
local Diamond = require 'entities.diamond'
local SlowMotion = require 'entities.slowmo'

local Play = Game:addState('Play')

function Play:enteredState()
  Log.info('Entered state Play')

  self.swallowTouch = false
  self.shakeIntensity = 0
  self.shake = false
  -- For slow motion
  self:saveVelocityConfig()

  -- Must clear the timer on entering the scene or old timer from previous
  -- state might still be running
  Timer.clear()

  -- Create the physics world
  self:createWorld()

  self.tilesheetGrid = Anim8.newGrid(12,12,Assets.img.tilesheet:getDimensions())

  -- Hud must be created after the tilesheet grid because it's using it
  self:createHUD('GamePlay')

  local file = self.state.cli
  if conf.build == 'debug' then
    self.state.cli = 6
    file = self.state.cli
  end
  if game.state.cli > conf.mapsCount then
    self:pushState('WinSeason')
    file = 'credits.lua'
  end
  local map,w,h = self:loadWorldMap(file)
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
  self:fadeIn(function()
    Push:setShader()
  end)
end

function Play:tilesheetFrame(i,j)
  return self.tilesheetGrid(i,j)[1]
end

-- Used for slow motion
function Play:saveVelocityConfig()
  self.back = Lume.pick(conf,'bulletVelocity','enemyVelocity','laserVelocity','laserTimeout')
end

function Play:slowMotion()
  conf.laserTimeout = self.back.laserTimeout * conf.slowMotionScale
  conf.laserVelocity = self.back.laserVelocity / conf.slowMotionScale
  conf.enemyVelocity = self.back.enemyVelocity / conf.slowMotionScale
  conf.bulletVelocity = self.back.bulletVelocity / conf.slowMotionScale
end

function Play:restoreVelocityConfig()
  conf.laserTimeout = self.back.laserTimeout
  conf.bulletVelocity = self.back.bulletVelocity
  conf.enemyVelocity = self.back.enemyVelocity
  conf.laserVelocity = self.back.laserVelocity
end

function Play:createEventHandlers()
  Beholder.group(self,function()
    Beholder.observe('GameOver',function() self:onGameOver() end)
    Beholder.observe('ResetLevel',function() self:onResetLevel() end)
    Beholder.observe('GotoMainMenu',function() self:onGotoMainMenu() end)
    Beholder.observe('NextLevel',function() self:onNextLevel() end)
    Beholder.observe('entered',function(polygon,x,y)
      local tail = Tail:new(self.world,x,y)
      tail.isInvincible = self.player.isInvincible
    end)
    Beholder.observe('slowmo',function(obj,timeout)
      self:slowMotion()
      Timer.after(timeout,function()
        self:restoreVelocityConfig()
        Beholder.trigger('normalSpeed')
      end)
    end)
    Beholder.observe('xup',function()
      if self.state.lives < conf.maxLives then
        self.state.lives = self.state.lives + 1
      end
    end)
    -- Camera shake doesnt work fine with very low resolution
    -- Beholder.observe('killed',function()
    --   self:setShake(2)
    -- end)
    Beholder.observe('lose',function()
      -- self.shake = false
      self.state.lives = self.state.lives - 1
      if self.state.lives < 1 then
        Beholder.trigger('GameOver')
      else
        local x,y = self.checkpoint:getLastPosition()
        self:createPlayer(x,y)
        self.player:gotoState('Blink')
        Beholder.trigger('start')
      end
    end)
    local diamonds = 0
    Beholder.observe('diamond',function()
      diamonds = diamonds + 1
    end)
    self.completed = 0
    local area = 0
    Beholder.observe('area',function(value)
      area = area + value
      self.completed = (area / game.totalArea) / conf.targetPercentArea
      Beholder.trigger('progress',self.completed)
      if self.completed >= 1 then
        local oldHighScore = game:getGrandScore()
        local level = self:getCurrentLevelState()
        area = math.ceil(area * conf.areaScoreScale)
        if level.score + level.diamonds * conf.diamondScore < area + diamonds * conf.diamondScore then
          level.score = area
          level.diamonds = diamonds
        end
        self:pushState('Win',{
          new=game:getGrandScore(),
          old=oldHighScore,
          diamonds=diamonds
        })
        self:writeGameState()
        return false -- stop propagation
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
  -- No need to call stopObserving since we reset the event system
  -- Beholder.stopObserving(self)
  Beholder.reset()
  Timer.clear()
  self:restoreVelocityConfig()
  self.hud = nil
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
function Play:loadWorldMap(file)
  local filename = ''
  if type(file) == 'number' then
    filename = string.format('resources/maps/map%02d.lua',file)
  else
    filename = 'resources/maps/'..tostring(file)
  end
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
      Enemy:new(self.world,obj.x,obj.y,obj.properties)
    elseif obj.type == 'laser' then
      Laser:new(self.world,obj.x,obj.y)
    elseif obj.type == 'xup' then
      Xup:new(self.world,obj.x,obj.y)
    elseif obj.type == 'cannon' then
      Cannon:new(self.world,obj.x,obj.y)
    elseif obj.type == 'barrier' then
      Barrier:new(self.world,obj.x,obj.y,obj.width,obj.height)
    elseif obj.type == 'diamond' then
      Diamond:new(self.world,obj.x,obj.y)
    elseif obj.type == 'slowmo' then
      SlowMotion:new(self.world,obj.x,obj.y,obj.properties.timeout)
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

function Play:update(dt)
  Game.update(self,dt)
  self.map:update(dt)
end

function Play:drawEntities(l,t,w,h)
  g.stencil(function() self:stencil(l,t,w,h) end,'replace',1)
  g.setStencilTest('greater',0)
  -- self.map:draw()
  -- self.map:drawTileLayer('tiles')
  g.setColor(255,255,255,255)
  self.map.layers.clipped:draw()
  g.setStencilTest()
  self.map.layers.tiles:draw()
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

function Play:onNextLevel()
  self.state.cli = self.state.cli + 1
  self:gotoState('Play')
end

function Play:pressed(x,y)
  self._p = Vector(x,y)
  Game.pressed(self,x,y)
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

function Play:saveWorldScreenShot()
  local l,t,w,h = self.camera:getWorld()
  Log.info('Save world screenshot',l,t,w,h)
  local canvas = love.graphics.newCanvas(w,h)
  love.graphics.setCanvas(canvas)
    g.clear(to_rgb(palette.bg))
    self:drawBeforeCamera(l,t,w,h)
    self:drawEntities(l,t,w,h)
    self:drawAfterCamera(l,t,w,h)
  love.graphics.setCanvas()
  canvas:newImageData():encode('png','screenshot.png')
end

function Play:keypressed(key, scancode, isrepeat)
  if key == 'escape' then
    Beholder.trigger('GotoMainMenu')
  elseif key == 'r' then
    Beholder.trigger('ResetGame')
  -- elseif key == 's' then
  --   self:saveWorldScreenShot()
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
