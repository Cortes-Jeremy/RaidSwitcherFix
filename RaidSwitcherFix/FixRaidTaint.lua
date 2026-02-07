-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2012.10.01					---
--- Version: 0.2 [2012.10.01]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/fixraidtaint
--- WoWInterface	http://www.wowinterface.com/downloads/info21705-FixRaidTaint.html

if not IsAddOnLoaded("Blizzard_CompactRaidFrames") then
	return -- Nothing to fix
end

-- yes I'm a noob with libraries >.<
if not FixRaidTaint then
	local container = CompactRaidFrameContainer
	
	local t = {
		discrete = "flush",
		flush = "discrete",
	}
	
	-- refresh the (tainted) raid frames after combat
	local function OnEvent(self)
		-- secure or still in combat somehow
		if issecurevariable("CompactRaidFrame1") or InCombatLockdown() or not container:IsShown() then return end
		
		-- Bug #1: left/joined players not updated
		-- Bug #2: sometimes selecting different than the intended target
		
		-- change back and forth from flush <-> discrete
		local mode = container.groupMode -- groupMode changes after _SetGroupMode calls
		CompactRaidFrameContainer_SetGroupMode(container, t[mode]) -- forth
		CompactRaidFrameContainer_SetGroupMode(container, mode) -- back
	end
	
	local f = CreateFrame("Frame", "FixRaidTaint")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:SetScript("OnEvent", OnEvent)
	
	f.version = 0.2
end
