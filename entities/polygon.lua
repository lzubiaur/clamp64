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

local scale = 100

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

-- Create a new Polygon Entity
-- opt: table with entity options (optional)
-- ...: can be a array of vertices (e.g. 100,100,200,200,...) or a PolygonShape object (aka HC.polygon)
function Polygon:initialize(world,opt,...)
  local p,pts,len = select(1,...)
  if type(p) == 'table' then
    self.shape = p
    pts = { p:unpack() }
    len = #pts
  else
    self.shape = PolygonShape(...)
    pts = table.pack(...)
    len = #pts
  end

  local ax,ay,bx,by = self.shape:bbox()
  Entity.initialize(self,world,ax,ay,bx-ax,by-ay)

  -- Create the polygon vertical and horizontal edges
  self.edges = {}
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
      -- Offet the path
      local w = game.visible:pointToPixel(conf.pathOffset/2) * scale
      cl:addPath(newPath(self.shape:unpack()),'subject')
      cl:addPaths(co:offsetPaths(paths,w,'miter','openSquare'),'clip')
      self:split(cl:execute('difference'))
      self:destroy()
    end)
  end)

end

function Polygon:split(paths)
  local target = nil
  -- Look for the biggest polygon area and for polygons with enemies
  for i=1,paths:size() do
    local p = PolygonShape(unpack(pathToPoints(paths:get(i))))
    local enemies,len = self:getEnemiesInRect(p:bbox())
    if len > 0 then
      target = p
      break
    elseif not target or p.area > target.area then
      target = p
    end
  end
  if target and target.area > 100 then
    local p = Polygon:new(self.world,nil,target)
    Beholder.trigger('area',self.shape.area - target.area)
  end
end

function Polygon:getEnemiesInRect(l,t,r,b)
  return self.world:queryRect(l,t,r-l,b-t,function(item)
    return item.class.name == 'Enemy'
  end)
end

function Polygon:addEdge(ax,ay,bx,by)
  local sg = Segment:new(self.world,ax,ay,bx,by,.1)
  sg.isPolygonEdge = true
  sg.polygon = self
  table.insert(self.edges,sg)
end

function Polygon:contains(x,y)
  return self.shape:contains(x,y)
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
  g.setColor(255,0,77,200) -- red
  -- g.setColor(255,163,0,255) -- yellow
  -- g.setColor(69,69,69,255) -- black
  g.polygon('line',self.shape:unpack())
end

return Polygon
