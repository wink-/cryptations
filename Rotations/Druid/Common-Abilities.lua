Druid = {
  Balance = {},
  Feral = {},
  Restoration = {},
  Guardian = {},
}

local Spell = LibStub("Spell")
local Unit  = LibStub("Unit")

function Druid.Rejuvenation()
  if Spell.CanCast(SB["Rejuvenation"], HealTarget, 0, MaxMana * 0.1)
  and not Buff.Has(LowestFriend, 774, true)
  and Unit.IsInLOS(HealTarget)
  and RejuvenationCount < MaxRejuv then
    return Spell.Cast(SB["Rejuvenation"], HealTarget)
  end
end

function Druid.HealingTouch()
  if Spell.CanCast(SB["Healing Touch"], LowestFriend, 0, MaxMana * 0.09)
  and Unit.IsInLOS(LowestFriend) then
    return Spell.Cast(SB["Healing Touch"], LowestFriend)
  end
end

function Druid.Regrowth()
  if Spell.CanCast(SB["Regrowh"], nil, 0, MaxMana * 0.1863) then
    return Spell.Cast(SB["Regrowh"])
  end
end
