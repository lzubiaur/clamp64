-- entity.lua

-- Entity fields:
-- id
-- x,y
-- w,h
-- zOrder

-- hidden entities are not drawn and do not participate in touch events

-- TODO implement node/parent entity

-- Physic world entity
local Entity = Class('Entity')

local DELTA = 1e-10 -- floating-point margin of error

function Entity:initialize(world, x,y, w,h, opt)
  opt = opt or {}
  Lume.extend(self,{
    world = world,
    x = x, y = y, -- position
    w = w, h = h, -- size
    -- Options
    zOrder = opt.zOrder or 0, -- draw and touch order
    id = opt.id,
    children = {},
  })
  -- add this instance to the physics world
  world:add(self, x,y, w,h)
end

function Entity:destroy()
  for _,child in ipairs(self.childre) do
    child:destroy()
  end
  Beholder.stopObserving(self)
  self.world:remove(self)
end

function Entity:addChild(child)
  table.insert(self.children,child)
end

function Entity:removeChild(child)
  Lume.remove(self.children,child)
end

function Entity:setVisible(visible)
  Lume.all(self.children,Entity.setVisible)
  self.hiden = not visible
  return true
end

function Entity:getPosition()
  return self.x,self.y
end

function Entity:getLocalPoint(x,y)
  return x-self.x,y-self.y
end

function Entity:getCenter()
  return self.x + self.w / 2, self.y + self.h / 2
end

function Entity:containsPoint(x,y)
  return x - self.x > DELTA and y - self.y > DELTA and
         self.x + self.w - x > DELTA and self.y + self.h - y > DELTA
end

function Entity:getEdges()
  local x,y,w,h = self.x,self.y,self.w,self.h
  return x,y, x+w,y, x+w,y+h, x,y+h
end

function Entity:resize(w,h)
  self.w,self.h = w,h
  self.world:update(self,self.x,self.y,self.w,self.h)
end

function Entity:teleport(x,y)
  self.x,self.y = x,y
  self.world:update(self,self.x,self.y)
  for _,child in ipairs(self.childre) do
    child:teleport(x,y)
  end
end

-- XXX move children
function Entity:move(x,y,filter)
  local cols,len
  self.x,self.y,cols,len = self.world:move(self,x,y,filter)
  return cols,len
end

-- TODO to be tested. Need to add push:toScreen but it does not work
function Entity:getCenterToScreen()
  if game.camera then
    return game.camera:toScreen(self:getCenter())
  end
  return self:getCenter()
end

-- Ascending ZOrder sort
function Entity:sortByZOrderAsc(other)
  return self.zOrder < other.zOrder
end

-- Descending ZOrder sort
function Entity:sortByZOrderDesc(other)
  return self.zOrder > other.zOrder
end

function Entity:update(dt)
  -- nothing
end

-- debug draw
function Entity:draw()
  g.setColor(0,255,255,255)
  g.rectangle('line',self.x,self.y,self.w,self.h)
end

function Entity:loadState()
  if not self.id then
    error('No ID for entity',self.class.name)
  end
  return game:getCurrentLevelState().entities[self.id]
end

function Entity:saveState(name,state)
  if not self.id then
    error('No ID for entity', self.class.name)
  end
  game:getCurrentLevelState().entities[self.id] = {
    name = name,
    state = state
  }
end

function Entity:removeState()
  if not self.id then
    error('No ID for entity',self.class.name)
  end
  if game:getCurrentLevelState().entities[self.id] then
    game:getCurrentLevelState().entities[self.id] = nil
  end
end

-- Load and restore this entity state from the Game.State database.
-- The entity must have an ID or an error is raised.
function Entity:restoreState()
  local state = self:loadState()
  if state then
    if state.name then
      self:gotoState(state.name)
    end
    -- Lume.extend(self,state.state)
    return state.state
  end
  return nil
end

function Entity:observeOnce(...)
  local param, id = {...}
  local callback = table.remove(param,#param)
  table.insert(param, function(...)
    callback(...)
    Beholder.stopObserving(id)
  end)
  id = Beholder.observe(unpack(param))
  return id
end

return Entity
