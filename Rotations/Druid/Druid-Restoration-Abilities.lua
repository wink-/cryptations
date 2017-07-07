function DRTranquility()
end

function DRInnervate()
  if Spell.CanCast(29166) then
    return Spell.Cast(29166)
  end
end

function DRIronbark()
end

function DREoG()
end

function DRFlourish()
  if Spell.CanCast(197721) and HoTCount >= 3 then
    return Spell.Cast(197721)
  end
end

function DREfflorescence()
end

function DRLifebloom()
  if MainTank ~= nil and Spell.CanCast(33763, MainTank, 0, MaxMana * 0.12)
  and Unit.IsInLOS(MainTank) then
    if not Buff.Has(MainTank, 33763, true)
    or select(3, Buff.Has(MainTank, 33763, true)) <= 4.5 then
      return Spell.Cast(33763, MainTank)
    end
  end
end

function DRRegrowthClearcast()
  if MainTank ~= nil and Spell.CanCast(8936, MainTank)
  and Buff.Has(PlayerUnit, 16870) and Unit.IsInLOS(MainTank) then
    return Spell.Cast(8936, MainTank)
  end
end

function DRCenarionWard()
  if Spell.CanCast(102351, HealTarget, 0, MaxMana * 0.092)
  and Unit.IsInLOS(HealTarget) then
    return Spell.Cast(102351, HealTarget)
  end
end

function DRWildGrowth()
end

function DRSwiftmend()
end
