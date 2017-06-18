-- contains all the rotation logic and will be pulsed OnUpdate
function ct.MageFrost()

  TargetObj = GetObjectWithGUID(UnitGUID("target"))

  -- combat rotation
  if UnitAffectingCombat("player") then

    -- Ice Lance
    -- TODO: fix not casting
    if ct.UnitIsHostile(TargetObj) and ct.IsInLOS(TargetObj)
    and ct.CanCast(30455, TargetObj, 0, 9) then
      return ct.AddSpellToQueue(30455)
    end

    -- Frost Bolt
    if ct.UnitIsHostile(TargetObj) and ct.IsInLOS(TargetObj)
    and ct.CanCast(116, TargetObj, 0, 7) then
      return ct.AddSpellToQueue(116)
    end
  end
end
