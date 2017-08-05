local Player  = LibStub("Player")
local LAD     = LibStub("LibArtifactData-1.0")

-- Holds the values required for calculating the damage that the player took over time
PLAYER_DAMAGE = {
  damage,
  damageTakenTime
}

GroupInCombat = false -- This updates with the "PLAYER_REGEN_ENABLED" and "PLAYER_REGEN_DISABLED" Events
                      -- and is used to recognize when group memebers are in combat

local SetPieceBonus = 0

-- given the spellID of the artifact trait, returns the current rank of this artifact
-- returns 0 if the player does not have the rank unlocked
function Player.ArtifactTraitRank(spellID)
  local _, traits = LAD:GetArtifactTraits()

  if traits == nil or #traits == 0 then
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
  if #PLAYER_DAMAGE == 0 then
    return 0
  end

  local Sum = 0
  for i = 1, PLAYER_DAMAGE do
    if GetTime() - PLAYER_DAMAGE[i].damageTakenTime < period then
      Sum = Sum + PLAYER_DAMAGE[i].damage
    end
  end

  return Sum
end

-- returns true if the player has selected the given talent
function Player.HasTalent(tier, column)
  local _, _, _, HasTalent = GetTalentInfo(tier, column, 1)
  return HasTalent
end

-- returns the current gcd duration in seconds
function Player.GetGCDDuration()
  local HastePercent = GetHaste() / 100 + 1
  return 1.5 / HastePercent
end

-- This returns true when the player has at least "Piece" items of the given Tier equipped
-- Tier represents the Table where the item information is in
-- This is a helper for determining the set pieces and should never be called manually
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

-- This sets the "SetPieceBonus" variable accordingly
-- This is called whenever a player changes equipment and should never be called manually
function Player.GetSetPieceLatestTier()
  local CurrentTier    = T19
  local MaxBonusPieces = 4
  local Count = 0
  for i = 1, MaxBonusPieces do
    if Player.HasSetBonus(CurrentTier, i) then
      Count = i
    end
  end

  SetPieceBonus = Count
end

-- This function returns wheter or not the player has the given set piece bonus
-- Because of its design, this can only return information about the latest tier sets
function Player.HasSetPiece(Piece)
  return SetPieceBonus >= Piece
end

-- returns true if the player is currently using any shapeshift
function Player.IsInShapeshift()
  if GetShapeshiftForm() ~= 0 then return true end
  return false
end
