local Rotation  = LibStub("Rotation")
local Unit      = LibStub("Unit")
local Spell     = LibStub("Spell")
local Player    = LibStub("Player")
local Buff      = LibStub("Buff")
local Debuff    = LibStub("Debuff")
local Utils     = LibStub("Utils")

-- delays the next pulse by given amount of time (in seconds)
function Rotation.Delay(seconds)
  NextPulse = NextPulse + seconds
end

-- The spell queue shall only contain spells that are a 100% required to be casted (rest is done by the rotation itself)
-- Example use for the spell queue would be a sequence that has to be casted in a certain order
-- There are also some instant spells that require being casted by the spell queue
function Rotation.PulseQueue()

  -- pulse rotation if spellQueue is empty
  if #SPELL_QUEUE == 0
  and not Unit.IsCasting(PlayerUnit)
  and not Unit.IsChanneling(PlayerUnit) then
    Pulse()
  elseif #SPELL_QUEUE ~= 0 then
    local SpellID = SPELL_QUEUE[1].spell
    SpellTarget = "target"

    -- if the entry contains a target, cast the spell on it (if it exists)
    if SPELL_QUEUE[1].unit ~= nil
    and ObjectExists(SPELL_QUEUE[1].unit)
    and not UnitIsDeadOrGhost(SPELL_QUEUE[1].unit) then
      SpellTarget = SPELL_QUEUE[1].unit
    end

    -- Cast Spell
    if (not Unit.IsMoving(PlayerUnit) or Spell.CanCastWhileMoving(SpellID))
    and not Unit.IsCasting(PlayerUnit) and UnitGUID(SpellTarget) ~= nil then
      Spell.Cast(SpellID, SpellTarget)

      -- instantly remove the spell and add it to the history if it is an instant cast
      local _, _, _, CastTime = GetSpellInfo(SpellID)
      if CastTime == 0 then
        Spell.DeQueue(SpellID)
        Spell.AddToHistory(SpellID)
      end
    end
  end
end

-- removes every entry from the whole queue
function Rotation.CleanUpQueue()
  for i = 1, #SPELL_QUEUE do
    table.remove(SPELL_QUEUE, 1)
  end
end

-- this handles all the targeting logic and it's called by the rotation functions
-- mode : friendly or hostile
function Rotation.Target(mode)
  if UnitAffectingCombat("player") then
    -- re targeting logic
    if UnitGUID("target") == nil then
      if TargetMode == 1 then
        TargetUnit(Unit.FindHighest(mode, true))
      elseif TargetMode == 2 then
        TargetUnit(Unit.FindLowest(mode, true))
      elseif TargetMode == 0 then
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
  local IsOtherTankTanking = false

  for Object, _ in pairs(UNIT_TRACKER) do
    if Unit.IsHostile(Object) then
      local IsTanking = UnitDetailedThreatSituation(PlayerUnit, Object)

      -- check if other tank is tanking the object
      if #GROUP_TANKS > 1 then
        for j = 1, #GROUP_TANKS do
          if GROUP_TANKS[i] ~= PlayerUnit
          and UnitDetailedThreatSituation(GROUP_TANKS[i], Object) == true then
            IsOtherTankTanking = true
            print("othertankistanking")
          end
        end
      end

      if GetNumGroupMembers() >= 1
      and UnitAffectingCombat(Object) and not IsTanking
      and Unit.IsInRange(PlayerUnit, Object, 30) and Taunt ~= nil and not IsOtherTankTanking then
        return Taunt(Object)
      end
    end
  end
end

-- Handles Interrupting
function Rotation.Interrupt()
  -- interrupt any unit
  if InterruptAny then
    for Object, _ in pairs(UNIT_TRACKER) do
      local _, _, _, _, _, _, _, _, NotInterruptible = UnitCastingInfo(Object)
      if NotInterruptible == 1
      and Unit.IsHostile(Object) then
        local PercentCasted = Unit.CastedPercent(Object)
        if InterruptMin < PercentCasted
        and PercentCasted < InterruptMax and Interrupt ~= nil then
          Interrupt(Object)
        end
      end
    end
    -- interrupt target
  else
    local Target = PlayerTarget()
    if Target == nil then return end
    local _, _, _, _, _, _, _, _, NotInterruptible = UnitCastingInfo(Target)

    if NotInterruptible == false
    and Unit.IsHostile(Target) then
      local PercentCasted = Unit.CastedPercent(Target)
      if InterruptMin < PercentCasted
      and PercentCasted < InterruptMax and Interrupt ~= nil then
        Interrupt(Target)
      end
    end
  end
end

-- Handles Disspelling of group members
function Rotation.Dispell()
  local Unit = nil
  for i = 1, #GROUP_MEMBERS do
    Unit = GROUP_MEMBERS[i]
    for j = 1, Debuff.GetCount(Unit) do
      local _, _, _, _, DispellType = UnitDebuff(Unit, j)
      if DispellType ~= nil
      and Dispell ~= nil then
        Dispell(Unit, DispellType)
      end
    end
  end
end

function Rotation.Pause()
  Paused = true
  ChatOverlay("Pausing Rotation", 2, "RED")
end

function Rotation.TogglePause()
  Paused = not Paused
  if Paused then
    ChatOverlay("Pausing Rotation", 2, "RED")
  else
    ChatOverlay("Resuming Rotation", 2, "GREEN")
  end
end

function Rotation.ToggleCD()
  AllowCD = not AllowCD
  if AllowCD then
    ChatOverlay("Cooldown usage Enabled", 2, "GREEN")
  else
    ChatOverlay("Cooldown usage Disabled", 2, "RED")
  end
end

function Rotation.ToggleAoE()
  AllowAoE = not AllowAoE
  if AllowAoE then
    ChatOverlay("AoE Enabled", 2, "GREEN")
  else
    ChatOverlay("AoE Disabled", 2, "RED")
  end
end

function Rotation.ToggleDebug()
  Debug = not Debug
  if Debug then
    ChatOverlay("Debug Information Enabled", 2, "GREEN")
  else
    ChatOverlay("Debug Information Disabled", 2, "RED")
  end
end

-- Prints a message to the chat window if the 'Debug' toggle is set
function Rotation.Debug(msg)
  if Debug then
    print(msg)
  end
end
