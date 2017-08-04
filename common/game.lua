-- game.lua
local Entity = require 'entities.base.entity'
local Visible = require 'common.visible'
local HUD = require 'common.hud'

local Game = Class('Game'):include(Stateful)

function Game:initialize()
  Log.info('Create the game instance.')

  self.entities = {}
  self.swallowTouch = false

  self.state = {
    path = 'db.data', -- this database filename
    cli = 1, -- current level id
    csi = 1, -- current season id
    levels = {} -- Array with all levels states.
  }

  self:loadGameState()

  -- shader = love.graphics.newShader("resources/shaders/separate_chroma.glsl")
  -- Uncomment below to use two post-process effects
  -- Push:setupCanvas({
  --   -- { name = 'noshader' }, -- in case we want a no shader canvas
  --   { name = 'shader1', shader = kaleidoscope },
  -- })
  -- Push:setShader(shader2) --applied to final render

  -- In case we only want one shader
  -- Push:setShader(shader1)

  -- default graphics params
  g.setLineWidth(conf.lineWidth)
  g.setLineJoin('miter') -- none/miter/bevel
  g.setLineStyle('rough') -- rough/smooth
  g.setPointSize(conf.pointSize)

  i18n.loadFile('resources/i18n.lua')

  self.visible = Visible:new()
end

function Game:setFont(path,size)
  local font = love.graphics.newFont(path,size)
  self.fontHeight = font:getHeight()
  love.graphics.setFont(font)
end

function Game:createWorld()
  self.world = Bump.newWorld(conf.cellSize)
end

function Game:destroy()
  self:writeGameState()
end

function Game:writeGameState()
  Log.info('Serialize game state',Inspect(self.state))
  local data = Binser.serialize(self.state)
  if not data then
    Log.error('Cannot serialize game state')
    return
  end
  local success,msg = love.filesystem.write(self.state.path,data)
  if not success then
    Log.error('Cannot write to database:',msg)
  end
end

function Game:createHUD()
  self.hud = HUD:new()
end

function Game:loadGameState()
  local fs = love.filesystem
  if fs.exists(self.state.path) then
    local data,len = fs.read(self.state.path)
    if not data then
      Log.error('Cannot read file:',len)
      return
    end
    data,len = Binser.deserialize(data)
    if data then
      self.state = data[1]
      Log.debug('Game state = ',Inspect(self.state))
    else
      Log.error('Cannot read deserialize database')
    end
  end
end

function Game:updateShaders(dt,shift,alpha)
  -- shader:send('alpha', alpha)
end

function Game:keypressed(key, scancode, isRepeat)
  -- nothing to do
end

function Game:drawEntities(l,t,w,h)
  -- Only draw only visible entities
  local items,len = self.world:queryRect(l,t,w,h)
  table.sort(items,Entity.sortByZOrderAsc)
  for i=1,len do
    if not items[i].hidden then
      items[i]:draw()
    end
  end
end

function Game:drawBeforeCamera(l,t,w,h)
end

function Game:drawAfterCamera(l,t,w,h)
  if self.hud then self.hud:draw(l,t,w,h) end
end

function Game:draw()
  Push:start()
  g.clear(to_rgb(palette.bg))
  self:drawBeforeCamera(self.visible:screen())
  self.camera:draw(function(l,t,w,h)
    self:drawEntities(l,t,w,h) -- Call a function so it can be override by other state
  end)
  self:drawAfterCamera(self.visible:screen())
  Push:finish()
end

-- Update visible entities
function Game:updateEntities(dt)
  -- TODO add a padding parameter to update outside the visible windows
  local l,t,w,h = self.camera:getVisible()
  local items,len = self.world:queryRect(l,t,w,h)
  Lume.each(items,'update',dt)
  if self.hud then self.hud:update(dt) end
end

function Game:updateCamera(dt)
  -- Move the camera
  -- TODO smooth the camera. X doesnt work smoothly
  -- TODO Check Lume.smooth instead of lerp for X (and y?)
  if self.follow then
    local x,y = self.camera:getPosition()
    local px, py = self.follow:getCenter()
    -- self.camera:setPosition(Lume.lerp(x,px + conf.camOffsetX,.05), Lume.lerp(y,py,.05))
    self.camera:setPosition(px,py)
    if self.parallax then
      self.parallax:setTranslation(self.camera:getPosition())
    end
  end
  -- self.parallax:update(dt) -- not required
end

function Game:update(dt)
  Timer.update(dt)
  -- self:updateShaders(dt)
  self:updateEntities(dt)
  self:updateCamera(dt)
end

function Game:touchFilter(item)
  return not item.hidden
end

-- 'Pressed' event
-- event args: entity,world x,y
function Game:pressed(x, y)
  -- Query HUD entities first. Pressed events on HUD entities are always swallowed.
  if self.hud then
    local x,y = self:screenToDesign(x,y)
    local items, len = self.hud.world:queryPoint(x,y)
    table.sort(items,Entity.sortByZOrderDesc)
    if len > 0 then
      Beholder.trigger('Pressed',items[1],x,y)
      table.insert(self.entities,items[1])
      return
    end
  end
  -- Query game entities world
  x,y = self:screenToWorld(x,y)
  local items, len = self.world:queryPoint(x,y,function(item) return self:touchFilter(item) end)
  table.sort(items,Entity.sortByZOrderDesc)
  -- If swallow touch is enable only the first entity (highest zOrder) will be triggerd
  if self.swallowTouch and len > 1 then len = 1 end
  for i=1,len do
    local ent = items[i]
    Beholder.trigger('Pressed',ent,x,y)
    table.insert(self.entities,ent)
  end
end

-- 'Moved' event
-- event args: entity,world x,y, delta x,y
function Game:moved(x, y, dx, dy)
  dx,dy = self:screenToWorld(x-dx,y-dy)
  x,y = self:screenToWorld(x,y)
  for i=1,#self.entities do
    Beholder.trigger('Moved',self.entities[i],x,y,x-dx,y-dy)
  end
end

-- 'Released' event
-- event args: entity,world x,y
function Game:released(x, y)
  x,y = self:screenToWorld(x,y)
  for i=1,#self.entities do
    Beholder.trigger('Released',self.entities[i],x,y)
  end
  self.entities = {}
end

function Game:touchpressed(id, x, y, dx, dy, pressure)
  self:pressed(x,y)
end

function Game:touchmoved(id, x, y, dx, dy, pressure)
  self:moved(x,y,dx,dy)
end

function Game:touchreleased(id, x, y, dx, dy, pressure)
  self:released(x,y,dx,dy)
end

function Game:mousepressed(x, y, button, istouch)
  if istouch then return end
  self:pressed(x,y)
end

function Game:mousemoved(x, y, dx, dy, istouch)
  if istouch then return end
  self:moved(x,y,dx,dy)
end

function Game:mousereleased(x, y, button, istouch)
  if istouch then return end
  self:released(x,y,dx,dy)
end

function Game:mousefocus(focus)
  if not focus then
    for _,v in ipairs(self.entities) do
      Beholder.trigger('Cancelled',v.entity)
    end
    self.entities = {}
  end
end

-- Create a new camera with:
-- size w,h (default to screen size),
-- margin mx,my (default to zero),
-- offset ox,oy (default to zero) and
-- grid size gs (default to 32)
function Game:createCamera(w,h,mx,my,ox,oy,gs)
  w,h = w or conf.sw, h or conf.sh
  mx,my = mx or 0,my or 0
  ox,oy = ox or 0,oy or 0
  -- Create the follow camera. Size of the camera is the size of the map + offset.
  self.camera = Gamera.new(-mx,-my,w+mx,h+my)
  -- Camera window must be set to the game resolution and not the
  -- the actual screen resolution
  self.camera:setWindow(0,0,conf.sw,conf.sh)

  if self.follow then
    local px, py = self.follow:getCenter()
    self.camera:setPosition(px+ox,py+oy)
  end

  Log.debug('Camera world',self.camera:getWorld())
  Log.debug('Camera window',self.camera:getWindow())

  -- Create the grid
  if conf.build == 'debug' then
    self.grid = EditGrid.grid(self.camera,{
      size = gs or 32,
      subdivisions = 10,
      color = {128, 140, 250},
      drawScale = false,
      xColor = {255, 255, 0},
      yColor = {0, 255, 255},
      fadeFactor = 0.3,
      textFadeFactor = 0.5,
      hideOrigin = false,
      -- interval = 200
    })
  end
end

-- Convert from real screen coords to game design resolution
function Game:screenToDesign(x,y)
  return Push:toGame(x,y or 0)
end

-- Convert from real screen coords to world coords
function Game:screenToWorld(x,y)
  -- Push:toGame might return nil
  x,y = Push:toGame(x,y or 0)
  if self.camera then
    x,y = self.camera:toWorld(x and x or 0,y and y or 0)
  end
  return x,y
end

-- function love.wheelmoved( x, y )
-- end

function Game:resetCurrentLevelState()
  local i = self.state.cli
  if self.state.levels[i] then
    self.state.levels[i] = nil
  end
end

-- Lazy create and returns the current level state
function Game:getCurrentLevelState()
  local state,i = self.state,self.state.cli
  if not state.levels[i] then
    state.levels[i] = {
      score = 0,
      entities = {}
    }
  end
  return state.levels[i]
end

return Game
