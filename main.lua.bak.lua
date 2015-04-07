-- Project: Undercover


--Require
local composer = require( "composer" )
local loadsave = require("loadsave")
local device = require("device")
local socket = require( "socket" )
local widget = require ( "widget" )
local server = require ("server")
local steve = require("test")
widget.setTheme("widget_theme_ios")
display.setStatusBar(display.HiddenStatusBar)

local inviteButt, connectButt, deviceName, serverList, newServers, servers, serverCounter
local adButt, stopButt
local stopServer
local testText

-- local function addServer()

--     for serverName in pairs(newServers) do
--         serverCounter = serverCounter + 1
--         --print("Server Counter is: " .. serverCounter)
--         servers[serverCounter] = serverName
--         print("Found add function: " .. servers[2])
--     end

--     for i = 2, serverCounter do

--     -- Insert a row into the tableView
--     serverList:insertRow(
--         {
--             rowHeight = 36,
--             rowColor = { default={ 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } },
--             lineColor = { 0.5, 0.5, 0.5 }
--         }
--     )
--     end
-- end

-- local function onRowRender(event)

--     local row = event.row
    
--     local rowHeight = row.contentHeight
--     local rowWidth = row.contentWidth
--     local rowTitle
--     local serverName = servers[row.index]
--     --print("Found Render: " .. serverName)

--     if row.index == 1 then
--         rowTitle = display.newText( row, "Servers", 0, 0, nil, 14 )
--     rowTitle:setFillColor( 0 )
--     elseif row.index > 1 then
--         rowTitle = display.newText( row, serverName .. " " .. newServers[serverName]["ip"], 0, 0, nil, 14 )
--         rowTitle:setFillColor( gray )
--     end

--     -- Align the label left and vertically centered
--     rowTitle.anchorX = 0
--     rowTitle.x = 0
--     rowTitle.y = rowHeight * 0.5
-- end



-- --Advertise the Server

-- local function advertiseServer( event )
--     local phase = event.phase
--     local serverBroadcast, broadcast
--     local counter = 0  --using this, we can advertise our IP address for a limited time

--     if phase == "ended" then
--     if inviteButt:getLabel() == "Invite" then
    
--     inviteButt:setLabel("Advertising...")

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
--             inviteButt:setLabel("Invite")
--         end
--     end

--     --pulse 10 times per second
--     serverBroadcast = timer.performWithDelay( 100, broadcast, 0 )

--   end
--   end
-- end

-- --Get own IP

-- local getIP = function()
--     local s = socket.udp()  --creates a UDP object
--     s:setpeername( "74.125.115.104", 80 )  --Google website
--     local ip, sock = s:getsockname()
--     print( "myIP:", ip, sock )
--     return ip
-- end

--Listen for the Server

-- local function findServer(  )
--   --local phase = event.phase
--   --if phase == "ended" then

--     newServers = {}
--     local msg = "AwesomeGameServer"
--     local stop, actualData, serverName

--     local listen = socket.udp()
--     listen:setsockname( "228.192.1.1", 1234 )  --this only works if the device supports multicast

--     local name = listen:getsockname()
--     if ( name ) then  --test to see if device supports multicast
--         listen:setoption( "ip-add-membership", { multiaddr="228.192.1.1", interface = getIP() } )
--     else  --the device doesn't support multicast so we'll listen for broadcast
--         listen:close()  --first we close the old socket; this is important
--         listen = socket.udp()  --make a new socket
--         listen:setsockname( getIP(), 1234 )  --set the socket name to the real IP address
--     end

--     listen:settimeout( 0 )  --move along if there is nothing to hear

--     local counter = 0  --pulse counter

--     local function look()
--         repeat
--             local data, ip, port = listen:receivefrom()
--             --print( "data: ", data, "IP: ", ip, "port: ", port )
--             if data ~= nil then
--               actualData = string.sub( data, 0, 17)
--               serverName = string.sub(data, 18)
--               --print(actualData .. " and " .. serverName) 
--             end
--             if actualData and actualData == msg then
--                 if not newServers[serverName] then
--                     print( "Server Found: " .. serverName .. ", " .. ip .. ", " .. port )
--                     local params = { ["name"]=serverName, ["ip"]=ip, ["port"]=1235 }
--                     newServers[serverName] = params
--                     for serverName, value in pairs(newServers) do
--                         print("Found Server: " .. serverName)
--                     end
--                     --print(newServers[serverName]["ip"])
--                 end
--             end
--         until not data

--         counter = counter + 1
--         if counter == 20 then  --stop after 2 seconds
--             stop()
--         end
--      end

--      --pulse 10 times per second
--      local beginLooking = timer.performWithDelay( 100, look, 0 )
--      print("looking...")

--      function stop()
--          timer.cancel( beginLooking )
--          print("stop looking")
--          --evaluateServerList( newServers ) --do something with your found servers
--          listen:close()  --never forget to close the socket!
--          print("socket closed")
--          --print(#newServers)
--      end
--      timer.performWithDelay( 1100, addServer, 1 )
--    --end
-- end

-- Connect to Server

local function connectToServer( ip, port )
    local sock, err = socket.connect( ip, port )
    if sock == nil then
        return false
    end
    sock:settimeout( 0 )
    sock:setoption( "tcp-nodelay", true )  --disable Nagle's algorithm
    sock:send( "we are connected" )
    return sock
end

-- local function prepServerList( event )
-- local phase = event.phase
-- if phase == "ended" then
--     timer.performWithDelay( 3000, findServer )

--     if serverCounter > 1 then
--         for serverName in pairs(newServers) do
--             newServers[serverName] = nil
--         end

--         serverList:deleteAllRows( )
--         serverList:insertRow(
--         {
--             isCategory = true,
--             rowHeight = 40,
--             rowColor = { default={ 0.8, 0.8, 0.8, 0.8 } },
--             lineColor = { 1, 0, 0 }
--         }
--     )
--         serverCounter = 1
--     end
-- end
-- end

local function stopFunction( event )
    local phase = event.phase
    if phase == "ended" then

        stopServer()     

    end
end

local function createServer( event )
local phase = event.phase
    if phase == "ended" then

        stopServer = server.createServer()

        adButt.alpha = 1
        inviteButt.alpha = 0

    end
end

--**************************

local back = display.newRect( display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )

servers = {}
serverCounter = 1

deviceName = system.getInfo("name")

stopButt = widget.newButton
{
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "stopButt",
    label = "STOP",
    onEvent = stopFunction
}
stopButt.anchorX = 0.5
stopButt.anchorX = 0.5
stopButt.x = display.contentCenterX
stopButt.y = display.contentHeight - 175

inviteButt = widget.newButton
{
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "inviteButt",
    label = "Create",
    onEvent = createServer
}
inviteButt.anchorX = 0.5
inviteButt.anchorX = 0.5
inviteButt.x = display.contentCenterX
inviteButt.y = display.contentHeight - 115

adButt = widget.newButton
{
    left = display.contentCenterX,
    top = display.contentCenterY,
    id = "adButt",
    label = "Invite",
    onEvent = advertiseServer
}
adButt.anchorX = 0.5
adButt.anchorX = 0.5
adButt.x = display.contentCenterX
adButt.y = display.contentHeight - 115
adButt.alpha = 0

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

serverList = widget.newTableView( 
{
    id = "serverList",
    top = 0,
    left = 0,
    width = display.contentWidth,
    height = display.contentHeight/2,
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

testText = native.newTextField( display.contentCenterX, 300, 200, 35 )
testText.text = "Testing..."