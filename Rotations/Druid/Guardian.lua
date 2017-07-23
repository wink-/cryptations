local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Guardian.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Taunt           = Settings.UseTaunt
Interrupt       = Settings.UseInterruptEngine
SurvInstincts   = Settings.UseSurvivalInstincts
Barkskin        = Settings.UseBarkskin
Ironfur         = Settings.UseIronfur
FRegen          = Settings.UseFrenziedRegeneration
Moonfire        = Settings.UseMoonfire
Maul            = Settings.UseMaul
RotS            = Settings.UseRotS
AutoSwitchForm  = Settings.AutoSwitchForm
SIHealth        = Settings.SurvivalInstincsHealth
BSHealth        = Settings.BarkskinHealth
IFHealth        = Settings.IronFurHealth
FRHealth        = Settings.FrenziedRegenerationHealth
MaulHealth      = Settings.MaulHealth
MaulRage        = Settings.MaulRage
RotSHealth      = Settings.RotSHealth
MaxMana         = UnitPowerMax("player" , 0)
MaxHealth       = UnitHealthMax("player")
Rage            = UnitPower("player", 1)

local Unit        = LibStub("Unit")
local Rotation    = LibStub("Rotation")

function Pulse()
  -- Call Taunt engine
  if Taunt then
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
    if Interrupt then
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
