-- contains all the rotation logic and will be pulsed OnUpdate
function ct.PaladinProtection()
  local MaxMana           = UnitPowerMax(ct.player , 0)
  local MaxHealth         = UnitHealthMax(ct.player)

  local LowestFriend      = ct.FindLowestUnit("friendly")

  local MainTank, OffTank = ct.FindTanks()

  -- Call Taunt engine
  if UseTauntEngine then
    ct.TauntEngine()
  end

  -- combat rotation
  if UnitAffectingCombat(ct.player)
  or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and ct.UnitIsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    ct.TargetEngine("hostile")
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      ct.InterruptEngine()
    end

    -- COOLDOWNS
    -- Avenging Wrath (Use on Cooldown)
    if ct.CanCast(31884) and UseAvengingWrath
    and ct.IsInRange(ct.player, ct.Target, 30) then
      return ct.Cast(31884)
    end

    -- Bastion of Light (Talent)

    -- Guardian of the Ancient Kings (use when below 30%)
    if ct.CanCast(86659) and UseGuardianOfTheAncientKings
    and UnitHealth(ct.player) <= MaxHealth * 0.3 then
      return ct.Cast(86659)
    end

    -- Ardent Defender (use when below 20%)
    if ct.CanCast(31850) and UseArdentDefender
    and UnitHealth(ct.player) <= MaxHealth * 0.2 then
      return ct.Cast(31850)
    end

    -- Lay on Hands (use when player or lowest raid member is below 15%)
    if ct.CanCast(633) and UseLayOnHandsSelf
    and ct.PercentHealth(ct.player) <= LayOnHandsHealthThreshold then
      return ct.Cast(633)
    end

    if ct.CanCast(633) and UseLayOnHandsFriend and LowestFriend ~= nil
    and ct.PercentHealth(LowestFriend) <= LayOnHandsHealthThreshold then
      return ct.Cast(633, LowestFriend)
    end

    -- Eye of Tyr (Use when 3 enemys are within 8 yards)
    if ct.CanCast(209202) and UseEyeOfTyr
    and getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 3 then
      return ct.Cast(209202)
    end

    -- Sepharim (Talent)
    -- when not actively tanking (or tanking trash)
    -- at least one charge of Shield of the Righteous
    -- in melee range of target
    if (ct.player ~= MainTank or not ct.IsTankingBoss(ct.player))
    and select(4, GetTalentInfo(7, 2, 1)) and ct.CanCast(152262)
    and ct.IsInAttackRange(53600, ct.Target) and select(1, GetSpellCharges(53600)) >= 1 then
      return ct.Cast(152262)
    end

    -- Divine Shield (do not use yet)

    -- MITIGATION
    -- IDEALLY : stand in Consecration

    -- Shield of the Righteous:
    -- use when not having the buff
    -- use when 3 charges
    -- keep one charge in reserve (two charges when having sepharim and not actively tanking)
    if ct.UnitIsHostile(ct.Target) and ct.CanCast(53600, ct.Target)
    and not ct.UnitHasBuff(ct.player, 53600) and ct.IsFacing(ct.Target, ct.CastAngle) then
      if select(4, GetTalentInfo(7, 2, 1)) and select(1, GetSpellCharges(53600)) > 2
      and ct.player ~= MainTank then
        return ct.Cast(53600)
      elseif select(1, GetSpellCharges(53600)) > 1 and not select(4, GetTalentInfo(7, 2, 1)) then
        return ct.Cast(53600)
      elseif UnitHealth(ct.player) <= MaxHealth * 0.4 then
        return ct.Cast(53600)
      end
    end

    -- Light of the Protector:
    -- if not talented Hand of the Protector
    -- use when below defined health
    if ct.CanCast(184092) and ct.PercentHealth(ct.player) <= LightOfTheProtectorHealthThreshold
    and not select(4, GetTalentInfo(5, 1, 1))
    and (ct.GetPreviousSpell() ~= 184092 or ct.GetTimeSinceLastSpell() >= 500) then
      return ct.Cast(184092)
    end

    -- Hand of the Protector (Talent)
    -- same as Light of the Protector
    -- use when lowest friend below 30%
    if select(4, GetTalentInfo(5, 1, 1)) and ct.CanCast(213652, nil, nil, nil, false)
    and (ct.GetPreviousSpell() ~= 213652 or ct.GetTimeSinceLastSpell() >= 500) then
      if ct.PercentHealth(ct.player) <= LightOfTheProtectorHealthThreshold then
        return ct.Cast(213652)
      elseif ct.PercentHealth(LowestFriend) <= HandOfTheProtectorFriendHealthThreshold then
        return ct.Cast(213652, LowestFriend)
      end
    end

    -- Flash of Light (use when below 30% health)
    if ct.CanCast(19750, ct.player) and ct.PercentHealth(ct.player) <= FlashOfLightHealthThreshold
    and not ct.UnitIsMoving(ct.player) then
      return ct.Cast(19750, ct.player)
    end

    -- AOE ROTATION
    if getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 3 then

      -- Consecration (when not moving)
      if ct.UnitIsHostile(ct.Target) and not ct.UnitIsMoving(ct.player)
      and ct.CanCast(26573) and ct.IsInRange(ct.player, ct.Target, 8) then
        return ct.Cast(26573)
      end

      -- Avenger's Shield
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(31935, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.Cast(31935)
      end

      -- Judgment
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(20271, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.Cast(20271)
      end

      -- Blessed Hammer (or Hammer of the Righteous)
      if select(4, GetTalentInfo(1, 2, 1)) then
        if ct.UnitIsHostile(ct.Target) and ct.CanCast(204019, nil, nil, nil, false)
        and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.Cast(204019)
        end
      else
        if ct.UnitIsHostile(ct.Target) and ct.CanCast(53595)
        and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.Cast(53595)
        end
      end

    -- SINGLE TARGET
    else

      -- Judgement
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(20271, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.Cast(20271)
      end

      -- Consecration (when not moving)
      if ct.UnitIsHostile(ct.Target) and not ct.UnitIsMoving(ct.player)
      and ct.CanCast(26573) and ct.IsInRange(ct.player, ct.Target, 8) then
        return ct.Cast(26573)
      end

      -- Avenger's Shield
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(31935, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.Cast(31935)
      end

      -- Blessed Hammer (Talent)
      -- use when fully charged
      if ct.UnitIsHostile(ct.Target) and ct.CanCast(204019, nil, nil, nil, false)
      and select(1, GetSpellCharges(204019)) == 3 and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.Cast(204019)
      end
    end
  end
end

-- Taunt spells are handled here
function ct.PaladinProtectionTaunt(unit)
  -- Hand of Reckoning
  if ct.CanCast(62124, unit) and ct.UnitIsHostile(unit) and ct.IsInLOS(unit) then
    -- Here it is necessary to let the queue cast the spell
    return ct.AddSpellToQueue(62124, unit)
  end

  -- Avenger's Shield
  if ct.UnitIsHostile(unit) and ct.IsInLOS(unit)
  and ct.CanCast(31935, unit) and ct.IsFacing(unit, ct.CastAngle) then
    return ct.Cast(31935, unit)
  end

  -- Judgment
  if ct.UnitIsHostile(unit) and ct.IsInLOS(unit)
  and ct.CanCast(20271, unit) and ct.IsFacing(unit, ct.CastAngle) then
    return ct.Cast(20271, unit)
  end
end

-- Interrupt spells are handled here
function ct.PaladinProtectionInterrupt(unit)
  -- Rebuke
  if ct.CanCast(96231, unit) and ct.IsInLOS(unit) then
    return ct.Cast(96231, unit)
  end

  -- Blinding Light
  if ct.CanCast(115750) and ct.IsInLOS(unit) and ct.IsInRange(ct.player, unit, 10) then
    return ct.Cast(115750, unit)
  end

  -- Hammer of Justice
  -- TODO: fix using this on bosses
  if ct.CanCast(853, unit) and ct.IsInLOS(unit) then
    return ct.Cast(853, unit)
  end
end

-- This is called to setup important functions
function ct.PaladinProtectionSetUp()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Paladin - Protection.JSON")

  if json.decode(content) == nil then
    return message("Error loading config file. Please contact the Author.")
  end

  UseTauntEngine                          = json.decode(content).UseTauntEngine
  UseInterruptEngine                      = json.decode(content).UseInterruptEngine
  UseAvengingWrath                        = json.decode(content).UseAvengingWrath
  UseGuardianOfTheAncientKings            = json.decode(content).UseGuardianOfTheAncientKings
  UseArdentDefender                       = json.decode(content).UseArdentDefender
  UseLayOnHandsSelf                       = json.decode(content).UseLayOnHandsSelf
  UseLayOnHandsFriend                     = json.decode(content).UseLayOnHandsFriend
  UseEyeOfTyr                             = json.decode(content).UseEyeOfTyr
  UseSepharim                             = json.decode(content).UseSepharim
  UseHandOfTheProtectorFriend             = json.decode(content).UseHandOfTheProtectorFriend
  LayOnHandsHealthThreshold               = json.decode(content).LayOnHandsHealthThreshold
  LightOfTheProtectorHealthThreshold      = json.decode(content).LightOfTheProtectorHealthThreshold
  HandOfTheProtectorFriendHealthThreshold = json.decode(content).HandOfTheProtectorFriendHealthThreshold
  FlashOfLightHealthThreshold             = json.decode(content).FlashOfLightHealthThreshold

  ct.Taunt      = ct.PaladinProtectionTaunt
  ct.Interrupt  = ct.PaladinProtectionInterrupt
end
