function ct.PaladinHoly()
  local MaxMana                 = UnitPowerMax(ct.player , 0)
  local MaxHealth               = UnitHealthMax(ct.player)

  local LowestFriend            = ct.FindLowestUnit(ct.friends)
  local HighestFriend           = ct.FindHighestUnit(ct.friends)

  local MainTank, OffTank       = ct.FindTanks()

  if UnitAffectingCombat(ct.player) then
    -- Call Targeting engine and remember target
    ct.TargetEngine(ct.enemys)
    local TargetObj = GetObjectWithGUID(UnitGUID("target"))

    -- COOLDOWNS
    -- Avenging Wrath (Use when 50% of group is below 70% health)
    if ct.CanCast(31842) and GetNumGroupMembers() ~= 1
    and ct.GetUnitCountBelowHealth(ct.friends, 70) >= math.floor(GetNumGroupMembers() * 0.5) then
      return ct.AddSpellToQueue(31842)
    end

    -- Lay on Hands (use when player or lowest raid member is below 15% health)
    if ct.CanCast(633) and UnitHealth(ct.player) <= MaxHealth * 0.15 then
      return ct.AddSpellToQueue(633)
    end

    if ct.CanCast(633) and LowestFriend ~= nil
    and UnitHealth(LowestFriend) <= UnitHealthMax(LowestFriend) * 0.15 then
      return ct.AddSpellToQueue(633, LowestFriend)
    end

    -- Blessing of Sacrifice (Use together with Divine Protection on units below 20% health)
    -- TODO: rotation freezing after this was casted
    if ct.CanCast(6940) and ct.CanCast(498) and LowestFriend ~= nil
    and not ct.UnitHasAura(LowestFriend, 6940)
    and ct.PercentHealth(LowestFriend) <= 20 then
      local Sequence = {498, 6940}
      return ct.AddSpellToQueue(Sequence, LowestFriend)
    end

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

    -- Tyr's Deliverance (Used when 30% of group are below 70% health)
    if ct.CanCast(200652) then
      local UnitsInRadius = ct.GetUnitsInRadius(ct.player, ct.friends, 15)
      if GetNumGroupMembers() ~= 1
      and ct.GetUnitCountBelowHealth(UnitsInRadius, 70) >= math.floor(GetNumGroupMembers() * 0.3) then
        return ct.AddSpellToQueue(200652)
      end
    end

    -- TANK HEALING --
    if MainTank ~= nil and MainTank == LowestFriend
    and ct.PercentHealth(MainTank) <= ct.TankHealthThreshold
    and not ct.GetUnitCountBelowHealth(ct.friends, ct.OtherHealthThreshold) >= math.floor(GetNumGroupMembers() * 0.2) then
      -- Beacon of Light (Cast on Main Tank if BOV is not Talented)
      if not IsSpellKnown(200025) and ct.CanCast(53563, MainTank)
      and not ct.UnitHasAura(MainTank, 53563) and ct.IsInLOS(MainTank) then
        return ct.AddSpellToQueue(53563, MainTank)
      end

      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if ct.UnitHasAura(ct.player, 53576) then
        if ct.UseHolyLightOnInfusion then
          if ct.CanCast(82326, MainTank) and ct.IsInLOS(MainTank) then
            return ct.AddSpellToQueue(82326, MainTank)
          end
        elseif ct.UseFlashOfLightOnInfusion then
          if ct.CanCast(19750, MainTank) and ct.IsInLOS(MainTank) then
            return ct.AddSpellToQueue(19750, MainTank)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if moving and Holy Shock has CD)
      if not ct.UnitIsMoving(ct.player) then
        if ct.CanCast(20473, MainTank) and ct.IsInLOS(MainTank) then
          return ct.AddSpellToQueue(20473)
        end
      else
        if ct.CanCast(183998, MainTank) and ct.IsInLOS(MainTank) then
          return ct.AddSpellToQueue(183998)
        end
      end

      -- Bestow Faith on cooldown
      if ct.CanCast(223306, MainTank) and not ct.UnitHasAura(MainTank, 223306)
      and ct.IsInLOS(MainTank) then
        return ct.AddSpellToQueue(223306, MainTank)
      end

      -- Holy Light (Flash of Light for greater damage)
      if ct.PercentHealth(MainTank) <= ct.FlashOfLightThreshold then
        if ct.CanCast(19750, MainTank) and ct.IsInLOS(MainTank) then
          return ct.AddSpellToQueue(19750, MainTank)
        end
      else
        if ct.CanCast(82326, MainTank) and ct.IsInLOS(MainTank) then
          return ct.AddSpellToQueue(82326, MainTank)
        end
      end

    -- RAID / AOE HEALING (Use this during periods of high damage)
    elseif ct.PercentHealth(LowestFriend) <= ct.OtherHealthThreshold then
      -- Beacon of Light on Tank (If not Talented BOV)
      if not IsSpellKnown(200025) and ct.CanCast(53563, LowestFriend)
      and not ct.UnitHasAura(LowestFriend, 53563) and ct.IsInLOS(LowestFriend) then
        return ct.AddSpellToQueue(53563, LowestFriend)
      end

      -- Beacon of Faith on LowestFriend (If Talented BOF)
      if LowestFriend ~= nil and ct.CanCast(156910, LowestFriend)
      and not UnitHasAura(LowestFriend, 156910) and ct.IsInLOS(LowestFriend) then
        return ct.AddSpellToQueue(156910, LowestFriend)
      end

      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      if ct.UnitHasAura(ct.player, 53576) then
        if ct.UseHolyLightOnInfusion then
          if ct.CanCast(82326, LowestFriend) and ct.IsInLOS(LowestFriend) then
            return ct.AddSpellToQueue(82326, LowestFriend)
          end
        elseif ct.UseFlashOfLightOnInfusion then
          if ct.CanCast(19750, LowestFriend) and ct.IsInLOS(LowestFriend) then
            return ct.AddSpellToQueue(19750, LowestFriend)
          end
        end
      end

      -- Holy Shock on cooldown (or Light of the Martyr if moving and Holy Shock has CD)
      if not ct.UnitIsMoving(ct.player) then
        if ct.CanCast(20473, LowestFriend) and ct.IsInLOS(LowestFriend) then
          return ct.AddSpellToQueue(20473)
        end
      else
        if ct.CanCast(183998, LowestFriend) and ct.IsInLOS(LowestFriend) then
          return ct.AddSpellToQueue(183998)
        end
      end

      -- Judgment (when Judgment of Light is talented)
      if IsSpellKnown(183778) and ct.CanCast(20271, TargetObj)
      and ct.IsInLOS(TargetObj) then
        return ct.AddSpellToQueue(20271, TargetObj)
      end

      -- Light of Dawn (Use when 2 Units are in the cone)
      if ct.CanCast(85222) and getn(ct.GetUnitsInCone(ct.player, ct.friends, ct.ConeAngle, 15)) >= 2 then
        return ct.AddSpellToQueue(85222)
      end

      -- Holy Prism (Use on Enemys with at least 4 Players around them)
      if ct.CanCast(114165) then
        for index, value in ipairs(ct.enemys) do
          Enemy = ct.enemys[index][1]
          if Enemy ~= nil and ct.CanCast(114165, Enemy) and ct.IsInLOS(Enemy)
          and getn(ct.GetUnitsInRadius(Enemy, ct.friends, 15)) >= 4 then
            return ct.AddSpellToQueue(114165, Enemy)
          end
        end
      end

      -- Beacon of Virtue TODO: add mana logic
      if ct.CanCast(200025, LowestFriend) and ct.IsInLOS(LowestFriend)
      and getn(ct.GetUnitsInRadius(LowestFriend, ct.friends, 30)) >= 3 then
        return ct.AddSpellToQueue(200025, LowestFriend)
      end


      -- Holy Light (Flash of Light for greater damage)
      if ct.PercentHealth(LowestFriend) <= ct.FlashOfLightThreshold then
        if ct.CanCast(19750, LowestFriend) and ct.IsInLOS(LowestFriend) then
          return ct.AddSpellToQueue(19750, LowestFriend)
        end
      else
        if ct.CanCast(82326, LowestFriend) and ct.IsInLOS(LowestFriend) then
          return ct.AddSpellToQueue(82326, LowestFriend)
        end
      end
    end
  else
    -- OUT OF COMBAT ROUTINE
  end
end

-- TODO: Disspell Spells are handled here
function ct.PaladinHolyDisspell()
end

-- This sets up basic settings
function ct.PaldinHolySetUp()
  -- Infusion of Light Settings
  ct.UseHolyLightOnInfusion           = true
  ct.UseFlashOfLightOnInfusion        = false

  -- Health thresholds
  ct.TankHealthThreshold              = 90
  ct.OtherHealthThreshold             = 70

  ct.FlashOfLightThreshold            = 50
end
