local composer = require("composer")

local scene = composer.newScene()

local json = require("json")
local pontosTable = {}
local filePath = system.pathForFile ("score.json", system.DocumentsDirectory)

local function carregaPontos ()
		local file = io.open (filePath, "r") 
		
		if file then
			local contents = file:read ("*a") 
			io.close (file ) 
			pontosTable = json.decode (contents) 
		end 
		if (pontosTable == nil or #pontosTable == 0 ) then
			pontosTable = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0} 
		end
end 

local function savePontos ()
	for i = #pontosTable, 11, -1 do  
		table.remove( pontosTable, i ) 
	end 

	local file = io.open (filePath, "w") 
	if file then 
		file:write (json.encode (pontosTable) ) 
		io.close( file ) 
	end 
end 

local function gotoMenu ()
	composer.gotoScene( "menu", {time=800, effect="crossFade"})
end

function scene:create( event )

	local sceneGroup = self.view

	carregaPontos()
	table.insert( pontosTable, composer.getVariable ( "finalScore") ) 
	composer.setVariable ("finalScore", 0)

	local function compare (a, b)
	return a > b
	end

table.sort (pontosTable, compare)

savePontos()

local bg = display.newImageRect(sceneGroup, "imagens/records-bg.png", 409, 610)
bg.x = display.contentCenterX
bg.y = display.contentCenterY

local recordsHeader = display.newText( sceneGroup, "Records", display.contentCenterX, 80, "fonts/Tangerine-Bold.ttf", 70)
	recordsHeader:setFillColor(0.88, 0, 0.02)
	for i = 1, 5 do
		if (pontosTable [i]) then 
			local yPos = 150 + (i * 56) 

local rankNum = display.newText (sceneGroup, i .. "º", display.contentCenterX-30, yPos-60, "fonts/Tangerine-Bold.ttf", 50)
	rankNum:setFillColor(1, 0.6, 0.05)
	rankNum.anchorX = 1 

local thisScore = display.newText( sceneGroup, pontosTable[i], display.contentCenterX-10, yPos-60, "fonts/Tangerine-Bold.ttf", 50)
	thisScore:setFillColor(0)
	thisScore.anchorX = 0 
		end
	end 
local buttonMenu = display.newText (sceneGroup, "Menu", display.contentCenterX, 430, "fonts/Tangerine-Bold.ttf", 45)
	buttonMenu:setFillColor(0.88, 0, 0.02)
	buttonMenu:addEventListener( "tap", gotoMenu )

	recordsSound = audio.loadStream("audio/records-sound.wav")
end

function scene:show( event )
	audio.play(recordsSound, {channel=4, loops=-1})
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		
	elseif ( phase == "did" ) then
	end
end

function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	audio.stop(4)
	composer.removeScene( "records" )
	end
end

function scene:destroy( event )

	local sceneGroup = self.view
	audio.dispose(recordsSound)
		
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene