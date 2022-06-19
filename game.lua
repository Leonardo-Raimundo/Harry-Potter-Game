local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

local backGroup 
local mainGroup 
local uiGroup 

local score = 0
local scoreText 
local hp = 3
local countBeans = 4
local hpText 
local dead = false

local harry
local rock
local trunk
local lightning
local red
local purple
local green
local striped

local spellSound = audio.loadSound("audio/spell-sound.wav")
local bgSound = audio.loadStream("audio/bg-sound.wav")
local menuSound
local recordsSound
local collectSound = audio.loadSound("audio/collect-sound.wav")

local landscapeTable = {}
local enemiesTable= {}
local beansTable={}
local gameLoopTimer

audio.play(bgSound, {channel=1, loops=-1})

--função para colocar movimento no personagem.
local function moveHarry(event)
	local harry = event.target
	local phase = event.phase

	if("began"==phase) then
		display.currentStage:setFocus(harry)
		harry.touchOffsetX=event.x -harry.x
		harry.touchOffsetY=event.y -harry.y

	elseif("moved"==phase) then
		harry.x=event.x -harry.touchOffsetX
		harry.y=event.y -harry.touchOffsetY

	elseif("ended"==phase or "cancelled"==phase) then
		display.currentStage:setFocus(nil)
	end
	return true
end

--[[removendo esse personagem por enquanto.
local pixie = display.newImageRect("imagens/pixie.png", 567/5, 440/5)
pixie.x=display.contentCenterX
pixie.y=display.contentHeight -390
physics.addBody(pixie, "dynamic", {radius=40, bounce=0.8})
able.insert(enemiesTable, pixie)--]]


-- table.insert(beansTable, striped)


local function create_imp()
	local imp = display.newImageRect(mainGroup,"imagens/imp.png", 574/6, 435/6)
	physics.addBody(imp, "dynamic", {radius=40, bounce=0.8})
	imp.myName="Imp"
	table.insert(enemiesTable, imp)

	local location = math.random (2)
		if(location == 1) then
			imp.x = -60
			imp.y = math.random(500)
			imp:setLinearVelocity(math.random (40, 120), math.random (20, 60)) 
		
		elseif(location == 2) then
			imp.x = 200
			imp.y = -60
			imp:setLinearVelocity(math.random(-40, 40),math.random(40,120))
		end
end

local function create_spider()
	local spider = display.newImageRect(mainGroup,"imagens/spider.png", 622/5, 401/5)
	physics.addBody(spider, "dynamic", {radius=40, bounce=0.8})
	spider.myName="Spider"
	table.insert(enemiesTable, spider)

	local location = math.random (2)
	if(location ==1) then
		spider.x = -30
		spider.y = 180
		spider:setLinearVelocity(math.random(40,120), math.random(20,60))

	elseif(location ==2)then
		spider.x = 400
		spider.y = 200
		spider:setLinearVelocity(math.random(-40,40), math.random(40,120))
	end
end

local function gameLoop()
	create_imp()
	create_spider()

	for i = #enemiesTable, 1, - 1 do
		local thisImp = enemiesTable [i]
		local thisSpider = enemiesTable[i]

		if (thisImp.x < -100 or
			thisSpider.x < -100 or

			thisImp.x > display.contentWidth +100 or 
			thisSpider.x > display.contentWidth +100 or

			thisImp.x < -100 or
			thisSpider.x < -100 or

			thisImp.x > display.contentHeight +100 or 
			thisSpider.x > display.contentHeight +100)
		then
			display.remove(thisImp)
			display.remove(thisSpider)
			table.remove(enemiesTable, i)
		end
	end
end

local function shoot()
	audio.play(spellSound, {channel=2})
	local newSpell = display.newImageRect(mainGroup, "imagens/spell.png",280/4, 500/10)
	physics.addBody(newSpell, "dynamic", {isSensor=true})
	newSpell.isBullet=true
	newSpell.myName="Spell"
	newSpell.x = harry.x
	newSpell.y = harry.y
	newSpell:toBack()
	transition.to(newSpell, {y=-40, time=600, onComplete=function() display.remove(newSpell) end })
end

local function atualizeText()
	hpText.text = "   " .. hp
	scoreText.text = "score: " .. score
end

local function restoreHarry()
	harry.isBodyActive = false
	harry.x = display.contentCenterX
	harry.y = display.contentHeight - 100

	transition.to(harry, {alpha=1, time=4000, 
		onComplete = function()
			harry.isBodyActive = true
			dead = false
	end
})
end

local function endGame()
	composer.setVariable("finalScore", score)
	composer.gotoScene("recordes", {time=800, effect="crossFade"})
end

local function onCollision(event)
	if(event.phase=="began") then
		local obj1 = event.object1
		local obj2 = event.object2

-- evento de colisão do feitiço com os imps e aranhas
	if (((obj1.myName == "Spell" and obj2.myName == "Imp") or
		(obj1.myName == "Imp" and obj2.myName == "Spell")) 
		or ((obj1.myName=="Spell" and obj2.myName=="Spider") or
		(obj1.myName=="Spider" and obj2.myName=="Spell")))
		then
		display.remove(obj1)
		display.remove(obj2)

		for i = #enemiesTable, 1, -1 do
			if (enemiesTable [i] == obj1 or enemiesTable [i] == obj2) then
				table.remove(enemiesTable, i)
				break
				end
			end
			score=score+100
			scoreText.text="score: " .. score

-- evento de colisão do player com os imps e aranhas
	elseif(((obj1.myName == "Harry" and obj2.myName == "Imp") or
		(obj1.myName == "Imp" and obj2.myName == "Harry"))
		or ((obj1.myName=="Harry" and obj2.myName=="Spider") or
		(obj1.myName=="Spider" and obj2.myName=="Harry")))
		then
			if (dead == false) then
				dead = true

			hp = hp -1
			hpText.text = "   " .. hp

				if (hp == 0) then
					display.remove(harry)
					timer.performWithDelay(1000, endGame)
				else
					harry.alpha = 0
					timer.performWithDelay(1000, restoreHarry)
				end	
			end
		end
	end
end

local function onCollisionBeans(event)
	if(event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2

	if(((obj1.myName == "Harry" and obj2.myName == "red") or
			(obj1.myName == "red" and obj2.myName == "Harry"))
			
			or ((obj1.myName=="Harry" and obj2.myName=="purple") or
			(obj1.myName=="purple" and obj2.myName=="Harry"))
			
			or ((obj1.myName=="Harry" and obj2.myName=="green") or
			(obj1.myName=="green" and obj2.myName=="Harry"))

			or ((obj1.myName=="Harry" and obj2.myName=="striped") or
			(obj1.myName=="striped" and obj2.myName=="Harry")))
	then
		if(obj1.myName=="red" or obj1.myName=="purple" or obj1.myName=="green" or obj1.myName=="striped") 
			then
				display.remove(obj1)
				audio.play(collectSound,{channel=5})
				countBeans = countBeans - 1

		elseif(obj2.myName=="red" or obj2.myName=="purple" or obj2.myName=="green" or obj2.myName=="striped") 
			then
				display.remove(obj2)
				audio.play(collectSound,{channel=5})
				countBeans = countBeans - 1

		end -- fecha if dos feijões myname remove

			score=score+200
			scoreText.text="score: " .. score

			if(countBeans==0) then
					display.remove(harry)
					timer.performWithDelay(1000, endGame)
			end

	end -- fecha o if do myname
	end -- fecha if do phase
end -- fecha função

function scene:create(event)
	local sceneGroup = self.view

	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local bg = display.newImageRect (backGroup, "imagens/bg.png", 450, 450)
	bg.x = display.contentCenterX
	bg.y = display.contentCenterY

	rock=display.newImageRect(backGroup,"imagens/rock.png", 602/5, 414/5)
	rock.x=display.contentWidth -20
	rock.y=display.contentHeight -300
	physics.addBody(rock, "static")

	trunk = display.newImageRect(backGroup,"imagens/trunk.png", 707/6, 353/6)
	trunk.x=display.contentWidth -300
	trunk.y=display.contentHeight -130
	physics.addBody(trunk, "static")
	table.insert(landscapeTable, trunk)

	harry = display.newImageRect(mainGroup,"imagens/hp.png", 1000/12, 1000/12)
	harry.x=display.contentCenterX
	harry.y=display.contentHeight - 100
	physics.addBody(harry, {radius=50, isSensor=true})
	harry.myName="Harry"

	red = display.newImageRect(mainGroup,"imagens/red.png", 200/5, 200/5)
	red.x=display.contentWidth -310
	red.y=display.contentHeight -160
	physics.addBody(red, "static", {radius=40, bounce=0.8})
	table.insert(beansTable, red)
	red.myName = "red"

	purple=display.newImageRect(mainGroup,"imagens/purple.png", 200/5,200/5)
	purple.x=display.contentWidth -15
	purple.y=display.contentHeight -400
	physics.addBody(purple, "static", {radius=40, bounce=0.8})
	table.insert(beansTable, purple)
	purple.myName = "purple"

	green=display.newImageRect(mainGroup,"imagens/green.png", 200/4, 200/4)
	green.x=display.contentWidth -30
	green.y=display.contentHeight -90
	physics.addBody(green, "static", {radius=40, bounce=0.8})
	table.insert(beansTable, green)
	green.myName = "green"

	striped=display.newImageRect(mainGroup,"imagens/striped.png", 200/5, 200/5)
	striped.x=display.contentWidth -240
	striped.y=display.contentHeight -320
	physics.addBody(striped, "static", {radius=40, bounce=0.8})
	table.insert(beansTable, striped)
	striped.myName = "striped"

	lightning = display.newImageRect(uiGroup, "imagens/lightning.png", 632/9, 395/9)
	lightning.x =  10
	lightning.y =  90

	hpText= display.newText(uiGroup,"   " .. hp, 30, 90, Arial, 25)
	scoreText= display.newText(uiGroup,"score: " .. score, 40, 50, Arial, 25)

	harry:addEventListener("tap", shoot)
	harry:addEventListener("touch", moveHarry)
end

function scene:show(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		-- Quando a cena está pronta para ser exibida antes da transição.

	elseif (phase == "did") then
		-- Quando a cena já está sendo exibida após a transição.

		physics.start()
		Runtime:addEventListener("collision", onCollision)
		Runtime:addEventListener("collision", onCollisionBeans)
		gameLoopTimer = timer.performWithDelay(1000, gameLoop, 0)
		audio.play(somdeFundo, {channel=1, loops=-1})
		
	end
end

function scene:hide(event)

	local sceneGroup = self.view
	local phase = event.phase

	if (phase == "will") then
		timer.cancel (gameLoopTimer)

	elseif (phase == "did") then
		Runtime:removeEventListener("collision", onCollision)
		Runtime:removeEventListener("collision", onCollisionBeans)
		physics.pause ()
		audio.stop(1)
		composer.removeScene ("game")
	end
end

function scene:destroy(event)
	local sceneGroup = self.view
	audio.dispose(spellSound)
	audio.dispose(collectSound)
	audio.dispose(bgSound)
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
