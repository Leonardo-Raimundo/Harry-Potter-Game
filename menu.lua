local composer = require( "composer" )

local scene = composer.newScene()

local function gotoGame()
	composer.gotoScene ("game", {time=800, effect="crossFade"})
end

local function gotoRecords()
	composer.gotoScene ("records", {time=800, effect="crossFade"})
end

function scene:create(event)
	local sceneGroup = self.view

	local bg = display.newImageRect(sceneGroup,"imagens/bg-menu.jpg", 1063/3, 1890/3)
	bg.x=display.contentCenterX
	bg.y=display.contentCenterY

	local title = display.newImageRect(sceneGroup,"imagens/logo.png", 370/2, 334/2)
	title.x=display.contentCenterX +10
	title.y= 90

	local buttonPlay = display.newText(sceneGroup,"Play", display.contentCenterX, 185, "fonts/Tangerine-Bold.ttf", 65)
	buttonPlay:setFillColor (0.82, 0.86, 1)

	local buttonRecords = display.newText (sceneGroup, "Records", display.contentCenterX, 260, "fonts/Tangerine-Bold.ttf", 65)
	buttonRecords:setFillColor (0.82, 0.86, 1)

	buttonPlay:addEventListener("tap", gotoGame)
	buttonRecords:addEventListener("tap", gotoRecords)

	menuSound = audio.loadStream("audio/menuSound.wav")
end

function scene:show(event)
	audio.play(menuSound, {channel=3, loops=-1})
	local sceneGroup = self.view
	local phase = event.phase

	if(phase == "will") then

	elseif(phase == "did") then
	end
end

function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	audio.stop(3)
	end
end

function scene:destroy(event)

	local sceneGroup = self.view
	audio.dispose(menuSound)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene