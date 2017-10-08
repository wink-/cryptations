local PaladinProtection = LibStub("PaladinProtection")
local Unit              = LibStub("Unit")
local Rotation          = LibStub("Rotation")

function PaladinProtection.Initialize()
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
  InterruptAny      = Settings.InterruptAny
  InterruptMin      = Settings.InterruptMin
  InterruptMax      = Settings.InterruptMax
  AutoEngage        = Settings.AutoEngage
  AutoTarget        = Settings.AutoTarget
  TargetMode        = Settings.TargetMode
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
  PauseHotkey       = Settings.PauseHotkey
  AoEHotkey         = Settings.AoEHotkey
  CDHotkey          = Settings.CDHotkey
  MaxMana           = UnitPowerMax("player" , 0)

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }

  -- set function variables
  Pulse = PaladinProtection.Pulse
  Taunt = PaladinProtection.Taunt
  Interrupt = PaladinProtection.Interrupt
  print("Protection Paladin loaded. Have fun.")
end

function PaladinProtection.Pulse()
  -- Call Taunt engine
  if UseTauntEngine then
    Rotation.Taunt()
  end

  -- combat rotation
  if (UnitAffectingCombat(PlayerUnit) or AutoEngage)
  and UnitGUID("target") ~= nil
  and Unit.IsHostile("target") and UnitHealth("target") ~= 0 then

    -- pulse target engine and remember target
    Rotation.Target("hostile")

    -- call interrupt engine
    if Interrupt then
      Rotation.Interrupt()
    end

    -- COOLDOWNS
    PaladinProtection.AvengingWrath()
    PaladinProtection.GotaK()
    PaladinProtection.ArdentDefender()
    PaladinProtection.LayOnHands()
    PaladinProtection.EyeOfTyr()
    PaladinProtection.Sepharim()
    PaladinProtection.SotR()
    PaladinProtection.LotP()
    PaladinProtection.HotP()
    PaladinProtection.FlashOfLight()

    -- AOE ROTATION
    if #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= 3 then
      PaladinProtection.Consecration()
      PaladinProtection.AvengersShield()
      PaladinProtection.Judgment()
      PaladinProtection.BlessedHammer()
      PaladinProtection.HotR()
    else
      -- SINGLE TARGET
      PaladinProtection.Judgment()
      PaladinProtection.Consecration()
      PaladinProtection.AvengersShield()
      PaladinProtection.BlessedHammerST()
    end
  end
end

-- Taunt spells are handled here
function PaladinProtection.Taunt(Target)
  if Target ~= nil
  and Spell.CanCast(SB["Hand of Reckoning"], Target)
  and Unit.IsInLOS(Target) then
    -- Here it is necessary to let the queue cast the spell
    return Spell.AddToQueue(SB["Hand of Reckoning"], Target)
  end

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(SB["Avenger's Shield"], Target)
  and Player.IsFacing(Target) then
    return Spell.Cast(SB["Avenger's Shield"], Target)
  end

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(SB["Judgment"], Target)
  and Player.IsFacing(Target) then
    return Spell.Cast(SB["Judgment"], Target)
  end
end

-- Interrupt spells are handled here
function PaladinProtection.Interrupt(Target)
  PaladinCommon.Rebuke(Target)
  PaladinCommon.BlindingLight(Target)
  PaladinCommon.HammerOfJustice(Target)
end
