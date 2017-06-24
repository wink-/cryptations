ct.SpellQueue = {}
ct.SpellHistory = {}

-- pulses the SpellQueue and tries to cast from it
-- spells will be casted on the current target by default

function ct.PulseQueue()

  -- pulse appropriate rotation if spellQueue is empty
  if getn(ct.SpellQueue) == 0 then
    ct.PulseRotation()
  end

  for i = 1, getn(ct.SpellQueue) do
    local SpellID = nil
    local TargetUnit = "target"
    local SpecificTarget = false

    -- if the entry contains a target, cast the spell on it (if it exists)
    if ct.SpellQueue[i].unit ~= nil
    and ObjectExists(ct.SpellQueue[i].unit)
    and not UnitIsDeadOrGhost(ct.SpellQueue[i].unit) then
      TargetUnit = ct.SpellQueue[i].unit
      SpecificTarget = true
    end

    -- only cast the spell if a specific target was given or if the player has a target
    SpellID = ct.SpellQueue[i].spell
    -- Cast Spell
    if (not ct.UnitIsMoving("player") or ct.CanCastWhileMoving(SpellID))
    and not ct.PlayerIsCasting() and (UnitGUID("target") ~= nil or SpecificTarget == true) then
      -- maximum lenght of spell history is 10 entries
      if getn(ct.SpellHistory) > 10 then
        table.remove(ct.SpellHistory, 1)
      end

      -- add spell to history like : SPELL; TARGET; TIME
      local Entry = {spell = SpellID, target = TargetUnit, time = GetTime()}
      table.insert(ct.SpellHistory, Entry)

      return CastSpellByID(SpellID, TargetUnit)
    end
  end
end

-- adds an entry to the SpellQueue
-- entry can contain spellID and unit to cast the spell on
function ct.AddSpellToQueue(spell, unit)
  -- Add every spell from a sequence
  if type(spell) == "table" then
    for i = 1, getn(spell) do
      QueueEntry = {spell = spell[i], unit = unit}
      table.insert(ct.SpellQueue, QueueEntry)
    end
  -- Add Single Spell
  else
    QueueEntry = {spell = spell, unit = unit}
    table.insert(ct.SpellQueue, QueueEntry)
  end
end

-- removes the given spell from the queue if it is at first position
function ct.DeQueueSpell(spell)
  -- exit if queue is empty
  if getn(ct.SpellQueue) == 0 then
    return
  end

  -- find spell in queue and dequeue it
  if ct.SpellQueue[1].spell == spell then
    table.remove(ct.SpellQueue, 1)
  end
end

-- removes every entry from the whole queue
function ct.CleanUpQueue()
  for i = 1, getn(ct.SpellQueue) do
    table.remove(ct.SpellQueue, 1)
  end
end
