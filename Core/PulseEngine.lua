function Pulse(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed

  while (self.TimeSinceLastUpdate > ct.UpdateInterval and ct.UpdateInterval ~= 0) do

    if FireHack == nil then
      ct.UpdateInterval = 0
      return message("No Unlocker Loaded. Attatch Unlocker and Reload")
    else
      -- Testing this
      ct.player = GetObjectWithGUID(UnitGUID("player"))
    end

    -- TODO: pulse engine delays for:
    -- when player left combat
    -- when player is looting

    -- Pulse the Queue
    if UnitAffectingCombat("player") or IsInGroup()
    or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil) then
      ct.PulseQueue()
    end

    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - ct.UpdateInterval
  end
end
