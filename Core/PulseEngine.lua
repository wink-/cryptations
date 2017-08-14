local Rotation = LibStub("Rotation")

local UpdateInterval = 0.1
local LastPulse      = GetTime()
NextPulse            = GetTime()

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
    -- when player is looting

    -- Pulse the Queue
    Rotation.PulseQueue()
  end
end

f:SetScript("OnUpdate", PulseEngine)
