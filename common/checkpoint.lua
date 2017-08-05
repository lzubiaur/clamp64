-- checkpoint.lua

local Checkpoint = Class('Checkpoint')

function Checkpoint:initialize(world)
  self.pos,self.world = {},world
  Timer.every(1,function()
    self:trigger()
  end)
  self:trigger()
end

function Checkpoint:trigger()
  local t = {}
  local count = Beholder.trigger('checkpoint',t)
  if not count or count < 1 then return end -- Player might not exists (e.g. killed)
  table.insert(self.pos,t)
  if #self.pos > 10 then
    table.remove(self.pos,1)
  end
  Log.debug('Checkpoint',unpack(t))
end

function Checkpoint:getLastPosition()
  local p = self.pos
  for i=#p,1,-1 do
    local item,len = self.world:queryRect(unpack(p[i]))
    if len == 0 then return unpack(p[i]) end
  end
  return 0,0
end

return Checkpoint
