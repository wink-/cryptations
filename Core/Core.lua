-- Global Table
ct = {}

-- Global Variables
ct.Target                   = nil           -- The unit which the player is targeting
ct.Spelltarget              = nil           -- The unit on which a spell shall be casted

-- GLOBAL SETTINGS

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
ct.CastDelay                = 150           -- The lower, the more delay will be between each spellcast
ct.CastAngle                =  90           -- Facing angle for casted spells
ct.ConeAngle                =  45           -- Facing angle for cone logic

function ct.StartUp()
  if FireHack ~= nil then
    -- Setup event frame
    local frame = CreateFrame("FRAME", "EventFrame")
    local spellframe = CreateFrame("FRAME", "SpellFrame")

    frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    -- this is some next level trickery
    local function spellHandler()
      if not ct.IsCasting(ct.player) and ct.CastedPercent(ct.player) ~= nil then
        ct.DeQueueSpell(ct.GetSpellID(select(1, UnitCastingInfo(ct.player))))

        -- Spell History
        -- maximum lenght of spell history is 10 entries
        if getn(ct.SpellHistory) > 10 then
          table.remove(ct.SpellHistory, 1)
        end

        -- add spell to history like : SPELL; TARGET; TIME
        local Entry = {spell = arg5, time = GetTime()}
        table.insert(ct.SpellHistory, Entry)
      end
    end

    local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6)
      if event == "UNIT_SPELLCAST_FAILED" and arg1 == "player" then
        print("failed")
        -- re add spell to the queue when it was failed to cast
        --ct.AddSpellToQueue(arg5, ct.SpellTarget)
      end
      if event == "PLAYER_REGEN_ENABLED" then
        -- player left any combat action (or the target died) so the queue will be cleaned up
        print("player left combat")
        ct.CleanUpQueue()
      end
    end

    frame:SetScript("OnEvent", eventHandler)
    spellframe:SetScript("OnUpdate", spellHandler)

    -- define player object (needed for ewt)
    ct.player = GetObjectWithGUID(UnitGUID("player"))

    ct.SetUpRotationEngine()
  else
    message("No unlocker loaded")
  end
end
