
local addonName, ns = ...

local COPY_PROFILE_URL_POPUP = {
    id = "QUICK_LINK_COPY_URL",
    text = "%s",
    button2 = CLOSE,
    hasEditBox = true,
    hasWideEditBox = true,
    editBoxWidth = 350,
    preferredIndex = 3,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnShow = function(self)
        self:SetWidth(420)
        local editBox = _G[self:GetName() .. "WideEditBox"] or _G[self:GetName() .. "EditBox"]
        editBox:SetText(self.text.text_arg2)
        editBox:SetFocus()
        editBox:HighlightText(false)
        local button = _G[self:GetName() .. "Button2"]
        button:ClearAllPoints()
        button:SetWidth(200)
        button:SetPoint("CENTER", editBox, "CENTER", 0, -30)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    OnHide = nil,
    OnAccept = nil,
    OnCancel = nil
}

StaticPopupDialogs[COPY_PROFILE_URL_POPUP.id] = COPY_PROFILE_URL_POPUP

local function ShowCopyUrlPopup(url, name, realm)
    if IsModifiedClick("CHATLINK") then
        local editBox = ChatFrame_OpenChat(url, DEFAULT_CHAT_FRAME)
        editBox:HighlightText()
    else
        StaticPopup_Show(COPY_PROFILE_URL_POPUP.id, format("%s (%s)", name, realm), url)
    end
end

function QuickLink:ShowCopyRaiderIOProfilePopup(...)
    local url, name, realm = QuickLink:GetRaiderIOProfileUrl(...)
    ShowCopyUrlPopup(url, name, realm)
end

function QuickLink:ShowCopyArmoryUrlPopup(...)
    local url, name, realm = QuickLink:GetArmoryUrl(...)
    ShowCopyUrlPopup(url, name, realm)
end

function QuickLink:ShowCopyCheckPvpUrlPopup(...)
    local url, name, realm = QuickLink:GetCheckPvpUrl(...)
    ShowCopyUrlPopup(url, name, realm)
end

function QuickLink:ShowCopyWcLogsUrlPopup(...)
    local url, name, realm = QuickLink:GetWarcraftLogsUrl(...)
    ShowCopyUrlPopup(url, name, realm)
end