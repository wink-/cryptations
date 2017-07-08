local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Holy.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

-- Apply settings from config file
UseDispell                          = Settings.UseDispell
UseAvengingWrath                    = Settings.UseAvengingWrath
UseHolyAvenger                      = Settings.UseHolyAvenger
UseLayOnHands                       = Settings.UseLayOnHands
UseBlessingOfSacrifice              = Settings.UseBlessingOfSacrifice
UseTyrsDeliverance                  = Settings.UseTyrsDeliverance
UseRuleOfLaw                        = Settings.UseRuleOfLaw
UseBeaconOfLight                    = Settings.UseBeaconOfLight
UseBeaconOfFaith                    = Settings.UseBeaconOfFaith
UseHolyLightOnInfusion              = Settings.UseHolyLightOnInfusion
UseFlashOfLightOnInfusion           = Settings.UseFlashOfLightOnInfusion
UseJudgment                         = Settings.UseJudgment
UseLightsHammer                     = Settings.UseLightsHammer
UseLightofDawn                      = Settings.UseLightofDawn
UseHolyPrism                        = Settings.UseHolyPrism
UseBeaconOfVirtue                   = Settings.UseBeaconOfVirtue

AvengingWrathUnitThreshold          = Settings.AvengingWrathUnitThreshold
AvengingWrathHealthThreshold        = Settings.AvengingWrathHealthThreshold
HolyAvengerUnitThreshold            = Settings.HolyAvengerUnitThreshold
HolyAvengerHealthThreshold          = Settings.HolyAvengerHealthThreshold
LayOnHandsHealthThreshold           = Settings.LayOnHandsHealthThreshold
BlessingOfSacrificeHealthThreshold  = Settings.BlessingOfSacrificeHealthThreshold
TyrsDeliveranceUnitThreshold        = Settings.TyrsDeliveranceUnitThreshold
TyrsDeliveranceHealthThreshold      = Settings.TyrsDeliveranceHealthThreshold
LightsHammerUnitThreshold           = Settings.LightsHammerUnitThreshold
LightsHammerHealthThreshold         = Settings.LightsHammerHealthThreshold
LightOfDawnUnitThreshold            = Settings.LightOfDawnUnitThreshold
LightOfDawnHealthThreshold          = Settings.LightOfDawnHealthThreshold
HolyPrismUnitThreshold              = Settings.HolyPrismUnitThreshold
BeaconOfVirtueUnitThreshold         = Settings.BeaconOfVirtueUnitThreshold
BeaconOfVirtueHealthThreshold       = Settings.BeaconOfVirtueHealthThreshold

TankHealthThreshold                 = Settings.TankHealthThreshold
OtherHealthThreshold                = Settings.OtherHealthThreshold
ToppingHealthThreshold              = Settings.ToppingHealthThreshold
FlashOfLightThreshold               = Settings.FlashOfLightThreshold
BestowFaithThreshold                = Settings.BestowFaithThreshold
MaxMana                             = UnitPowerMax(PlayerUnit , 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function Pulse()

  local MaxHealth               = UnitHealthMax(PlayerUnit)

  local LowestFriend            = Unit.FindLowest("friendly")

  local MainTank, OffTank       = Unit.FindTanks()
  local HealTarget              = nil

  if UnitAffectingCombat(PlayerUnit) then
    -- Dispell engine
    if UseDispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- COOLDOWNS
    -- Avenging Wrath (Use when 3 units are below 60% health)
    if UseAvengingWrath and Spell.CanCast(31842) and GetNumGroupMembers() ~= 1
    and (getn(Unit.GetUnitsBelowHealth(AvengingWrathHealthThreshold, "friendly", true))
    >= AvengingWrathUnitThreshold) then
      return Spell.Cast(31842)
    end

    -- Holy Avenger (Talent) use when 2 units are below 60% health
    if UseHolyAvenger and Spell.CanCast(105809) and GetNumGroupMembers() ~= 1
    and (getn(Unit.GetUnitsBelowHealth(HolyAvengerHealthThreshold, "friendly", true))
    >= HolyAvengerUnitThreshold) then
      return Spell.Cast(105809)
    end

    -- Lay on Hands (use when lowest raid member is below 15% health)
    if UseLayOnHands and Spell.CanCast(633) and LowestFriend ~= nil
    and Unit.PercentHealth(LowestFriend) <= LayOnHandsHealthThreshold then
      return Spell.Cast(633, LowestFriend)
    end

    -- Blessing of Sacrifice (Use together with Divine Protection on units below 20% health)
    if UseBlessingOfSacrifice and Spell.CanCast(6940) and Spell.CanCast(498) and LowestFriend ~= nil
    and not Buff.Has(LowestFriend, 6940)
    and Unit.PercentHealth(LowestFriend) <= BlessingOfSacrificeHealthThreshold then
      local Sequence = {498, 6940}
      return Spell.AddToQueue(Sequence, LowestFriend)
    end

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

    -- Tyr's Deliverance (Used when 2 units in group are below 80% health)
    if UseTyrsDeliverance and Spell.CanCast(200652) then
      if GetNumGroupMembers() ~= 1 and Spell.GetPreviousSpell() ~= 200652
      and (getn(Unit.GetUnitsBelowHealth(TyrsDeliveranceHealthThreshold, "friendly", true, PlayerUnit, 15))
      >= TyrsDeliveranceUnitThreshold) then
        return Spell.Cast(200652)
      end
    end

    -- HEAL LOGIC
    if Unit.IsInRange(PlayerUnit, MainTank, 40) and Unit.IsInLOS(MainTank)
    and Unit.PercentHealth(MainTank) <= TankHealthThreshold
    and (not (Unit.PercentHealth(LowestFriend) <= OtherHealthThreshold)
    or LowestFriend == MainTank) then
      HealTarget = MainTank
    elseif Unit.IsInRange(PlayerUnit, LowestFriend, 40) and Unit.IsInLOS(LowestFriend)
    and Unit.PercentHealth(LowestFriend) <= OtherHealthThreshold then
      HealTarget = LowestFriend
    -- TOPPING ROTATION
    elseif Unit.PercentHealth(LowestFriend) <= ToppingHealthThreshold then
      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if Buff.Has(PlayerUnit, 53576) then
        if UseHolyLightOnInfusion then
          if Spell.CanCast(82326, LowestFriend, 0, MaxMana * 0.12) and Unit.IsInLOS(LowestFriend) then
            return Spell.Cast(82326, LowestFriend)
          end
        elseif UseFlashOfLightOnInfusion then
          if Spell.CanCast(19750, LowestFriend, 0, MaxMana * 0.18) and Unit.IsInLOS(LowestFriend) then
            return Spell.Cast(19750, LowestFriend)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if Holy Shock has CD)
      if Spell.CanCast(20473, LowestFriend, 0, MaxMana * 0.1) and Unit.IsInLOS(LowestFriend) then
        return Spell.Cast(20473, LowestFriend)
      elseif Unit.IsMoving(PlayerUnit) and not Spell.CanCast(20473, LowestFriend, 0, MaxMana * 0.1) then
        if Spell.CanCast(183998, LowestFriend, 0, MaxMana * 0.075) and Unit.IsInLOS(LowestFriend) then
          return Spell.Cast(183998, LowestFriend)
        end
      end

      -- Holy Light
      if Spell.CanCast(82326, LowestFriend, 0, MaxMana * 0.12) and Unit.IsInLOS(LowestFriend) then
        return Spell.Cast(82326, LowestFriend)
      end
    end

    -- HEAL ROTATION
    if HealTarget ~= nil then
      -- Rule of Law (Talent)
      if UseRuleOfLaw and Spell.CanCast(214202) then
        return Spell.Cast(214202)
      end

      -- Beacon of Light on Tank (If not Talented BOV)
      if UseBeaconOfLight and MainTank ~= nil and not select(4, GetTalentInfo(7, 3, 1))
      and Spell.CanCast(53563, MainTank, 0, MaxMana * 0.025) and Unit.IsInLOS(MainTank)
      and not Buff.Has(MainTank, 53563) then
        return Spell.Cast(53563, MainTank)
      end

      -- Beacon of Faith on LowestFriend (If Talented BOF)
      if UseBeaconOfFaith and LowestFriend ~= nil
      and Spell.CanCast(156910, LowestFriend, 0, MaxMana * 0.03125)
      and not Buff.Has(LowestFriend, 156910) and Unit.IsInLOS(LowestFriend)
      and not Buff.Has(LowestFriend, 53563) then
        return Spell.Cast(156910, LowestFriend)
      end

      -- Bestow Faith (Alywas use on MainTank)
      if Spell.CanCast(223306, MainTank, 0, MaxMana * 0.06) and Unit.IsInLOS(MainTank)
      and not Buff.Has(MainTank, 223306) and
      Unit.PercentHealth(MainTank) <= BestowFaithThreshold then
        return Spell.Cast(223306, MainTank)
      end

      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if Buff.Has(PlayerUnit, 53576) then
        if UseHolyLightOnInfusion then
          if Spell.CanCast(82326, HealTarget, 0, MaxMana * 0.12) and Unit.IsInLOS(HealTarget) then
            return Spell.Cast(82326, HealTarget)
          end
        elseif UseFlashOfLightOnInfusion then
          if Spell.CanCast(19750, HealTarget, 0, MaxMana * 0.18) and Unit.IsInLOS(HealTarget) then
            return Spell.Cast(19750, HealTarget)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if Holy Shock has CD)
      if Spell.CanCast(20473, HealTarget, 0, MaxMana * 0.1) and Unit.IsInLOS(HealTarget) then
        return Spell.Cast(20473, HealTarget)
      elseif Unit.IsMoving(PlayerUnit) and not Spell.CanCast(20473, HealTarget, 0, MaxMana * 0.1) then
        if Spell.CanCast(183998, HealTarget, 0, MaxMana * 0.075) and Unit.IsInLOS(HealTarget) then
          return Spell.Cast(183998, HealTarget)
        end
      end

      -- Judgment (when Judgment of Light is talented)
      if UseJudgment and PlayerTarget ~= nil and IsSpellKnown(183778)
      and Spell.CanCast(20271, PlayerTarget, 0, MaxMana * 0.03) and Unit.IsInLOS(PlayerTarget) then
        return Spell.Cast(20271, PlayerTarget)
      end

      -- Light's Hammer (Talent)
      -- Use when at least two units within 10 yards of each other are below 80% health
      if UseLightsHammer and Spell.CanCast(114158, nil, 0, MaxMana * 0.28) then
        -- Find best fitting unit
        local GroupMembers = Player.GetGroupMembers()
        local BestUnit = nil
        local BestUnitTargetCount = 0
        for i = 1, getn(GroupMembers) do
          if (BestUnitTargetCount == 0
          and getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10)) >= LightsHammerUnitThreshold)
          or (BestUnitTargetCount ~= 0
          and getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10)) >= BestUnitTargetCount) then
            BestUnit = GroupMembers[i]
            BestUnitTargetCount = getn(Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, GroupMembers[i], 10))
          end
        end
        if BestUnit ~= nil then
          -- Place Hammer in center of suitable units (if in range)
          local Units = Unit.GetUnitsBelowHealth(LightsHammerHealthThreshold, "friendly", true, BestUnit, 10)
          local x, y, z = Unit.GetCenterBetweenUnits(Units)
          return Spell.CastGroundSpell(114158, x, y, z)
        end
      end

      -- Light of Dawn (Use when 2 Units are in the cone and at 70% or lower)
      if UseLightofDawn and Spell.CanCast(85222, nil, 0, MaxMana * 0.14) then
        -- Rule of Law
        if Buff.Has(PlayerUnit, 214202)
        and (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 22.5, "friendly", true, LightOfDawnHealthThreshold))
        >= LightOfDawnUnitThreshold) then
          return Spell.Cast(85222)
        -- Beacon of the Lightbringer
        elseif select(4, GetTalentInfo(7, 2, 1))
        and (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 19.5, "friendly", true, LightOfDawnHealthThreshold))
        >= LightOfDawnUnitThreshold) then
          return Spell.Cast(85222)
        -- Standard
      elseif (getn(Unit.GetUnitsInCone(PlayerUnit, ConeAngle, 15, "friendly", true, LightOfDawnHealthThreshold))
        >= LightOfDawnUnitThreshold) then
          return Spell.Cast(85222)
        end
      end

      -- Holy Prism (Use on Enemys with at least 4 Players around them)
      if UseHolyPrism and Spell.CanCast(114165, nil, 0, MaxMana * 0.17) then
        local ObjectCount = GetObjectCount()
        local Object = nil
        for i = 1, ObjectCount do
          Object = GetObjectWithIndex(i)
          if ObjectExists(Object) and ObjectIsType(Object, ObjectTypes.Unit) and Unit.IsInLOS(Object)
          and Spell.CanCast(114165, Object) and Unit.IsHostile(Object)
          and (getn(Unit.GetUnitsInRadius(Object, 15, "friendly", true))
          >= HolyPrismUnitThreshold) then
            return Spell.Cast(114165, Object)
          end
        end
      end

      -- Beacon of Virtue
      if UseBeaconOfVirtue
      and Spell.CanCast(200025, HealTarget, 0, MaxMana * 0.1) and Unit.IsInLOS(HealTarget)
      and getn(Unit.GetUnitsBelowHealth(70, "friendly", true, MainTank, 30)) >= 3 then
        return Spell.Cast(200025, HealTarget)
      end

      -- Holy Light (Flash of Light for greater damage)
      if Unit.PercentHealth(HealTarget) <= FlashOfLightThreshold then
        if Spell.CanCast(19750, HealTarget, 0, MaxMana * 0.18) and Unit.IsInLOS(HealTarget) then
          return Spell.Cast(19750, HealTarget)
        end
      else
        if Spell.CanCast(82326, HealTarget, 0, MaxMana * 0.12) and Unit.IsInLOS(HealTarget) then
          return Spell.Cast(82326, HealTarget)
        end
      end
    end
  else
    -- OUT OF COMBAT ROUTINE
  end
end

-- Dispell Spells are handled here
function Dispell(unit, dispelType)
  if Spell.CanCast(4987, unit, 0, MaxMana * 0.13) and dispelType ~= "Curse" then
    return Spell.Cast(4987, unit)
  end
end
