-- node.lua

-- Node fields:
-- id
-- x,y
-- w,h
-- angle
-- sx,sy scale size
-- zOrder
-- ax,ay anchor point (default .5,.5)
-- hidden entities are not drawn and do not participate in touch events

local DELTA = 1e-10 -- floating-point margin of error

local Node = Class('Node')

function Node:initialize(x,y,w,h,opt)
  opt = opt or {}
  Lume.extend(self,{
    x = x or 0, y = y or 0,
    w = w or 1, h = h or 1,
    ax = opt.ax or .5,
    ay = opt.ay or .5,
    sx = opt.sx or 1,
    sy = opt.sy or 1,
    kx = opt.kx or 0,
    ky = opt.ky or 0,
    angle = opt.angle or 0,
    -- Options
    zOrder = opt.zOrder or 0, -- draw and touch order
    id = opt.id,
    tag = opt.tag,
    children = {},
    color = opt.color or {255,255,255,255}
  })
  if opt.visible ~= nil then
    self:setVisible(opt.visible)
  end
end

function Node:destroy()
  self.destroyed = true
  for _,child in ipairs(self.children) do
    child:destroy()
  end
  if self.parent then self.parent:removeChild(self) end
  Beholder.stopObserving(self)
end

function Node:setZOrder(zOrder)
  -- TODO order other children
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

function Node:addChild(child,zOrder,tag)
  child.parent = self
  table.insert(self.children,child)
  if zOrder then child.zOrder = zOrder end
  if tag then child.tag = tag end
  table.sort(self.children,Node.sortByZOrderAsc)
  return child
end

-- Returns all children with the same tag
function Node:getChildByTag(tag)
  return unpack(Lume.filter(self.children,function(child)
    return child.tag == tag
  end))
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

function Node:isVisible()
  return not self.hidden
end

function Node:isOutsideVisibleScreen()
  -- TODO no camera
  if game.camera then
    local l,t,w,h = game.camera:getVisible()
    return self.x+self.w < l or self.x > l+w or self.y+self.h < t or self.y > t+h
  end
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
  if conf.build == 'debug' and conf.drawBBox then
    color = color or {0,255,255,255}
    g.setColor(color)
    g.rectangle('line',self.x,self.y,self.w,self.h)
  end
end

function Node:update(dt)
  for _,child in ipairs(self.children) do
    child:update(dt)
  end
end

function Node:draw()
  -- XXX don't draw this node if hidden?
  -- if self.hidden then return end
  self:drawBoundingBox(self.color)
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
