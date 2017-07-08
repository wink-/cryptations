local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Guardian.JSON")

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
MaxMana                     = UnitPowerMax("player" , 0)
MaxHealth                   = UnitHealthMax("player")
Rage                        = UnitPower("player", 1)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function Pulse()
  -- Call Taunt engine
  if UseTaunt then
    Rotation.Taunt()
  end

  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    SwitchToBearForm()

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if UseInterruptEngine then
      Rotation.Interrupt()
    end

    DGSurvivalInstincts()
    DGBarkskin()
    DGRotS()
    DGIronfur()
    DGFrenziedRegeneration()
    DGMoonfire()
    DGMangle()
    DGThrash()
    DGPulverize()
    DGMaul()
    DGSwipe()
  else
    -- out of combat rotation
  end
end

function Taunt(unit)
  PlayerTarget = unit
  DGGrowl()
  DGMoonfire()
end

function Interrupt()
end
