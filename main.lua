local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed( os.time () )

composer.gotoScene( "menu" )

audio.reserveChannels(1)
audio.setVolume(0.4, {channel=1})

audio.reserveChannels(2)
audio.setVolume(5.0, {channel=2})

audio.reserveChannels(3)
audio.setVolume(1.0,{channel=3})

audio.reserveChannels(4)
audio.setVolume(0.4, {channel=4})

audio.reserveChannels(5)
audio.setVolume(5.0, {channel=5})