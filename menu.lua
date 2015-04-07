local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ( "widget" )

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

local function goHost( event )
   if event.phase == "ended" then

      composer.gotoScene( "multiplayer")

   end
end

local function goJoin( event )
   if event.phase == "ended" then

      composer.gotoScene( "join")

   end
end

-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view

  local hostButt = widget.newButton( 
   {
      left = display.contentCenterX,
      top = display.contentCenterY,
      id = "hostButt",
      label = "Host",
      onEvent = goHost
      } )
   hostButt.anchorX = 0.5
   hostButt.anchorY = 0.5
   hostButt.x = display.contentCenterX
   hostButt.y = display.contentCenterY

   sceneGroup:insert( hostButt )

   local joinButt = widget.newButton( 
   {
      left = display.contentCenterX,
      top = display.contentCenterY,
      id = "joinButt",
      label = "Join",
      onEvent = goJoin
      } )
   joinButt.anchorX = 0.5
   joinButt.anchorY = 0.5
   joinButt.x = display.contentCenterX
   joinButt.y = display.contentCenterY - 100

   sceneGroup:insert( joinButt )

end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene