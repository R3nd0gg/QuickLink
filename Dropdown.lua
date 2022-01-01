local DDE = LibStub and LibStub:GetLibrary("LibDropDownExtension-1.0", true)
local addonName, ns = ...

local validTypes = {
	ARENAENEMY = true,
	BN_FRIEND = true,
	CHAT_ROSTER = true,
	COMMUNITIES_GUILD_MEMBER = true,
	COMMUNITIES_WOW_MEMBER = true,
	FOCUS = true,
	FRIEND = true,
	GUILD = true,
	GUILD_OFFLINE = true,
	PARTY = true,
	PLAYER = true,
	RAID = true,
	RAID_PLAYER = true,
	SELF = true,
	TARGET = true,
	WORLD_STATE_SCORE = true,
	ENEMY_PLAYER = true,
}

local selectedName, selectedRealm, selectedLevel

local function GetNameRealmForDropDown(dropdown)
	local unit = dropdown.unit
	local bnetIDAccount = dropdown.bnetIDAccount
	local menuList = dropdown.menuList
	local quickJoinMember = dropdown.quickJoinMember
	local quickJoinButton = dropdown.quickJoinButton
	local clubMemberInfo = dropdown.clubMemberInfo
	local tempName, tempRealm = dropdown.name, dropdown.server
	local name, realm, level
	-- unit
	if not name and UnitExists(unit) then
		if UnitIsPlayer(unit) then
			name, realm = QuickLink:GetNameRealm(unit)
			level = UnitLevel(unit)
		end
		-- if it's not a player it's pointless to check further
		return name, realm, level
	end
	-- bnet friend
	if not name and bnetIDAccount then
		local fullName, _, charLevel = QuickLink:GetNameRealmForBNetFriend(bnetIDAccount)
		if fullName then
			name, realm = QuickLink:GetNameRealm(fullName)
			level = charLevel
		end
		-- if it's a bnet friend we assume if eligible the name and realm is set, otherwise we assume it's not eligible for a url
		return name, realm, level
	end
	-- lfd
	if not name and menuList then
		for i = 1, #menuList do
			local whisperButton = menuList[i]
			if whisperButton and (whisperButton.text == _G.WHISPER_LEADER or whisperButton.text == _G.WHISPER) then
				name, realm = QuickLink:GetNameRealm(whisperButton.arg1)
				break
			end
		end
	end
	-- quick join
	if not name and (quickJoinMember or quickJoinButton) then
		local memberInfo = quickJoinMember or quickJoinButton.Members[1]
		if memberInfo.playerLink then
			name, realm, level = QuickLink:GetNameRealmFromPlayerLink(memberInfo.playerLink)
		end
	end
	-- dropdown by name and realm
	if not name and tempName then
		name, realm = QuickLink:GetNameRealm(tempName, tempRealm)
		if clubMemberInfo and clubMemberInfo.level and (clubMemberInfo.clubType == Enum.ClubType.Guild or clubMemberInfo.clubType == Enum.ClubType.Character) then
			level = clubMemberInfo.level
		end
	end
	-- if we don't got both we return nothing
	if not name or not realm then
		return
	end
	return name, realm, level
end

local function IsValidDropDown(dropdown)
	return (dropdown == LFGListFrameDropDown) or (type(dropdown.which) == "string" and validTypes[dropdown.which])
end

local dropdownItems = {
	{
		text = "Raider.IO Link",
		func = function(...) 
			QuickLink:ShowCopyRaiderIOProfilePopup(selectedName, selectedRealm) 
		end,
	},
	{
		text = "Check-PVP Link",
		func = function(...) 
			QuickLink:ShowCopyCheckPvpUrlPopup(selectedName, selectedRealm) 
		end,
	},
	{
		text = "Armory Link",
		func = function(...) 
			QuickLink:ShowCopyArmoryUrlPopup(selectedName, selectedRealm) 
		end,
	},
	{
		text = "WcLogs Link",
		func = function(...) 
			QuickLink:ShowCopyWcLogsUrlPopup(selectedName, selectedRealm) 
		end,
	},
}

-- the callback function for when the dropdown event occurs
local function OnEvent(dropdown, event, options)
	if event == "OnShow" then
		if not IsValidDropDown(dropdown) then
			return
		end
		selectedName, selectedRealm, selectedLevel = GetNameRealmForDropDown(dropdown)
        if not selectedName or not QuickLink:IsMaxLevel(selectedLevel, true) then
            return
        end
		-- add the dropdown options to the options table
		for i = 1, #dropdownItems do
			options[i] = dropdownItems[i]
		end
		-- we have added options to the dropdown menu
		return true
	elseif event == "OnHide" then
		-- when hiding we can remove our dropdown options from the options table
		for i = #options, 1, -1 do
			options[i] = nil
		end
	end
end
-- registers our callback function for the show and hide events for the first dropdown level only
DDE:RegisterEvent("OnShow OnHide", OnEvent, 1)