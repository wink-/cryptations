local Rotation = LibStub("Rotation")

UpdateInterval         = 0.1
LastPulse              = GetTime()
NextPulse              = GetTime()

local addonInitialized = false
local rotationEngineInitialized = false
local f = CreateFrame("FRAME", "PulseFrame")

function PulseEngine()
  if GetTime() >= NextPulse then

    if not addonInitialized then
      Initialize_NoUnlockerNeeded()
      addonInitialized = true
      print("Addon Initialized")
    end

    if not Paused then

      if not rotationEngineInitialized
      and FireHack ~= nil then
        Initialize_UnlockerNeeded()
        rotationEngineInitialized = true
        print("Rotation Initialized")
      elseif not rotationEngineInitialized then
        Paused = true
        return message('No unlocker found. Please attach unlocker and type "/cr toggle" ')
      end

      LastPulse = GetTime()
      NextPulse = GetTime() + UpdateInterval

      if PlayerUnit == nil
      or PlayerUnit ~= ObjectPointer("player")
      or not ObjectExists(PlayerUnit) then
        PlayerUnit = ObjectPointer("player")
      end

      -- delay for looting
      if GetNumLootItems() > 0 then
        return Rotation.Delay(2)
      end

      -- Pulse the Queue
      Rotation.PulseQueue()
    end
  end
end

f:SetScript("OnUpdate", PulseEngine)
