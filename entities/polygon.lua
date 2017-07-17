-- polygon.lua

-- The ´Polygon´ class is a rectilinear polygon
-- (http://en.wikipedia.org/wiki/Rectilinear_polygon) where only vertical and
-- horizontal edges are allowed.
-- Every Polygon edge is a `bump` rectangle with a very small width/height so
-- they are like lines.

local Entity = require 'entities.base.entity'
local PolygonShape = require 'modules.HC.polygon'
local Segment = require 'entities.segment'

local Polygon = Class('Polygon',Entity)

function Polygon:initialize(world,opt,...)
  self._poly = PolygonShape(...)

  local ax,ay,bx,by = self._poly:bbox()
  Entity.initialize(self,world,ax,ay,bx-ax,by-ay)

  -- Create the polygon vertical and horizontal edges
  local edges = {}
  local pts = {...}
  local len = #pts
  for i=1,len-2,2 do
    table.insert(edges,Segment:new(world,pts[i],pts[i+1],pts[i+2],pts[i+3]))
  end
  table.insert(edges,Segment:new(world,pts[len-1],pts[len],pts[1],pts[2]))
  self.edges = edges
end

function Polygon:getCenter()
  -- TODO
  -- return mlib.polygon.getCentroid(unpack(util.unpack(self.vertices)))
end

function Polygon:destroy()
  for _,edge in ipairs(self.edges) do
    edge:destroy()
  end
  self.edge = nil
  Entity.destroy(self)
end

function Polygon:draw(debugDraw)
end

return Polygon
