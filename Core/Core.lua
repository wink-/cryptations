-- Global Table
ct = {}

-- Global Variables
ct.Target                   = nil                                 -- The unit which the player is targeting
ct.Spelltarget              = nil                                 -- The unit on which a spell shall be casted
ct.SpellUniqueIdentifier    = 0                                   -- Every spell will have this value (like a primary key in a database)
ct.CurrentUniqueIdentifier  = nil                                 -- This is the primary key of the spell that is currently being casted
ct.CurrentSpell             = nil                                 -- This holds the id of the spell that is currently being casted (also for instant spells)
ct.LAD                      = LibStub("LibArtifactData-1.0")      -- Library for getting Artifact info
ct.TTD                      = {unit, start, duration, dps, ttd}   -- Holds the values required for calculating the ttd for
ct.PlayerDamage             = {damage, damageTakenTime}      -- Holds the values required for calculating the damage that the player took over time

-- GLOBAL SETTINGS

-- Update Values
ct.UpdateInterval           = 0.1           -- Update interval for the rotation
ct.UnitUpdateInterval       =   1           -- Update interval for the unit engine

-- Targeting behavior : Only one can be true
ct.ReTargetNearestUnit      = true
ct.ReTargetHighestUnit      = false
ct.ReTargetLowestUnit       = false

-- Combat behavior
ct.AllowOutOfCombatRoutine  = true

-- Interrupt behavior
ct.InterruptAnyUnit         = true
ct.InterruptMinPercent      = 20
ct.InterruptMaxPercent      = 80

-- Cast Logic Settings
ct.CastDelay                = 200           -- The lower, the more delay will be between each spellcast
ct.CastAngle                =  90           -- Facing angle for casted spells
ct.ConeAngle                =  45           -- Facing angle for cone logic

function ct.StartUp()
  -- Setup event frame
  local frame = CreateFrame("FRAME", "EventFrame")
  local spellframe = CreateFrame("FRAME", "SpellFrame")

  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:RegisterEvent("UNIT_SPELLCAST_START")
  frame:RegisterEvent("PLAYER_TALENT_UPDATE")
  frame:RegisterEvent("UNIT_COMBAT")

  -- This detects the completition of casted spells
  -- This is needed because of the way how the rotation chains up spells
  -- The rotation tries to cast spells with as little delay as possible
  -- and therefore using the "succeeded" event would not be fast enough
  local function spellDetectionHandler()
    -- add spell to the history (no matter if it was on the queue or not)
    if not ct.IsCasting(ct.player) and ct.CurrentSpell ~= nil then
      ct.AddSpellToHistory(ct.CurrentSpell)
      ct.CurrentSpell = nil
    end

    -- remove them from the queue
    if not ct.IsCasting(ct.player) and ct.CastedPercent(ct.player) ~= nil
    and ct.SpellQueue[1] ~= nil
    and ct.CurrentUniqueIdentifier == ct.SpellQueue[1].key then
      ct.DeQueueSpell(ct.CurrentSpell)
      ct.CurrentSpell = nil
    end
  end

  local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6)
    if event == "UNIT_SPELLCAST_START" and arg1 == "player" and getn(ct.SpellQueue) ~= 0 then
      ct.CurrentUniqueIdentifier = ct.SpellQueue[1].key
      ct.CurrentSpell = ct.GetSpellID(arg2)
    end
    if event == "PLAYER_REGEN_ENABLED" then
      -- player left any combat action so the queue will be cleaned up
      ct.CleanUpQueue()
    end
    if event == "PLAYER_TALENT_UPDATE" then
      ct.SetUpRotationEngine()
    end
    if event == "UNIT_COMBAT" and arg1 == "player" and arg2 == "WOUND"
    and arg4 ~= nil then
      -- the player damage table is limited to 100 entries
      if getn(ct.PlayerDamage) > 100 then
        table.remove(ct.PlayerDamage, 1)
      end

      -- add the event to the player damage table
      local Entry = {damage = arg4, damageTakenTime = GetTime()}
      table.insert(ct.PlayerDamage, Entry)
    end
  end

  frame:SetScript("OnEvent", eventHandler)
  spellframe:SetScript("OnUpdate", spellDetectionHandler)

  ct.SetUpRotationEngine()
end
