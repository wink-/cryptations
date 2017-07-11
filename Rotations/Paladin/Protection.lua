local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Protection.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Taunt             = Settings.UseTauntEngine
Interrupt         = Settings.UseInterruptEngine
AvengingWrath     = Settings.UseAvengingWrath
GotaK             = Settings.UseGuardianOfTheAncientKings
ArdentDefender    = Settings.UseArdentDefender
LayOnHands        = Settings.UseLayOnHandsSelf
LayOnHandsFriend  = Settings.UseLayOnHandsFriend
EyeOfTyr          = Settings.UseEyeOfTyr
Sepharim          = Settings.UseSepharim
HotPFriend        = Settings.UseHandOfTheProtectorFriend
FoL               = Settings.UseFlashOfLight
ADHealth          = Settings.ArdentDefenderHealthThreshold
GotaKHealth       = Settings.GuardianOfTheAncientKingsHealthThreshold
EoTUnits          = Settings.EyeOfTyrUnitThreshold
LoHHealth         = Settings.LayOnHandsHealthThreshold
LotPHealth        = Settings.LightOfTheProtectorHealthThreshold
HotPHealth        = Settings.HandOfTheProtectorFriendHealthThreshold
FoLHealth         = Settings.FlashOfLightHealthThreshold
MaxMana           = UnitPowerMax("player" , 0)

local Unit        = LibStub("Unit")
local Rotation    = LibStub("Rotation")

function Pulse()
  -- Call Taunt engine
  if UseTauntEngine then
    Rotation.Taunt()
  end

  -- combat rotation
  if UnitAffectingCombat(PlayerUnit)
  or (AllowOutOfCombatRoutine and UnitGUID("target") ~= nil
  and Unit.IsHostile("target")) and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    -- COOLDOWNS
    PPAvengingWrath()
    PPGotaK()
    PPArdentDefender()
    PPLayOnHands()
    PPEyeOfTyr()
    PPSepharim()
    PPSotR()
    PPLotP()
    PPHotP()
    PPFlashOfLight()

    -- AOE ROTATION
    if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= 3 then
      PPConsecration()
      PPAvengersShield()
      PPJudgment()
      PPBlessedHammer()
      PPHotR()
    else
      -- SINGLE TARGET
      PPJudgment()
      PPConsecration()
      PPAvengersShield()
      PPBlessedHammerST()
    end
  end
end

-- Taunt spells are handled here
function Taunt(unit)
  PlayerTarget = unit
  PPHoR()
  PPAvengersShield()
  PPJudgment()
end

-- Interrupt spells are handled here
function Interrupt(unit)
  PlayerTarget = unit
  PRebuke()
  PBlindingLight()
  PHammerOfJustice()
end
