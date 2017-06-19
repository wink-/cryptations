ct.SpellQueue = {}

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

    -- check if we have a sequence entry or a single spell
    -- (sequence entry is a table)
    -- only cast the spell if a specific target was given or if the player has a target
    if (type(ct.SpellQueue[i].spell) == "table") then
      while getn(ct.SpellQueue[i].spell) ~= 0 do
        SpellID = ct.SpellQueue[i].spell[1]
        -- Cast Spell
        if (not ct.UnitIsMoving("player") or ct.CanCastWhileMoving(SpellID))
        and not ct.PlayerIsCasting() and (UnitGUID("target") ~= nil or SpecificTarget == true) then
          -- TODO: script ran to long
          CastSpellByID(SpellID, TargetUnit)
        end
      end
    else
      SpellID = ct.SpellQueue[i].spell
      -- Cast Spell
      if (not ct.UnitIsMoving("player") or ct.CanCastWhileMoving(SpellID))
      and not ct.PlayerIsCasting() and (UnitGUID("target") ~= nil or SpecificTarget == true) then
        CastSpellByID(SpellID, TargetUnit)
      end
    end
  end
end

-- adds an entry to the SpellQueue
-- entry can contain spellID and unit to cast the spell on
function ct.AddSpellToQueue(spell, unit)
  QueueEntry = {spell = spell, unit = unit}
  table.insert(ct.SpellQueue, QueueEntry)
end

-- removes the given spell from the queue if it is at first position
function ct.DeQueueSpell(spell)
  -- exit if queue is empty
  if getn(ct.SpellQueue) == 0 then
    return
  end

  -- find spell in queue and dequeue it
  if (type(ct.SpellQueue[1].spell) == "table") then
    if ct.SpellQueue[1].spell[1] == spell then
      table.remove(ct.SpellQueue[1].spell, 1)
    end
  else
    if ct.SpellQueue[1].spell == spell then
      table.remove(ct.SpellQueue, 1)
    end
  end
end

-- removes every entry from the whole queue
function ct.CleanUpQueue()
  for i = 1, getn(ct.SpellQueue) do
    table.remove(ct.SpellQueue, 1)
  end
end
