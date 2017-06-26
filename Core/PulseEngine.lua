UpdateInterval = 0.1;

function Pulse(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

  while (self.TimeSinceLastUpdate > UpdateInterval and UpdateInterval ~= 0) do

    if FireHack == nil then
      UpdateInterval = 0
      return message("No Unlocker Loaded. Attatch Unlocker and Reload")
    elseif FireHack ~= nil and ct.player == nil then
      -- define player object 
      ct.player = GetObjectWithGUID(UnitGUID("player"))
    end
    -- TODO: pulse engine delays for:
    -- when player left combat
    -- when player is looting

    -- only pulse the queue when player is in combat or in a group
    -- EXPERIMENTAL
    if UnitAffectingCombat("player") or IsInGroup()
    or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil) then
      ct.PulseQueue()
    end

    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - UpdateInterval;
  end
end
