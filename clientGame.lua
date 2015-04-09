local composer = require( "composer" )
local scene = composer.newScene()
local widget = require ( "widget" )
local sData = require ("sData")
local cData = require ("cData")

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

local sock, ip, port
local stopClient
local messageData, message

---------------------------------------------------------------------------------

local function connectToServer( ip, port )
    local sock, err = socket.connect( ip, port )
    if sock == nil then
        return false
    end
    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    sock:send( "we are connected\n" )
    return sock
end

local function createClientLoop( sock, ip, port )

    local buffer = {"Client Sending Test\n"}
    local clientPulse

    local function cPulse()
        local allData = {}
        local data, err

        repeat
            data, err = sock:receive()
            --print("The message received is " .. data)
            if data then
              print("There was Data")
              allData[#allData+1] = data
            end
            if ( err == "closed" and clientPulse ) then  --try again if connection closed
                connectToServer( ip, port )
                data, err = sock:receive()
                if data then
                    allData[#allData+1] = data
                end
            end
        until not data

        if ( #allData > 0 ) then
            for i, thisData in ipairs( allData ) do
              --react to incoming data
                print( "clientData: " .. thisData )
                --cData.incoming = thisData
                --message.text = thisData 
            end
        end

        for i, msg in pairs( buffer ) do
            local data, err = sock:send(msg)
            if ( err == "closed" and clientPulse ) then  --try to reconnect and resend
                connectToServer( ip, port )
                data, err = sock:send( msg )
            end
        end
    end

    --pulse 10 times per second
    clientPulse = timer.performWithDelay( 100, cPulse, 0 )

    local function stopClient()
        timer.cancel( clientPulse )  --cancel timer
        clientPulse = nil
        sock:close()
        print("Client Closed")
    end
    return stopClient
end

local function goConnect2()

   if sock == false then
      print("It didn't work")
   else
      stopClient = createClientLoop( sock, ip, port)
   end
end

local function goConnect(event)
   local phase = event.phase

   if phase == "ended" then
      timer.performWithDelay( 2000, goConnect2, 1 )
      sock = connectToServer(ip, port)
   end
end

local function stopConnect(event)
   local phase = event.phase

   if phase == "ended" then
      stopClient()
   end
end

-- "scene:create()"
function scene:create( event )

   local sceneGroup = self.view

   print(sData.serverData["ip"] .. ", " .. sData.serverData["port"])
   ip = sData.serverData["ip"]
   port = sData.serverData["port"]

   local message = native.newTextField( display.contentCenterX, display.contentCenterY, 250, 30 )
   message.text = "This is the message"

   local connectButt = widget.newButton
   {
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "connectButt",
    label = "Connect",
    onEvent = goConnect
   }
   connectButt.anchorX = 0.5
   connectButt.anchorX = 0.5
   connectButt.x = display.contentCenterX
   connectButt.y = display.contentHeight - 170
   sceneGroup:insert(connectButt)

   local stopButt = widget.newButton
   {
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "stopButt",
    label = "STOP",
    onEvent = stopConnect
   }
   stopButt.anchorX = 0.5
   stopButt.anchorX = 0.5
   stopButt.x = display.contentCenterX
   stopButt.y = display.contentHeight - 115
   sceneGroup:insert(stopButt)

   messageData = message.text .. "\n"


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
      stopClient()
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