local Rotation = LibStub("Rotation")

local UpdateInterval  = 0.1
local LastUpdate      = GetTime()
local Initialized     = false

local f = CreateFrame("FRAME", "PulseFrame")

function PulseEngine()
  if LastUpdate < GetTime() + UpdateInterval
  and not Paused then

    if FireHack ~= nil
    and not Initialized then
      Initialized = true
      Initialize()
    elseif FireHack == nil then
      Messaged = true
      Rotation.Pause()
      return message("No unlocker attached. Please attach unlocker and reload.")
    end

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

    LastUpdate = GetTime()
  end
end

f:SetScript("OnUpdate", PulseEngine)
