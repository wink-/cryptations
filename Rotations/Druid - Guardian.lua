function ct.DruidGuardian()
  local MaxMana           = UnitPowerMax(ct.player , 0)
  local MaxHealth         = UnitHealthMax(ct.player)
  local Rage              = UnitPower(ct.player, 1)

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

    -- Bear form usage
    if not ct.UnitHasBuff(ct.player, 5487) then
      if AutoSwitchForm then
        return ct.Cast(5487)
      else
        return
      end
    end

    -- pulse target engine and remember target
    ct.TargetEngine("hostile")
    ct.Target = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      ct.InterruptEngine()
    end

    -- COOLDOWNS
    -- Survival Instincts:
    -- Use when below 70% health
    -- Or when the BossManager notices the need to use a def cooldown
    if ct.CanCast(61336) and UseSurvivalInstincts then
      if ct.PercentHealth(ct.player) <= SurvivalInstincsHealth
      or BossManager.IsDefCooldownNeeded() then
        return ct.Cast(61336)
      end
    end

    -- Barkskin:
    -- same as Survival Instincts but when stunned
    if ct.CanCast(22812) and UseBarkskin then
      if ct.PercentHealth(ct.player) <= BarkskinHealth
      or BossManager.IsDefCooldownNeeded() then
        return ct.Cast(22812)
      end
    end

    -- Rage of the Sleeper:
    -- same as other def cooldowns
    if ct.CanCast(200851) and UseRotS then
      if ct.PercentHealth(ct.player) <= RotSHealth
      or BossManager.IsDefCooldownNeeded() then
        return ct.Cast(200851)
      end
    end

    -- MITIGATION
    -- Ironfur:
    -- Use if below 85% health
    -- Or when the BossManager notices the need to use a def cooldown
    if ct.CanCast(192081) and UseIronfur then
      if ct.PercentHealth(ct.player) <= IronFurHealth
      or BossManager.IsDefCooldownNeeded() then
        return ct.Cast(192081)
      end
    end

    -- Frenzied Regeneration:
    -- Use when taken 20% of maxhealth as damage in the last 5 seconds
    if ct.CanCast(22842) and UseFrenziedRegeneration then
      if ct.GetDamageOverPeriod(5) >= UnitHealthMax(ct.player) * (FrenziedRegenerationHealth / 100) then
        return ct.Cast(22842)
      end
    end

    -- BASE ROTATION

    -- Moonfire:
    -- Use with Galactic Guardian proc
    -- Or when the target does not have the debuff (this is experimental here)
    if ct.CanCast(8921, ct.Target) and UseMoonfire and ct.IsInLOS(ct.Target) then
      if ct.UnitHasBuff(ct.player, 203964) or not ct.UnitHasDebuff(ct.Target, 164812) then
        return ct.Cast(8921, ct.Target)
      end
    end

    -- Mangle: Use on cooldown
    if ct.CanCast(33917, ct.Target) then
      return ct.Cast(33917, ct.Target)
    end

    -- Thrash: Use on cooldown
    if ct.CanCast(77758, nil, nil, nil, false) then
      return ct.Cast(77758)
    end

    -- Pulverize: (Talent) Use when target has 2+ Stacks of Thrash
    if ct.CanCast(80313, ct.Target) and select(2, ct.UnitHasDebuff(77758)) >= 2 then
      return ct.Cast(80313, ct.Target)
    end

    -- Maul: Use only when we don't need rage for mitigation (95% health) and when rage is >= 95
    if ct.CanCast(6807, ct.Target, 1, 45) then
      if Rage >= MaulRage and ct.PercentHealth(ct.player) >= MaulHealth then
        return ct.Cast(6807, ct.Target)
      end
    end

    -- Swipe
    if ct.CanCast(213764) then
      return ct.Cast(213764)
    end
  else
    -- out of combat rotation
  end
end

function ct.DruidGuardianTaunt()
  -- Growl
  if ct.CanCast(6795, ct.Target) and ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target) then
    return ct.Cast(6795, ct.Target)
  end

  -- Moonfire
  if ct.CanCast(8921, ct.Target) and ct.UnitIsHostile(ct.Target) and ct.IsInLOS(ct.Target) then
    return ct.Cast(8921, ct.Target)
  end
end

function ct.DruidGuardianInterrupt()
end

function ct.DruidGuardianSetUp()
  if FireHack == nil then
    return
  end

  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Druid - Guardian.JSON")

  if json.decode(content) == nil then
    return message("Error loading config file. Please contact the Author.")
  end

  local Settings = json.decode(content)

  UseTaunt                    = Settings.UseTaunt
  UseInterruptEngine          = Settings.UseInterruptEngine
  UseSurvivalInstincts        = Settings.UseSurvivalInstincts
  UseBarkskin                 = Settings.UseBarkskin
  UseIronfur                  = Settings.UseIronfur
  UseFrenziedRegeneration     = Settings.UseFrenziedRegeneration
  UseMoonfire                 = Settings.UseMoonfire
  UseMaul                     = Settings.UseMaul
  UseRotS                     = Settings.UseRotS
  AutoSwitchForm              = Settings.AutoSwitchForm
  SurvivalInstincsHealth      = Settings.SurvivalInstincsHealth
  BarkskinHealth              = Settings.BarkskinHealth
  IronFurHealth               = Settings.IronFurHealth
  FrenziedRegenerationHealth  = Settings.FrenziedRegenerationHealth
  MaulHealth                  = Settings.MaulHealth
  MaulRage                    = Settings.MaulRage
  RotSHealth                  = Settings.RotSHealth

  ct.Interrupt = ct.DruidGuardianInterrupt
  ct.Taunt     = ct.DruidGuardianTaunt
end
