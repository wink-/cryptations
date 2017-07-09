local ClassID = select(3, UnitClass("player"))
local SpecID  = GetSpecialization()

if ClassID ~= 11 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")

function DFRakeV1()
  if PlayerTarget ~= nil
  and Spell.CanCast(1822, PlayerTarget, 3, 35) then
    if Buff.Has(PlayerUnit, 5215)
    or Buff.Has(PlayerUnit, 58984) then
      return Spell.Cast(1822, PlayerTarget)
    end
  end
end

function DFTigersFury()
  if Spell.CanCast(5217) then
    if not Buff.Has(PlayerUnit, 16870)
    and MaxEnergy - Energy >= 60
    or MaxEnergy - Energy >= 80 then
      return Spell.Cast(5217)
  end
end

function DFIKotJ()
  if Spell.CanCast(102543)
  and Buff.Has(PlayerUnit, 5217) then
    return Spell.Cast(102543)
  end
end

function DFBerserk()
  if Spell.CanCast(106951)
  and Buff.Has(PlayerUnit, 5217) then
    return Spell.Cast(106951)
  end
end

function DFFerociousBiteMaxEnergy()
  local EnergyNeeded = 25
  if Buff.Has(PlayerUnit, 106951) then
    EnergyNeeded = EnergyNeeded / 2
  elseif Buff.Has(PlayerUnit, 102543) then
    EnergyNeeded = EnergyNeeded * 0.4
  end

  return EnergyNeeded * 2
end

function DFElunesGuidance()
  if Spell.CanCast(202060)
  and ComboPoints <= 1
  and Energy >= DFFerociousBiteMaxEnergy() then
    return Spell.Cast(202060)
  end
end
