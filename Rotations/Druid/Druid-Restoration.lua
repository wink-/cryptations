local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 4 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid - Restoration.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Dispell       = Settings.Dispell
Tranquility   = Settings.Tranquility
Innervate     = Settings.Innervate
Ironbark      = Settings.Ironbark
EoG           = Settings.EoG
Flourish      = Settings.Flourish
TankHealth    = Settings.TankHealth
OtherHealth   = Settings.OtherHealth
ToppingHealth = Settings.ToppingHealth
MaxRejuv      = Settings.MaxRejuv

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function Pulse()
  MaxMana                 = UnitPowerMax(PlayerUnit , 0)
  MaxHealth               = UnitHealthMax(PlayerUnit)
  LowestFriend            = Unit.FindLowest("friendly")
  MainTank, OffTank       = Unit.FindTanks()
  HealTarget              = nil
  RejuvenationCount       = getn(Buff.FindUnitsWith(774, true))
  HoTCount                = RejuvenationCount + getn(Buff.FindUnitsWith(48438, true))

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

    -- Innervate:
    -- Use on cooldown

    -- Ironbark:
    -- Use when Tank is in danger

    -- Essence of G'Hanir:
    -- Use on heavy group damage
    -- Is best used with Wild Growth

    -- Flourish:
    -- Use on cooldown when having at least 3 hots active on the group

    -- HEAL LOGIC
    if Unit.IsInRange(PlayerUnit, MainTank, 40) and Unit.IsInLOS(MainTank)
    and Unit.PercentHealth(MainTank) <= TankHealth
    and (not (Unit.PercentHealth(LowestFriend) <= OtherHealth)
    or LowestFriend == MainTank) then
      HealTarget = MainTank
    elseif Unit.IsInRange(PlayerUnit, LowestFriend, 40) and Unit.IsInLOS(LowestFriend)
    and Unit.PercentHealth(LowestFriend) <= OtherHealth then
      HealTarget = LowestFriend
    -- TOPPING ROTATION
    elseif Unit.PercentHealth(LowestFriend) <= ToppingHealth then
      -- Rejuvenation
      if Spell.CanCast(774, LowestFriend, 0, MaxMana * 0.1) and not Buff.Has(LowestFriend, 774, true)
      and RejuvenationCount < MaxRejuv and Unit.IsInLOS(LowestFriend) then
        return Spell.Cast(774, LowestFriend)
      end

      -- Healing Touch
      if Spell.CanCast(5185, LowestFriend, 0, MaxMana * 0.09) and Unit.IsInLOS(LowestFriend) then
        return Spell.Cast(5185, LowestFriend)
      end
    end

    -- HEAL ROTATION
    if HealTarget ~= nil then
      -- Efflorescence:
      -- Maintain under damaged group

      -- Lifebloom:
      -- Keep active on tank, refresh when remaining time < 4.5 seconds

      -- Regrowth with Clearcasting:
      -- Use on active tank

      -- Cenarion Ward:
      -- Use on cooldown


      -- Rejuvenation:
      -- Use on damaged Players
      -- Don't exceed the maximum Rejuvenation count
      -- Don't use when the target already has a Rejuvenation from us

      -- Wild Growth:
      -- Use on group damage (Raid 6; Dungeon 4) within 30 yards
      -- Is best used with Innervate

      -- Swiftmend:
      -- Use on players with low health

      -- Regrowth without Clearcasting:
      -- Use as emergency

      -- Healing Touch
    end

  -- Out Of Combat Rotation
  else

  end
end

function Dispell()
end
