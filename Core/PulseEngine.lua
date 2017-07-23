local Rotation = LibStub("Rotation")

function PulseEngine(self, elapsed)
  if FireHack == nil then
    return message("No Unlocker Loaded. Attatch Unlocker and Reload")
  end

  -- TODO: pulse engine delays for:
  -- when player left combat
  -- when player is looting

  -- Pulse the Queue
  Rotation.PulseQueue()
end

AddTimerCallback(0.1, PulseEngine)
