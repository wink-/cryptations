local _, _, ClassID = UnitClass("player")
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
  local _, _, _, CastTime = GetSpellInfo(Spell.GetName(SB["New Moon"]))
  return CastTime / 1000
end

-- returns the current state of the artifact spell
function DBArtifactState()
  local _, _, _, _, _, _, ID = GetSpellInfo(Spell.GetName(SB["New Moon"]))
  if ID == SB["New Moon"] then return 1
  elseif ID == SB["Half Moon"] then return 2
  elseif ID == SB["Full Moon"] then return 3
  end
end

function DBPowerGainSolarWrath()
  local Power = 8
  if Buff.Has(PlayerUnit, AB["Celestial Alignment"])
  or Buff.Has(PlayerUnit, AB["Incarnation: Chosen of Elune"]) then
    Power = Power * 1.5
  end
  if Buff.Has(PlayerUnit, AB["Blessing of Elune"]) then
    Power = Power * 1.25
  end

  return Power
end

function DBPowerGainLunarStrike()
  local Power = 12
  if Buff.Has(PlayerUnit, AB["Celestial Alignment"])
  or Buff.Has(PlayerUnit, AB["Incarnation: Chosen of Elune"]) then
    Power = Power * 1.5
  end
  if Buff.Has(PlayerUnit, AB["Blessing of Elune"]) then
    Power = Power * 1.25
  end

  return Power
end

function DBStarfallRadius()
  local Radius = 15
  if Player.HasTalent(7, 2) then
    Radius = Radius * 1.3
  end

  return Radius
end

function DBMoonkin()
  if Spell.CanCast(SB["Moonkin Form"])
  and not Player.IsInShapeshift() then
    return Spell.Cast(SB["Moonkin Form"])
  end
end

function DBBotA()
  if Spell.CanCast(SB["Blessing of the Ancients"])
  and not Buff.Has(PlayerUnit, AB["Blessing of Elune"]) then
    return Spell.Cast(SB["Blessing of the Ancients"])
  end
end

function DBStarsurgeV1()
  local GCD = Player.GetGCDDuration()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["The Emerald Dreamcatcher"])
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) < GCD then
    return Spell.Cast(SB["Starsurge"], PlayerTarget)
  end
end

function DBFoE()
  local x, y, z = ObjectPosition(Unit.FindBestToAOE(5, 1, 40))
  if x == nil or y == nil or z == nil then return end
  local LunarPower  = UnitPower("player", 8)
  if Spell.CanCast(SB["Fury of Elune"], nil, 8, 6)
  and LunarPower >= 80 then
    return Spell.CastGroundSpell(SB["Fury of Elune"], x, y, z)
  end
end

function DBNewMoonV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["New Moon"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Spell.GetRemainingChargeTime(SB["New Moon"]) == 0
  and (not Buff.Has(PlayerUnit, AB["The Emerald Dreamcatcher"])
  or Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > DBNewMoonCastTime()) then
     return Spell.Cast(SB["New Moon"], PlayerTarget)
  end
end

function DBMoonfireV1()

  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Moonfire"], PlayerTarget, 0, MaxMana * 0.06)
  and Unit.IsInLOS(PlayerTarget)
  and (not Debuff.Has(PlayerTarget, AB["Moonfire"], true)
  or Debuff.RemainingTime(PlayerTarget, AB["Moonfire"], true) < 3) then
    return Spell.Cast(SB["Moonfire"], PlayerTarget)
  end
end

function DBSunfireV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Sunfire"], PlayerTarget, 0, MaxMana * 0.12)
  and Unit.IsInLOS(PlayerTarget)
  and (not Debuff.Has(PlayerTarget, AB["Sunfire"], true)
  or Debuff.RemainingTime(PlayerTarget, AB["Sunfire"], true) < 3) then
    return Spell.Cast(SB["Sunfire"], PlayerTarget)
  end
end

function DBStellarFlareV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Stellar Flare"], PlayerTarget, 8, 10)
  and Unit.IsInLOS(PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and (not Debuff.Has(PlayerTarget, AB["Stellar Flare"], true)
  or Debuff.RemainingTime(PlayerTarget, AB["Stellar Flare"], true) < 3) then
    return Spell.Cast(SB["Stellar Flare"], PlayerTarget)
  end
end

function DBStarfallV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and Unit.IsInLOS(PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Oneth's Intuition"]) then
    local x, y, z = ObjectPosition(PlayerTarget)
    return Spell.CastGroundSpell(SB["Starfall"], x, y, z)
  end
end

function DBNewMoonV2()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local SpellState    = DBArtifactState()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["New Moon"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and LunarPower < LunarPowerMax - 10 * (1 + SpellState) then
    return Spell.Cast(SB["New Moon"], PlayerTarget)
  end
end

function DBStarfallV2Pos()
  return ObjectPosition(Unit.FindBestToAOE(DBStarfallRadius(), 2, 40))
end

function DBStarfallV2()
  local x, y, z = DBStarfallV2Pos()
  if x == nil or y == nil or z == nil then return end
  if Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and (not Player.HasTalent(7, 1)
  or (not Buff.Has(PlayerUnit, AB["Fury of Elune"]) and Spell.GetRemainingCooldown(SB["Fury of Elune"]) > 5)) then
    return Spell.CastGroundSpell(SB["Starfall"], x, y, z)
  end
end

function DBStellarFlareV2()
  local Target = Group.FindDoTTarget(SB["Stellar Flare"], SB["Stellar Flare"], 2)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(SB["Stellar Flare"], Target, 8, 10)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Stellar Flare"], true)
  or Debuff.RemainingTime(Target, AB["Stellar Flare"], true) < 7) then
    return Spell.Cast(SB["Stellar Flare"], Target)
  end
end

function DBSunfireV2()
  local Target = Group.FindDoTTarget(SB["Sunfire"], SB["Sunfire"], 10)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(SB["Sunfire"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(PlayerTarget)
  and (not Debuff.Has(Target, AB["Sunfire"], true)
  or Debuff.RemainingTime(Target, AB["Sunfire"], true) < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(SB["Sunfire"], Target)
  end
end

function DBMoonfireV2()
  local Target = Group.FindDoTTarget(SB["Moonfire"], SB["Moonfire"], 10)
  if Target == nil or not ObjectExists(Target) then return end
  if Spell.CanCast(SB["Moonfire"], Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(PlayerTarget)
  and (not Debuff.Has(Target, AB["Moonfire"], true)
  or Debuff.RemainingTime(Target, AB["Moonfire"], true) < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DBStarsurgeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Oneth's Intuition"]) then
    return Spell.Cast(SB["Starsurge"], PlayerTarget)
  end
end

function DBStarsurgeV3()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and not IsEquippedItem(137062)
  and #Unit.GetUnitsInRadius(PlayerUnit, DBStarfallRadius(), "hostile", true) < 2
  and Buff.Stacks(PlayerUnit, AB["Solar Empowerment"]) < 3
  and Buff.Stacks(PlayerUnit, AB["Lunar Empowerment"]) < 3
  and (not Player.HasTalent(7, 1)
  or (not Spell.CanCast(SB["Fury of Elune"], nil, 8, 6)
  and not Buff.Has(PlayerUnit, AB["Fury of Elune"]))) then
    return Spell.Cast(SB["Starsurge"], PlayerTarget)
  end
end

function DBSolarWrathV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Solar Wrath"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Solar Empowerment"]) then
    return Spell.Cast(SB["Solar Wrath"], PlayerTarget)
  end
end

function DBLunarStrikeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Lunar Strike"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Lunar Empowerment"]) then
    return Spell.Cast(SB["Lunar Strike"], PlayerTarget)
  end
end

function DBLunarStrikeV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Lunar Strike"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Warrior of Elune"]) then
    return Spell.Cast(SB["Lunar Strike"], PlayerTarget)
  end
end

function DBSolarWrathV2()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Solar Wrath"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(SB["Solar Wrath"], PlayerTarget)
  end
end

function DBAstralCommunion()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  if Spell.CanCast(SB["Astral Communion"])
  and LunarPowerMax - LunarPower >= 75
  and (not Player.HasTalent(7, 1) or not Buff.Has(PlayerUnit, AB["Fury of Elune"])) then
    return Spell.Cast(SB["Astral Communion"])
  end
end

function DBFoN()
  if Spell.CanCast(SB["Force of Nature"])
  and not IsInGroup() then
    local x, y, z = ObjectPosition(PlayerUnit)
    return Spell.CastGroundSpell(SB["Force of Nature"], x, y, z)
  end
end

function DBWoE()
  if Spell.CanCast(SB["Warrior of Elune"]) then
    return Spell.Cast(SB["Warrior of Elune"])
  end
end

function DBIncarnation()
  local StarfallIsValid = DBStarfallV2Pos() ~= nil
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Incarnation: Chosen of Elune"])
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and StarfallIsValid
  or (Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40) and not StarfallIsValid) then
    return Spell.Cast(SB["Incarnation: Chosen of Elune"])
  end
end

function DBCA()
  local StarfallIsValid = DBStarfallV2Pos() ~= nil
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Celestial Alignment"])
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and StarfallIsValid
  or (Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40) and not StarfallIsValid) then
    return Spell.Cast(SB["Celestial Alignment"])
  end
end

function DBStarsurgeV4()
  local LunarPower = UnitPower("player", 8)
  local GCD = Player.GetGCDDuration()
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and (Buff.Has(PlayerUnit, AB["Incarnation: Chosen of Elune"])
  and Buff.RemainingTime(PlayerUnit, AB["Incarnation: Chosen of Elune"]) <= math.floor(LunarPower / 40) * GCD)
  or (Buff.Has(PlayerUnit, AB["Celestial Alignment"])
  and Buff.RemainingTime(PlayerUnit, AB["Celestial Alignment"]) <= math.floor(LunarPower / 40) * GCD) then
    return Spell.Cast(SB["Starsurge"], PlayerTarget)
  end
end

function DBSolarWrathV3()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local SWCastTime    = 1.5 / (GetHaste() / 100 + 1)
  local LSCastTime    = 2.5 / (GetHaste() / 100 + 1)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Solar Wrath"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Stack(PlayerUnit, AB["Solar Empowerment"]) > 1
  and LunarPowerMax - LunarPower >= DBPowerGainSolarWrath()
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > math.max(0.75, SWCastTime) * 2
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) < LSCastTime + math.max(0.75, SWCastTime) then
    return Spell.Cast(SB["Solar Wrath"], PlayerUnit)
  end
end

function DBLunarStrikeV3()
  local LSCastTime    = 2.5 / (GetHaste() / 100 + 1)
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  if PlayerTarget     ~= nil
  and Spell.CanCast(SB["Lunar Strike"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Lunar Empowerment"])
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > LSCastTime
  and LunarPowerMax - LunarPower >= DBPowerGainLunarStrike() then
    return Spell.Cast(SB["Lunar Strike"], PlayerTarget)
  end
end

function DBSolarWrathV4()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Solar Wrath"], PlayerTarget)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and Buff.Has(PlayerUnit, AB["Solar Empowerment"])
  and LunarPowerMax - LunarPower >= DBPowerGainSolarWrath() then
    return Spell.Cast(SB["Solar Wrath"], PlayerTarget)
  end
end

function DBStarsurgeV5()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  if PlayerTarget ~= nil
  and Spell.CanCast(SB["Starsurge"], PlayerTarget, 8, 40)
  and ObjectIsFacing(PlayerUnit, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget)
  and LunarPowerMax - LunarPower <= DBPowerGainLunarStrike() then
    return Spell.Cast(SB["Starsurge"], PlayerTarget)
  end
end
