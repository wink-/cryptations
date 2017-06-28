function ct.PaladinHoly()
  local MaxMana                 = UnitPowerMax(ct.player , 0)
  local MaxHealth               = UnitHealthMax(ct.player)

  local LowestFriend            = ct.FindLowestUnit("friendly")
  local HighestFriend           = ct.FindHighestUnit("friendly")

  local MainTank, OffTank       = ct.FindTanks()
  local HealTarget              = nil

  if UnitAffectingCombat(ct.player) then

    -- Dispell engine
    ct.DispellEngine()

    -- pulse target engine and remember target
    ct.TargetEngine("hostile")
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- COOLDOWNS
    -- Avenging Wrath (Use when 3 units are below 60% health)
    if ct.CanCast(31842) and GetNumGroupMembers() ~= 1
    and getn(ct.GetUnitsBelowHealth(60, "friendly", true)) >= 3 then
      return ct.Cast(31842)
    end

    -- Holy Avenger (Talent) use when 2 units are below 60% health
    if ct.CanCast(105809) and GetNumGroupMembers() ~= 1
    and getn(ct.GetUnitsBelowHealth(60, "friendly", true)) >= 2 then
      return ct.Cast(105809)
    end

    -- Lay on Hands (use when player or lowest raid member is below 15% health)
    if ct.CanCast(633) and UnitHealth(ct.player) <= MaxHealth * 0.15 then
      return ct.Cast(633)
    end

    if ct.CanCast(633) and LowestFriend ~= nil
    and UnitHealth(LowestFriend) <= UnitHealthMax(LowestFriend) * 0.15 then
      return ct.Cast(633, LowestFriend)
    end

    -- Blessing of Sacrifice (Use together with Divine Protection on units below 20% health)
    if ct.CanCast(6940) and ct.CanCast(498) and LowestFriend ~= nil
    and not ct.UnitHasBuff(LowestFriend, 6940)
    and ct.PercentHealth(LowestFriend) <= 20 then
      local Sequence = {498, 6940}
      return ct.AddSpellToQueue(Sequence, LowestFriend)
    end

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

    -- Tyr's Deliverance (Used when 2 units in group are below 80% health)
    if ct.CanCast(200652) then
      if GetNumGroupMembers() ~= 1 and ct.GetPreviousSpell() ~= 200652
      and getn(ct.GetUnitsBelowHealth(80, "friendly", true, ct.player, 15)) >= 2 then
        return ct.Cast(200652)
      end
    end

    -- HEAL LOGIC
    if ct.IsInRange(ct.player, MainTank, 40) and ct.IsInLOS(MainTank)
    and ct.PercentHealth(MainTank) <= ct.TankHealthThreshold
    and (not (ct.PercentHealth(LowestFriend) <= ct.OtherHealthThreshold)
    or LowestFriend == MainTank) then
      HealTarget = MainTank
    elseif ct.IsInRange(ct.player, LowestFriend, 40) and ct.IsInLOS(LowestFriend)
    and ct.PercentHealth(LowestFriend) <= ct.OtherHealthThreshold then
      HealTarget = LowestFriend
    -- TOPPING LOGIC
    elseif ct.PercentHealth(LowestFriend) <= ct.ToppingHealthThreshold then
      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if ct.UnitHasBuff(ct.player, 53576) then
        if ct.UseHolyLightOnInfusion then
          if ct.CanCast(82326, LowestFriend, 0, MaxMana * 0.12) and ct.IsInLOS(LowestFriend) then
            return ct.Cast(82326, LowestFriend)
          end
        elseif ct.UseFlashOfLightOnInfusion then
          if ct.CanCast(19750, LowestFriend, 0, MaxMana * 0.18) and ct.IsInLOS(LowestFriend) then
            return ct.Cast(19750, LowestFriend)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if Holy Shock has CD)
      if ct.CanCast(20473, LowestFriend, 0, MaxMana * 0.1) and ct.IsInLOS(LowestFriend) then
        return ct.Cast(20473, LowestFriend)
      elseif ct.UnitIsMoving(ct.player) and not ct.CanCast(20473, LowestFriend, 0, MaxMana * 0.1) then
        if ct.CanCast(183998, LowestFriend, 0, MaxMana * 0.075) and ct.IsInLOS(LowestFriend) then
          return ct.Cast(183998, LowestFriend)
        end
      end

      -- Holy Light
      if ct.CanCast(82326, LowestFriend, 0, MaxMana * 0.12) and ct.IsInLOS(LowestFriend) then
        return ct.Cast(82326, LowestFriend)
      end
    end

    -- HEAL ROTATION
    if HealTarget ~= nil then
      -- Rule of Law (Talent)
      if ct.CanCast(214202) then
        return ct.Cast(214202)
      end

      -- Beacon of Light on Tank (If not Talented BOV)
      if MainTank ~= nil and not select(4, GetTalentInfo(7, 3, 1))
      and ct.CanCast(53563, MainTank, 0, MaxMana * 0.025) and ct.IsInLOS(MainTank)
      and not ct.UnitHasBuff(MainTank, 53563) then
        return ct.Cast(53563, MainTank)
      end

      -- Beacon of Faith on LowestFriend (If Talented BOF)
      if LowestFriend ~= nil and ct.CanCast(156910, LowestFriend, 0, MaxMana * 0.03125)
      and not UnitHasBuff(LowestFriend, 156910) and ct.IsInLOS(LowestFriend) then
        return ct.Cast(156910, LowestFriend)
      end

      -- Bestow Faith (Alywas use on MainTank)
      if ct.CanCast(223306, MainTank, 0, MaxMana * 0.06) and ct.IsInLOS(MainTank)
      and not ct.UnitHasBuff(MainTank, 223306) and
      ct.PercentHealth(MainTank) <= ct.BestowFaithThreshold then
        return ct.Cast(223306, MainTank)
      end

      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if ct.UnitHasBuff(ct.player, 53576) then
        if ct.UseHolyLightOnInfusion then
          if ct.CanCast(82326, HealTarget, 0, MaxMana * 0.12) and ct.IsInLOS(HealTarget) then
            return ct.Cast(82326, HealTarget)
          end
        elseif ct.UseFlashOfLightOnInfusion then
          if ct.CanCast(19750, HealTarget, 0, MaxMana * 0.18) and ct.IsInLOS(HealTarget) then
            return ct.Cast(19750, HealTarget)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if Holy Shock has CD)
      if ct.CanCast(20473, HealTarget, 0, MaxMana * 0.1) and ct.IsInLOS(HealTarget) then
        return ct.Cast(20473, HealTarget)
      elseif ct.UnitIsMoving(ct.player) and not ct.CanCast(20473, HealTarget, 0, MaxMana * 0.1) then
        if ct.CanCast(183998, HealTarget, 0, MaxMana * 0.075) and ct.IsInLOS(HealTarget) then
          return ct.Cast(183998, HealTarget)
        end
      end

      -- Judgment (when Judgment of Light is talented)
      if ct.Target ~= nil and IsSpellKnown(183778)
      and ct.CanCast(20271, ct.Target, 0, MaxMana * 0.03) and ct.IsInLOS(ct.Target) then
        return ct.Cast(20271, ct.Target)
      end

      -- Light's Hammer (Talent)
      -- Use when at least two units within 10 yards of each other are below 80% health
      if ct.CanCast(114158, nil, 0, MaxMana * 0.28) then
        -- Find best fitting unit
        local GroupMembers = ct.GetGroupMembers()
        local BestUnit = nil
        local BestUnitTargetCount = 0
        for i = 1, getn(GroupMembers) do
          if (BestUnitTargetCount == 0
          and getn(ct.GetUnitsBelowHealth(90, "friendly", true, GroupMembers[i], 10)) >= 2)
          or (BestUnitTargetCount ~= 0
          and getn(ct.GetUnitsBelowHealth(90, "friendly", true, GroupMembers[i], 10)) >= BestUnitTargetCount) then
            BestUnit = GroupMembers[i]
            BestUnitTargetCount = getn(ct.GetUnitsBelowHealth(90, "friendly", true, GroupMembers[i], 10))
          end
        end
        if BestUnit ~= nil then
          -- Place Hammer in center of suitable units (if in range)
          local Units = ct.GetUnitsBelowHealth(90, "friendly", true, BestUnit, 10)
          local x, y, z = ct.GetCenterBetweenUnits(Units)
          return ct.CastGroundSpell(114158, x, y, z)
        end
      end

      -- Light of Dawn (Use when 2 Units are in the cone and at 70% or lower)
      if ct.CanCast(85222, nil, 0, MaxMana * 0.14) then
        -- Rule of Law
        if ct.UnitHasBuff(ct.player, 214202)
        and getn(ct.GetUnitsInCone(ct.player, ct.ConeAngle, 22.5, "friendly", true, 70)) >= 2 then
          return ct.Cast(85222)
        -- Beacon of the Lightbringer
        elseif select(4, GetTalentInfo(7, 2, 1))
        and getn(ct.GetUnitsInCone(ct.player, ct.ConeAngle, 19.5, "friendly", true, 70)) >= 2 then
          return ct.Cast(85222)
        -- Standard
        elseif getn(ct.GetUnitsInCone(ct.player, ct.ConeAngle, 15, "friendly", true, 70)) >= 2 then
          return ct.Cast(85222)
        end
      end

      -- Holy Prism (Use on Enemys with at least 4 Players around them)
      if ct.CanCast(114165, nil, 0, MaxMana * 0.17) then
        local ObjectCount = GetObjectCount()
        local Object = nil
        for i = 1, ObjectCount do
          Object = GetObjectWithIndex(i)
          if ObjectExists(Object) and ct.CanCast(114165, Object) and ct.IsInLOS(Object)
          and ObjectIsType(Object, ObjectTypes.Unit) and ct.UnitIsHostile(Object)
          and getn(ct.GetUnitsInRadius(Object, 15, "friendly", true)) >= 4 then
            return ct.Cast(114165, Object)
          end
        end
      end

      -- Beacon of Virtue TODO: add mana logic
      if ct.CanCast(200025, HealTarget, 0, MaxMana * 0.1) and ct.IsInLOS(HealTarget)
      and getn(ct.GetUnitsBelowHealth(70, "friendly", true, MainTank, 30)) >= 3 then
        return ct.Cast(200025, HealTarget)
      end


      -- Holy Light (Flash of Light for greater damage)
      if ct.PercentHealth(HealTarget) <= ct.FlashOfLightThreshold then
        if ct.CanCast(19750, HealTarget, 0, MaxMana * 0.18) and ct.IsInLOS(HealTarget) then
          return ct.Cast(19750, HealTarget)
        end
      else
        if ct.CanCast(82326, HealTarget, 0, MaxMana * 0.12) and ct.IsInLOS(HealTarget) then
          return ct.Cast(82326, HealTarget)
        end
      end
    end
  else
    -- OUT OF COMBAT ROUTINE
  end
end

-- TODO: Disspell Spells are handled here
function ct.PaladinHolyDispell(unit, dispelType)
  local MaxMana = UnitPowerMax(ct.player , 0)

  if ct.CanCast(4987, unit, 0, MaxMana * 0.13) and dispelType ~= "Curse" then
    return ct.Cast(4987, unit)
  end
end

-- This sets up basic settings
function ct.PaldinHolySetUp()
  -- Infusion of Light Settings
  ct.UseHolyLightOnInfusion           = true
  ct.UseFlashOfLightOnInfusion        = false

  -- Health thresholds
  ct.TankHealthThreshold              = 90
  ct.OtherHealthThreshold             = 70
  ct.ToppingHealthThreshold           = 90

  ct.FlashOfLightThreshold            = 50
  ct.BestowFaithThreshold             = 80

  -- Disspelling
  ct.Dispell = ct.PaladinHolyDispell
end
