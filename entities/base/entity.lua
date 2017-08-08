-- entity.lua

-- An entity is a node with logic (update function) and physics.

-- XXX prefix self/internal variables with double underscore (__)

local Node = require 'entities.base.node'
local Entity = Class('Entity',Node)

function Entity:initialize(world, x,y, w,h, opt)
  Node.initialize(self,x,y,w,h,opt)
  self.world = world
  -- add this instance to the physics world
  world:add(self, x,y, w,h)
end

function Entity:destroy()
  Node.destroy(self)
  self.world:remove(self)
  -- TODO destroy children
end

function Entity:addSprite(sprite)
  if not self.spritesNode then
    self.spritesNode = Node:new(self.x,self.y,0,0)
  end
  self.spritesNode:addChild(sprite)
  return sprite
end

function Entity:removeSprite(sprite)
  assert(self.spritesNode,'No sprites')
  self.spritesNode:removeChild(sprite)
end

function Entity:resize(x,y,w,h)
  self:teleport(x,y)
  self.w,self.h = w,h
  self.world:update(self,self.x,self.y,self.w,self.h)
end

function Entity:setPosition(x,y)
  self:teleport(x,y)
end

function Entity:teleport(x,y)
  local dx,dy = self.x-x, self.y-y
  self.x,self.y = x,y
  self.world:update(self,self.x,self.y)
  for _,child in ipairs(self.children) do
    child:teleport(child.x-dx,child.y-dy)
  end
  if self.spritesNode then
    self.spritesNode:setPosition(self.x,self.y)
  end
end

function Entity:move(x,y,filter)
  local cols,len,dx,dy = nil,0,self.x-x,self.y-y
  self.x,self.y,cols,len = self.world:move(self,x,y,filter)
  for _,child in ipairs(self.children) do
    child:move(child.x-dx,child.y-dy,filter)
  end
  if self.spritesNode then
    self.spritesNode:setPosition(self.x,self.y)
  end
  return cols,len
end

function Entity:update(dt)
  if self.spritesNode then
    self.spritesNode:update(dt)
  end
end

function Entity:draw()
  if self.spritesNode then
    self.spritesNode:draw()
  end
  self:drawBoundingBox(self.color)
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

return Entity
