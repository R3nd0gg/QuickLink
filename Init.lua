QuickLink = {}
QuickLink.modules = {}
QuickLink.defaults = {}

local addonName, ns = ...
ns.EXPANSION = max(LE_EXPANSION_SHADOWLANDS, GetExpansionLevel() - 1)
ns.MAX_LEVEL = GetMaxLevelForExpansionLevel(ns.EXPANSION)
ns.FACTION_TO_ID = {Alliance = 1, Horde = 2, Neutral = 3}
ns.REGIONS = {
	"us",
	"kr",
	"eu",
	"tw",
	"ch",
}