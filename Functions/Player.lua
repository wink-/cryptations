local Player  = LibStub("Player")
local LAD     = LibStub("LibArtifactData-1.0")

-- Holds the values required for calculating the damage that the player took over time
PLAYER_DAMAGE = {
  damage,
  damageTakenTime
}

-- given the spellID of the artifact trait, returns the current rank of this artifact
-- returns 0 if the player does not have the rank unlocked
function Player.ArtifactTraitRank(spellID)
  local traits = select(2, LAD:GetArtifactTraits())

  if traits == nil or getn(traits) == 0 then
    return nil
  end

  for i = 1, #traits do
    if traits[i].spellID == spellID then
      return traits[i].currentRank
    end
  end

  return 0
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

-- returns true if the player has selected the given talent
function Player.HasTalent(tier, column)
  return select(4, GetTalentInfo(tier, column, 1)) == true
end

-- returns the current gcd duration in seconds
function Player.GetGCDDuration()
  local HastePercent = GetHaste() / 100 + 1
  return 1.5 / HastePercent
end

-- This returns true when the player has at least "Piece" items of the given Tier equipped
-- Tier represents the Table where the item information is in
function Player.HasSetBonus(Tier, Piece)
  local _, Class  = UnitClass("player")
  local Count     = 0
  for i = 1, #Tier[Class] do
    if IsEquippedItem(Tier[Class][i]) then
      Count = Count + 1
    end
  end

  return Count >= Piece
end
