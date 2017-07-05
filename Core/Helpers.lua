-- returns table containing units that are within the player's group or raid
function ct.GetGroupMembers()
  local Units = {}
  local ObjectCount = GetObjectCount()
  local Object = nil
  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    if ObjectExists(Object) and (UnitInRaid(Object) or UnitInParty(Object)) then
      table.insert(Units, Object)
    end
  end
  return Units
end

-- returns the distance between x1,y1,z1 and x2,y2,z2
-- TODO: implement
function ct.GetDistanceBetweenPositions(x1, y1, z1, x2, y2, z2)
end

-- given the spellID of the artifact trait, produces true if currently equipped artifact has this trait unlocked
function ct.PlayerHasArtifactTrait(spellID)
  local traits = select(2, ct.LAD:GetArtifactTraits())

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
function ct.GetDamageOverPeriod(period)
  if getn(ct.PlayerDamage) == 0 then
    return 0
  end

  local Sum = 0
  for i = 1, getn(ct.PlayerDamage) do
    if GetTime() - ct.PlayerDamage[i].damageTakenTime < period then
      Sum = Sum + ct.PlayerDamage[i].damage
    end
  end

  return Sum
end
