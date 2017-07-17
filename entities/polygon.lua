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

local scale = 1000

local function newPath(...)
  local p = Clipper.Path()
  local n = select('#',...)
  local t = {...}
  for i=1,n,2 do
    p:add(t[i]*scale,t[i+1]*scale)
  end
  return p
end

local function pathToPoints(p)
  points = {}
  for i=1,p:size() do
    local point = p:get(i)
    table.insert(points,tonumber(point.x)/scale)
    table.insert(points,tonumber(point.y)/scale)
  end
  return points
end

function Polygon:initialize(world,opt,...)
  self._poly = PolygonShape(...)

  local ax,ay,bx,by = self._poly:bbox()
  Entity.initialize(self,world,ax,ay,bx-ax,by-ay)

  -- Create the polygon vertical and horizontal edges
  self.edges = {}
  local pts = {...}
  local len = #pts
  for i=1,len-2,2 do
    self:addEdge(pts[i],pts[i+1],pts[i+2],pts[i+3])
  end
  self:addEdge(pts[len-1],pts[len],pts[1],pts[2])

  local paths = Clipper.Paths()
  local co = Clipper.ClipperOffset()
  local cl = Clipper.Clipper()
  Beholder.group(self,function()
    Beholder.observe('entered',self,function(x,y)
      ax,ay = x,y
    end)
    Beholder.observe('moved',self,function(bx,by)
      paths:add(newPath(ax,ay,bx,by))
      ax,ay = bx,by
    end)
    Beholder.observe('leaved',self,function(bx,by)
      paths:add(newPath(ax,ay,bx,by))
      local w = game.visible:pointToPixel(6) * scale
      cl:addPath(newPath(self._poly:unpack()),'subject')
      cl:addPaths(co:offsetPaths(paths,w,'miter','openSquare'),'clip')
      local out = cl:execute('difference')
      for i=1,out:size() do
        Polygon:new(self.world,nil,unpack(pathToPoints(out:get(i))))
      end
      self:destroy()
    end)
  end)
end

function Polygon:addEdge(ax,ay,bx,by)
  local sg = Segment:new(self.world,ax,ay,bx,by)
  sg.isPolygonEdge = true
  sg.polygon = self
  table.insert(self.edges,sg)
end

function Polygon:contains(x,y)
  return self._poly:contains(x,y)
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
  g.setColor(255,0,0,255)
  g.polygon('line',self._poly:unpack())
end

return Polygon
