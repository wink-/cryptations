local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 2 then return end
if SpecID ~= 2 then return end
if FireHack == nil then return end

local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Buff        = LibStub("Buff")
local BossManager = LibStub("BossManager")
local Group       = LibStub("Group")
local Player      = LibStub("Player")

function PPAvengingWrath()
  if PlayerTarget ~= nil
  and Spell.CanCast(31884) and AvengingWrath
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 30) then
    return Spell.Cast(31884)
  end
end

-- TODO: add check so that def cooldowns do not stack if they shouldn't
function PPGotaK()
  if Spell.CanCast(86659) and GotaK then
    if Unit.PercentHealth(PlayerUnit) <= GotaKHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(86659)
    end
  end
end

function PPArdentDefender()
  if Spell.CanCast(31850) and ArdentDefender then
    if Unit.PercentHealth(PlayerUnit) <= ADHealth
    or BossManager.IsDefCooldownNeeded() then
      return Spell.Cast(31850)
    end
  end
end

function PPLayOnHandsTarget()
end

function PPLayOnHands()
  if Spell.CanCast(633) and LayOnHands
  and Unit.PercentHealth(PlayerUnit) <= LoHHealth then
    return Spell.Cast(633)
  end
end

function PPEyeOfTyr()
  if Spell.CanCast(209202) and EyeOfTyr
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= EoTUnits then
    return Spell.Cast(209202)
  end
end

function PPSepharim()
  if PlayerTarget ~= nil
  and Spell.CanCast(152262)
  and Sepharim
  and Player.HasTalent(7, 2)
  and (PlayerUnit ~= MainTank or not Unit.IsTankingBoss(PlayerUnit))
  and Unit.IsInAttackRange(53600, PlayerTarget)
  and Spell.GetCharges(53600) >= 1 then
    return Spell.Cast(152262)
  end
end

function PPSotR()
  if PlayerTarget ~= nil
  and Unit.IsHostile(PlayerTarget)
  and Spell.CanCast(53600, PlayerTarget)
  and not Buff.Has(PlayerUnit, 53600)
  and Unit.IsFacing(PlayerTarget, CastAngle) then
    if Player.HasTalent(7, 2)
    and Spell.GetCharges(53600) > 2
    and PlayerUnit ~= MainTank then
      return Spell.Cast(53600)
    elseif Spell.GetCharges(53600) > 1
    and not Player.HasTalent(7, 2) then
      return Spell.Cast(53600)
    elseif UnitHealth(PlayerUnit) <= UnitHealthMax(PlayerUnit) * 0.4 then
      return Spell.Cast(53600)
    end
  end
end

function PPLotP()
  if Spell.CanCast(184092)
  and Unit.PercentHealth(PlayerUnit) <= LoHHealth
  and not Player.HasTalent(5, 1)
  and (Spell.GetPreviousSpell() ~= 184092 or Spell.GetTimeSinceLastSpell() >= 500) then
    return Spell.Cast(184092)
  end
end

function PPHotPTarget()
  local Lowest = Group.UnitToHeal()
  if Unit.PercentHealth(PlayerUnit) <= LotPHealth then
    return PlayerUnit
  elseif Unit.PercentHealth(Lowest) <= HotPHealth then
    return Lowest
  end
end

function PPHotP()
  local Target = PPHotPTarget()
  if Target ~= nil
  and Player.HasTalent(5, 1)
  and Spell.CanCast(213652, Target, nil, nil, false)
  and (Spell.GetPreviousSpell() ~= 213652 or Spell.GetTimeSinceLastSpell() >= 500) then
    return Spell.Cast(213652, Target)
  end
end

function PPFlashOfLight()
  if Spell.CanCast(19750, PlayerUnit)
  and FoL
  and Unit.PercentHealth(PlayerUnit) <= FoLHealth
  and not Unit.IsMoving(PlayerUnit) then
    return Spell.Cast(19750, PlayerUnit)
  end
end

function PPConsecration()
  if not Unit.IsMoving(PlayerUnit)
  and Spell.CanCast(26573)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(26573)
  end
end

function PPAvengersShield()
  if PlayerTarget ~= nil
  and Unit.IsInLOS(PlayerTarget)
  and Spell.CanCast(31935, PlayerTarget)
  and Unit.IsFacing(PlayerTarget, CastAngle) then
    return Spell.Cast(31935)
  end
end

function PPJudgment()
  if PlayerTarget ~= nil
  and Unit.IsInLOS(PlayerTarget)
  and Spell.CanCast(20271, PlayerTarget)
  and Unit.IsFacing(PlayerTarget, CastAngle) then
    return Spell.Cast(20271)
  end
end

function PPBlessedHammer()
  if PlayerTarget ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(204019, nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(204019)
  end
end

function PPBlessedHammerST()
  if PlayerTarget ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(204019, nil, nil, nil, false)
  and Spell.GetCharges(204019) == 3
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(204019)
  end
end

function PPHotR()
  if PlayerTarget ~= nil
  and Spell.CanCast(53595)
  and not Player.HasTalent(1, 2)
  and Unit.IsInRange(PlayerUnit, PlayerTarget, 8) then
    return Spell.Cast(53595)
  end
end

function PPHoR()
  if PlayerTarget ~= nil
  and Spell.CanCast(62124, PlayerTarget)
  and Unit.IsInLOS(PlayerTarget) then
    -- Here it is necessary to let the queue cast the spell
    return Spell.AddToQueue(62124, PlayerTarget)
  end
end
