local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

-- load profile content
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Druid - Restoration.JSON")

if json.decode(content) == nil then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

Dispell = Settings.Dispell

function Pulse()
  local MaxMana                 = UnitPowerMax(PlayerUnit , 0)
  local MaxHealth               = UnitHealthMax(PlayerUnit)

  local LowestFriend            = Unit.FindLowest("friendly")

  local MainTank, OffTank       = Unit.FindTanks()
  local HealTarget              = nil

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
    and Unit.PercentHealth(MainTank) <= TankHealthThreshold
    and (not (Unit.PercentHealth(LowestFriend) <= OtherHealthThreshold)
    or LowestFriend == MainTank) then
      HealTarget = MainTank
    elseif Unit.IsInRange(PlayerUnit, LowestFriend, 40) and Unit.IsInLOS(LowestFriend)
    and Unit.PercentHealth(LowestFriend) <= OtherHealthThreshold then
      HealTarget = LowestFriend
    -- TOPPING ROTATION
    elseif Unit.PercentHealth(LowestFriend) <= ToppingHealthThreshold then
      -- Rejuvenation

      -- Healing Touch
    end
    if HealTarget ~= nil then
      -- HEAL ROTATION

      -- Efflorescence:
      -- Maintain under damaged group

      -- Lifebloom:
      -- Keep active on tank, refresh when remaining time < 4.5 seconds#

      -- Regrowth with Clearcasting:
      -- Use on Tanks

      -- Cenarion Ward:
      -- Use on cooldown

      -- Rejuvenation:
      -- Use on damaged Players

      -- Wild Growth:
      -- Use on group damage (Raid 6; Dungeon 4) within 30 yards
      -- Is best used with Innervate

      -- Swiftmend:
      -- Use on players with low health

      -- Regrowth without Clearcasting:
      -- Use as emergency
    end

  -- Out Of Combat Rotation
  else

  end
end

function Dispell()
end
