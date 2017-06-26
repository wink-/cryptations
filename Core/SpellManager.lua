ct.SpellQueue = {}
ct.SpellHistory = {}

-- The Spell Queue does only contain casted or channeled spells
-- However, the PulseQueue function also pulses the Rotation file (which also contains instant casts)
-- Unless there is some real necessity Instant casts shall always be casted by the rotation file (with CastSpellByID)
function ct.PulseQueue()

  -- pulse appropriate rotation if spellQueue is empty
  if getn(ct.SpellQueue) == 0 then
    ct.PulseRotation()
  elseif getn(ct.SpellQueue) ~= 0 then
    local SpellID = ct.SpellQueue[1].spell
    ct.SpellTarget = "target"

    -- if the entry contains a target, cast the spell on it (if it exists)
    if ct.SpellQueue[1].unit ~= nil
    and ObjectExists(ct.SpellQueue[1].unit)
    and not UnitIsDeadOrGhost(ct.SpellQueue[1].unit) then
      ct.SpellTarget = ct.SpellQueue[1].unit
    end

    -- Cast Spell
    if (not ct.UnitIsMoving(ct.player) or ct.CanCastWhileMoving(SpellID))
    and not ct.IsCasting(ct.player) and UnitGUID(ct.SpellTarget) ~= nil then
      CastSpellByID(SpellID, ct.SpellTarget)

      -- instantly remove the spell if it is an instant cast
      if select(4, GetSpellInfo(SpellID)) == 0 then
        ct.DeQueueSpell(SpellID)
      end
    end
  end
end

-- adds an entry to the SpellQueue
-- entry can contain spellID and unit to cast the spell on
function ct.AddSpellToQueue(spell, unit)
  -- Add every spell from a sequence
  if type(spell) == "table" then
    for i = 1, getn(spell) do
      ct.SpellUniqueIdentifier = ct.SpellUniqueIdentifier + 1
      QueueEntry = {spell = spell[i], unit = unit, key = ct.SpellUniqueIdentifier}
      table.insert(ct.SpellQueue, QueueEntry)
    end
  -- Add Single Spell
  else
    ct.SpellUniqueIdentifier = ct.SpellUniqueIdentifier + 1
    QueueEntry = {spell = spell, unit = unit, key = ct.SpellUniqueIdentifier}
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
