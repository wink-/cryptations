local Rotation = LibStub("Rotation")

UpdateInterval         = 0.1
LastPulse              = GetTime()
NextPulse              = GetTime()

local f = CreateFrame("FRAME", "PulseFrame")

function PulseEngine()
  if GetTime() >= NextPulse
  and not Paused then
    LastPulse = GetTime()
    NextPulse = GetTime() + UpdateInterval

    if PlayerUnit == nil
    or PlayerUnit ~= ObjectPointer("player")
    or not ObjectExists(PlayerUnit) then
      PlayerUnit = ObjectPointer("player")
    end

    -- TODO: pulse engine delays for:
    -- when player left combat
    if GetNumLootItems() > 0 then
      return Rotation.Delay(2)
    end

    -- Pulse the Queue
    Rotation.PulseQueue()
  end
end

f:SetScript("OnUpdate", PulseEngine)
