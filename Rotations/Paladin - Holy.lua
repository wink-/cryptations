function ct.PaladinHoly()
  local TargetObj               = GetObjectWithGUID(UnitGUID("target"))
  local MaxMana                 = UnitPowerMax(ct.player , 0)
  local MaxHealth               = UnitHealthMax(ct.player)

  local LowestFriend            = ct.FindLowestUnit(ct.friends)
  local HighestFriend           = ct.FindHighestUnit(ct.friends)

  local MainTank, OffTank       = ct.FindTanks()

  if UnitAffectingCombat(ct.player) then
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
    if ct.CanCast(6940) and ct.CanCast(498) and LowestFriend ~= nil
    and not ct.UnitHasAura(LowestFriend, 6940)
    and UnitHealth(LowestFriend) <= UnitHealthMax(LowestFriend) * 20 then
      local Sequence = {498, 6940}
      return ct.AddSpellToQueue(Sequence, LowestFriend)
    end

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

    -- Tyr's Deliverance (Used when 30% of group are below 70% health)
    if ct.CanCast(200652) then
      local UnitsInRadius = ct.GetUnitsInRadius(ct.friends, 15)
      if GetNumGroupMembers() ~= 1
      and ct.GetUnitCountBelowHealth(UnitsInRadius, 70) >= math.floor(GetNumGroupMembers() * 0.3) then
        return ct.AddSpellToQueue(200652)
      end
    end

    -- TANK / SINGLE TARGET HEALING
    if MainTank ~= nil and MainTank == LowestFriend
    and ct.PercentHealth(MainTank) <= ct.TankHealthThreshold then
      -- Beacon of Light (Cast on Main Tank. If BOF is talented, place BOF on lowest unit)
      if ct.CanCast(53563, MainTank) and not UnitHasAura(MainTank, 53563)
      and ct.IsInLOS(MainTank) then
        return ct.AddSpellToQueue(53563, MainTank)
      end

      -- TODO: remove from here
      -- Beacon of Faith Talent
      if LowestFriend ~= nil and ct.CanCast(156910, LowestFriend)
      and not UnitHasAura(LowestFriend, 156910) and ct.IsInLOS(LowestFriend) then
        return ct.AddSpellToQueue(156910, LowestFriend)
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

      -- RAID / AOE HEALING
      -- Beacon of Light on Tank (If talented, place second beacon on lowest unit)
      -- Infusion of Light Proc (Either Holy Light or Flash of Light)
      -- Holy Shock on cooldown (or Light of the Martyr if moving and Holy Shock has CD)
      -- Judgment (when Judgment of Light is talented)
      -- Light of Dawn
      -- Holy Prism or Beacon of Virtue
      -- Holy Light (Flash of Light for greater damage)
    end
  else
    -- OUT OF COMBAT ROUTINE
  end
end

function ct.PaldinHolySetUp()
  -- Infusion of Light Settings
  ct.UseHolyLightOnInfusion           = true
  ct.UseFlashOfLightOnInfusion        = false

  -- Health thresholds
  ct.TankHealthThreshold              = 90
  ct.OtherHealthThreshold             = 70

  ct.FlashOfLightThreshold            = 50
end
