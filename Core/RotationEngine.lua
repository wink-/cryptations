-- this should be straightforward
function ct.PulseRotation()
  if ct.Spec ~= nil then
    ct.Spec()
  end
end

-- this handles all the targeting logic and it's called by the rotation functions
-- mode : friendly or hostile
function ct.TargetEngine(mode)
  if UnitAffectingCombat("player") then
    -- re targeting logic
    if UnitGUID("target") == nil then
      if ct.ReTargetHighestUnit then
        TargetUnit(ct.FindHighestUnit(mode, true))
      elseif ct.ReTargetLowestUnit then
        TargetUnit(ct.FindLowestUnit(mode, true))
      elseif ct.ReTargetNearestUnit then
        local NearestUnit = ct.FindNearestUnit(mode, true)
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

  local ObjectCount = GetObjectCount()
  local Object = nil

  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    local IsTanking = select(1, UnitDetailedThreatSituation(ct.player, Object))

    if MainTank ~= nil then
      IsOtherTankTanking = select(1, UnitDetailedThreatSituation(MainTank, Object)) ~= nil
    elseif OffTank ~= nil then
      IsOtherTankTanking = select(1, UnitDetailedThreatSituation(OffTank, Object)) ~= nil
    end

    if ct.UnitIsHostile(Object) and GetNumGroupMembers() >= 1
    and ObjectIsType(Object, ObjectTypes.Unit) and UnitAffectingCombat(Object) and not IsTanking
    and ct.IsInRange(ct.player, Object, 30) and ct.Taunt ~= nil and not IsOtherTankTanking then
      return ct.Taunt(Object)
    end
  end
end

-- Handles Interrupting
function ct.InterruptEngine()
  local ObjectCount = GetObjectCount()
  local Object = nil
  -- interrupt any unit
  if ct.InterruptAnyUnit then
    for i = 1, ObjectCount do
      Object = GetObjectWithIndex(i)
      if Object ~= nil and select(9, UnitCastingInfo(Object)) == false and ct.UnitIsHostile(Object) then
        local PercentCasted = ct.CastedPercent(Object)
        if ct.InterruptMinPercent < PercentCasted
        and PercentCasted < ct.InterruptMaxPercent and ct.Interrupt ~= nil then
          ct.Interrupt(Object)
        end
      end
    end
    -- interrupt target
  else
    if UnitGUID("target") ~= nil then
      Object = GetObjectWithGUID(UnitGUID("target"))
    end
    if Object ~= nil and select(9, UnitCastingInfo(Unit)) == false and ct.UnitIsHostile(Object) then
      local PercentCasted = ct.CastedPercent(Object)
      if ct.InterruptMinPercent < PercentCasted
      and PercentCasted < ct.InterruptMaxPercent and ct.Interrupt ~= nil then
        ct.Interrupt(Object)
      end
    end
  end
end

-- Handles Disspelling of group members
function ct.DispellEngine()
  local Units = ct.GetGroupMembers()
  local Unit = nil
  for i = 1, getn(Units) do
    Unit = Units[i]
    for j = 1, ct.GetDebuffCount(Unit) do
      if select(5, UnitDebuff(Unit, j)) ~= nil then
        ct.Dispell(Unit, select(5, UnitDebuff(Unit, j)))
      end
    end
  end
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
    if     GetSpecialization() == 1 then           message("This class/spec is not yet supported.")
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
    elseif GetSpecialization() == 3 then           message("This class/spec is not yet supported.")
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
