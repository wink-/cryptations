-- contains all the rotation logic and will be pulsed OnUpdate
function ct.PaladinProtection()
  local MaxMana       = UnitPowerMax(ct.player , 0)
  local MaxHealth     = UnitHealthMax(ct.player)

  local LowestFriend  = ct.FindLowestUnit(ct.friends)

  local LowestEnemy   = ct.FindLowestUnit(ct.enemys)
  local HighestEnemy  = ct.FindHighestUnit(ct.enemys)

  -- Call Taunt engine
  ct.TauntEngine()

  -- combat rotation
  if UnitAffectingCombat(ct.player)
  or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil and ct.UnitIsHostile("target")) then

    -- pulse target engine and remember target
    ct.TargetEngine(ct.enemys)
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    ct.InterruptEngine()

    -- COOLDOWNS
    -- Avenging Wrath (Use on Cooldown)
    if ct.CanCast(31884) then
      return ct.AddSpellToQueue(31884)
    end

    -- Guardian of the Ancient Kings (use when below 30%)
    if ct.CanCast(86659) and UnitHealth(ct.player) <= MaxHealth * 0.3 then
      return ct.AddSpellToQueue(86659)
    end

    -- Ardent Defender (use when below 20%)
    if ct.CanCast(31850) and UnitHealth(ct.player) <= MaxHealth * 0.2 then
      return ct.AddSpellToQueue(31850, ct.player)
    end

    -- Lay on Hands (use when player or lowest raid member is below 15%)
    if ct.CanCast(633) and UnitHealth(ct.player) <= MaxHealth * 0.15 then
      return ct.AddSpellToQueue(633)
    end

    if ct.CanCast(633) and LowestFriend ~= nil
    and UnitHealth(LowestFriend) <= UnitHealthMax(LowestFriend) * 0.15 then
      return ct.AddSpellToQueue(633, LowestFriend)
    end

    -- Eye of Tyr (Use when 3 enemys are within 8 yards)
    if getn(ct.GetUnitsInRadius(ct.player, ct.enemys, 8)) >= 3 and ct.CanCast(209202) then
      return ct.AddSpellToQueue(209202)
    end

    -- Divine Shield (do not use yet)

    -- MITIGATION
    -- IDEALLY : stand in Consecration

    -- Shield of the Righteous:
    -- use when not having the buff
    -- use when 3 charges
    -- keep one charge in reserve (use the reserve when below 40% health)
    if ct.UnitIsHostile(ct.Target) and ct.CanCast(53600, ct.Target)
    and not ct.UnitHasAura(53600) and ct.IsFacing(ct.Target, ct.CastAngle) then
      if select(1, GetSpellCharges(53600)) > 1 then
        return ct.AddSpellToQueue(53600)
      elseif UnitHealth(ct.player) <= MaxHealth * 0.4 then
        return ct.AddSpellToQueue(53600)
      end
    end

    -- Light of the Protector:
    -- use when below 50% health
    if ct.CanCast(184092) and UnitHealth(ct.player) <= MaxHealth * 0.5
    and (ct.GetPreviousSpell() ~= 184092 or ct.GetTimeSinceLastSpell() >= 500) then
      return ct.AddSpellToQueue(184092)
    end

    -- Flash of Light (use when below 30% health)
    if ct.CanCast(19750, ct.player) and UnitHealth(ct.player) <= MaxHealth * 0.3
    and not ct.UnitIsMoving(ct.player) then
      return ct.AddSpellToQueue(19750, ct.player)
    end

    -- AOE ROTATION
    if getn(ct.GetUnitsInRadius(ct.player, ct.enemys, 8)) >= 3 then

      -- Consecration (when not moving)
      if ct.UnitIsHostile(ct.Target) and not ct.UnitIsMoving(ct.player)
      and ct.CanCast(26573) and ct.IsInRange(ct.player, ct.Target, 8) then
        return ct.AddSpellToQueue(26573)
      end

      -- Avenger's Shield
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(31935, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.AddSpellToQueue(31935)
      end

      -- Judgment
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(20271, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.AddSpellToQueue(20271)
      end

      -- Blessed Hammer (or Hammer of the Righteous)
      if IsSpellKnown(204019) then
        if ct.UnitIsHostile(ct.Target) and ct.CanCast(204019)
        and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.AddSpellToQueue(204019)
        end
      elseif IsSpellKnown(53595) then
        if ct.UnitIsHostile(ct.Target) and ct.CanCast(53595)
        and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.AddSpellToQueue(53595)
        end
      end

    -- SINGLE TARGET
    else

      -- Judgement
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(20271, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.AddSpellToQueue(20271)
      end

      -- Consecration (when not moving)
      if ct.UnitIsHostile(ct.Target) and not ct.UnitIsMoving(ct.player)
      and ct.CanCast(26573) and ct.IsInRange(ct.player, ct.Target, 8) then
        return ct.AddSpellToQueue(26573)
      end

      -- Avenger's Shield
      if ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target)
      and ct.CanCast(31935, ct.Target) and ct.IsFacing(ct.Target, ct.CastAngle) then
        return ct.AddSpellToQueue(31935)
      end

      -- Blessed Hammer
      -- use when fully charged
      if IsSpellKnown(204019) and ct.UnitIsHostile(ct.Target)
      and ct.CanCast(204019) and select(1, GetSpellCharges(204019)) == 3
      and ct.IsInRange(ct.player, ct.Target, 8) then
          return ct.AddSpellToQueue(204019)
      end
    end
  end
end

-- Taunt spells are handled here
function ct.PaladinProtectionTaunt(unit)

  -- Hand of Reckoning
  if ct.CanCast(62124, unit) and ct.UnitIsHostile(unit) and ct.IsInLOS(unit)
  and ct.IsInRange(ct.player, unit, 25) then
    return ct.AddSpellToQueue(62124, unit)
  end

  -- Avenger's Shield
  if ct.UnitIsHostile(unit) and ct.IsInLOS(unit)
  and ct.CanCast(31935, unit) and ct.IsFacing(unit, ct.CastAngle) then
    return ct.AddSpellToQueue(31935, unit)
  end

  -- Judgment
  if ct.UnitIsHostile(unit) and ct.IsInLOS(unit)
  and ct.CanCast(20271, unit) and ct.IsFacing(unit, ct.CastAngle) then
    return ct.AddSpellToQueue(20271, unit)
  end
end

-- Interrupt spells are handled here
function ct.PaladinProtectionInterrupt(unit)

  -- Rebuke
  if ct.CanCast(96231, unit) and ct.IsInLOS(unit) then
    print("Interrupted with Rebuke")
    return ct.AddSpellToQueue(96231)
  end

  -- Blinding Light
  if ct.CanCast(115750) and ct.IsInLOS(unit) and ct.IsInRange(ct.player, unit, 10) then
    print("Interrupted with Blinding Light")
    return ct.AddSpellToQueue(115750)
  end

  -- Hammer of Justice
  if ct.CanCast(853, unit) and ct.IsInLOS(unit)
  and UnitClassification(Unit) ~= "elite" and UnitClassification(Unit) ~= "worldboss" then
    print("Interrupted with Hammer of Justice (Stun)")
    return ct.AddSpellToQueue(853)
  end
end

-- This is called to setup important functions
function ct.PaladinProtectionSetUp()
  ct.Taunt      = ct.PaladinProtectionTaunt
  ct.Interrupt  = ct.PaladinProtectionInterrupt
end
