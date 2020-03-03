hs.loadSpoon("Lunette")
spoon.Lunette:bindHotkeys()

function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

local function open(name)
    return function()
        hs.application.launchOrFocus(name)
        if name == "Finder" then
            hs.appfinder.appFromName(name):activate()
        end
    end
end
local function bluetooth(power)
    print("Setting bluetooth to " .. power)
    -- requires $(brew install blueutil)
    local t = hs.task.new("/usr/local/bin/blueutil", checkBluetoothResult, {"--power", power})
    t:start()
end

local function setSlackStatus(text, emoji)
    local json = require("json")

    local slackApiKey = require("slack")

    headers = {
        ["Content-Type"] = "application/json; charset=utf-8",
        ["Authorization"] = string.format("Bearer %s", slackApiKey)
    }

    request_body = {
        profile = {
            status_text = text,
            status_emoji = emoji
        }
    }

    hs.http.asyncPost(
        "https://slack.com/api/users.profile.set",
        json.encode(request_body),
        headers,
        function(code, body, c)
            print(code)
            print(body)
        end
    )
end

hs.hotkey.bind({"alt"}, "F", open("Firefox Developer Edition"))
hs.hotkey.bind({"alt"}, "T", open("kitty"))
hs.hotkey.bind({"alt"}, "S", open("Slack"))
hs.hotkey.bind({"alt"}, "G", open("Goland"))

wifiMenu = hs.menubar.new()
wifiNameWork = "felyx"

local function setActiveNetworkName()
    local wifiName = hs.wifi.currentNetwork() or "Offline"
    hs.timer.doAfter(
        3,
        function()
            if (wifiName ~= wifiNameWork and wifiName ~= nil) then
                setSlackStatus("Working Remotely", ":house_with_garden:")
            else
                setSlackStatus("Office", ":computer:")
            end
        end
    )
    wifiMenu:setTitle(wifiName)
end

hs.network.reachability.internet():setCallback(
    function(self, flags)
        if (flags & hs.network.reachability.flags.reachable) > 0 then
        end
    end
):start()

function on_screen_event(event)
    if event == hs.caffeinate.watcher.systemWillSleep then
        bluetooth("off")
    elseif event == hs.caffeinate.watcher.screensDidWake then
        bluetooth("on")
    end
end

powerWatcher = hs.caffeinate.watcher.new(on_screen_event):start()
wifiWatcher = hs.wifi.watcher.new(setActiveNetworkName):start()
