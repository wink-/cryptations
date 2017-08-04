-- These checks are necessary to only load ONE rotaion for the correct class / spec
local _, _, ClassID = UnitClass("player")
local SpecID  = GetSpecialization()

if ClassID ~= 1 then return end
if SpecID ~= 1 then return end
if FireHack == nil then return end


-- This is the settings segment. Loading settings is handled here
local wowdir = GetWoWDirectory()
local profiledir = wowdir .. "\\Interface\\Addons\\cryptations\\Profiles\\"
local content = ReadFile(profiledir .. "Example.JSON")

if content == nil or content == "" then
  return message("Error loading config file. Please contact the Author.")
end

local Settings = json.decode(content)

-- Settings that you can use for the rotations.
-- Look inside the Example.JSON for more info.
Interrupt = Settings.Interrupt
Dispell   = Settings.Dispell
Taunt     = Settings.Taunt
AoECount  = Settings.AoECount

-- This is the table that holds the key combinations
-- and the function that should be called upon pressing the key(s).
-- Some functions are already pre coded, look them up on the wiki.
-- If you need your own functions, implement them in Class-Abilities.lua
KeyCallbacks = {
  [Settings.PauseKey] = PauseRotation,
  [Settings.ToggleAoE] = ToggleAoE,

  -- WHICH WOULD INTERNALLY LOOK LIKE THIS

  ["CTRL,P"] = PauseRotation,
  ["CTRL,A"] = ToggleAoE
}

-- Every rotation MUST have this. The rough structure comes here.
function Pulse()
  -- This is the Action List of your rotation.
  -- You can structure it as you wish but keep in mind that you MUST only call spell functions here
  -- You can also use conds but only for greater blocks that also contain spells

  -- EXFireball()
  -- EXFireblast()

  -- Cond Example
  -- if Unit.PercentHealth(PlayerUnit) <= 50 then
  -- function1()
  -- function2()
  -- function3()
  -- end

  -- etc.
end

-- Every rotation that should / can interrupt MUST have this in order to interrupt.
-- You can either put a function here which is defined in the Class-Abilities.lua or Class-Common.lua or use conditions here.
function Interrupt(TargetToInterrupt)
  -- Kick()

  -- OR

  -- if Spell.CanCast(ID, TargetToInterrupt)
  -- and Unit.IsInLOS(TargetToInterrupt)
  -- and etc. then
  -- return Spell.Cast(ID, TargetToInterrupt)
end

-- Every rotation that should / can taunt MUST have this in order to taunt (mostly only tank rotations).
-- You can either put a function here which is defined in the Class-Abilities.lua or Class-Common.lua or use conditions here.
function Taunt(TargetToTaunt)
  -- Growl()

  -- OR

  -- if Spell.CanCast(ID, TargetToTaunt)
  -- and Unit.IsInLOS(TargetToTaunt)
  -- and etc. then
  -- return Spell.Cast(ID, TargetToTaunt)
end

-- Every rotation that should / can dispell MUST have this in order to dispell.
-- You can either put a function here which is defined in the Class-Abilities.lua or Class-Common.lua or use conditions here.
function Dispell(TargetToDispell, DispellType)
 -- CleanseToxins()

 -- OR

 -- if Spell.CanCast(ID, TargetToDispell)
 -- and Unit.IsInLOS(TargetToDispell)
 -- and DispellType == "Curse"
 -- and etc. then
 -- return Spell.Cast(ID, TargetToDispell)
end
