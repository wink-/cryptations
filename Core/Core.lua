local Unit      = LibStub("Unit")
local Rotation  = LibStub("Rotation")
local Spell     = LibStub("Spell")
local Group     = LibStub("Group")

-- GLOBAL SETTINGS

-- Targeting behavior : Only one can be true
ReTargetNearestUnit      = true
ReTargetHighestUnit      = false
ReTargetLowestUnit       = false

-- Combat behavior
AllowOutOfCombatRoutine  = true

-- Interrupt behavior
InterruptAnyUnit         = true
InterruptMinPercent      = 20
InterruptMaxPercent      = 80

function Initialize()
  if FireHack then
    if PlayerUnit == nil or not ObjectExists(PlayerUnit) then
      PlayerUnit = GetObjectWithGUID(UnitGUID("player"))
    end
  end

  -- Setup event frame
  local frame = CreateFrame("FRAME", "EventFrame")
  local spellframe = CreateFrame("FRAME", "SpellFrame")

  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:RegisterEvent("UNIT_SPELLCAST_START")
  frame:RegisterEvent("UNIT_COMBAT")
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

  local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6)
    if event == "UNIT_SPELLCAST_START" and arg1 == "player" and getn(SPELL_QUEUE) ~= 0 then
      CurrentUniqueIdentifier = SPELL_QUEUE[1].key
      CurrentSpell = Spell.GetID(arg2)
    end
    if event == "PLAYER_REGEN_ENABLED" then
      -- player left any combat action so the queue will be cleaned up
      Rotation.CleanUpQueue()
    end
    if event == "UNIT_COMBAT" and arg1 == "player" and arg2 == "WOUND"
    and arg4 ~= nil then
      -- the player damage table is limited to 100 entries
      if getn(PLAYER_DAMAGE) > 100 then
        table.remove(PLAYER_DAMAGE, 1)
      end

      -- add the event to the player damage table
      local Entry = {damage = arg4, damageTakenTime = GetTime()}
      table.insert(PLAYER_DAMAGE, Entry)
    end
    if event == "GROUP_ROSTER_UPDATE" then
      Group.UpdateMembers()
    end
    if event == "ACTIVE_TALENT_GROUP_CHANGED" and IsInGroup() then
      Group.UpdateTanks()
    end
  end

  frame:SetScript("OnEvent", eventHandler)
  spellframe:SetScript("OnUpdate", Spell.DetectionHandler)
end
