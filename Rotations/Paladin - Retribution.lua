function ct.PaladinRetribution()
  local MaxMana           = UnitPowerMax(ct.player , 0)
  local MaxHealth         = UnitHealthMax(ct.player)
  local HolyPower         = UnitPower(ct.player, 9)

  -- combat rotation
  if UnitAffectingCombat(ct.player)
  or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and ct.UnitIsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    ct.TargetEngine("hostile")
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    ct.InterruptEngine()

    -- OPENING SEQUENCE

    -- Judgment
    -- Blade of Justice
    -- Crusader Strike (Skip if Liadrin's Fury or T20 2-piece Bonus)
    -- Crusade + Execution Sentence (if talented) OR Templar's Verdict
    -- Wake of Ashes
    -- Arcane Torrent + Templar's Verdict (If Blood elf and Liadrin's Fury) or Crusader Strike
    -- Templar's Verdict

    -- COOLDOWNLS

    -- Avenging Wrath (On Cooldown, when Judgment debuff is applied on target)
    if ct.CanCast(31884) and ct.UnitHasDebuff(ct.Target, 197277) then
      return ct.Cast(31884)
    end

    -- Shield of Vengeance (Use when below 70% health (defensive) or when 3 Enemy Units are within 8 yards (offensive))
    if ct.CanCast(184662) then
      if ct.PercentHealth(ct.player) <= 70 then
        return ct.Cast(184662)
      elseif getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 3 then
        return ct.Cast(184662)
      end
    end

    -- Crusade (Talent, Use on Cooldown)
    if ct.CanCast(231895) then
      return ct.Cast(231895)
    end

    -- Holy Wrath (Use when 4 Enemys are around and Health is below 50%)
    if ct.CanCast(210220) and ct.PercentHealth(ct.player) <= 50
    and getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 4 then
      return ct.Cast(210220)
    end

    -- ROTATION --

    -- Holy Power Generating Phase --

    -- Don't overcap Holy Power
    -- Only cast during Judgment debuff when there is need to generate Holy Power
    if (HolyPower < 5 and not ct.UnitHasDebuff(ct.Target, 197277)) or HolyPower < 3
    or ct.GetRemainingCooldown(20271) >= 1 then
      -- Consecration (Use when at least 2 targets within 8 yards and not moving)
      if ct.CanCast(205228) and not ct.UnitIsMoving(ct.player)
      and getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 2 then
        return ct.Cast(205228)
      end

      -- Wake of Ashes (Use when having the Ashes to Ashes trait
      -- to generate Holy Power during Judgment debuff)
      if HolyPower == 0 and ct.PlayerHasArtifactTrait(179546) and ct.CanCast(205273)
      and ct.IsFacing(ct.Target, 90) then
        return ct.Cast(205273)

      -- Crusader Strike (or Zeal if Talented)
      -- At least one charge used and charging
      elseif ((select(1, GetSpellCharges(ct.StrikeOrZeal)) ~= 0 and not ct.CanCast(ct.BladeOrHammer))
      or (select(1, GetSpellCharges(ct.StrikeOrZeal)) > 1 and ct.CanCast(ct.BladeOrHammer)))
      and HolyPower <= 4
      and ct.CanCast(ct.StrikeOrZeal, ct.Target, nil, nil, false) then
        return ct.Cast(ct.StrikeOrZeal)

      -- Blade of Justice (or Divine Hammer talent)
      -- Use together with Righteous Verdict if available
      elseif ct.CanCast(ct.BladeOrHammer, ct.Target, nil, nil, false) then
        -- Use Spender before using Blade of Justice to benefit from Righteous Verdict
        if ct.PlayerHasArtifactTrait(238062) and HolyPower >= 3 then
          -- Use AOE Spender (Divine Storm)
          if getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 3
          and ct.CanCast(53385) then
            local Sequence = {53385, ct.BladeOrHammer}
            return ct.AddSpellToQueue(Sequence)
          end
          -- Use ST Spender (Templar's Verdict)
          if ct.CanCast(85256, ct.Target) and ct.IsInLOS(ct.Target) then
            local Sequence = {85256, ct.BladeOrHammer}
            return ct.AddSpellToQueue(Sequence)
          end
        elseif HolyPower <= 3 then
          -- Use without Spender
          return ct.Cast(ct.BladeOrHammer)
        end
      end
    end

    -- Phase Independent Spells --

    -- Justicar's Vengeance (Talent, use if 5 HolyPower and below 80% health)
    if HolyPower == 5 and ct.PercentHealth(ct.player) <= 80 and ct.CanCast(215661) then
      return ct.Cast(215661)
    end

    -- Eye for an Eye (Talent, use when below 80% health)
    if ct.PercentHealth(ct.player) <= 80 and ct.CanCast(205191) then
      ct.Cast(205191)
    end

    -- Word of Glory (Talent, use when 3 units within 15 yards are below 80% health)
    if getn(ct.GetUnitsBelowHealth(80, "friendly", true, ct.player, 15)) >= 3
    and ct.CanCast(210191) then
      ct.Cast(210191)
    end

    -- Holy Power Spending Phase --

    -- Judgment (Cast when Holy Power >= 4)
    if HolyPower >= 4 and not ct.UnitHasDebuff(ct.Target, 197277)
    and ct.CanCast(20271, ct.Target) and ct.IsInLOS(ct.Target) then
      return ct.Cast(20271, ct.Target)
    end

    -- Execution Sentence (Talent, Cast during Judgment debuff)
    if ct.UnitHasDebuff(ct.Target, 197277) and ct.CanCast(213757, ct.Target, 9, 3)
    and ct.IsInLOS(ct.Target) or ct.GetRemainingCooldown(20271) >= 1 then
      return ct.Cast(213757, ct.Target)
    end

    -- Templar's Verdict (Cast during Judgment debuff)
    -- or Divine Storm during AOE
    if ct.UnitHasDebuff(ct.Target, 197277) or ct.GetRemainingCooldown(20271) >= 1 then
      if getn(ct.GetUnitsInRadius(ct.player, 8, "hostile", true)) >= 3
      and ct.CanCast(53385, nil, 9, 3) then
        return ct.Cast(53385)
      elseif ct.CanCast(85256, ct.Target, 9, 3) then
        return ct.Cast(85256, ct.Target)
      end
    end
  else
    -- out of combat
  end
end

function ct.PaladinRetributionInterrupt(unit)
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

function ct.PaladinRetributionSetUp()
  -- Interrupt function
  ct.Interrupt = ct.PaladinRetributionInterrupt

  -- Use Blade or Hammer
  ct.BladeOrHammer = nil
  if select(4, GetTalentInfo(4, 3, 1)) then
    ct.BladeOrHammer = 198034 -- Hammer
  else
    ct.BladeOrHammer = 184575 -- Blade
  end

  -- Use Strike or Zeal
  ct.StrikeOrZeal = nil
  if select(4, GetTalentInfo(2, 2, 1)) then
    ct.StrikeOrZeal = 217020 -- Zeal
  else
    ct.StrikeOrZeal = 35395 -- Strike
  end
end
