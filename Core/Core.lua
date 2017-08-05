local Unit      = LibStub("Unit")
local Rotation  = LibStub("Rotation")
local Spell     = LibStub("Spell")
local Group     = LibStub("Group")
local Player    = LibStub("Player")
local Events    = LibStub("Events")
local Utils     = LibStub("Utils")

function Initialize_UnlockerNeeded()

  -- Setup event frame
  local frame = CreateFrame("FRAME", "EventFrame")
  local spellframe = CreateFrame("FRAME", "SpellFrame")

  frame:RegisterEvent("PLAYER_REGEN_ENABLED")
  frame:RegisterEvent("UNIT_SPELLCAST_START")
  frame:RegisterEvent("UNIT_COMBAT")
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_REGEN_DISABLED")
  frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")

  local function eventHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6)
    if event == "UNIT_SPELLCAST_START" and arg1 == "player" then
      if #SPELL_QUEUE ~= 0 then
        CurrentUniqueIdentifier = SPELL_QUEUE[1].key
      end

      CurrentSpell = Spell.GetID(arg2)
    end

    if event == "PLAYER_REGEN_ENABLED" then
      Rotation.CleanUpQueue()
      GroupInCombat = false
    end

    if event == "PLAYER_REGEN_DISABLED" then
      GroupInCombat = true
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

    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
      -- This is needed because UnitInRaid or UnitInParty
      -- does not recognize if Units are in the group right after the roster has updated
      Utils.Wait(1, Group.UpdateMembers)
      Utils.Wait(1, Group.UpdateTanks)
    end

    if event == "ACTIVE_TALENT_GROUP_CHANGED" and IsInGroup() then
      Group.UpdateTanks()
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
      Player.GetSetPieceLatestTier()
    end

    if event == "PLAYER_TARGET_CHANGED" and OnTargetSwitch ~= nil then
      OnTargetSwitch()
    end
  end

  -- Set Frame Scripts
  frame:SetScript("OnEvent", eventHandler)
  spellframe:SetScript("OnUpdate", Spell.DetectionHandler)

  -- Create Timers
  if GetKeyState ~= nil then
    AddTimerCallback(0.05, Events.KeyListener)
  end
  AddTimerCallback(0.1, Events.GetUnits)
end

function Initialize_NoUnlockerNeeded()
  local function SlashCommands(msg, editbox)
    if msg == 'toggle' then
      Rotation.TogglePause()
    elseif msg == 'help' then
      print('"toggle": toggle the rotation')
    else
      print('Unknown command. Type "/cr help" for a list of available commands')
    end
  end

  SLASH_CR1 = '/cr'
  SlashCmdList["CR"] = SlashCommands
end
