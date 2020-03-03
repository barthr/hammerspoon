hs.loadSpoon("Lunette")
spoon.Lunette:bindHotkeys()

local function open(name)
    return function()
        hs.application.launchOrFocus(name)
        if name == 'Finder' then
            hs.appfinder.appFromName(name):activate()
        end
    end
end 

hs.hotkey.bind({"alt"}, "F", open("Firefox Developer Edition"))
hs.hotkey.bind({"alt"}, "T", open("kitty"))
hs.hotkey.bind({"alt"}, "S", open("Slack"))
hs.hotkey.bind({"alt"}, "G", open("Goland"))


wifiMenu = hs.menubar.new()
wifiNameWork = "felyx"

local function setSlackStatus() 
    local json = require("json")

    headers = {
	["Content-Type"] = "application/json; charset=utf-8",
	["Authorization"] = string.format("Bearer %s", os.getenv("SLACK_API_TOKEN"))
    }

    hs.http.asyncPost(
	"https://slack.com/api/users.profile.set",
	json.encode(request_body),
	headers,
	function(code,body,c) 
		print(code)
		print(body)
	end
    )
end


local function setActiveNetworkName() 
    local wifiName = hs.wifi.currentNetwork() or "Offline"
    wifiMenu:setTitle(wifiName)
end


hs.network.reachability.internet():setCallback(function(self, flags)
    if (flags & hs.network.reachability.flags.reachable) > 0 then
	    print("ACTIVE")
    end 
end):start()



spotifyMenu = hs.menubar.new()
hs.timer.doEvery(1, function() 
	local track = string.format("%s - %s", hs.spotify.getCurrentTrack(), hs.spotify.getCurrentArtist())
	if not hs.spotify.isPlaying() then
		track = "No Track Playing"
	end
	spotifyMenu:setTitle(track)
end):start()


local function bluetooth(power)
    print("Setting bluetooth to " .. power)
    local t = hs.task.new("/usr/local/bin/blueutil", checkBluetoothResult, {"--power", power})
    t:start()
end

function on_screen_event(event)
    if event == hs.caffeinate.watcher.systemWillSleep then
		bluetooth("off")		
    elseif event == hs.caffeinate.watcher.screensDidWake then
		bluetooth("on")		
    end
end

powerWatcher = hs.caffeinate.watcher.new(on_screen_event):start()
wifiWatcher = hs.wifi.watcher.new(setActiveNetworkName):start()
