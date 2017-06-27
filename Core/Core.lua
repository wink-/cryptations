-- Global Table
ct = {}

-- Global Variables
ct.Target                   = nil           -- The unit which the player is targeting
ct.Spelltarget              = nil           -- The unit on which a spell shall be casted
ct.SpellUniqueIdentifier    = 0             -- Every spell will have this value (like a primary key in a database)
ct.CurrentUniqueIdentifier  = nil           -- This is the primary key of the spell that is currently being casted
ct.CurrentSpell             = nil

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
ct.EnableInterrupt          = true
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

  -- This handles the removing of casted spells from the spellqueue
  -- TODO: fix spells with cooldown double casting
  local function spellDetectionHandler()
    if not ct.IsCasting(ct.player) and ct.CastedPercent(ct.player) ~= nil
    and ct.SpellQueue[1] ~= nil
    and ct.CurrentUniqueIdentifier == ct.SpellQueue[1].key then
      -- TODO: add functionality for instant spells
      -- Spell History
      -- maximum lenght of spell history is 10 entries
      if getn(ct.SpellHistory) > 10 then
        table.remove(ct.SpellHistory, 1)
      end

      -- add spell to history like : SPELL; TARGET; TIME
      local Entry = {spell = ct.CurrentSpell, time = GetTime()}
      table.insert(ct.SpellHistory, Entry)

      ct.DeQueueSpell(ct.CurrentSpell)
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
  end

  frame:SetScript("OnEvent", eventHandler)
  spellframe:SetScript("OnUpdate", spellDetectionHandler)

  ct.SetUpRotationEngine()
end
