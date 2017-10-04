-- These are the "Includes" to use the functions from the corrseponding table.
-- Include them as you need.
local Example     = LibStub("Example")
local Unit        = LibStub("Unit")
local Spell       = LibStub("Spell")
local Rotation    = LibStub("Rotation")
local Player      = LibStub("Player")
local Buff        = LibStub("Buff")
local Debuff      = LibStub("Debuff")
local BossManager = LibStub("BossManager")
local Group       = LibStub("Group")



-- Here are the functions for the abilities.
-- The conditions required to cast the spell are declared inside these functions.
-- You can have multiple functions for the same ability
-- which is useful when you need the same ability but with different conditions

-- You can also write your custom Target conditions here
function Example.FireballTarget()
  -- if CONDITIONS then
  --  return Target
  -- end
end

function Example.Fireball()
  -- local Target = EXFireballTarget()
  -- if CONDITIONS then
  --  return Spell.Cast(SB["Fireball"], Target)
  -- end
end

function Example.Fireblast()
  -- if CONDITIONS then
  --  return Spell.Cast(SB["Fireblast"], Target)
  -- end
end
