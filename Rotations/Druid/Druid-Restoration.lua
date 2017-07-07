local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 4 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid-Restoration.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Dispell         = Settings.Dispell
Tranquility     = Settings.Tranquility
Innervate       = Settings.Innervate
Ironbark        = Settings.Ironbark
EoG             = Settings.EoG
Flourish        = Settings.Flourish
TankHealth      = Settings.TankHealth
OtherHealth     = Settings.OtherHealth
ToppingHealth   = Settings.ToppingHealth
MaxRejuv        = Settings.MaxRejuv
RejuvHealth     = Settings.RejuvHealth
RegrowthHealth  = Settings.RegrowthHealth
HTHealth        = Settings.HTHealth
MaxMana         = UnitPowerMax("player", 0)

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function Pulse()
  -- Combat Rotation
  if UnitAffectingCombat(PlayerUnit) then
    -- Dispell engine
    if Dispell then
      Rotation.Dispell()
    end

    -- pulse target engine and remember target
    Rotation.Target("hostile")
    PlayerTarget = GetObjectWithGUID(UnitGUID("target"))

    -- COOLDOWNLS

    -- Tranquility:
    -- Use on heavy group damage
    DRTranquility()
    -- Innervate:
    -- Use on cooldown
    DRInnervate()
    -- Ironbark:
    -- Use when Tank is in danger
    DRIronbark()
    -- Essence of G'Hanir:
    -- Use on heavy group damage
    -- Is best used with Wild Growth
    DREoG()
    -- Flourish:
    -- Use on cooldown when having at least 3 hots active on the group
    DRFlourish()
    -- Efflorescence:
    -- Maintain under damaged group
    DREfflorescence()
    -- Lifebloom:
    -- Keep active on tank, refresh when remaining time < 4.5 seconds
    DRLifebloom()
    -- Regrowth with Clearcasting:
    -- Use on active tank
    DRRegrowthClearcast()
    -- Cenarion Ward:
    -- Use on cooldown
    DRCenarionWard()
    -- Rejuvenation:
    -- Use on damaged Players
    -- Don't exceed the maximum Rejuvenation count
    -- Don't use when the target already has a Rejuvenation from us
    DRRejuvenation()
    -- Wild Growth:
    -- Use on group damage (Raid 6; Dungeon 4) within 30 yards
    -- Is best used with Innervate
    DRWildGrowth()
    -- Swiftmend:
    -- Use on players with low health
    DRSwiftmend()
    -- Regrowth without Clearcasting:
    -- Use as emergency
    DRRegrowth()
    -- Healing Touch
    DHealingTouch()
  -- Out Of Combat Rotation
  else

  end
end

function Dispell()
end
