local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Group       = LibStub("Group")

local MaxMana = UnitPowerMax("player", 0)

function DBNewMoonCastTime()
  local _, _, _, CastTime = GetSpellInfo(Spell.GetName(202767))
  return CastTime / 1000
end

-- returns the current state of the artifact spell
function DBArtifactState()
  local _, _, _, _, _, _, ID = GetSpellInfo(Spell.GetName(202767))
  if ID == 202767 then return 1
  elseif ID == 202768 then return 2
  elseif ID == 202771 then return 3
  end
end

function DBStarfallRadius()
  local Radius = 15
  if Player.HasTalent(7, 2) then
    Radius = Radius * 1.3
  end

  return Radius
end

function DBBotA()

end

function DBStarsurgeV1()
  local HasBuff, _, RemainingTime = Buff.Has(PlayerUnit, 224706)
  local GCD = Player.GetGCDDuration()
  if PlayerTarget ~= nil
  and Spell.CanCast(78674, PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and HasBuff == true
  and RemainingTime < GCD then
    return Spell.Cast(78674, PlayerTarget)
  end
end

function DBFoEPos()
  local Units = Group.FindBestToAOE(5, 3)
  if Units ~= nil then
    return Unit.GetCenterBetweenUnits(Units)
  end

  return nil
end

function DBFoE()
  local x, y, z = DBFoEPos()
  if x == nil or y == nil or z == nil then return end
  local LunarPower  = UnitPower("player", 8)
  if Spell.CanCast(202770, nil, 8, 6)
  and LunarPower >= 80 then
    return Spell.CastGroundSpell(202770, x, y, z)
  end
end

function DBNewMoonV1()
  local HasBuff, _, RemainingTime = Buff.Has(PlayerUnit, 224706)
  if PlayerTarget ~= nil
  and Spell.CanCast(202767, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Spell.GetRemainingChargeTime(202767) == 0
  and (HasBuff ~= true or RemainingTime > DBNewMoonCastTime()) then
     return Spell.Cast(202767, PlayerTarget)
  end
end

function DBMoonfireV1()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 164812)
  if PlayerTarget ~= nil
  and Spell.CanCast(8921, PlayerTarget, 0, MaxMana * 0.06)
  and Unit.IsInLOS(PlayerTarget)
  and (HasDebuff ~= true or RemainingTime < 3) then
    return Spell.Cast(8921, PlayerTarget)
  end
end

function DBSunfireV1()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 164815)
  if PlayerTarget ~= nil
  and Spell.CanCast(93402, PlayerTarget, 0, MaxMana * 0.12)
  and Unit.IsInLOS(PlayerTarget)
  and (HasDebuff ~= true or RemainingTime < 3) then
    return Spell.Cast(93402, PlayerTarget)
  end
end

function DBStellarFlareV1()
  local HasDebuff, _, RemainingTime = Debuff.Has(PlayerTarget, 202347)
  if PlayerTarget ~= nil
  and Spell.CanCast(202347, PlayerTarget, 8, 10)
  and Unit.IsInLOS(PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and (HasDebuff ~= true or RemainingTime < 3) then
    return Spell.Cast(202347, PlayerTarget)
  end
end

function DBStarfallV1()
  local HasBuff = Buff.Has(PlayerUnit, 209406)
  if PlayerTarget ~= nil
  and Spell.CanCast(191034, nil, 8, 60)
  and Unit.IsInLOS(PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and HasBuff then
    local x, y, z = ObjectPosition(PlayerTarget)
    return Spell.CastGroundSpell(191034, x, y, z)
  end
end

function DBNewMoonV2()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local SpellState    = DBArtifactState()
  if PlayerTarget ~= nil
  and Spell.CanCast(202767, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and LunarPower < LunarPowerMax - 10 * (1 + SpellState) then
    return Spell.Cast(202767, PlayerTarget)
  end
end

function DBStarfallV2Pos()
  local Units = Group.FindBestToAOE(DBStarfallRadius(), 2)
  if Units ~= nil then
    return Unit.GetCenterBetweenUnits(Units)
  end

  return nil
end

function DBStarfallV2()
  local x, y, z = DBStarfallV2Pos()
  if x == nil or y == nil or z == nil then return end
  local HasBuff = Buff.Has(PlayerUnit, 202770)
  if Target ~= nil
  and Spell.CanCast(191034, nil, 8, 60)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and (not Player.HasTalent(7, 1)
  or (HasBuff ~= true and Spell.GetRemainingCooldown(202770) > 5)) then
    return Spell.CastGroundSpell(191034, x, y, z)
  end
end

function DBStellarFlareV2()
  local Target = Group.FindDoTTarget(202347, 202347, 2)
  local HasDebuff, _, RemainingTime = Debuff.Has(Target, 202347)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(202347, Target, 8, 10)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and (HasDebuff ~= true or RemainingTime < 7) then
    return Spell.Cast(202347, Target)
  end
end

function DBSunfireV2()
  local Target = Group.FindDoTTarget(93402, 164815, 10)
  local HasDebuff, _, RemainingTime = Debuff.Has(Target, 164815)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(93402, Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(PlayerTarget)
  and (HasDebuff ~= true or RemainingTime < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(93402, Target)
  end
end

function DBMoonfireV2()
  local Target = Group.FindDoTTarget(8921, 164812, 10)
  local HasDebuff, _, RemainingTime = Debuff.Has(Target, 164812)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(8921, Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(PlayerTarget)
  and (HasDebuff ~= true or RemainingTime < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(8921, Target)
  end
end

function DBStarsurgeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(78674, PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, 209406) then
    return Spell.Cast(209406, PlayerTarget)
  end
end

function DBStarsurgeV3()
  if PlayerTarget ~= nil
  and Spell.CanCast(78674, PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and not IsEquippedItem(137062)
  and #Unit.GetUnitsInRadius(PlayerUnit, DBStarfallRadius(), "hostile", true) < 2
  and (not Player.HasTalent(7, 1)
  or (not Spell.CanCast(202770, nil, 8, 6)
  and not Buff.Has(PlayerUnit, 202770))) then
    return Spell.Cast(209406, PlayerTarget)
  end
end

function DBSolarWrathV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(190984, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, 164545) then
    return Spell.Cast(190984, PlayerTarget)
  end
end

function DBLunarStrikeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(194153, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, 164547) then
    return Spell.Cast(194153, PlayerTarget)
  end
end

function DBLunarStrikeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(194153, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, 202425) then
    return Spell.Cast(194153, PlayerTarget)
  end
end

function DBSolarWrathV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(190984, PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(190984, PlayerTarget)
  end
end
