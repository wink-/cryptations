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
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Avenging Wrath"])
  and AvengingWrath
  and Unit.IsInRange(PlayerUnit, Target, 30) then
    return Spell.Cast(SB["Avenging Wrath"])
  end
end

-- TODO: add check so that def cooldowns do not stack if they shouldn't
function PPGotaK()
  if Spell.CanCast(SB["Guardian of Ancient Kings"])
  and GotaK
  and (Unit.PercentHealth(PlayerUnit) <= GotaKHealth
  or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Guardian of Ancient Kings"])
  end
end

function PPArdentDefender()
  if Spell.CanCast(SB["Ardent Defender"])
  and ArdentDefender
  and (Unit.PercentHealth(PlayerUnit) <= ADHealth
    or BossManager.IsDefCooldownNeeded()) then
    return Spell.Cast(SB["Ardent Defender"])
  end
end

function PPLayOnHandsTarget()
end

function PPLayOnHands()
  if Spell.CanCast(SB["Lay on Hands"])
  and LayOnHands
  and Unit.PercentHealth(PlayerUnit) <= LoHHealth then
    return Spell.Cast(SB["Lay on Hands"])
  end
end

function PPEyeOfTyr()
  if Spell.CanCast(SB["Eye of Tyr"])
  and EyeOfTyr
  and #Unit.GetUnitsInRadius(PlayerUnit, 8, "hostile", true) >= EoTUnits then
    return Spell.Cast(SB["Eye of Tyr"])
  end
end

function PPSepharim()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Sepharim"])
  and Sepharim
  and Player.HasTalent(7, 2)
  and (PlayerUnit ~= MainTank or not Unit.IsTankingBoss(PlayerUnit))
  and Unit.IsInAttackRange(53600, Target)
  and Spell.GetCharges(SB["Shield of the Righteous"]) >= 1 then
    return Spell.Cast(SB["Sepharim"])
  end
end

function PPSotR()
  local Target = PlayerTarget()

  if Target ~= nil
  and Unit.IsHostile(Target)
  and Spell.CanCast(SB["Shield of the Righteous"], Target)
  and not Buff.Has(PlayerUnit, AB["Shield of the Righteous"])
  and Unit.IsFacing(Target, CastAngle) then
    if Player.HasTalent(7, 2)
    and Spell.GetCharges(SB["Shield of the Righteous"]) > 2
    and PlayerUnit ~= MainTank then
      return Spell.Cast(SB["Shield of the Righteous"])
    elseif Spell.GetCharges(SB["Shield of the Righteous"]) > 1
    and not Player.HasTalent(7, 2) then
      return Spell.Cast(SB["Shield of the Righteous"])
    elseif UnitHealth(PlayerUnit) <= UnitHealthMax(PlayerUnit) * 0.4 then
      return Spell.Cast(SB["Shield of the Righteous"])
    end
  end
end

function PPLotP()
  if Spell.CanCast(SB["Light of the Protector"])
  and Unit.PercentHealth(PlayerUnit) <= LoHHealth
  and not Player.HasTalent(5, 1)
  and (Spell.GetPreviousSpell() ~= SB["Light of the Protector"]
  or Spell.GetTimeSinceLastSpell() >= 500) then
    return Spell.Cast(SB["Light of the Protector"])
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
  and Spell.CanCast(SB["Hand of the Protector"], Target, nil, nil, false)
  and (Spell.GetPreviousSpell() ~= SB["Hand of the Protector"]
  or Spell.GetTimeSinceLastSpell() >= 500) then
    return Spell.Cast(SB["Hand of the Protector"], Target)
  end
end

function PPFlashOfLight()
  if Spell.CanCast(SB["Flash of Light"], PlayerUnit)
  and FoL
  and Unit.PercentHealth(PlayerUnit) <= FoLHealth
  and not Unit.IsMoving(PlayerUnit) then
    return Spell.Cast(SB["Flash of Light"], PlayerUnit)
  end
end

function PPConsecration()
  local Target = PlayerTarget()

  if not Unit.IsMoving(PlayerUnit)
  and Spell.CanCast(SB["Consecration Protection"])
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Consecration Protection"])
  end
end

function PPAvengersShield()
  local Target = PlayerTarget()

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(SB["Avenger's Shield"], Target)
  and Unit.IsFacing(Target, CastAngle) then
    return Spell.Cast(SB["Avenger's Shield"])
  end
end

function PPJudgment()
  local Target = PlayerTarget()

  if Target ~= nil
  and Unit.IsInLOS(Target)
  and Spell.CanCast(SB["Judgment Protection"], Target)
  and Unit.IsFacing(Target, CastAngle) then
    return Spell.Cast(SB["Judgment Protection"])
  end
end

function PPBlessedHammer()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(SB["Blessed Hammer"], nil, nil, nil, false)
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Blessed Hammer"])
  end
end

function PPBlessedHammerST()
  local Target = PlayerTarget()

  if Target ~= nil
  and Player.HasTalent(1, 2)
  and Spell.CanCast(SB["Blessed Hammer"], nil, nil, nil, false)
  and Spell.GetCharges(SB["Blessed Hammer"]) == 3
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Blessed Hammer"])
  end
end

function PPHotR()
  local Target = PlayerTarget()

  if Target ~= nil
  and Spell.CanCast(SB["Hammer of the Righteous"])
  and not Player.HasTalent(1, 2)
  and Unit.IsInRange(PlayerUnit, Target, 8) then
    return Spell.Cast(SB["Hammer of the Righteous"])
  end
end
