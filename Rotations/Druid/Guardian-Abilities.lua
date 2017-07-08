local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 3 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function SwitchToBearForm()
  if not Buff.Has(PlayerUnit, 5487) then
    if AutoSwitchForm then
      return Spell.Cast(5487)
    else
      return
    end
  end
end

function DGSurvivalInstincts()
  if Spell.CanCast(61336) and UseSurvivalInstincts then
    if Unit.PercentHealth(PlayerUnit) <= SurvivalInstincsHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(61336)
    end
  end
end

function DGBarkskin()
  if Spell.CanCast(22812) and UseBarkskin then
    if Unit.PercentHealth(PlayerUnit) <= BarkskinHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(22812)
    end
  end
end

function DGRotS()
  if Spell.CanCast(200851) and UseRotS then
    if Unit.PercentHealth(PlayerUnit) <= RotSHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(200851)
    end
  end
end

function DGIronfur()
  if Spell.CanCast(192081) and UseIronfur then
    if Unit.PercentHealth(PlayerUnit) <= IronFurHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(192081)
    end
  end
end

function DGFrenziedRegeneration()
  if Spell.CanCast(22842) and UseFrenziedRegeneration then
    if Player.GetDamageOverPeriod(5) >= UnitHealthMax(PlayerUnit) * (FrenziedRegenerationHealth / 100) then
      return Spell.Cast(22842)
    end
  end
end

function DGMoonfire()
  if PlayerTarget ~= nil
  and Spell.CanCast(8921, PlayerTarget)
  and UseMoonfire
  and Unit.IsInLOS(PlayerTarget) then
    if Buff.Has(PlayerUnit, 203964)
    or not Debuff.Has(PlayerTarget, 164812) then
      return Spell.Cast(8921, PlayerTarget)
    end
  end
end

function DGMangle()
  if PlayerTarget ~= nil
  and Spell.CanCast(33917, PlayerTarget) then
    return Spell.Cast(33917, PlayerTarget)
  end
end

function DGThrash()
  if PlayerTarget ~= nil
  and Spell.CanCast(77758, nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(77758)
  end
end

function DGPulverize()
  if PlayerTarget ~= nil
  and Spell.CanCast(80313, PlayerTarget)
  and select(2, Debuff.Has(PlayerTarget, 77758)) >= 2 then
    return Spell.Cast(80313, PlayerTarget)
  end
end

function DGMaul()
  if PlayerTarget ~= nil
  and Spell.CanCast(6807, PlayerTarget, 1, 45) then
    if Rage >= MaulRage
    and Unit.PercentHealth(PlayerUnit) >= MaulHealth then
      return Spell.Cast(6807, PlayerTarget)
    end
  end
end

function DGSwipe()
  if PlayerTarget ~= nil
  and Spell.CanCast(213764)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(213764)
  end
end
