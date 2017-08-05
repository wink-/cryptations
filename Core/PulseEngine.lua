local Rotation = LibStub("Rotation")

local UpdateInterval          = 0.1
local LastUpdate              = GetTime()
local Initialized_Unlocker    = false
local Initialized_NoUnlocker  = false

local f = CreateFrame("FRAME", "PulseFrame")

function PulseEngine()
  if LastUpdate < GetTime() + UpdateInterval
  and not Paused then

    if not Initialized_NoUnlocker then
      Initialized_NoUnlocker = true
      Initialize_NoUnlockerNeeded()
    end

    if FireHack ~= nil
    and not Initialized_Unlocker then
      Initialized_Unlocker = true
      Initialize_UnlockerNeeded()
    elseif FireHack == nil then
      Messaged = true
      Rotation.Pause()
      return message("No unlocker attached. Please attach unlocker and type '/cr toggle'.")
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
