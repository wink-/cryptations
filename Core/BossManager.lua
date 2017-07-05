BossManager = {}

-- The bossmanager provides the rotation with useful information
-- e.g. the rotation can ask the bossmanager if it should cast a deff cd in order to counter boss mechanics

-- This function looks at the table of spells that need to be countered with deff cds
-- returns true when deff cd is needed
-- also returns true when the sum of damage taken within 2 seconds is higher than 20% of the player's max health
function BossManager.IsDefCooldownNeeded()
  -- Check if target is boss and is casting dangerous spell
  if ct.Target ~= nil and ct.IsBoss(ct.Target)
  and UnitCastingInfo(ct.Target) ~= nil then
    local SpellID = ct.GetSpellID(select(1, UnitCastingInfo(ct.Target)))
    -- TODO: use correct table, this one is just for performance testing
    for i = 1, getn(ct.SpellsToCounterWithDefCD) do
      if ct.SpellsToCounterWithDefCD[i] == SpellID then
        return true
      end
    end
  end

  -- Check if taken high damage
  if ct.GetDamageOverPeriod(2) >= UnitHealthMax(ct.player) * 0.2 then
    return true
  end

  return false
end
