local Rotation = LibStub("Rotation")

function PulseEngine(self, elapsed)
  -- TODO: pulse engine delays for:
  -- when player left combat
  -- when player is looting

  -- Pulse the Queue
  Rotation.PulseQueue()
end

if FireHack ~= nil then
  AddTimerCallback(0.1, PulseEngine)
end
