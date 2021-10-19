print("Ezarena - 'SEE ABILITY PORTRAITS'");
-- https://wowwiki-archive.fandom.com/wiki/API_UnitCastingInfo
-- "UNIT_SPELLCAST_SUCCEEDED": even when resisted, multiple hits of same button
-- UnitName
-- UnitGUID
-- /fstack /run

-- Examples I borrowed from:
-- https://github.com/Trufi/TrufiGCD/blob/master/TrufiGCD.lua
-- platebuffs

-- official Arena API from blizzard to figure out how to figure out who arena 1 is and who party1 and party2 are
-- https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_ArenaUI/Blizzard_ArenaUI.lua
-- 	self:RegisterEvent("ARENA_OPPONENT_UPDATE");

-- LUA
-- https://www.lua.org/pil/6.2.html
-- self as first arg to table:func functions 

-- Extension ideas: 
-- 1. see what stance a warrior is in
-- 2. saved variables for UI position on world_exit event
-- https://www.wowinterface.com/forums/showthread.php?t=19104
-- https://wowwiki-archive.fandom.com/wiki/Saving_variables_between_game_sessions
-- UI coordinates: https://wowwiki-archive.fandom.com/wiki/UI_coordinates
-- in toc: ## SavedVariables: PB_DB
 

-- Make frame
local testFrame = CreateFrame("Frame", "Ezarena_PLAYER", UIParent);
testFrame:SetFrameStrata("HIGH");
testFrame:SetWidth(90);
testFrame:SetHeight(90);
local testTexture = testFrame:CreateTexture(nil, "BACKGROUND");
testTexture:SetTexture("Interface\\CharacterFrame\\TempPortrait");
testTexture:SetAllPoints(testFrame);
testFrame.texture = testTexture;
testFrame:SetPoint("CENTER",80,80); -- up and right
testFrame:Show();

-- Make frame draggable
testFrame:SetMovable(true);
testFrame:EnableMouse(true);
testFrame:RegisterForDrag("LeftButton");
testFrame:SetScript("OnDragStart", testFrame.StartMoving);
testFrame:SetScript("OnDragStop", testFrame.StopMovingOrSizing);

-- Spell successfully casted event handler
function testFrame:isUsefulUnit(unitName)
    local usefulRoles = {"party1", "party2", "party3", "player"};

    for index, value in ipairs(usefulRoles) do
        if unitName == value then
            return true;
        end
    end

    return false;
end

function testFrame:isPlayer(unitName)
    local ownName = GetUnitName("player");

    if GetUnitName(unitName) == ownName then
        return true;
    end

    return false;
end

-- Gets spellId from just the spell's name; taken from core.lua of PlateBuffs
function testFrame:GetAllSpellIDs()	
	local spells = {}
	local name

	for i = 76567, 1, -1 do
		name = GetSpellInfo(i)
		if name and not spells[name] then
			spells[name] = i
		end
	end
	return spells
end

local listenedEvent = "UNIT_SPELLCAST_SUCCEEDED";
local debugging = true;
-- could we register an event to UIParent ON WORLD LOAD? instead of here?
testFrame.spells = testFrame:GetAllSpellIDs();
testFrame:RegisterEvent(listenedEvent);

-- In Lua, if you have a function as a property of a table, and you use a colon (:) instead of a period (.) to reference the function, it will automatically pass the table in as the first argument!
-- events are double/triply/quadruply listened for when they are your TARGET and/or RAID and/or FOCUS and/or PARTY and/or PLAYER
-- FOR CASTERS: arena teammates: raid1, raid2, raid3
testFrame:SetScript("OnEvent", function(self, event, caster, spellName, spellRank, spellTarget) -- spellTarget is actually line number in combat log?
    if(debugging == false) then return; end
    if(self:isUsefulUnit(caster) == false) then return; end

    -- for k, v in testFrame do
    --     print(k, v)
    -- end

	if(event == listenedEvent) then
        local eventSpellId = testFrame.spells[spellName]
        local name, rank, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(eventSpellId)
        -- print("BEGIN");
        -- print("Caster: "..caster); -- from my POV, so my target or focus or raid teammate
        -- print("Spell: "..spellName);
        -- print("Rank: "..spellRank);
        -- print("Target: "..spellTarget) ;-- a NUMBER that represents the line in combat log? resets at 255
        -- print("SpellId: "..eventSpellId) ;-- a NUMBER that represents the line in combat log? resets at 255
        -- print("SpellTexture: "..icon) ;-- a NUMBER that represents the line in combat log? resets at 255
        -- print("END");

        testTexture:SetTexture(icon);
        testTexture:SetAllPoints(testFrame);
        testFrame.texture = testTexture;
        testFrame:Show();
	end

end);


