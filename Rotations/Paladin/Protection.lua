local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin - Protection.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

UseTauntEngine                            = Settings.UseTauntEngine
UseInterruptEngine                        = Settings.UseInterruptEngine
UseAvengingWrath                          = Settings.UseAvengingWrath
UseGuardianOfTheAncientKings              = Settings.UseGuardianOfTheAncientKings
UseArdentDefender                         = Settings.UseArdentDefender
UseLayOnHandsSelf                         = Settings.UseLayOnHandsSelf
UseLayOnHandsFriend                       = Settings.UseLayOnHandsFriend
UseEyeOfTyr                               = Settings.UseEyeOfTyr
UseSepharim                               = Settings.UseSepharim
UseHandOfTheProtectorFriend               = Settings.UseHandOfTheProtectorFriend
UseFlashOfLight                           = Settings.UseFlashOfLight
UnitsToSwitchToAOE                        = Settings.UnitsToSwitchToAOE
ArdentDefenderHealthThreshold             = Settings.ArdentDefenderHealthThreshold
GuardianOfTheAncientKingsHealthThreshold  = Settings.GuardianOfTheAncientKingsHealthThreshold
EyeOfTyrUnitThreshold                     = Settings.EyeOfTyrUnitThreshold
LayOnHandsHealthThreshold                 = Settings.LayOnHandsHealthThreshold
LightOfTheProtectorHealthThreshold        = Settings.LightOfTheProtectorHealthThreshold
HandOfTheProtectorFriendHealthThreshold   = Settings.HandOfTheProtectorFriendHealthThreshold
FlashOfLightHealthThreshold               = Settings.FlashOfLightHealthThreshold
MaxMana                                   = UnitPowerMax(PlayerUnit , 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

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
    if UseInterruptEngine then
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
    if getn(Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true)) >= UnitsToSwitchToAOE then
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
  PlayerTarget = Unit
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
