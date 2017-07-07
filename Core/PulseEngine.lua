UpdateInterval = 0.1

local Rotation = LibStub("Rotation")

function PulseEngine(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed

  while (self.TimeSinceLastUpdate > UpdateInterval and UpdateInterval ~= 0) do

    if FireHack == nil then
      UpdateInterval = 0
      return message("No Unlocker Loaded. Attatch Unlocker and Reload")
    end

    -- TODO: pulse engine delays for:
    -- when player left combat
    -- when player is looting

    -- Pulse the Queue
    if UnitAffectingCombat("player") or IsInGroup()
    or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil) then
      Rotation.PulseQueue()
    end

    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - UpdateInterval
  end
end
