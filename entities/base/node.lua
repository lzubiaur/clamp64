-- node.lua

-- Node fields:
-- id
-- x,y
-- w,h
-- angle
-- zOrder
-- ax,ay anchor point (default .5,.5)
-- hidden entities are not drawn and do not participate in touch events

local DELTA = 1e-10 -- floating-point margin of error

local Node = Class('Node')

function Node:initialize(x,y,w,h,opt)
  opt = opt or {}
  Lume.extend(self,{
    x = x, y = y,
    w = w, h = h,
    ax = opt.ax or .5,
    ay = opt.ay or .5,
    angle = opt.angle or 0,
    -- Options
    zOrder = opt.zOrder or 0, -- draw and touch order
    id = opt.id,
    children = {},
  })
  if opt.visible ~= nil then
    self:setVisible(opt.visible)
  end
end

function Node:destroy()
  for _,child in ipairs(self.children) do
    child:destroy()
  end
  Beholder.stopObserving(self)
end

function Node:setZOrder(zOrder)
  self.zOrder = zOrder
end

-- Ascending ZOrder sort
function Node:sortByZOrderAsc(other)
  return self.zOrder < other.zOrder
end

-- Descending ZOrder sort
function Node:sortByZOrderDesc(other)
  return self.zOrder > other.zOrder
end

function Node:addChild(child)
  child.parent = self
  table.insert(self.children,child)
end

function Node:removeChild(child)
  Lume.remove(self.children,child)
  child.parent = nil
end

function Node:setVisible(visible)
  for _,child in ipairs(self.children) do
    child:setVisible(visible)
  end
  self.hidden = not visible
end

function Node:getPosition()
  return self.x,self.y
end

function Node:getLocalPoint(x,y)
  return x-self.x,y-self.y
end

function Node:getCenter()
  return self.x + self.w / 2, self.y + self.h / 2
end

function Node:containsPoint(x,y)
  return x - self.x > DELTA and y - self.y > DELTA and
         self.x + self.w - x > DELTA and self.y + self.h - y > DELTA
end

function Node:getEdges()
  local x,y,w,h = self.x,self.y,self.w,self.h
  return x,y, x+w,y, x+w,y+h, x,y+h
end

-- TODO to be tested. Need to add push:toScreen but it does not work
function Node:getCenterToScreen()
  if game.camera then
    return game.camera:toScreen(self:getCenter())
  end
  return self:getCenter()
end

function Node:setPosition(x,y)
  self.x, self.y = x,y
end

function Node:setAnchor(x,y)
  self.ax,self.ay = x,y
end

function Node:transform()
  g.translate(self.x,self.y)
  g.rotate(self.angle)
end

function Node:setColor(color)
  assert(type(color)=='table')
  self.color = color
end

function Node:observeOnce(...)
  local param, id = {...}
  local callback = table.remove(param,#param)
  table.insert(param, function(...)
    callback(...)
    Beholder.stopObserving(id)
  end)
  id = Beholder.observe(unpack(param))
  return id
end

function Node:drawBoundingBox(color)
  if conf.build == 'debug' then
    color = color or {0,255,255,255}
    g.setColor(unpack(color))
    g.rectangle('line',self.x,self.y,self.w,self.h)
  end
end

function Node:update(dt)
  for _,child in ipairs(self.children) do
    child:update(dt)
  end
end

function Node:draw()
  self:drawBoundingBox(self.color)
  table.sort(self.children,Node.sortByZOrderAsc)
  g.push()
  self:transform()
  for _,child in ipairs(self.children) do
    if not child.hidden then
      child:draw()
    end
  end
  g.pop()
end

return Node
