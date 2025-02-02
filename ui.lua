local api = require("api")
local helpers = require('ExpressYourself/util/helpers')

local UI = {}
local listWnd
local pageSize = 3

UI.Init = function() UI.CreateList() end
UI.ShowList = function() if listWnd ~= nil then listWnd:Show(true) end end

UI.listCtrl = nil
UI.listItems = {}
UI.listControls = {}
UI.ListRowSetFunc = function(subItem, data, setValue)
    if setValue then
        -- Data Assignments
        local index = data.index
        UI.listControls[index].words:SetText(data.words)
        UI.listControls[index].emotion:SetText(data.emotion)

        local deleteButton = UI.listControls[index].deleteButton
        function deleteButton.OnClick(self)
            UI.DeleteListItem(data.realIndex, data.index)
        end
        deleteButton:SetHandler("OnClick", deleteButton.OnClick)

        local saveButton = UI.listControls[index].saveButton
        function saveButton.OnClick(self)
            UI.SaveButtonClicked(data.realIndex, data.index)
        end
        saveButton:SetHandler("OnClick", saveButton.OnClick)

    end
end
UI.ListRowRenderFunc = function(frame, rowIndex, colIndex, subItem)

    -- check if listcontrols exist
    if UI.listControls[rowIndex] == nil then UI.listControls[rowIndex] = {} end

    local wordsLabel = helpers.createLabel("wordsLabel" .. rowIndex, subItem,
                                           'Keywords', 0, 0)
    wordsLabel:RemoveAllAnchors()
    wordsLabel:AddAnchor("TOPLEFT", subItem, 30, 5)
    wordsLabel.style:SetAlign(ALIGN.LEFT)
    wordsLabel.style:SetFontSize(16)
    ApplyTextColor(wordsLabel, FONT_COLOR.WHITE)

    local words = helpers.createTextarea("words" .. rowIndex, subItem, '', 0, 0)
    words:SetExtent(200, 90)
    words:RemoveAllAnchors()
    words:AddAnchor("TOPLEFT", wordsLabel, 0, 25)
    words.style:SetAlign(ALIGN.LEFT)
    words:SetInset(10, -50, 10, 5)
    words:SetMaxTextLength(110)
    ApplyTextColor(words, FONT_COLOR.DEFAULT)
    UI.listControls[rowIndex].words = words

    local emotionLabel = helpers.createLabel("emotionLabel" .. rowIndex,
                                             subItem, 'Emotion', 0, 0)
    emotionLabel:RemoveAllAnchors()
    emotionLabel:AddAnchor("TOPRIGHT", wordsLabel, 220, 0)
    emotionLabel.style:SetAlign(ALIGN.LEFT)
    emotionLabel.style:SetFontSize(16)
    ApplyTextColor(emotionLabel, FONT_COLOR.WHITE)

    local emotion = helpers.createEdit("emotion" .. rowIndex, subItem, '', 0, 0)
    emotion:RemoveAllAnchors()
    emotion:AddAnchor("TOPLEFT", emotionLabel, 0, 25)
    emotion.style:SetAlign(ALIGN.LEFT)
    emotion.style:SetFontSize(16)
    ApplyTextColor(emotion, FONT_COLOR.DEFAULT)
    UI.listControls[rowIndex].emotion = emotion

    local saveButton = helpers.createButton("saveButton" .. rowIndex, subItem,
                                            'Save', 0, 0)
    saveButton:RemoveAllAnchors()
    saveButton:AddAnchor("BOTTOMLEFT", emotion, 0, 45)
    saveButton.style:SetAlign(ALIGN.CENTER)
    saveButton.style:SetFontSize(16)
    ApplyTextColor(saveButton, FONT_COLOR.DEFAULT)
    saveButton:SetExtent(100, 26)
    UI.listControls[rowIndex].saveButton = saveButton

    local deleteButton = helpers.createButton("deleteButton" .. rowIndex,
                                              subItem, 'Delete', 0, 0)
    deleteButton:RemoveAllAnchors()
    deleteButton:AddAnchor("BOTTOMLEFT", saveButton, 0, 25)
    deleteButton.style:SetAlign(ALIGN.CENTER)
    deleteButton.style:SetFontSize(16)
    ApplyTextColor(deleteButton, FONT_COLOR.DEFAULT)
    deleteButton:SetExtent(100, 26)
    UI.listControls[rowIndex].deleteButton = deleteButton

end

UI.fillListWithData = function(listCtrl, pageIndex)
    local startingIndex = 1
    if pageIndex > 1 then startingIndex = ((pageIndex - 1) * pageSize) + 1 end

    listCtrl:ResetScroll(0)
    listCtrl:DeleteAllDatas()

    local indexCount = 1
    local endingIndex = startingIndex + pageSize
    UI.listItems = {}

    local savedItems = helpers.getItems()
    savedItems = table.reverse(savedItems)

    for i = 1, #savedItems do
        local curElem = savedItems[i]
        local itemData = {
            words = curElem.words,
            emotion = curElem.emotion,
            realIndex = #savedItems + 1 - i,
            -- Required fields
            isViewData = true,
            isAbstention = false
        }
        table.insert(UI.listItems, itemData)
        if i >= startingIndex and i < endingIndex then
            itemData.index = indexCount
            listCtrl:InsertData(i, 1, itemData)
            indexCount = indexCount + 1
        end
    end
end
UI.CreateList = function()
    listWnd = api.Interface:CreateEmptyWindow("expressListWnd")
    listWnd:AddAnchor("CENTER", 'UIParent', 0, 0)

    listWnd.bg = listWnd:CreateNinePartDrawable(TEXTURE_PATH.HUD, "background")
    listWnd.bg:SetTextureInfo("bg_quest")
    listWnd.bg:SetColor(0, 0, 0, 0.8)
    listWnd.bg:AddAnchor("TOPLEFT", listWnd, 0, 0)
    listWnd.bg:AddAnchor("BOTTOMRIGHT", listWnd, 0, 0)
    listWnd:SetExtent(380, 500)

    listWnd.closeBtn = listWnd:CreateChildWidget("button", "closeBtn", 0, true)
    listWnd.closeBtn:AddAnchor("TOPRIGHT", listWnd, -10, 5)
    api.Interface:ApplyButtonSkin(listWnd.closeBtn,
                                  BUTTON_BASIC.WINDOW_SMALL_CLOSE)
    listWnd.closeBtn:Show(true)
    listWnd.OnClose = nil

    function OnClose(button, clicktype) listWnd:Show(false) end

    listWnd.closeBtn:SetHandler("OnClick", OnClose)

    local title =
        helpers.createLabel("title", listWnd, 'Express Yourself', 0, 0)
    title:RemoveAllAnchors()
    title:AddAnchor("TOP", listWnd, 0, 5)
    title.style:SetAlign(ALIGN.CENTER)
    title.style:SetFontSize(18)
    ApplyTextColor(title, FONT_COLOR.WHITE)

    function listWnd:OnDragStart(arg)
        listWnd:StartMoving()
        api.Cursor:ClearCursor()
        api.Cursor:SetCursorImage(CURSOR_PATH.MOVE, 0, 0)
    end
    function listWnd:OnDragStop()
        listWnd:StopMovingOrSizing()
        api.Cursor:ClearCursor()
    end

    listWnd:SetHandler("OnDragStart", listWnd.OnDragStart)
    listWnd:SetHandler("OnDragStop", listWnd.OnDragStop)

    if listWnd.RegisterForDrag ~= nil then
        listWnd:RegisterForDrag("LeftButton")
    end
    if listWnd.EnableDrag ~= nil then listWnd:EnableDrag(true) end
    -- /window

    -- add new item button

    local addNewButton = helpers.createButton("addNewButton", listWnd,
                                              'Add new', 0, 0)
    addNewButton:RemoveAllAnchors()
    addNewButton:AddAnchor("BOTTOMRIGHT", listWnd, -15, -10)
    addNewButton.style:SetAlign(ALIGN.CENTER)
    addNewButton.style:SetFontSize(16)
    ApplyTextColor(addNewButton, FONT_COLOR.DEFAULT)
    addNewButton:SetExtent(100, 26)
    addNewButton:SetHandler("OnClick", UI.AddNewButtonClicked)
    -- /add new item button

    UI.listCtrl = W_CTRL.CreatePageScrollListCtrl("listCtrl", listWnd)
    UI.listCtrl:RemoveAllAnchors()

    local wndWidth = listWnd:GetWidth()
    local wndHeight = listWnd:GetHeight()

    UI.listCtrl:SetExtent(wndWidth, 400)
    UI.listCtrl:AddAnchor("TOP", listWnd, -5, 40)
    UI.listCtrl.scroll:Show(false)

    UI.listCtrl:InsertColumn('', wndWidth, 1, UI.ListRowSetFunc, nil, nil,
                             UI.ListRowRenderFunc)

    UI.listCtrl:InsertRows(pageSize, false)
    UI.listCtrl.listCtrl:DisuseSorting()
    UI.listCtrl.listCtrl:UseOverClickTexture()

    UI.fillListWithData(UI.listCtrl, 1)

    if UI.listItems ~= nil then
        UI.maxPage = math.ceil(#UI.listItems / pageSize)
    else
        UI.maxPage = 1
    end

    -- pager styles
    ApplyTextColor(UI.listCtrl.pageControl.pageLabel, FONT_COLOR.WHITE)

    UI.listCtrl.pageControl.maxPage = UI.maxPage or 1

    UI.listCtrl.pageControl:SetCurrentPage(1, true)
    function UI.listCtrl:OnPageChangedProc(pageIndex)
        UI.fillListWithData(UI.listCtrl, pageIndex)
    end
end

-- EVENTS

UI.SaveButtonClicked = function(realIndex, index)
    local cur = UI.listItems[#UI.listItems + 1 - realIndex]

    local data = {name = cur.name, x = cur.x, y = cur.y, z = cur.z}

    -- check for values changes
    local words = UI.listControls[index].words:GetText()
    data.words = words

    local emotion = UI.listControls[index].emotion:GetText()
    data.emotion = emotion

    local savedData = helpers.getItems()

    local existingData = savedData[realIndex]

    if existingData then
        for i = 1, #savedData do
            if i == realIndex then savedData[i] = data end
        end
    else
        table.insert(savedData, data)
    end
    helpers.saveItems(savedData)
    api.Log:Info('Saved keywords for emotion "' .. data.emotion .. '"')
end

UI.DeleteListItem = function(realIndex, index)
    local cur = UI.listItems[#UI.listItems + 1 - realIndex]

    local savedData = helpers.getItems()

    if savedData[realIndex] ~= nil then
        table.remove(savedData, realIndex)
        helpers.saveItems(savedData)

        -- reloading list
        local curPage = UI.listCtrl.pageControl:GetCurrentPageIndex()

        UI.fillListWithData(UI.listCtrl, 1)

        if UI.listItems ~= nil then
            UI.maxPage = math.ceil(#UI.listItems / pageSize)
        else
            UI.maxPage = 1
        end

        if curPage > UI.maxPage then curPage = curPage - 1 end

        UI.listCtrl.pageControl.maxPage = UI.maxPage or 1

        UI.listCtrl.pageControl:SetCurrentPage(curPage, true)

    end
end

UI.AddNewButtonClicked = function()
    local savedData = helpers.getItems()
    table.insert(savedData, {words = 'hi, hello', emotion = '/waving'})
    helpers.saveItems(savedData)

    -- reloading list
    UI.fillListWithData(UI.listCtrl, 1)

    if UI.listItems ~= nil then
        UI.maxPage = math.ceil(#UI.listItems / pageSize)
    else
        UI.maxPage = 1
    end

    UI.listCtrl.pageControl.maxPage = UI.maxPage or 1

    UI.listCtrl.pageControl:SetCurrentPage(1, true)
end

UI.UnLoad = function()
    if listWnd ~= nil then
        listWnd:Show(false)
        listWnd = nil
    end
end

return UI
