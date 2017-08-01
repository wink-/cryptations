local _, _, ClassID = UnitClass("player")
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

Taunt           = Settings.Taunt
Interrupt       = Settings.Interrupt
SurvInstincts   = Settings.SurvInstincts
Barkskin        = Settings.Barkskin
Ironfur         = Settings.Ironfur
FRegen          = Settings.FRegen
Moonfire        = Settings.Moonfire
Maul            = Settings.Maul
RotS            = Settings.RotS
AutoSwitchForm  = Settings.AutoSwitchForm
SIHealth        = Settings.SIHealth
BSHealth        = Settings.BSHealth
IFHealth        = Settings.IFHealth
FRHealth        = Settings.FRHealth
MaulHealth      = Settings.MaulHealth
MaulRage        = Settings.MaulRage
RotSHealth      = Settings.RotSHealth
MaxMana         = UnitPowerMax("player" , 0)
MaxHealth       = UnitHealthMax("player")

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
