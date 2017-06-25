-- Global Table
ct = {}

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
ct.CastDelay                = 100           -- The lower, the more delay will be between each spellcast
ct.CastAngle                =  90           -- Facing angle for casted spells
ct.ConeAngle                =  45           -- Facing angle for cone logic

function ct.StartUp()
  if FireHack ~= nil then
    -- Setup event frame
    local frame = CreateFrame("FRAME", "EventFrame")

    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")

    local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6)
      if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        -- removes the spell from the Queue
        ct.DeQueueSpell(arg5)
      end
      if event == "PLAYER_REGEN_ENABLED" then
        -- player left any combat action (or the target died) so the queue will be cleaned up
        print("player left combat")
        ct.CleanUpQueue()
      end
    end

    frame:SetScript("OnEvent", eventHandler)

    -- define player object (needed for ewt)
    ct.player = GetObjectWithGUID(UnitGUID("player"))

    ct.SetUpRotationEngine()
  else
    message("No unlocker loaded")
  end
end
