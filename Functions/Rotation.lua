local Rotation  = LibStub:NewLibrary("Rotation", 1)
local Unit      = LibStub("Unit")
local Spell     = LibStub("Spell")
local Player    = LibStub("Player")


-- The spell queue shall only contain spells that are a 100% required to be casted (rest is done by the rotation itself)
-- Example use for the spell queue would be a sequence that has to be casted in a certain order
-- There are also some instant spells that require being casted by the spell queue
function Rotation.PulseQueue()

  -- pulse rotation if spellQueue is empty
  if getn(SPELL_QUEUE) == 0 and not Unit.IsCasting(PlayerUnit) then
    Pulse()
  elseif getn(SPELL_QUEUE) ~= 0 then
    local SpellID = SPELL_QUEUE[1].spell
    SpellTarget = "target"

    -- if the entry contains a target, cast the spell on it (if it exists)
    if SPELL_QUEUE[1].unit ~= nil
    and ObjectExists(SPELL_QUEUE[1].unit)
    and not UnitIsDeadOrGhost(SPELL_QUEUE[1].unit) then
      SpellTarget = SPELL_QUEUE[1].unit
    end

    -- Cast Spell
    if (not Unit.IsMoving(PlayerUnit) or Unit.CanCastWhileMoving(SpellID))
    and not Unit.IsCasting(PlayerUnit) and UnitGUID(SpellTarget) ~= nil then
      Spell.Cast(SpellID, SpellTarget)

      -- instantly remove the spell and add it to the history if it is an instant cast
      if select(4, GetSpellInfo(SpellID)) == 0 then
        Spell.DeQueue(SpellID)
        Spell.AddToHistory(SpellID)
      end
    end
  end
end

-- removes every entry from the whole queue
function Rotation.CleanUpQueue()
  for i = 1, getn(SPELL_QUEUE) do
    table.remove(SPELL_QUEUE, 1)
  end
end

-- this handles all the targeting logic and it's called by the rotation functions
-- mode : friendly or hostile
function Rotation.Target(mode)
  if UnitAffectingCombat("player") then
    -- re targeting logic
    if UnitGUID("target") == nil then
      if ReTargetHighestUnit then
        TargetUnit(Unit.FindHighest(mode, true))
      elseif ReTargetLowestUnit then
        TargetUnit(Unit.FindLowest(mode, true))
      elseif ReTargetNearestUnit then
        local NearestUnit = Unit.FindNearest(mode, true)
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
function Rotation.Taunt()
  local MainTank, OffTank = Unit.FindTanks()
  local IsOtherTankTanking = nil

  local ObjectCount = GetObjectCount()
  local Object = nil

  for i = 1, ObjectCount do
    Object = GetObjectWithIndex(i)
    local IsTanking = select(1, UnitDetailedThreatSituation(PlayerUnit, Object))

    if MainTank ~= nil then
      IsOtherTankTanking = select(1, UnitDetailedThreatSituation(MainTank, Object)) ~= nil
    elseif OffTank ~= nil then
      IsOtherTankTanking = select(1, UnitDetailedThreatSituation(OffTank, Object)) ~= nil
    end

    if Unit.IsHostile(Object) and GetNumGroupMembers() >= 1
    and ObjectIsType(Object, ObjectTypes.Unit) and UnitAffectingCombat(Object) and not IsTanking
    and Unit.IsInRange(PlayerUnit, Object, 30) and Taunt ~= nil and not IsOtherTankTanking then
      return Taunt(Object)
    end
  end
end

-- Handles Interrupting
function Rotation.Interrupt()
  local ObjectCount = GetObjectCount()
  local Object = nil
  -- interrupt any unit
  if InterruptAnyUnit then
    for i = 1, ObjectCount do
      Object = GetObjectWithIndex(i)
      if Object ~= nil and select(9, UnitCastingInfo(Object)) == false and Unit.IsHostile(Object) then
        local PercentCasted = Unit.CastedPercent(Object)
        if InterruptMinPercent < PercentCasted
        and PercentCasted < InterruptMaxPercent and Interrupt ~= nil then
          Interrupt(Object)
        end
      end
    end
    -- interrupt target
  else
    if UnitGUID("target") ~= nil then
      Object = GetObjectWithGUID(UnitGUID("target"))
    end
    if Object ~= nil and select(9, UnitCastingInfo(Unit)) == false and Unit.IsHostile(Object) then
      local PercentCasted = Unit.CastedPercent(Object)
      if InterruptMinPercent < PercentCasted
      and PercentCasted < InterruptMaxPercent and Interrupt ~= nil then
        Interrupt(Object)
      end
    end
  end
end

-- Handles Disspelling of group members
function Rotation.Dispell()
  local Units = Player.GetGroupMembers()
  local Unit = nil
  for i = 1, getn(Units) do
    Unit = Units[i]
    for j = 1, Debuff.GetCount(Unit) do
      if select(5, UnitDebuff(Unit, j)) ~= nil
      and Dispell ~= nil then
        Dispell(Unit, select(5, UnitDebuff(Unit, j)))
      end
    end
  end
end
