-- entities/cannon.lua

local Entity = require 'entities.base.entity'
local Quad = require 'entities.base.quad'
local Animated = require 'entities.base.animated'
local Bullet = require 'entities.bullet'

local Cannon = Class('Cannon',Entity)

function Cannon:initialize(world,x,y,opt)
  opt = opt or {}
  opt.zOrder = -1
  Entity.initialize(self,world,x,y,16,16,optl)
  local tilesheet = Assets.img.cannon_tilesheet
  local grid = Anim8.newGrid(20,20,tilesheet:getDimensions())
  local anim = self:addSprite(Animated:new(tilesheet,0,0,20,20))
  anim:setPosition(8,8)

  local closing,opening
  opening = function()
    -- Set the next animation
    anim:setAnimation(grid('1-3',1,'1-2',2),{.3,.3,.3,.3,.1},closing)
  end

  closing = function()
    -- Set the next animation
    anim:setAnimation(grid(1,2,'3-1',1),.3,opening)
    -- create bullet
    local cx,cy = self:getCenter()
    local dir = (Vector(game.player:getCenter())-Vector(cx,cy)):normalized()
    Bullet:new(world,cx,cy,dir.x,dir.y,{zOrder=1})
  end
  opening()
  anim:pauseAtStart()
  self.anim = anim
end

function Cannon:update(dt)
  local cx,cy = self:getCenter()
  local items,len = self.world:queryRect(cx-20,cy-20,40,40,function(item)
    return item.class.name == 'Player'
  end)
  if len > 0 then
    self.anim:resume()
  end
  Entity.update(self,dt)
end

return Cannon
