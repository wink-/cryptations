-- this should be straightforward
function ct.PulseRotation()
  if ct.Spec ~= nil then
    -- unit manager shall only be updated when the rotation needs it
    ct.GetUnitTables()
    ct.UpdateTables()

    ct.Spec()
  end
end

-- this handles all the targeting logic and it's called by the rotation functions
-- table specifies from which table the target should be chosen (usually ct.enemys)
function ct.TargetEngine(table)
  -- re targeting logic
  if UnitGUID("target") == nil then
    if ct.ReTargetHighestUnit then
      TargetUnit(ct.FindHighestUnit(table))
    elseif ct.ReTargetLowestUnit then
      TargetUnit(ct.FindLowestUnit(table))
    elseif ct.ReTargetNearestUnit then
      local NearestUnit = ct.FindNearestUnit(table)
      if NearestUnit ~= nil then
        TargetUnit(NearestUnit)
      end
    end
  end
  StartAttack()
end

-- Handles Taunting
-- TODO: recognize when unit is already tanked by another tank
function ct.TauntEngine()
  for index, value in ipairs(ct.enemys) do
    local Unit = ct.enemys[index][1]
    local IsTanking = select(1, UnitDetailedThreatSituation(ct.player, Unit))

    if UnitAffectingCombat(Unit) and not IsTanking and ct.IsInRange(Unit, 30)
    and ct.Taunt ~= nil then
      ct.Taunt(Unit)
    end
  end
end

-- Handles Interrupting
-- this can currently only interrupt the current target
function ct.InterruptEngine(unit)
  if unit ~= nil and select(9, UnitCastingInfo(unit)) == false and ct.UnitIsHostile(unit) then
    local PercentCasted = ct.CastedPercent(unit)
    if ct.InterruptMinPercent < PercentCasted
    and PercentCasted < ct.InterruptMaxPercent and ct.Interrupt ~= nil then
      ct.Interrupt(unit)
    end
  end
end

-- Handles Disspelling
function ct.DisspellEngine()
end

function ct.SetUpRotationEngine()
  -- identify player class and spec
  if     select(3, UnitClass("player")) ==  0 then message("Invalid Class.")
  elseif select(3, UnitClass("player")) ==  1 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  2 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           ct.Spec = ct.PaladinProtection; ct.PaladinProtectionSetUp()
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  3 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  4 then
    if     GetSpecialization() == 1 then           ct.Spec = ct.RogueAssasination
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  5 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  6 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  7 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) ==  8 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           ct.Spec = ct.MageFrost
    end
  elseif select(3, UnitClass("player")) ==  9 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) == 10 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) == 11 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  elseif select(3, UnitClass("player")) == 12 then
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 2 then           message("This class/spec is not yet supported.")
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
    end
  end
end
