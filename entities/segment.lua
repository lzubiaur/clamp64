-- segment.lua
local Entity = require 'entities.base.entity'

local Segment = Class('Segment',Entity)

--- Initialize a path segment with a start and end point
function Segment:initialize(world,ax,ay,bx,by,thickness)
  -- Create a dummy rectangle and update its dimenions afterwards
  Entity.initialize(self,world,0,0,1,1)

  self.updateEndPoint = function(self,x,y)
    self.bx,self.by = x,y
    local offset = game.visible:pointToPixel(thickness or conf.pathOffset)
    local w = math.abs(ax - bx)
    local h = math.abs(ay - by)
    local x = math.min(ax,bx) - offset / 2
    local y = math.min(ay,by) - offset / 2
    w = w > 0 and w + offset or offset
    h = h > 0 and h + offset or offset
    world:update(self,x,y,w,h)
    self.x,self.y,self.w,self.h = x,y,w,h
  end
  self:updateEndPoint(bx,by)
  self.isVertical = self.w > self.h
end

function Segment:draw()
end

return Segment
