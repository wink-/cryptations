UpdateInterval = 0.1;

function Pulse(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

  while (self.TimeSinceLastUpdate > UpdateInterval) do

    -- TODO: pulse engine delays for:
    -- when player left combat
    -- when player is looting

    -- only pulse the queue when player is in combat or in a group
    -- EXPERIMENTAL
    if UnitAffectingCombat("player") or IsInGroup() then
      ct.PulseQueue()
    end


    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - UpdateInterval;
  end
end
