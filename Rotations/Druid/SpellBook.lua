local _, _, ClassID = UnitClass("player")

if ClassID ~= 11 then return end
if FireHack == nil then return end

SB = {
  ["Ashamane's Frenzy"] = 210722,
  ["Astral Communion"] = 202359,
  ["Barkskin"] = 22812,
  ["Bear Form"] = 5487,
  ["Berserk"] = 106951,
  ["Blessing of the Ancients"] = 202360,
  ["Brutal Slash"] = 202028,
  ["Celestial Alignment"] = 194223,
  ["Cenarion Ward"] = 102351,
  ["Efflorescence"] = 145205,
  ["Elune's Guidance"] = 202060,
  ["Essence of G'Hanir"] = 208253,
  ["Ferocious Bite"] = 22568,
  ["Flourish"] = 197721,
  ["Force of Nature"] = 205636,
  ["Frenzied Regeneration"] = 22842,
  ["Full Moon"] = 202771,
  ["Fury of Elune"] = 202770,
  ["Growl"] = 6795,
  ["Half Moon"] = 202768,
  ["Savage Roar"] = 52610,
  ["Healing Touch"] = 5185,
  ["Incarnation: Chosen of Elune"] = 102560,
  ["Incarnation: King of the Jungle"] = 102543,
  ["Innervate"] = 29166,
  ["Ironbark"] = 102342,
  ["Ironfur"] = 192081,
  ["Lifebloom"] = 33763,
  ["Lunar Strike"] = 194153,
  ["Maim"] = 22570,
  ["Mangle"] = 33917,
  ["Maul"] = 6807,
  ["Moonfire"] = 8921,
  ["Moonkin Form"] = 24858,
  ["Nature's Cure"] = 88423,
  ["New Moon"] = 202767,
  ["Prowl"] = 5215,
  ["Pulverize"] = 80313,
  ["Rage of the Sleeper"] = 200851,
  ["Rake"] = 1822,
  ["Regrowth"] = 8936,
  ["Rejuvenation"] = 774,
  ["Rip"] = 1079,
  ["Shadowmeld"] = 58984,
  ["Shred"] = 5221,
  ["Solar Beam"] = 78675,
  ["Solar Wrath"] = 190984,
  ["Starfall"] = 191034,
  ["Starsurge"] = 78674,
  ["Stellar Flare"] = 202347,
  ["Sunfire"] = 93402,
  ["Survival Instincts"] = 61336,
  ["Swiftmend"] = 18562,
  ["Swipe Bear"] = 213764,
  ["Swipe Cat"] = 106785,
  ["Cat Form"] = 768,
  ["Thrash Bear"] = 77758,
  ["Thrash Cat"] = 106830,
  ["Tiger's Fury"] = 5217,
  ["Tranquility"] = 740,
  ["Warrior of Elune"] = 202425,
  ["Wild Growth"] = 48438,
}
