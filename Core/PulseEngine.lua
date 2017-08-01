local Rotation = LibStub("Rotation")

function PulseEngine(self, elapsed)

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
AddTimerCallback(0.1, PulseEngine)
