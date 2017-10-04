local PaladinHoly = LibStub("PaladinHoly")
local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local BossManager = LibStub("BossManager")
local Utils       = LibStub("Utils")

function PaladinHoly.Initialize()
  -- load profile content
  local wowdir = GetWoWDirectory()
  local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
  local content = ReadFile(profiledir .. "Paladin-Holy.JSON")

  if content == nil or content == "" then
    return message("Error loading config file. Please contact the Author.")
  end

  local Settings = json.decode(content)

  -- Apply settings from config file
  Dispell                 = Settings.Dispell
  AutoEngage              = Settings.AutoEngage
  AutoTarget              = Settings.AutoTarget
  TargetMode              = Settings.TargetMode
  AvengingWrath           = Settings.AvengingWrath
  HolyAvenger             = Settings.HolyAvenger
  LayOnHands              = Settings.LayOnHands
  BoS                     = Settings.BoS
  TyrsDeliverance         = Settings.TyrsDeliverance
  RuleOfLaw               = Settings.RuleOfLaw
  BoL                     = Settings.BoL
  BoF                     = Settings.BoF
  Judgment                = Settings.UseJudgment
  LightsHammer            = Settings.Judgment
  LightOfDawn             = Settings.LightOfDawn
  HolyPrism               = Settings.HolyPrism
  BoV                     = Settings.BoV

  BeaconEmergency         = Settings.BeaconEmergency
  InfusionFoL             = Settings.InfusionFoL
  AWHealth                = Settings.AWHealth
  HAHealth                = Settings.HAHealth
  LoHHealth               = Settings.LoHHealth
  BoSHealth               = Settings.BoSHealth
  TDHealth                = Settings.TDHealth
  TDUnits                 = Settings.TDUnits
  LHUnits                 = Settings.LHUnits
  LHHealth                = Settings.LHHealth
  LoDUnits                = Settings.LoDUnits
  LoDHealth               = Settings.LoDHealth
  HolyPrismUnits          = Settings.HolyPrismUnits
  BoVUnits                = Settings.BoVUnits
  BoVHealth               = Settings.BoVHealth
  FoLHealth               = Settings.FoLHealth
  BestowFaithHealth       = Settings.BestowFaithHealth
  HLHealth                = Settings.HLHealth
  HSHealth                = Settings.HSHealth
  PauseHotkey             = Settings.PauseHotkey
  AoEHotkey               = Settings.AoEHotkey
  CDHotkey                = Settings.CDHotkey
  MaxMana                 = UnitPowerMax("player" , 0)

  KeyCallbacks = {
    [PauseHotkey] = Rotation.TogglePause,
    [AoEHotkey] = Rotation.ToggleAoE,
    [CDHotkey] = Rotation.ToggleCD
  }
end

function PaladinHoly.Pulse()
  -- Dispell engine
  if Dispell then
    Rotation.Dispell()
  end

  -- pulse target engine and remember target
  Rotation.Target("hostile")

  PaladinHoly.AvengingWrath()
  PaladinHoly.HolyAvenger()
  PaladinHoly.LayOnHands()
  PaladinHoly.BoS()

    -- TODO
    -- Aura Mastery (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Protection (SHOULD BE HANDELED BY BOSS MANAGER)
    -- Blessing of Freedom (SHOULD BE HANDELED BY BOSS MANAGER)

  PaladinHoly.TyrsDeliverance()
  --PaladinHoly.RuleOfLaw()
  PaladinHoly.BoL()
  PaladinHoly.BoF()
  PaladinHoly.BestowFaith()
  PaladinHoly.InfusionProc()
  PaladinHoly.HolyShock()
  PaladinHoly.Judgment()
  PaladinHoly.LightsHammer()
  PaladinHoly.LoD()
  PaladinHoly.HolyPrism()
  PaladinHoly.BoV()
  PaladinHoly.HolyLight()
  PaladinHoly.FlashOfLight()
end

-- Dispell Spells are handled here
function PaladinHoly.Dispell(unit, dispelType)
  if Spell.CanCast(4987, unit, 0, MaxMana * 0.13) and dispelType ~= "Curse" then
    return Spell.Cast(4987, unit)
  end
end
