local BossManager = LibStub:NewLibrary("BossManager", 1)
local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Player      = LibStub("Player")

-- The bossmanager provides the rotation with useful information
-- e.g. the rotation can ask the bossmanager if it should cast a deff cd in order to counter boss mechanics

-- This function looks at the table of spells that need to be countered with deff cds
-- returns true when deff cd is needed
-- also returns true when the sum of damage taken within 2 seconds is higher than 20% of the player's max health
function BossManager.IsDefCooldownNeeded()
  -- Check if target is boss and is casting dangerous spell
  if PlayerTarget ~= nil and Unit.IsBoss(PlayerTarget)
  and UnitCastingInfo(PlayerTarget) ~= nil then
    local SpellID = Spell.GetID(select(1, UnitCastingInfo(PlayerTarget)))
    for i = 1, getn(SpellsToCounterWithDefCD) do
      if SpellsToCounterWithDefCD[i] == SpellID then
        return true
      end
    end
  end

  -- Check if taken high damage
  if Player.GetDamageOverPeriod(2) >= UnitHealthMax(PlayerUnit) * 0.4 then
    return true
  end

  return false
end
