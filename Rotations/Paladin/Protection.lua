local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Paladin-Protection.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Taunt             = Settings.Taunt
Interrupt         = Settings.Interrupt
AvengingWrath     = Settings.AvengingWrath
GotaK             = Settings.GotaK
ArdentDefender    = Settings.ArdentDefender
LayOnHands        = Settings.LayOnHands
LayOnHandsFriend  = Settings.LayOnHandsFriend
EyeOfTyr          = Settings.EyeOfTyr
Sepharim          = Settings.Sepharim
HotPFriend        = Settings.HotPFriend
FoL               = Settings.FoL
ADHealth          = Settings.ADHealth
GotaKHealth       = Settings.GotaKHealth
EoTUnits          = Settings.EoTUnits
LoHHealth         = Settings.LoHHealth
LotPHealth        = Settings.LotPHealth
HotPHealth        = Settings.HotPHealth
FoLHealth         = Settings.FoLHealth
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
    if #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= 3 then
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
function Taunt(Target)
  if Target ~= nil
  and Spell.CanCast(62124, Target)
  and Unit.IsInLOS(Target) then
    -- Here it is necessary to let the queue cast the spell
    return Spell.AddToQueue(62124, Target)
  end

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(31935, Target)
  and Unit.IsFacing(Target, MeleeAngle) then
    return Spell.Cast(31935, Target)
  end

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(20271, Target)
  and Unit.IsFacing(Target, MeleeAngle) then
    return Spell.Cast(20271, Target)
  end
end

-- Interrupt spells are handled here
function Interrupt(Target)
  PRebuke(Target)
  PBlindingLight(Target)
  PHammerOfJustice(Target)
end
