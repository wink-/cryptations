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
  if UnitAffectingCombat("player") then
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
end

-- Handles Taunting
-- This does not handle taunting logic for encounters
function ct.TauntEngine()
  local MainTank, OffTank = ct.FindTanks()
  local IsOtherTankTanking = nil
  local IsTanking = select(1, UnitDetailedThreatSituation(ct.player, Unit))

  if MainTank ~= nil then
    IsOtherTankTanking = select(1, UnitDetailedThreatSituation(MainTank, Unit)) ~= nil
  elseif OffTank ~= nil then
    IsOtherTankTanking =select(1, UnitDetailedThreatSituation(OffTank, Unit)) ~= nil
  end

  for index, value in ipairs(ct.enemys) do
    local Unit = ct.enemys[index][1]

    if GetNumGroupMembers() > 1 and UnitAffectingCombat(Unit) and not IsTanking
    and ct.IsInRange(ct.player, Unit, 30) and ct.Taunt ~= nil and not IsOtherTankTanking then
      ct.Taunt(Unit)
    end
  end
end

-- Handles Interrupting
-- this can currently only interrupt the current target
-- TODO: add setting to interrupt any unit
function ct.InterruptEngine()
  local Unit = nil
  if UnitGUID("target") ~= nil then
    Unit = GetObjectWithGUID(UnitGUID("target"))
  end
  if Unit ~= nil and select(9, UnitCastingInfo(Unit)) == false and ct.UnitIsHostile(Unit) then
    local PercentCasted = ct.CastedPercent(Unit)
    if ct.InterruptMinPercent < PercentCasted
    and PercentCasted < ct.InterruptMaxPercent and ct.Interrupt ~= nil then
      ct.Interrupt(Unit)
    end
  end
end

-- TODO: add function to predict incoming healing and absorbs on a unit

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
    if     GetSpecialization() == 1 then           ct.Spec = ct.PaladinHoly;        ct.PaldinHolySetUp()
    elseif GetSpecialization() == 2 then           ct.Spec = ct.PaladinProtection;  ct.PaladinProtectionSetUp()
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
