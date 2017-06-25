ct.SpellQueue = {}
ct.SpellHistory = {}

-- pulses the SpellQueue and tries to cast from it
-- spells will be casted on the current target by default

-- TODO: fix spells double casting becasuse they were not removed quick enough
function ct.PulseQueue()

  -- pulse appropriate rotation if spellQueue is empty
  if getn(ct.SpellQueue) == 0 then
    ct.PulseRotation()
  elseif getn(ct.SpellQueue) ~= 0 then
    local SpellID = nil
    ct.SpellTarget = "target"

    -- if the entry contains a target, cast the spell on it (if it exists)
    if ct.SpellQueue[1].unit ~= nil
    and ObjectExists(ct.SpellQueue[1].unit)
    and not UnitIsDeadOrGhost(ct.SpellQueue[1].unit) then
      ct.SpellTarget = ct.SpellQueue[1].unit
    end

    -- only cast the spell if a specific target was given or if the player has a target
    SpellID = ct.SpellQueue[1].spell
    -- Cast Spell
    if (not ct.UnitIsMoving(ct.player) or ct.CanCastWhileMoving(SpellID))
    and not ct.IsCasting(ct.player) and UnitGUID(ct.SpellTarget) ~= nil then
      CastSpellByID(SpellID, ct.SpellTarget)
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
