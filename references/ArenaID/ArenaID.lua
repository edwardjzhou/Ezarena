local LibNP = LibStub("LibNameplate-1.0")

local ipairs = ipairs

local GetNumArenaOpponents = GetNumArenaOpponents
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local UnitIsUnit = UnitIsUnit

local THROTTLE_TIME = 0.1

local EventHandler = CreateFrame("Frame")

EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")

EventHandler:SetScript("OnEvent", function(self)
	local _, instanceType = IsInInstance()
	
	if instanceType == "arena" then
		self.elapsedTime = THROTTLE_TIME
		
		self:SetScript("OnUpdate", function(self, elapsed)
			self.elapsedTime = self.elapsedTime + elapsed
			
			if THROTTLE_TIME > self.elapsedTime then return end
				
			for i = 1, GetNumArenaOpponents() do
				local player = LibNP:GetNameplateByUnit("arena" .. i)
				local pet = LibNP:GetNameplateByUnit("arenapet" .. i)
				
				for _, f in ipairs({player, pet}) do
					if f then
						local levelText = LibNP:GetLevelRegion(f)
						
						if levelText and levelText.SetText then
							levelText:SetText(i)
						end
					end
				end
			end
			
			self.elapsedTime = 0
		end)
	else
		self:SetScript("OnUpdate", nil)
	end
end)

hooksecurefunc("TargetFrame_CheckLevel", function (self)
	if IsActiveBattlefieldArena() and self.unit then
		for i = 1, GetNumArenaOpponents() do
			for _, u in ipairs({"arena", "arenapet"}) do
				if UnitIsUnit(self.unit, u .. i) then
					self.levelText:SetText(i)
				end
			end
		end
	end
end)