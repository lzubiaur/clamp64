-- path.lua
local Entity = require 'entities.base.entity'
local Segment = require 'entities.segment'

local Path = Class('Path',Entity)

--- Initialize a new path
function Path:initialize(world,ax,ay,bx,by)
  self.sgmts = {}
  -- TODO update size when adding new segments
  Entity.initialize(self,world,ax,ay,1,1)
end

--- Extend this path with a new segmet
function Path:addSegment(bx,by)
  if self.prev then self.prev.isSolid = true end
  local ax,ay
  if self.cur then
    ax,ay = self.cur.bx,self.cur.by
  else
    ax,ay = self.x,self.y
  end
  self.prev = self.cur
  self.cur = Segment:new(self.world,ax,ay,bx,by)
  table.insert(self.sgmts,self.cur)
end

--- Change the current/last segment end point
function Path:updateEndPoint(x,y)
  self.cur:updateEndPoint(x,y)
end

--- Return all the points for this path
-- @return An array of points
function Path:getPoints()
  local pts = {}
  table.insert(pts,self.x)
  table.insert(pts,self.y)
  for _,sg in ipairs(self.sgmts)  do
    table.insert(pts,sg.bx)
    table.insert(pts,sg.by)
  end
  return pts
end

--- Remove this path and all its segments
function Path:destroy()
  for _,sg in ipairs(self.sgmts) do
    sg:destroy()
  end
  self.sgmts = nil
  Entity.destroy(self)
end

return Path
