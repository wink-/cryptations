-- All modules are registered here

-- Engine Modules
local Spell         = LibStub:NewLibrary("Spell", 1)
local Unit          = LibStub:NewLibrary("Unit", 1)
local Buff          = LibStub:NewLibrary("Buff", 1)
local Debuff        = LibStub:NewLibrary("Debuff", 1)
local Group         = LibStub:NewLibrary("Group", 1)
local Player        = LibStub:NewLibrary("Player", 1)
local Rotation      = LibStub:NewLibrary("Rotation", 1)
local Utils         = LibStub:NewLibrary("Utils", 1)
local Events        = LibStub:NewLibrary("Events", 1)
local BossManager   = LibStub:NewLibrary("BossManager", 1)
local ClassManager  = LibStub:NewLibrary("ClassManager", 1)

-- Class Modules
-- Druid
local DruidCommon       = LibStub:NewLibrary("DruidCommon", 1)
local DruidBalance      = LibStub:NewLibrary("DruidBalance", 1)
local DruidFeral        = LibStub:NewLibrary("DruidFeral", 1)
local DruidRestoration  = LibStub:NewLibrary("DruidRestoration", 1)
local DruidGuardian     = LibStub:NewLibrary("DruidGuardian", 1)

-- Paladin
local PaladinCommon       = LibStub:NewLibrary("PaladinCommon", 1)
local PaladinHoly         = LibStub:NewLibrary("PaladinHoly", 1)
local PaladinRetribution  = LibStub:NewLibrary("PaladinRetribution", 1)
local PaladinProtection   = LibStub:NewLibrary("PaladinProtection", 1)

-- Rogue
local RogueCommon       = LibStub:NewLibrary("RogueCommon", 1)
local RogueOutlaw       = LibStub:NewLibrary("RogueOutlaw", 1)
local RogueAssasination = LibStub:NewLibrary("RogueAssasination", 1)
local RogueSubtlety     = LibStub:NewLibrary("RogueSubtlety", 1)
