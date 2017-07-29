local _, _, ClassID = UnitClass("player")

if ClassID ~= 11 then return end
if FireHack == nil then return end

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function DRejuvenation()
  if Spell.CanCast(774, HealTarget, 0, MaxMana * 0.1) and not Buff.Has(LowestFriend, 774, true)
  and Unit.IsInLOS(HealTarget) and RejuvenationCount < MaxRejuv then
    return Spell.Cast(774, HealTarget)
  end
end

function DHealingTouch()
  if Spell.CanCast(5185, LowestFriend, 0, MaxMana * 0.09) and Unit.IsInLOS(LowestFriend) then
    return Spell.Cast(5185, LowestFriend)
  end
end

function DRegrowth()
  if Spell.CanCast(8936, nil, 0, MaxMana * 0.1863) then
    return Spell.Cast(8936)
  end
end
