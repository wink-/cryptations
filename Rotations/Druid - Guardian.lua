local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

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

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function Pulse()
  local MaxMana           = UnitPowerMax(PlayerUnit , 0)
  local MaxHealth         = UnitHealthMax(PlayerUnit)
  local Rage              = UnitPower(PlayerUnit, 1)

  local LowestFriend      = Unit.FindLowest("friendly")

  local MainTank, OffTank = Unit.FindTanks()

  -- Call Taunt engine
  if UseTauntEngine then
    Rotation.Taunt()
  end

  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    -- Bear form usage
    if not Buff.Has(PlayerUnit, 5487) then
      if AutoSwitchForm then
        return Spell.Cast(5487)
      else
        return
      end
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      Rotation.Interrupt()
    end

    -- COOLDOWNS
    -- Survival Instincts:
    -- Use when below 70% health
    -- Or when the BossManager notices the need to use a def cooldown
    if Spell.CanCast(61336) and UseSurvivalInstincts then
      if Unit.PercentHealth(PlayerUnit) <= SurvivalInstincsHealth
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(61336)
      end
    end

    -- Barkskin:
    -- same as Survival Instincts but when stunned
    if Spell.CanCast(22812) and UseBarkskin then
      if Unit.PercentHealth(PlayerUnit) <= BarkskinHealth
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(22812)
      end
    end

    -- Rage of the Sleeper:
    -- same as other def cooldowns
    if Spell.CanCast(200851) and UseRotS then
      if Unit.PercentHealth(PlayerUnit) <= RotSHealth
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(200851)
      end
    end

    -- MITIGATION
    -- Ironfur:
    -- Use if below 85% health
    -- Or when the BossManager notices the need to use a def cooldown
    if Spell.CanCast(192081) and UseIronfur then
      if Unit.PercentHealth(PlayerUnit) <= IronFurHealth
      or BossManager.IsDefCooldownNeeded() then
        return Spell.Cast(192081)
      end
    end

    -- Frenzied Regeneration:
    -- Use when taken 20% of maxhealth as damage in the last 5 seconds
    if Spell.CanCast(22842) and UseFrenziedRegeneration then
      if Player.GetDamageOverPeriod(5) >= UnitHealthMax(PlayerUnit) * (FrenziedRegenerationHealth / 100) then
        return Spell.Cast(22842)
      end
    end

    -- BASE ROTATION

    -- Moonfire:
    -- Use with Galactic Guardian proc
    -- Or when the target does not have the debuff (this is experimental here)
    if Spell.CanCast(8921, PlayerTarget) and UseMoonfire and Unit.IsInLOS(PlayerTarget) then
      if Buff.Has(PlayerUnit, 203964) or not Debuff.Has(PlayerTarget, 164812) then
        return Spell.Cast(8921, PlayerTarget)
      end
    end

    -- Mangle: Use on cooldown
    if Spell.CanCast(33917, PlayerTarget) then
      return Spell.Cast(33917, PlayerTarget)
    end

    -- Thrash: Use on cooldown
    if Spell.CanCast(77758, nil, nil, nil, false) and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
      return Spell.Cast(77758)
    end

    -- Pulverize: (Talent) Use when target has 2+ Stacks of Thrash
    if Spell.CanCast(80313, PlayerTarget) and select(2, Debuff.Has(PlayerTarget, 77758)) >= 2 then
      return Spell.Cast(80313, PlayerTarget)
    end

    -- Maul: Use only when we don't need rage for mitigation (95% health) and when rage is >= 95
    if Spell.CanCast(6807, PlayerTarget, 1, 45) then
      if Rage >= MaulRage and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
        return Spell.Cast(6807, PlayerTarget)
      end
    end

    -- Swipe
    if Spell.CanCast(213764) and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
      return Spell.Cast(213764)
    end
  else
    -- out of combat rotation
  end
end

function Taunt()
  -- Growl
  if Spell.CanCast(6795, PlayerTarget) and Unit.IsHostile(PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(6795, PlayerTarget)
  end

  -- Moonfire
  if Spell.CanCast(8921, PlayerTarget) and Unit.IsHostile(PlayerTarget) and Unit.IsInLOS(PlayerTarget) then
    return Spell.Cast(8921, PlayerTarget)
  end
end

function Interrupt()
end
