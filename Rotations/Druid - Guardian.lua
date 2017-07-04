function ct.DruidGuardian()
  local MaxMana           = UnitPowerMax(ct.player , 0)
  local MaxHealth         = UnitHealthMax(ct.player)

  local LowestFriend      = ct.FindLowestUnit("friendly")

  local MainTank, OffTank = ct.FindTanks()

  -- Call Taunt engine
  if UseTauntEngine then
    ct.TauntEngine()
  end

  -- combat rotation
  if UnitAffectingCombat(ct.player)
  or (ct.AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and ct.UnitIsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    ct.TargetEngine("hostile")
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      ct.InterruptEngine()
    end

    -- COOLDOWNS
    -- Survival Instincts:
    -- Use when large damage is incoming (through boss spells)

    -- Barkskin:
    -- same as survival instinc but when stunned

    -- MITIGATION
    -- Ironfur:
    -- Use when about to take damage

    -- Frenzied Regeneration:
    -- Use when taken high damage in the last 5 seconds

  else
    -- out of combat rotation
  end
end

function ct.DruidGuardianTaunt()
end

function ct.DruidGuardianInterrupt()
end

function ct.DruidGuardianSetUp()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Paladin - Protection.JSON")

  if json.decode(content) == nil then
    return message("Error loading config file. Please contact the Author.")
  end

  local Settings = json.decode(content)

  UseTaunt = Settings.UseTaunt
  UseInterruptEngine = Settings.UseInterruptEngine

  ct.Interrupt = ct.DruidGuardianInterrupt
  ct.Taunt     = ct.DruidGuardianTaunt
end
