local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin - Protection.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

UseTauntEngine                            = Settings.UseTauntEngine
UseInterruptEngine                        = Settings.UseInterruptEngine
UseAvengingWrath                          = Settings.UseAvengingWrath
UseGuardianOfTheAncientKings              = Settings.UseGuardianOfTheAncientKings
UseArdentDefender                         = Settings.UseArdentDefender
UseLayOnHandsSelf                         = Settings.UseLayOnHandsSelf
UseLayOnHandsFriend                       = Settings.UseLayOnHandsFriend
UseEyeOfTyr                               = Settings.UseEyeOfTyr
UseSepharim                               = Settings.UseSepharim
UseHandOfTheProtectorFriend               = Settings.UseHandOfTheProtectorFriend
UseFlashOfLight                           = Settings.UseFlashOfLight
UnitsToSwitchToAOE                        = Settings.UnitsToSwitchToAOE
ArdentDefenderHealthThreshold             = Settings.ArdentDefenderHealthThreshold
GuardianOfTheAncientKingsHealthThreshold  = Settings.GuardianOfTheAncientKingsHealthThreshold
EyeOfTyrUnitThreshold                     = Settings.EyeOfTyrUnitThreshold
LayOnHandsHealthThreshold                 = Settings.LayOnHandsHealthThreshold
LightOfTheProtectorHealthThreshold        = Settings.LightOfTheProtectorHealthThreshold
HandOfTheProtectorFriendHealthThreshold   = Settings.HandOfTheProtectorFriendHealthThreshold
FlashOfLightHealthThreshold               = Settings.FlashOfLightHealthThreshold

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function Pulse()
  local MaxMana           = UnitPowerMax(PlayerUnit , 0)
  local MaxHealth         = UnitHealthMax(PlayerUnit)

  local LowestFriend      = Unit.FindLowest("friendly")

  local MainTank, OffTank = Unit.FindTanks()

  -- Call Taunt engine
  if UseTauntEngine then
    Rotation.Taunt()
  end

  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      Rotation.Interrupt()
    end

    -- COOLDOWNS
    -- Avenging Wrath (Use on Cooldown)
    if Spell.CanCast(31884) and UseAvengingWrath
    and Unit.IsInRange(PlayerUnit, PlayerTarget, 30) then
      return Spell.Cast(31884)
    end

    -- Bastion of Light (Talent)

    -- Guardian of the Ancient Kings (use when below 30%)
    -- Or when the BossManager notices the need to use a def cooldown
    if Spell.CanCast(86659) and UseGuardianOfTheAncientKings then
      if Unit.PercentHealth(PlayerUnit) <= GuardianOfTheAncientKingsHealthThreshold
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(86659)
      end
    end

    -- Ardent Defender (use when below 20%)
    -- Or when the BossManager notices the need to use a def cooldown
    if Spell.CanCast(31850) and UseArdentDefender then
      if Unit.PercentHealth(PlayerUnit) <= ArdentDefenderHealthThreshold
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(31850)
      end
    end

    -- Lay on Hands (use when player or lowest raid member is below 15%)
    if Spell.CanCast(633) and UseLayOnHandsSelf
    and Unit.PercentHealth(PlayerUnit) <= LayOnHandsHealthThreshold then
      return Spell.Cast(633)
    end

    if Spell.CanCast(633) and UseLayOnHandsFriend and LowestFriend ~= nil
    and Unit.PercentHealth(LowestFriend) <= LayOnHandsHealthThreshold then
      return Spell.Cast(633, LowestFriend)
    end

    -- Eye of Tyr (Use when 3 enemys are within 8 yards)
    if Spell.CanCast(209202) and UseEyeOfTyr
    and getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= EyeOfTyrUnitThreshold then
      return Spell.Cast(209202)
    end

    -- Sepharim (Talent)
    -- when not actively tanking (or tanking trash)
    -- at least one charge of Shield of the Righteous
    -- in melee range of target
    if Spell.CanCast(152262) and UseSepharim and select(4, GetTalentInfo(7, 2, 1))
    and (PlayerUnit ~= MainTank or not Unit.IsTankingBoss(PlayerUnit))
    and Unit.IsInAttackRange(53600, PlayerTarget) and select(1, GetSpellCharges(53600)) >= 1 then
      return Spell.Cast(152262)
    end

    -- Divine Shield (do not use yet)

    -- MITIGATION
    -- IDEALLY : stand in Consecration

    -- Shield of the Righteous:
    -- use when not having the buff
    -- use when 3 charges
    -- keep one charge in reserve (two charges when having sepharim and not actively tanking)
    if Unit.IsHostile(PlayerTarget) and Spell.CanCast(53600, PlayerTarget)
    and not Buff.Has(PlayerUnit, 53600) and Unit.IsFacing(PlayerTarget, CastAngle) then
      if select(4, GetTalentInfo(7, 2, 1)) and select(1, GetSpellCharges(53600)) > 2
      and PlayerUnit ~= MainTank then
        return Spell.Cast(53600)
      elseif select(1, GetSpellCharges(53600)) > 1 and not select(4, GetTalentInfo(7, 2, 1)) then
        return Spell.Cast(53600)
      elseif UnitHealth(PlayerUnit) <= MaxHealth * 0.4 then
        return Spell.Cast(53600)
      end
    end

    -- Light of the Protector:
    -- if not talented Hand of the Protector
    -- use when below defined health
    if Spell.CanCast(184092) and Unit.PercentHealth(PlayerUnit) <= LightOfTheProtectorHealthThreshold
    and not select(4, GetTalentInfo(5, 1, 1))
    and (Spell.GetPreviousSpell() ~= 184092 or Spell.GetTimeSinceLastSpell() >= 500) then
      return Spell.Cast(184092)
    end

    -- Hand of the Protector (Talent)
    -- same as Light of the Protector
    -- use when lowest friend below 30%
    if select(4, GetTalentInfo(5, 1, 1)) and Spell.CanCast(213652, nil, nil, nil, false)
    and (Spell.GetPreviousSpell() ~= 213652 or Spell.GetTimeSinceLastSpell() >= 500) then
      if Unit.PercentHealth(PlayerUnit) <= LightOfTheProtectorHealthThreshold then
        return Spell.Cast(213652)
      elseif Unit.PercentHealth(LowestFriend) <= HandOfTheProtectorFriendHealthThreshold then
        return Spell.Cast(213652, LowestFriend)
      end
    end

    -- Flash of Light (use when below 30% health)
    if Spell.CanCast(19750, PlayerUnit) and UseFlashOfLight
    and Unit.PercentHealth(PlayerUnit) <= FlashOfLightHealthThreshold
    and not Unit.IsMoving(PlayerUnit) then
      return Spell.Cast(19750, PlayerUnit)
    end

    -- AOE ROTATION
    if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= UnitsToSwitchToAOE then

      -- Consecration (when not moving)
      if not Unit.IsMoving(PlayerUnit)
      and Spell.CanCast(26573) and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
        return Spell.Cast(26573)
      end

      -- Avenger's Shield
      if Unit.IsInLOS(PlayerTarget)
      and Spell.CanCast(31935, PlayerTarget) and Unit.IsFacing(PlayerTarget, CastAngle) then
        return Spell.Cast(31935)
      end

      -- Judgment
      if Unit.IsInLOS(PlayerTarget)
      and Spell.CanCast(20271, PlayerTarget) and Unit.IsFacing(PlayerTarget, CastAngle) then
        return Spell.Cast(20271)
      end

      -- Blessed Hammer (or Hammer of the Righteous)
      if select(4, GetTalentInfo(1, 2, 1)) then
        if Spell.CanCast(204019, nil, nil, nil, false)
        and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
          return Spell.Cast(204019)
        end
      else
        if Spell.CanCast(53595) and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
          return Spell.Cast(53595)
        end
      end

    -- SINGLE TARGET
    else

      -- Judgement
      if Unit.IsInLOS(PlayerTarget)
      and Spell.CanCast(20271, PlayerTarget) and Unit.IsFacing(PlayerTarget, CastAngle) then
        return Spell.Cast(20271)
      end

      -- Consecration (when not moving)
      if not Unit.IsMoving(PlayerUnit)
      and Spell.CanCast(26573) and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
        return Spell.Cast(26573)
      end

      -- Avenger's Shield
      if Unit.IsInLOS(PlayerTarget)
      and Spell.CanCast(31935, PlayerTarget) and Unit.IsFacing(PlayerTarget, CastAngle) then
        return Spell.Cast(31935)
      end

      -- Blessed Hammer (Talent)
      -- use when fully charged
      if Spell.CanCast(204019, nil, nil, nil, false)
      and select(1, GetSpellCharges(204019)) == 3 and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
          return Spell.Cast(204019)
      end
    end
  end
end

-- Taunt spells are handled here
function Taunt(unit)
  -- Hand of Reckoning
  if Spell.CanCast(62124, unit) and Unit.IsInLOS(unit) then
    -- Here it is necessary to let the queue cast the spell
    return Spell.AddToQueue(62124, unit)
  end

  -- Avenger's Shield
  if Unit.IsInLOS(unit)
  and Spell.CanCast(31935, unit) and Unit.IsFacing(unit, CastAngle) then
    return Spell.Cast(31935, unit)
  end

  -- Judgment
  if Unit.IsInLOS(unit)
  and Spell.CanCast(20271, unit) and Unit.IsFacing(unit, CastAngle) then
    return Spell.Cast(20271, unit)
  end
end

-- Interrupt spells are handled here
function Interrupt(unit)
  -- Rebuke
  if Spell.CanCast(96231, unit) and Unit.IsInLOS(unit) then
    return Spell.Cast(96231, unit)
  end

  -- Blinding Light
  if Spell.CanCast(115750) and Unit.IsInLOS(unit) and Unit.IsInRange(PlayerUnit, unit, 10) then
    return Spell.Cast(115750, unit)
  end

  -- Hammer of Justice
  if Spell.CanCast(853, unit) and Unit.IsInLOS(unit) and not Unit.IsBoss(unit) then
    return Spell.Cast(853, unit)
  end
end
