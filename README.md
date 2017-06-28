Basic framework to bootstrap a Love2D game project.

## Features


## Nice to have

* tags (e.g. search for entities using tags)
* Push notifications
* Android rate plugins https://github.com/hotchemi/Android-Rate
* Google Leaderboards

## project structure

README.md
conf.lua
main.lua
|-- common
|  |-- game.lua
|  |-- version.lua
|  |-- build.lua  
|-- design
|-- entities
|-- gamestates
  |-- debug
|-- modules
|-- resources
  |-- fonts
  |-- maps
  |-- music
  |-- shaders

## Events

* GameOver
* ResetLevel
* WinLevel
* WinSeason
* (Checkpoint)

## TODO

Search for the following in the code

TODO
HACK
XXX
FIXME
LZU

## Game states

* Start
* Play
* Paused
* GameplayIn/GameplayOut
* Loading
* Win
* Debug
