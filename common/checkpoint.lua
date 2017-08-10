-- checkpoint.lua

local Checkpoint = Class('Checkpoint')

function Checkpoint:initialize(world)
  self.pos,self.world = {},world
  Timer.every(1,function()
    self:trigger()
  end)
  -- save original position if no other checkpoint are valide
  self.ox,self.oy = self:trigger()
end

function Checkpoint:trigger()
  local t = {}
  local count = Beholder.trigger('checkpoint',t)
  if not count or count < 1 then return end -- Player might not exists (e.g. killed)
  table.insert(self.pos,t)
  if #self.pos > 10 then
    table.remove(self.pos,1)
  end
  -- Log.debug('Checkpoint',unpack(t))
  return unpack(t)
end

-- Don't return checkpoint inside a polygon
local function filter(item)
  return item.class.name == 'Polygon'
end

function Checkpoint:getLastPosition()
  local p = self.pos
  for i=#p,1,-1 do
    local x,y,w,h = unpack(p[i])
    local item,len = self.world:queryRect(x,y,w,h,filter)
    if len == 0 then return unpack(p[i]) end
  end
  return self.ox,self.oy
end

return Checkpoint
