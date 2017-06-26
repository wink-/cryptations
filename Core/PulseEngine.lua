function Pulse(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed

  while (self.TimeSinceLastUpdate > ct.UpdateInterval and ct.UpdateInterval ~= 0) do

    if FireHack == nil then
      ct.UpdateInterval = 0
      return message("No Unlocker Loaded. Attatch Unlocker and Reload")
    elseif FireHack ~= nil and (ct.player == nil or not ObjectExists(ct.player)) then
      -- define player object
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
