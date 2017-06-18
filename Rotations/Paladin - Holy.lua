function ct.PaladinHoly()
  local TargetObj               = GetObjectWithGUID(UnitGUID("target"))
  local MaxMana                 = UnitPowerMax(ct.player , 0)
  local MaxHealth               = UnitHealthMax(ct.player)

  local LowestFriend            = ct.FindLowestUnit(ct.friends)
  local HighestFriend           = ct.FindHighestUnit(ct.friends)

  -- COOLDOWNS
  -- Avenging Wrath (Use when 50% of group is below 70% health)
  if ct.CanCast(31842)
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
  if ct.CanCast(6940) and ct.CanCast(498) and not ct.UnitHasAura(LowestFriend, 6940)
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
    if ct.GetUnitCountBelowHealth(UnitsInRadius, 70) >= math.floor(GetNumGroupMembers() * 0.3) then
      return ct.AddSpellToQueue(200652)
    end
  end

  -- TANK / SINGLE TARGET HEALING
  -- Beacon of Light
  -- Infusion of Light Proc (Either Holy Light or Flash of Light)
  -- Holy Shock on cooldown (or Light of the Martyr if moving and Holy Shock has CD)
  -- Bestow Faith on cooldown
  -- Holy Light (Flash of Light for greater damage)

  -- RAID / AOE HEALING
  -- Beacon of Light on Tank (If talented, place second beacon on lowest unit)
  -- Infusion of Light Proc (Either Holy Light or Flash of Light)
  -- Holy Shock on cooldown (or Light of the Martyr if moving and Holy Shock has CD)
  -- Judgment (when Judgment of Light is talented)
  -- Light of Dawn
  -- Holy Prism or Beacon of Virtue
  -- Holy Light (Flash of Light for greater damage)
end
