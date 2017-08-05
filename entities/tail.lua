-- tail.lua
local Entity = require 'entities.base.entity'
local Segment = require 'entities.segment'

local Tail = Class('Tail',Entity)

function Tail:initialize(world,x,y)
  self.points = {}
  self:addPoint(x,y)
  -- XXX update size when adding new segments?
  Entity.initialize(self,world,x,y,1,1,{zOrder = 2})

  Beholder.group(self,function()
    Beholder.observe('moved',function(polygon,x,y)
      self:addPoint(x,y)
    end)
    Beholder.observe('leaved',function(polygon,x,y)
      self:destroy()
    end)
    Beholder.observe('lose',function()
      self:destroy()
    end)
    Beholder.observe('GameOver',function()
      self:destroy()
    end)
    Beholder.observe('killed',function()
      self:destroy()
    end)
    Beholder.observe('beatable',function()
      self.isInvincible = false
    end)
  end)
end

local function filter(other)
  if other.class.name == 'Enemy' then return true end
  return false
end

function Tail:querySegment(ax,ay,bx,by)
  if self.isInvincible then return end
  local items,len = self.world:querySegment(ax,ay,bx,by,filter)
  if len > 0 then
    Beholder.trigger('killed')
  end
end

function Tail:update(dt)
  local pts,len = self.points,#self.points
  for i=1,len-2,2 do
    self:querySegment(pts[i],pts[i+1],pts[i+2],pts[i+3])
  end
  self:querySegment(pts[len-1],pts[len],game.player:getCenter())
end

-- Extend this Tail with a new segment
function Tail:addPoint(x,y)
  Lume.push(self.points,x,y)
end

-- Change the current/last segment end point
function Tail:updateEndPoint(x,y)
  local len = #self.points
  self.points[len-1] = x
  self.points[len] = y
end

function Tail:draw()
  local t = Lume.concat(self.points,{game.player:getCenter()})
  g.setColor(0,255,255,255)
  g.line(unpack(t))
end

return Tail
