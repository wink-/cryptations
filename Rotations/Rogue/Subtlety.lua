local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 4 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Rotation = LibStub("Rotation")

PauseHotkey = "ALT,Q"
AoEHotkey   = "ALT,A"
CDHotkey    = "ALT,C"

KeyCallbacks = {
  [PauseHotkey] = Rotation.TogglePause,
  [AoEHotkey] = Rotation.ToggleAoE,
  [CDHotkey] = Rotation.ToggleCD
}

function RSBuilders()
  RSShurikenStormV1()
  RSGloomblade()
  RSBackstab()
end

function RSCooldowns()
  -- Potions
  -- Specter of BetrayalV1
  -- Specter of BetrayalV2
  -- Blood Fury
  -- Berserking
  -- Arcane Torrent
  -- Symbols of DeathV1
  -- Symbols of DeathV2
  -- Symbols of DeathV3
  -- Marked for DeathV1
  -- Marked for DeathV2
  -- Shadow Blades
  -- Goremaw's Bite
  -- Pool Resource (?)
  -- Vanish
end

function RSFinishers()
  -- Night BladeV1
  -- Night BladeV2
  -- Night BladeV3
  -- Death from Above
  -- Eviscerate
end

function RSStealthActions()
  RSStealthCoodlowns() -- V1
  RSStealthCoodlowns() -- V2
  RSStealthCoodlowns() -- V3
  RSStealthCoodlowns() -- V4
  RSStealthCoodlowns() -- V5
end

function RSStealthCoodlowns()
  -- Vanish
  -- Shadow DanceV1
  -- Pool Resource (?)
  -- Shadowmeld
  -- Shadow DanceV2
end

function RSStealthRotation()
  -- Shadowstrike
  RSFinishers() --V1
  -- Shuriken StormV2
  RSFinishers() --V2
  -- Shadowstrike
end

function Pulse()
  if UnitAffectingCombat("player")
  or GroupInCombat then
    -- actions=variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled&spell_targets.death_from_above<4
    -- Shadow DanceV3
    RSCooldowns()
    RSStealthRotation()
    -- Nightblade
    RSStealthActions() -- V1
    RSStealthActions() -- V2
    RSStealthActions() -- V3
    RSFinishers()
    -- wait
    -- wait
    RSBuilders()
  end
end
