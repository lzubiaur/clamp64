-- main.lua

local platform = love.system.getOS()

-- Global game configuration
conf = {
  version = require 'common.version',
  build = require 'common.build', -- release/debug build
  tests = false, -- run tests
  drawBBox = false,
  profiling = false, -- enable/disable code profiling report
  -- The game design resolution. Use a 16:9 aspect ratio
  width = 64, height = 64,
  -- Bump world cell size. Should be a multiple of the map's tile size.
  cellSize = 64,
  -- Run on a mobile platform?
  mobile = platform == 'Android' or platform == 'iOS',
  -- grafics
  lineWidth = 1,
  pointSize = 1,
  -- TODO add camera parameters (camera borders, smooth/lerp)
  camOffsetX = 0, -- offset from the player
  camMarginX = 10, -- horizontal outer space allowed to the camera to move outside the map/world
  camMarginY = 10, -- veritcal margin must be big enough so the player is still updated when outside the map.
  -- Player config
  gravity = 0, -- vertical gravity (default 1000)
  playerVelocity = 0, -- Player horizontal velocity in pixel/second. Default 500.
  playerImpulse = -1000, -- vertical impulse when jumping
  playerImpulse2 = -1000, -- jump 2 impulse
  playerMaxVelocity = { x=1000,y=1000 },
  -- custom
  pathOffset = 1,
}

-- Load 3rd party libraries/modules globally.
-- All modules should start with a capital letter.
Class     = require 'modules.middleclass'
Stateful  = require 'modules.stateful'
Inspect   = require 'modules.inspect'
Push      = require 'modules.push'
Loader    = require 'modules.love-loader'
Log       = require 'modules.log'
Clipper   = require 'modules.clipper'
Bump      = require 'modules.bump'
HC        = require 'modules.HC'
STI       = require 'modules.sti'
Tween     = require 'modules.tween'
Lume      = require 'modules.lume'
Gamera    = require 'modules.gamera'
Beholder  = require 'modules.beholder'
-- Cron      = require 'modules.cron' -- Not used
-- Chain = require 'modules.knife.chain'
i18n      = require 'modules.i18n'
Timer     = require 'modules.hump.timer'
Vector    = require 'modules.hump.vector'
Hue       = require 'modules.colors'
Parallax  = require 'modules.parallax'
Binser    = require 'modules.binser'
Matrix    = require 'modules.matrix'
EditGrid  = require 'modules.editgrid'
Anim8     = require 'modules.anim8'
Assets    = require 'modules.cargo'.init 'resources'

if conf.build == 'debug' then
  ProFi = require 'modules.profi'
  Lust = require 'modules.lust'
end

-- Love2D shortcuts
g = love.graphics

-- Log level
Log.level = conf.build == 'debug' and 'debug' or 'warn'
Log.usecolor = true

-- Note on loading package:
-- On some platforms like mac osx, the file system is by default not case sensitive
-- which means require is not case sensitive too and might cause some side effect.
-- For instance if we create the file mypackage.lua then require 'myapackage' or
-- require 'MyPackage' or require 'MYPACKAGE' will be able to load  "mypackage.lua".
-- But because it's loaded with different names (mypackage, MyPackage or MYPACKAGE)
-- it will be loaded several times and different instance of the package will be
-- kept in the table package.loaded. This can have side effect if we want to use
-- the same package instance but loaded it with a different name.

require 'common.palette'

local Game = require 'common.game'
-- Game states must be loaded after the Game class is created
require 'gamestates.loading'
require 'gamestates.start'
require 'gamestates.play'
require 'gamestates.paused'
require 'gamestates.transitions'
require 'gamestates.win'
require 'gamestates.gameover'
require 'gamestates.credits'
if conf.build == 'debug' then
  require 'gamestates.debug'
  if conf.tests then
    require 'gamestates.tests'
  end
end

require 'entities.blink' -- player blink state

-- Add table.pack
if not table.pack then
  table.pack = function(...)
    return { n=select('#',...), ...}
  end
end

-- Add table.pack
if not table.pack then
  table.pack = function(...)
    return { n=select('#',...), ...}
  end
end

-- The global game instance
game = nil

function love.load()
  -- Avoid anti-alising/blur when scaling. Useful for pixel art.
  love.graphics.setDefaultFilter('nearest', 'nearest', 0)

  -- setBackgroundColor doesnt work with push
  -- love.graphics.setBackgroundColor(0,0,0)

  Log.info(package.path)
  -- TODO get info about lua/luajit version
  Log.info(_VERSION)
  Log.debug('bit',bit ~= nil)
  Log.info("Love version",love.getVersion())

  setupMultiResolution()

  -- Create the game instance
  game = Game:new()
  -- must call gotoState "outside" Game:initialize or the global 'game'
  -- instance will not be available inside the 'start' state yet
  if conf.build == 'debug' and conf.tests then
    game:gotoState('TestState')
  else
    game:gotoState('Play')
  end
end

function setScaledResolution(w,h)
  -- https://developer.android.com/guide/practices/screens_support.html
  -- https://stackoverflow.com/questions/6272384/most-popular-screen-sizes-resolutions-on-android-phones
  -- http://www.cocos2d-x.org/wiki/Multi_resolution_support

  local res = {
    small  = { x=480,  y=320  },
    medium = { x=800,  y=480  },
    large  = { x=1200, y=768  },
    xlarge = { x=2560, y=1600 }
  }
  -- Scaled resolution
  local sw,sh = 0,0

  if w < res.medium.x then
    sw,sh = res.small.x,res.small.y
    conf.resolution = 'small'
  elseif w < res.large.x then
    sw,sh = res.medium.x,res.medium.y
    conf.resolution = 'medium'
  elseif w < res.xlarge.x then
    sw,sh = res.large.x,res.large.y
    conf.resolution = 'large'
  else
    sw,sh = res.xlarge.x,res.xlarge.y
    conf.resolution = 'xlarge'
  end

  conf.sw,conf.sh = sw,sh
  conf.scaleX, conf.scaleY = sw / conf.width, sh / conf.height
  Log.info('Screen size',w,h)
  Log.info('Design size',conf.width,conf.height)
  Log.info('Scaled size',conf.sw,conf.sh)
  Log.info('Resolution type',conf.resolution)
  Log.info('Resolution scale',conf.scaleX,conf.scaleY)
end

function setupMultiResolution()
  local w,h,flags = love.window.getMode()
  -- setScaledResolution(w,h)
  conf.sw,conf.sh = conf.width,conf.height
  conf.scaleX,conf.scaleY = 1,1
  Push:setupScreen(conf.sw,conf.sh, w,h, {
    fullscreen = conf.mobile,
    resizable = not conf.mobile,
    highdpi = flags.highdpi,
    canvas = true,  -- Canvas is required to scale the camera properly
    stretched = false, -- Keep aspect ratio or strech to borders
    pixelperfect = true,
  })
end

function love.draw()
  game:draw()
end

function love.update(dt)
  --  if dt > .02 then dt = .02 end
  game:update(dt)
end

if conf.build == 'debug' and conf.profiling then
  local run = love.run
  function love.run()
    ProFi:start()
    run()
    ProFi:stop()
    ProFi:writeReport('ProfilingReport.txt')
  end
end

-- Must call push:resize when window resizes.
-- Also called on mobile at app launch because fullscreen is enabled.
function love.resize(w,h)
  Push:resize(w,h)
end

local touchId = nil
function love.touchpressed(id, x, y, dx, dy, pressure)
  if not game.multitouchEnabled and touchId then return end
  touchId = id
  game:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
  if not game.multitouchEnabled and touchId ~= id then return end
  game:touchmoved(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  if not game.multitouchEnabled and touchId ~= id then return end
  game:touchreleased(id, x, y, dx, dy, pressure)
  touchId = nil
end

function love.keypressed(key, scancode, isrepeat)
  game:keypressed(key, scancode, isRepeat)
end

-- mouse

function love.mousepressed(x, y, button, istouch)
  game:mousepressed(x,y,button,istouch)
end

function love.mousereleased(x, y, button, istouch)
  game:mousereleased(x,y,button,istouch)
end

function love.mousemoved(x, y, dx, dy, istouch)
  game:mousemoved(x,y,dx,dy,istouch)
end

function love.mousefocus(focus)
  game:mousefocus(focus)
end

-- function love.wheelmoved( x, y )
-- end

-- TODO save/restore session
-- TODO android app is put on background/foreground
function love.focus()
end

function love.visible(visible)
end

function love.quit()
  game:destroy()
  Log.info('Quit app')
end

function love.lowmemory()
  -- TODO run garbage collector
  Log.warn('System is out of memory')
end
