print("Ezarena - 'SEE ABILITY PORTRAITS'");
local debugging = false;
-- https://wowwiki-archive.fandom.com/wiki/API_UnitCastingInfo
-- "UNIT_SPELLCAST_SUCCEEDED": even when resisted, multiple hits of same ability
-- UnitName UnitGUID
-- /fstack /run *lua code*

-- GOAL:
-- 1. Enemy plates have a last used ability on top
-- 2. Teammates have a portrait of their last used ability next to them

-- Similar addons:
-- https://github.com/Trufi/TrufiGCD/blob/master/TrufiGCD.lua
-- platebuffs

-- Blizzard's Arena API: 
-- to figure out how to figure out who arena 1 is and who party1 and party2 are and how many PORTRAITs to create
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
 
local ezarena = {};
local roles = {"player", "party1", "party2"};
function ezarena:Setup()
    for k, v in 

end

function ezarena:MakeFrame(role)
    -- Make a frame
    local f = CreateFrame("Frame", "Ezarena_"..role, UIParent);
    f:SetFrameStrata("HIGH");
    f:SetWidth(90);
    f:SetHeight(90);
    local testTexture = f:CreateTexture(nil, "BACKGROUND");
    testTexture:SetTexture("Interface\\CharacterFrame\\TempPortrait");
    testTexture:SetAllPoints(f);
    f.texture = testTexture;
    f:SetPoint("CENTER",80,80); -- up and right
    f:Show();

    -- Make frame draggable
    f:SetMovable(true);
    f:EnableMouse(true);
    f:RegisterForDrag("LeftButton");
    f:SetScript("OnDragStart", f.StartMoving);
    f:SetScript("OnDragStop", f.StopMovingOrSizing);

    local listenedEvent = "UNIT_SPELLCAST_SUCCEEDED"; -- many options to choose from
-- could we register an event to UIParent ON ADDON LOAD? instead of here?
    f:RegisterEvent(listenedEvent);
    -- ability-use events are double/triply/quadruply listened for when they are your TARGET and/or RAID and/or FOCUS and/or PARTY and/or PLAYER
    f:SetScript("OnEvent", function(self, event, caster, spellName, spellRank, spellTarget) 
        if(self:isUsefulUnit(caster) == false) then return; end
        if(debugging == true) then 
            print("BEGIN");
            print("Caster: "..caster); -- from my POV, so my target or focus or raid teammate
            print("Spell: "..spellName);
            print("Rank: "..spellRank);
            print("Target: "..spellTarget) ;-- a NUMBER that represents the line in combat log? resets at 255
            print("SpellId: "..eventSpellId) ;
            print("SpellTextureLoc: "..icon) ;
            print("END");
            for k, v in pairs(f) do
                print(k,v)
            end
        end

        if(event == listenedEvent) then
            local eventSpellId = f.spells[spellName]
            local name, rank, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(eventSpellId)


            testTexture:SetTexture(icon);
            testTexture:SetAllPoints(f);
            f.texture = testTexture;
            f:Show();
        end

    end);
end



-- Spell successfully casted event handler
-- function f:isUsefulUnit(unitName)
--     local usefulRoles = {"party1", "party2", "party3", "player"};

--     for index, value in ipairs(usefulRoles) do
--         if unitName == value then
--             return true;
--         end
--     end

--     return false;
-- end

-- function f:isPlayer(unitName)
--     local ownName = GetUnitName("player");

--     if GetUnitName(unitName) == ownName then
--         return true;
--     end

--     return false;
-- end


-- Gets spellId from just the spell's name; taken from core.lua of PlateBuffs
function GetAllSpellIDs()	
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
local spells = GetAllSpellIDs();









-- local activeUnitPlates = {}
 
-- local function AddNameplate(unitID)
--     local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
--     local unitframe = nameplate.UnitFrame
 
--     -- store nameplate and its unitID
--     activeUnitPlates[unitframe] = unitID
-- end
 
-- local function RemoveNameplate(unitID)
--     local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
--     local unitframe = nameplate.UnitFrame
    
--     -- recycle the nameplate
--     activeUnitPlates[unitframe] = nil
-- end
 
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
-- f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
 
-- f:SetScript("OnEvent", function(self,event,...)
--     if event == "NAME_PLATE_UNIT_ADDED" then
--         local unitID = ...
--         AddNameplate(unitID)
--     end
    
--     if event == "NAME_PLATE_UNIT_REMOVED" then
--         local unitID = ...
--         RemoveNameplate(unitID)
--     end
-- end
-- Plates = wipe(Plates)
-- Visible = 0
 
-- for i, frame in pairs({WorldFrame:GetChildren()}) do
--     local name = frame:GetName()
--     if name and strmatch(name, "NamePlate") and frame:IsShown() then
--         local unitFrame = frame:GetChildren()
--         local unit = unitFrame and unitFrame:GetAttribute("unit")
--         if unitFrame and unit then
--             Plates[unitFrame] = true
--         end
--         Visible = Visible + 1
--     end
-- end




