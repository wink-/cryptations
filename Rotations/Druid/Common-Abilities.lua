local _, _, ClassID = UnitClass("player")

if ClassID ~= 11 then return end
if FireHack == nil then return end

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function DRejuvenation()
  if Spell.CanCast(SB["Rejuvenation"], HealTarget, 0, MaxMana * 0.1)
  and not Buff.Has(LowestFriend, 774, true)
  and Unit.IsInLOS(HealTarget)
  and RejuvenationCount < MaxRejuv then
    return Spell.Cast(SB["Rejuvenation"], HealTarget)
  end
end

function DHealingTouch()
  if Spell.CanCast(SB["Healing Touch"], LowestFriend, 0, MaxMana * 0.09)
  and Unit.IsInLOS(LowestFriend) then
    return Spell.Cast(SB["Healing Touch"], LowestFriend)
  end
end

function DRegrowth()
  if Spell.CanCast(SB["Regrowh"], nil, 0, MaxMana * 0.1863) then
    return Spell.Cast(SB["Regrowh"])
  end
end
