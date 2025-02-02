local api = require("api")

local dataFileName = 'ExpressYourself/data/items.lua'
local helpers = {}

local labelHeight = 20
local editWidth = 100

function helpers.getItems()
    local items = {}

    local file = api.File:Read(dataFileName)
    if (file) then items = file end

    return items
end

function helpers.saveItems(items) api.File:Write(dataFileName, items) end

-- trim string function 
function string.trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
function string.split(input, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for word in string.gmatch(input, pattern) do
        table.insert(result, string.trim(word))
    end
    return result
end
function table.reverse(tab)
    for i = 1, math.floor(#tab / 2), 1 do
        tab[i], tab[#tab - i + 1] = tab[#tab - i + 1], tab[i]
    end
    return tab
end

function helpers.detectEmotion(message, items)
    local emotion = nil

    if not message then return emotion end

    message = " " .. string.lower(message) .. " "

    for i = 1, #items do
        local curItem = items[i]
        local curEmotion = curItem.emotion
        local words = string.split(curItem.words, ",")

        for j = 1, #words do
            local curWord = string.trim(words[j])
            curWord = string.lower(curWord)

            local pattern = "%f[%a]" .. curWord .. "%f[%A]"

            if string.find(message, pattern) then
                emotion = curEmotion
                break
            end
        end
    end

    return emotion
end

-- UI controls
function helpers.createButton(id, parent, text, x, y)
    local button = api.Interface:CreateWidget('button', id, parent)
    button:SetExtent(55, 26)
    button:AddAnchor("TOPLEFT", x, y)
    button:SetText(text)
    api.Interface:ApplyButtonSkin(button, BUTTON_BASIC.DEFAULT)
    return button
end
function helpers.createLabel(id, parent, text, offsetX, offsetY, fontSize)
    local label = api.Interface:CreateWidget('label', id, parent)
    label:AddAnchor("TOPLEFT", offsetX, offsetY)
    label:SetExtent(255, labelHeight)
    label:SetText(text)
    label.style:SetColor(FONT_COLOR.TITLE[1], FONT_COLOR.TITLE[2],
                         FONT_COLOR.TITLE[3], 1)
    label.style:SetAlign(ALIGN.LEFT)
    label.style:SetFontSize(fontSize or 18)

    return label
end
function helpers.createEdit(id, parent, text, offsetX, offsetY)
    local field = W_CTRL.CreateEdit(id, parent)
    field:SetExtent(editWidth, labelHeight)
    field:AddAnchor("TOPLEFT", offsetX, offsetY)
    field:SetText(tostring(text))
    field.style:SetColor(0, 0, 0, 1)
    field.style:SetAlign(ALIGN.LEFT)
    -- field:SetDigit(true)
    field:SetInitVal(text)
    -- field:SetMaxTextLength(4)
    return field
end
function helpers.createTextarea(id, parent, text, x, y)
    local field = W_CTRL.CreateMultiLineEdit(id, parent)
    field:SetExtent(editWidth, labelHeight)
    field:AddAnchor("TOPLEFT", x, y)
    field:SetText(text)
    field.style:SetColor(0, 0, 0, 1)
    field.style:SetAlign(ALIGN.LEFT)
    field.style:SetFontSize(14)
    field:SetMaxTextLength(700)
    field:SetInset(10, -65, 10, 5)
    return field
end

return helpers
