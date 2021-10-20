-- ezarena's goal:
-- 1. Enemy plates have a last used ability on top
-- 2. Teammates have a portrait of their last used ability next to them

ChatFrame1:AddMessage("|cff00FF00Ezarena|r  - 'See Abilities in PvP'|r")
local debugging = false;
local ezarena = {};
local roles = {"player", "party1", "party2"};
local spellNamesToSpellIds;
local size = 50;
-- LibNameplates API: https://www.wowace.com/projects/libnameplate-1-0/pages/api
local LibNP = LibStub("LibNameplate-1.0", true)
-- Gets spellId from just the spell's name; taken from core.lua of PlateBuffs
local function GetAllSpellIDs()	
	local spells = {};
	local name;

	for i = 76567, 1, -1 do
		name = GetSpellInfo(i);
		if name and not spells[name] then
			spells[name] = i;
		end
	end
	return spells;
end
spellNamesToSpellIds = GetAllSpellIDs();


function ezarena:Setup()
    for _, role in ipairs(roles) do
        self:MakeFrame(role);
    end
end

function ezarena:MakeFrame(role)
    -- Make a frame
    local f = CreateFrame("Frame", "Ezarena_"..role, UIParent);
    f:SetFrameStrata("HIGH");
    f:SetWidth(size);
    f:SetHeight(size);
    local t = f:CreateTexture(nil, "BACKGROUND");
    t:SetTexture("Interface\\CharacterFrame\\TempPortrait");
    t:SetAllPoints(f);
    f.texture = t;
    f:SetPoint("CENTER", 0, 0); -- up and right
    f:Show();

    -- Make frame draggable
    f:SetMovable(true);
    f:EnableMouse(true);
    f:RegisterForDrag("LeftButton");
    f:SetScript("OnDragStart", f.StartMoving);
    f:SetScript("OnDragStop", f.StopMovingOrSizing);

    local listenedEvent = "UNIT_SPELLCAST_SUCCEEDED"; -- many options to choose from; could use a table of registered event names pointing to callbacks
    -- could we register an event to UIParent ON ADDON LOAD or COMBAT_LOG_EVENT_UNFILTERED or ENTER_WORLD? instead of here?
    f:RegisterEvent(listenedEvent);
    
    -- Spell successfully casted event handler:
    -- (ability-use events are double/triply/quadruply listened for when they are your TARGET and/or RAID and/or FOCUS and/or PARTY and/or PLAYER)
    f:SetScript("OnEvent", function(self, event, caster, spellName, spellRank, spellTarget) 
        local _, instanceType = IsInInstance();
	    if instanceType ~= "arena" and role ~= "player" then return; end
        if caster ~= role then return; end
        if debugging == true then 
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
-- lib:GetNameplateByUnit(unitID)

        if event == listenedEvent then
            local eventSpellId = spellNamesToSpellIds[spellName]
            local name, rank, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(eventSpellId)
            t:SetTexture(icon);
            t:SetAllPoints(f);
            f.texture = t;
            f:Show();
        end                             
    end);

end

ezarena:Setup();








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





-- ARENA 123

-- 			for i = 1, GetNumArenaOpponents() do
-- 				local player = LibNP:GetNameplateByUnit("arena" .. i)
-- 				local pet = LibNP:GetNameplateByUnit("arenapet" .. i)
				
-- 				for _, f in ipairs({player, pet}) do
-- 					if f then
-- 						local levelText = LibNP:GetLevelRegion(f)
						
-- 						if levelText and levelText.SetText then
-- 							levelText:SetText(i)
-- 						end
-- 					end
-- 				end
-- 			end
			
-- 			self.elapsedTime = 0
-- 		end)

-- hooksecurefunc("TargetFrame_CheckLevel", function (self)
-- 	if IsActiveBattlefieldArena() and self.unit then
-- 		for i = 1, GetNumArenaOpponents() do
-- 			for _, u in ipairs({"arena", "arenapet"}) do
-- 				if UnitIsUnit(self.unit, u .. i) then
-- 					self.levelText:SetText(i)
-- 				end
-- 			end
-- 		end
-- 	end
-- end)





-- https://wowwiki-archive.fandom.com/wiki/API_UnitCastingInfo
-- "UNIT_SPELLCAST_SUCCEEDED": even when resisted, multiple hits of same ability
-- UnitName UnitGUID
-- /fstack /run *lua code* /console scriptErrors 0

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
-- 3. Dispel tracking
-- 4. arena 1,2,3 in plates instead of level (ArenaNumbers does thsi)
-- https://www.wowinterface.com/forums/showthread.php?t=19104
-- https://wowwiki-archive.fandom.com/wiki/Saving_variables_between_game_sessions
-- UI coordinates: https://wowwiki-archive.fandom.com/wiki/UI_coordinates
-- in toc: ## SavedVariables: PB_DB
-- 3. hide until enter arena

-- DISPELS TRCKING
-- https://wowwiki-archive.fandom.com/wiki/API_COMBAT_LOG_EVENT#Spell_School