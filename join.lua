local composer = require( "composer" )
local scene = composer.newScene()
local loadsave = require("loadsave")
local device = require("device")
local socket = require( "socket" )
local widget = require ( "widget" )
local server = require ("server")
local sData = require ("sData")
widget.setTheme("widget_theme_ios")
display.setStatusBar(display.HiddenStatusBar)

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

local inviteButt, connectButt, deviceName, serverList, newServers, servers, serverCounter
local adButt, stopButt
local stopServer
local testText

---------------------------------------------------------------------------------

local function onRowRender(event)

    local row = event.row
    
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
    local rowTitle
    local serverName = servers[row.index]
    --print("Found Render: " .. serverName)

    if row.index == 1 then
        rowTitle = display.newText( row, "Servers", 0, 0, nil, 14 )
    rowTitle:setFillColor( 0 )
    elseif row.index > 1 then
        rowTitle = display.newText( row, serverName .. " " .. newServers[serverName]["ip"], 0, 0, nil, 14 )
        rowTitle:setFillColor( gray )
    end

    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = 0
    rowTitle.y = rowHeight * 0.5
end

local function onRowTouch(event)
   local row = event.target
   if event.phase == "release" then

      local serverName = servers[event.target.index]

      sData.serverData = newServers[serverName]
      composer.gotoScene( "clientGame")

   end
end

--Advertise the Server

-- local function advertiseServer( event )
--     local phase = event.phase
--     local serverBroadcast, broadcast
--     local counter = 0  --using this, we can advertise our IP address for a limited time

--     if phase == "ended" then
--     if adButt:getLabel() == "Invite" then
    
--     adButt:setLabel("Advertising...")

--     local send = socket.udp()
--     send:settimeout( 0 )  --this is important (see notes below)

--     print("Broadcasting")

--     broadcast = function()
--         local msg = "AwesomeGameServer" .. deviceName
--         --multicast IP range from 224.0.0.0 to 239.255.255.255
--         send:sendto( msg, "228.192.1.1", 1234 )
--         --not all devices can multicast so it's a good idea to broadcast too
--         --however, for broadcast to work, the network has to allow it
--         send:setoption( "broadcast", true )  --turn on broadcast
--         send:sendto( msg, "255.255.255.255", 1234 )
--         send:setoption( "broadcast", false )  --turn off broadcast

--         counter = counter + 1
--         if ( counter == 80 ) then  --stop after 8 seconds
--             timer.cancel( serverBroadcast )  --cancel timer
--             print("Finished Broadcasting")
--             adButt:setLabel("Invite")
--         end
--     end

--     --pulse 10 times per second
--     serverBroadcast = timer.performWithDelay( 100, broadcast, 0 )

--   end
--   end
-- end

--Get own IP

local getIP = function()
    local s = socket.udp()  --creates a UDP object
    s:setpeername( "74.125.115.104", 80 )  --Google website
    local ip, sock = s:getsockname()
    print( "myIP:", ip, sock )
    return ip
end

local function addServer()

    for serverName in pairs(newServers) do
        serverCounter = serverCounter + 1
        --print("Server Counter is: " .. serverCounter)
        servers[serverCounter] = serverName
        print("Found add function: " .. servers[2])
    end

    for i = 2, serverCounter do

    -- Insert a row into the tableView
    serverList:insertRow(
        {
            rowHeight = 36,
            rowColor = { default={ 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } },
            lineColor = { 0.5, 0.5, 0.5 }
        }
    )
    end
end

local function findServer(  )
  --local phase = event.phase
  --if phase == "ended" then

    newServers = {}
    local msg = "AwesomeGameServer"
    local stop, actualData, serverName

    local listen = socket.udp()
    listen:setsockname( "228.192.1.1", 11111 )  --this only works if the device supports multicast

    local name = listen:getsockname()
    if ( name ) then  --test to see if device supports multicast
        listen:setoption( "ip-add-membership", { multiaddr="228.192.1.1", interface = getIP() } )
    else  --the device doesn't support multicast so we'll listen for broadcast
        listen:close()  --first we close the old socket; this is important
        listen = socket.udp()  --make a new socket
        listen:setsockname( getIP(), 11111 )  --set the socket name to the real IP address
    end

    listen:settimeout( 0 )  --move along if there is nothing to hear

    local counter = 0  --pulse counter

    local function look()
        repeat
            local data, ip, port = listen:receivefrom()
            --print( "data: ", data, "IP: ", ip, "port: ", port )
            if data ~= nil then
              actualData = string.sub( data, 0, 17)
              serverName = string.sub(data, 18)
              --print(actualData .. " and " .. serverName) 
            end
            if actualData and actualData == msg then
                if not newServers[serverName] then
                    print( "Server Found: " .. serverName .. ", " .. ip .. ", " .. port )
                    local params = { ["name"]=serverName, ["ip"]=ip, ["port"]=22222 }
                    newServers[serverName] = params
                    for serverName, value in pairs(newServers) do
                        print("Found Server: " .. serverName)
                    end
                    --print(newServers[serverName]["ip"])
                end
            end
        until not data

        counter = counter + 1
        if counter == 20 then  --stop after 2 seconds
            stop()
        end
     end

     --pulse 10 times per second
     local beginLooking = timer.performWithDelay( 100, look, 0 )
     print("looking...")

     function stop()
         timer.cancel( beginLooking )
         print("stop looking")
         --evaluateServerList( newServers ) --do something with your found servers
         listen:close()  --never forget to close the socket!
         print("socket closed")
         --print(#newServers)
     end
     timer.performWithDelay( 1100, addServer, 1 )
   --end
end

local function prepServerList( event )
local phase = event.phase
if phase == "ended" then
    timer.performWithDelay( 3000, findServer )

    if serverCounter > 1 then
        for serverName in pairs(newServers) do
            newServers[serverName] = nil
        end

        serverList:deleteAllRows( )
        serverList:insertRow(
        {
            isCategory = true,
            rowHeight = 40,
            rowColor = { default={ 0.8, 0.8, 0.8, 0.8 } },
            lineColor = { 1, 0, 0 }
        }
    )
        serverCounter = 1
    end
end
end

-- local function stopFunction( event )
--     local phase = event.phase
--     if phase == "ended" then

--         stopServer()
--         stopButt.alpha = 0
--         inviteButt.alpha = 1     

--     end
-- end

-- local function createServer( event )
-- local phase = event.phase
--     if phase == "ended" then

--         stopServer = server.createServer()

--         stopButt.alpha = 1
--         inviteButt.alpha = 0

--     end
-- end

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )

local sceneGroup = self.view

local back = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
sceneGroup:insert( back )

servers = {}
serverCounter = 1

deviceName = system.getInfo("name")

-- stopButt = widget.newButton
-- {
--     left = display.contentCenterX,
--     top = display.contentCenterY,
--     id = "stopButt",
--     label = "STOP",
--     onEvent = stopFunction
-- }
-- stopButt.anchorX = 0.5
-- stopButt.anchorX = 0.5
-- stopButt.x = display.contentCenterX
-- stopButt.y = display.contentHeight - 175
-- sceneGroup:insert(stopButt)
-- stopButt.alpha = 0

-- inviteButt = widget.newButton
-- {
--     left = display.contentCenterX,
--     top = display.contentCenterY,
--     id = "inviteButt",
--     label = "Create",
--     onEvent = createServer
-- }
-- inviteButt.anchorX = 0.5
-- inviteButt.anchorX = 0.5
-- inviteButt.x = display.contentCenterX
-- inviteButt.y = display.contentHeight - 175
-- sceneGroup:insert(inviteButt)

-- adButt = widget.newButton
-- {
--     left = display.contentCenterX,
--     top = display.contentCenterY,
--     id = "adButt",
--     label = "Invite",
--     onEvent = advertiseServer
-- }
-- adButt.anchorX = 0.5
-- adButt.anchorX = 0.5
-- adButt.x = display.contentCenterX
-- adButt.y = display.contentHeight - 115
-- sceneGroup:insert(adButt)

connectButt = widget.newButton
{
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "connectButt",
    label = "Search",
    onEvent = prepServerList
}
connectButt.anchorX = 0.5
connectButt.anchorY = 0.5
connectButt.x = display.contentCenterX
connectButt.y = display.contentHeight - 50
sceneGroup:insert(connectButt)

serverList = widget.newTableView( 
{
    id = "serverList",
    top = 0,
    left = 0,
    width = display.contentWidth,
    height = display.contentHeight/2,
    onRowTouch = onRowTouch,
    onRowRender = onRowRender
    } 
)

serverList:insertRow(
        {
            isCategory = true,
            rowHeight = 40,
            rowColor = { default={ 0.8, 0.8, 0.8, 0.8 } },
            lineColor = { 1, 0, 0 }
        }
    )
sceneGroup:insert(serverList)

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