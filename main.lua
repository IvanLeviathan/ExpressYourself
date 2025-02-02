local api = require("api")
local helpers = require('ExpressYourself/util/helpers')
local UI = require('ExpressYourself/ui')
local ExpressYourselfAddon = {
    name = "Express Yourself",
    author = "Misosoup",
    version = "0.1",
    desc = "Express emotions while chatting"
}

local playerName = nil
local items = {}

local lastUpdate = 0

local function OnUpdate(dt)
    lastUpdate = lastUpdate + dt
    -- 20 is ok
    if lastUpdate < 20 then return end
    lastUpdate = dt

end

local function OnChatMessage(channelId, speakerId, _, speakerName, message)
    if (speakerName ~= playerName) then return end
    -- if (channelId == -3 or channelId == -4) then return end -- whispers

    local emotion = helpers.detectEmotion(message, items)
    if (emotion ~= nil) then X2Chat:ExpressEmotion(emotion) end
end

local function Load()
    -- Init canvas
    ExpressYourselfAddon.CANVAS = api.Interface:CreateEmptyWindow(
                                      "ExpressYourself")
    ExpressYourselfAddon.CANVAS:Show(true)
    ExpressYourselfAddon.CANVAS:Clickable(false)

    -- Init items
    items = helpers.getItems()

    -- Init player name
    local unitId = api.Unit:GetUnitId('player')
    playerName = api.Unit:GetUnitNameById(unitId)

    -- init UI
    UI.Init()
    UI.ShowList()

    api.Log:Info("Loaded " .. ExpressYourselfAddon.name .. " v" ..
                     ExpressYourselfAddon.version .. " by " ..
                     ExpressYourselfAddon.author)
    api.On("UPDATE", OnUpdate)

end

local function Unload()
    UI.UnLoad()
    if ExpressYourselfAddon.CANVAS ~= nil then
        ExpressYourselfAddon.CANVAS:Show(false)
        ExpressYourselfAddon.CANVAS = nil
    end
end

ExpressYourselfAddon.OnLoad = Load
ExpressYourselfAddon.OnUnload = Unload
api.On("CHAT_MESSAGE", OnChatMessage)

return ExpressYourselfAddon
