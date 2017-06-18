function ct.RogueAssasination()

  TargetObj = GetObjectWithGUID(UnitGUID("target"))
  MeleeRange = 4

  -- combat rotation
  if UnitAffectingCombat("player") then

    -- Eviscerate
    if ct.UnitIsHostile(TargetObj) and ct.IsInLOS(TargetObj)
    and ct.CanCast(196819, TargetObj, 3, 35)
    and UnitPower("player", 4) >= 2 then
      return ct.AddSpellToQueue(196819)
    end

    -- Sinister Strike
    if ct.UnitIsHostile(TargetObj) and ct.IsInLOS(TargetObj)
    and ct.CanCast(1752, TargetObj, 3, 40) then
      return ct.AddSpellToQueue(1752)
    end
  else
    -- out of combat rotation

    -- Cheap Shot
    if ct.UnitIsHostile(TargetObj) and ct.IsInLOS(TargetObj)
    and ct.UnitHasAura("player", 1784)
    and ct.CanCast(1833, TargetObj, 3, 40) then
      return ct.AddSpellToQueue(1833)
    end

    -- Stealth
    if ct.UnitIsHostile(TargetObj) and UnitHealth(TargetObj) ~= 0 and IsSpellKnown(1784)
    and ct.IsInRange(TargetObj, 30) and not ct.UnitHasAura("player", 1784) then
      return ct.AddSpellToQueue(1784)
    end

    -- Deadly Poison
    if not ct.UnitHasAura("player", 2823) and IsSpellKnown(2823)
    and not ct.UnitIsMoving("player") then
      return ct.AddSpellToQueue(2823)
    end
  end
end
