local DruidBalance  = LibStub("DruidBalance")
local Unit          = LibStub("Unit")
local Spell         = LibStub("Spell")
local Rotation      = LibStub("Rotation")
local Player        = LibStub("Player")
local Buff          = LibStub("Buff")
local Debuff        = LibStub("Debuff")
local BossManager   = LibStub("BossManager")
local Group         = LibStub("Group")

local MaxMana = UnitPowerMax("player", 0)

function DruidBalance.NewMoonCastTime()
  local _, _, _, CastTime = GetSpellInfo(Spell.GetName(SB["New Moon"]))
  return CastTime / 1000
end

-- returns the current state of the artifact spell
function DruidBalance.ArtifactState()
  local _, _, _, _, _, _, ID = GetSpellInfo(Spell.GetName(SB["New Moon"]))
  if ID == SB["New Moon"] then return 1
  elseif ID == SB["Half Moon"] then return 2
  elseif ID == SB["Full Moon"] then return 3
  end
end

function DruidBalance.PowerGainSolarWrath()
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

function DruidBalance.PowerGainLunarStrike()
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

function DruidBalance.StarfallRadius()
  local Radius = 15
  if Player.HasTalent(7, 2) then
    Radius = Radius * 1.3
  end

  return Radius
end

function DruidBalance.Moonkin()
  if MoonkinForm
  and Spell.CanCast(SB["Moonkin Form"])
  and not Player.IsInShapeshift() then
    return Spell.Cast(SB["Moonkin Form"])
  end
end

function DruidBalance.BotA()
  if BotA
  and Spell.CanCast(SB["Blessing of the Ancients"])
  and ((not Buff.Has(PlayerUnit, AB["Blessing of Elune"]) and BoE)
  or (not Buff.Has(PlayerUnit, AB["Blessing of An'she"]) and BoA)) then
    return Spell.Cast(SB["Blessing of the Ancients"])
  end
end

function DruidBalance.StarsurgeV1()
  local GCD     = Player.GetGCDDuration()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starsurge"], Target, 8, 40)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["The Emerald Dreamcatcher"])
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) < GCD then
    return Spell.Cast(SB["Starsurge"], Target)
  end
end

function DruidBalance.FoE()
  local x, y, z = ObjectPosition(Unit.FindBestToAOE(5, 1, 40))

  if x == nil or y == nil or z == nil then return end
  local LunarPower  = UnitPower("player", 8)
  if Spell.CanCast(SB["Fury of Elune"], nil, 8, 6)
  and LunarPower >= 80 then
    return Spell.CastGroundSpell(SB["Fury of Elune"], x, y, z)
  end
end

function DruidBalance.NewMoonV1()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["New Moon"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Spell.GetRemainingChargeTime(SB["New Moon"]) == 0
  and (not Buff.Has(PlayerUnit, AB["The Emerald Dreamcatcher"])
  or Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > DruidBalance.NewMoonCastTime()) then
     return Spell.Cast(SB["New Moon"], Target)
  end
end

function DruidBalance.MoonfireV1()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Moonfire"], Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Moonfire"], true)
  or Debuff.RemainingTime(Target, AB["Moonfire"], true) < 3) then
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DruidBalance.SunfireV1()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Sunfire"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Sunfire"], true)
  or Debuff.RemainingTime(Target, AB["Sunfire"], true) < 3) then
    return Spell.Cast(SB["Sunfire"], Target)
  end
end

function DruidBalance.StellarFlareV1()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Stellar Flare"], Target, 8, 10)
  and Unit.IsInLOS(Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and (not Debuff.Has(Target, AB["Stellar Flare"], true)
  or Debuff.RemainingTime(Target, AB["Stellar Flare"], true) < 3) then
    return Spell.Cast(SB["Stellar Flare"], Target)
  end
end

function DruidBalance.StarfallV1()
  local Target  = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and Unit.IsInLOS(Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Buff.Has(PlayerUnit, AB["Oneth's Intuition"]) then
    local x, y, z = ObjectPosition(Target)
    return Spell.CastGroundSpell(SB["Starfall"], x, y, z)
  end
end

function DruidBalance.NewMoonV2()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local SpellState    = DruidBalance.ArtifactState()
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["New Moon"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and LunarPower < LunarPowerMax - 10 * (1 + SpellState) then
    return Spell.Cast(SB["New Moon"], Target)
  end
end

function DruidBalance.StarfallV2Pos()
  local StarfallRadius = DruidBalance.StarfallRadius()
  return ObjectPosition(Unit.FindBestToAOE(StarfallRadius, 2, 40))
end

function DruidBalance.StarfallV2()
  local x, y, z = DruidBalance.StarfallV2Pos()

  if x == nil or y == nil or z == nil then return end
  if Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and (not Player.HasTalent(7, 1)
  or (not Buff.Has(PlayerUnit, AB["Fury of Elune"]) and Spell.GetRemainingCooldown(SB["Fury of Elune"]) > 5)) then
    return Spell.CastGroundSpell(SB["Starfall"], x, y, z)
  end
end

function DruidBalance.StellarFlareV2()
  if StFMD then
    local Target = Group.FindDoTTarget(SB["Stellar Flare"], SB["Stellar Flare"], StFMDCount)
  else
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Stellar Flare"], Target, 8, 10)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Stellar Flare"], true)
  or Debuff.RemainingTime(Target, AB["Stellar Flare"], true) < 7) then
    return Spell.Cast(SB["Stellar Flare"], Target)
  end
end

function DruidBalance.SunfireV2()
  if SFMD then
    local Target = Group.FindDoTTarget(SB["Sunfire"], SB["Sunfire"], SFMDCount)
  else
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Sunfire"], Target, 0, MaxMana * 0.12)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Sunfire"], true)
  or Debuff.RemainingTime(Target, AB["Sunfire"], true) < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(SB["Sunfire"], Target)
  end
end

function DruidBalance.MoonfireV2()
  if MFMD then
    local Target = Group.FindDoTTarget(SB["Moonfire"], SB["Moonfire"], MFMDCount)
  else
    local Target = PlayerTarget()
  end

  if Target ~= nil
  and Spell.CanCast(SB["Moonfire"], Target, 0, MaxMana * 0.06)
  and Unit.IsInLOS(Target)
  and (not Debuff.Has(Target, AB["Moonfire"], true)
  or Debuff.RemainingTime(Target, AB["Moonfire"], true) < 5)
  and (not Player.HasTalent(7, 3)
  or #Unit.GetUnitsInRadius(PlayerUnit, 40, "hostile", true) > 1) then
    return Spell.Cast(SB["Moonfire"], Target)
  end
end

function DruidBalance.StarsurgeV2()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starsurge"], Target, 8, 40)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Oneth's Intuition"]) then
    return Spell.Cast(SB["Starsurge"], Target)
  end
end

function DruidBalance.StarsurgeV3()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starsurge"], Target, 8, 40)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and not IsEquippedItem(137062)
  and #Unit.GetUnitsInRadius(PlayerUnit, DruidBalance.StarfallRadius(), "hostile", true) < 2
  and Buff.Stacks(PlayerUnit, AB["Solar Empowerment"]) < 3
  and Buff.Stacks(PlayerUnit, AB["Lunar Empowerment"]) < 3
  and (not Player.HasTalent(7, 1)
  or (not Spell.CanCast(SB["Fury of Elune"], nil, 8, 6)
  and not Buff.Has(PlayerUnit, AB["Fury of Elune"]))) then
    return Spell.Cast(SB["Starsurge"], Target)
  end
end

function DruidBalance.SolarWrathV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Solar Wrath Balance"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Solar Empowerment"]) then
    return Spell.Cast(SB["Solar Wrath Balance"], Target)
  end
end

function DruidBalance.LunarStrikeV1()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Lunar Strike"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Lunar Empowerment"]) then
    return Spell.Cast(SB["Lunar Strike"], Target)
  end
end

function DruidBalance.LunarStrikeV2()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Lunar Strike"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Warrior of Elune"]) then
    return Spell.Cast(SB["Lunar Strike"], Target)
  end
end

function DruidBalance.SolarWrathV2()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Solar Wrath Balance"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target) then
    return Spell.Cast(SB["Solar Wrath Balance"], Target)
  end
end

function DruidBalance.AstralCommunion()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)

  if Spell.CanCast(SB["Astral Communion"])
  and LunarPowerMax - LunarPower >= 75
  and (not Player.HasTalent(7, 1) or not Buff.Has(PlayerUnit, AB["Fury of Elune"])) then
    return Spell.Cast(SB["Astral Communion"])
  end
end

function DruidBalance.FoN()
  if FoN
  and Spell.CanCast(SB["Force of Nature"])
  and not IsInGroup() then
    local x, y, z = ObjectPosition(PlayerUnit)
    return Spell.CastGroundSpell(SB["Force of Nature"], x, y, z)
  end
end

function DruidBalance.WoE()
  if WoE
  and Spell.CanCast(SB["Warrior of Elune"]) then
    return Spell.Cast(SB["Warrior of Elune"])
  end
end

function DruidBalance.Incarnation()
  local StarfallIsValid = DruidBalance.StarfallV2Pos() ~= nil
  local Target          = PlayerTarget()

  if Incarnation
  and Target ~= nil
  and Spell.CanCast(SB["Incarnation: Chosen of Elune"])
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and StarfallIsValid
  or (Spell.CanCast(SB["Starsurge"], Target, 8, 40) and not StarfallIsValid) then
    return Spell.Cast(SB["Incarnation: Chosen of Elune"])
  end
end

function DruidBalance.CA()
  local StarfallIsValid = DruidBalance.StarfallV2Pos() ~= nil
  local Target          = PlayerTarget()

  if CA
  and Target ~= nil
  and Spell.CanCast(SB["Celestial Alignment"])
  and Spell.CanCast(SB["Starfall"], nil, 8, 60)
  and StarfallIsValid
  or (Spell.CanCast(SB["Starsurge"], Target, 8, 40) and not StarfallIsValid) then
    return Spell.Cast(SB["Celestial Alignment"])
  end
end

function DruidBalance.StarsurgeV4()
  local LunarPower  = UnitPower("player", 8)
  local GCD         = Player.GetGCDDuration()
  local Target      = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starsurge"], Target, 8, 40)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and (Buff.Has(PlayerUnit, AB["Incarnation: Chosen of Elune"])
  and Buff.RemainingTime(PlayerUnit, AB["Incarnation: Chosen of Elune"]) <= math.floor(LunarPower / 40) * GCD)
  or (Buff.Has(PlayerUnit, AB["Celestial Alignment"])
  and Buff.RemainingTime(PlayerUnit, AB["Celestial Alignment"]) <= math.floor(LunarPower / 40) * GCD) then
    return Spell.Cast(SB["Starsurge"], Target)
  end
end

function DruidBalance.SolarWrathV3()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local SWCastTime    = 1.5 / (GetHaste() / 100 + 1)
  local LSCastTime    = 2.5 / (GetHaste() / 100 + 1)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Solar Wrath Balance"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Stack(PlayerUnit, AB["Solar Empowerment"]) > 1
  and LunarPowerMax - LunarPower >= DruidBalance.PowerGainSolarWrath()
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > math.max(0.75, SWCastTime) * 2
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) < LSCastTime + math.max(0.75, SWCastTime) then
    return Spell.Cast(SB["Solar Wrath Balance"], PlayerUnit)
  end
end

function DruidBalance.LunarStrikeV3()
  local LSCastTime    = 2.5 / (GetHaste() / 100 + 1)
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local Target        = PlayerTarget()

  if Target     ~= nil
  and Spell.CanCast(SB["Lunar Strike"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Lunar Empowerment"])
  and Buff.RemainingTime(PlayerUnit, AB["The Emerald Dreamcatcher"]) > LSCastTime
  and LunarPowerMax - LunarPower >= DruidBalance.PowerGainLunarStrike() then
    return Spell.Cast(SB["Lunar Strike"], Target)
  end
end

function DruidBalance.SolarWrathV4()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Solar Wrath Balance"], Target)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and Buff.Has(PlayerUnit, AB["Solar Empowerment"])
  and LunarPowerMax - LunarPower >= DruidBalance.PowerGainSolarWrath() then
    return Spell.Cast(SB["Solar Wrath Balance"], Target)
  end
end

function DruidBalance.StarsurgeV5()
  local LunarPower    = UnitPower("player", 8)
  local LunarPowerMax = UnitPowerMax("player", 8)
  local Target        = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Starsurge"], Target, 8, 40)
  and ObjectIsFacing(PlayerUnit, Target)
  and Unit.IsInLOS(Target)
  and LunarPowerMax - LunarPower <= DruidBalance.PowerGainLunarStrike() then
    return Spell.Cast(SB["Starsurge"], Target)
  end
end
