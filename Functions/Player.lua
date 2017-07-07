local Player  = LibStub:NewLibrary("Player", 1)
local LAD     = LibStub("LibArtifactData-1.0")

-- Holds the values required for calculating the damage that the player took over time
PLAYER_DAMAGE = {
  damage,
  damageTakenTime
}

-- given the spellID of the artifact trait, produces true if currently equipped artifact has this trait unlocked
function Player.HasArtifactTrait(spellID)
  local traits = select(2, LAD:GetArtifactTraits())

  if traits == nil or getn(traits) == 0 then
    return nil
  end

  for i = 1, #traits do
    if traits[i].spellID == spellID then
      return true
    end
  end

  return false
end

-- returns the sum of the damage that the player took over the given period of time (e.g. last 5 seconds)
function Player.GetDamageOverPeriod(period)
  if getn(PLAYER_DAMAGE) == 0 then
    return 0
  end

  local Sum = 0
  for i = 1, getn(PLAYER_DAMAGE) do
    if GetTime() - PLAYER_DAMAGE[i].damageTakenTime < period then
      Sum = Sum + PLAYER_DAMAGE[i].damage
    end
  end

  return Sum
end
