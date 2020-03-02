hs.loadSpoon("Lunette")
spoon.Lunette:bindHotkeys()


function open(name)
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
