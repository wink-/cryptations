ct.SpellQueue = {}
ct.SpellHistory = {}

-- The spell queue shall only contain spells that are a 100% required to be casted (rest is done by the rotation itself)
-- Example use for the spell queue would be a sequence that has to be casted in a certain order
-- There are also some instant spells that require being casted by the spell queue
function ct.PulseQueue()

  -- pulse appropriate rotation if spellQueue is empty
  if getn(ct.SpellQueue) == 0 and not ct.IsCasting(ct.player) then
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

      -- instantly remove the spell and add it to the history if it is an instant cast
      if select(4, GetSpellInfo(SpellID)) == 0 then
        ct.DeQueueSpell(SpellID)
        ct.AddSpellToHistory(SpellID)
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

-- Adds the given spell to the spell history and keeps the size at a maximum of 10 entries
function ct.AddSpellToHistory(spell)
  -- maximum lenght of spell history is 10 entries
  if getn(ct.SpellHistory) > 10 then
    table.remove(ct.SpellHistory, 1)
  end

  -- add spell to history like : SPELL; TARGET; TIME
  local Entry = {spell = spell, time = GetTime()}
  table.insert(ct.SpellHistory, Entry)
end
