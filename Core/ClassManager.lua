local ClassManager = LibStub("ClassManager")

local DruidBalance      = LibStub("DruidBalance")
local DruidFeral        = LibStub("DruidFeral")
local DruidGuardian     = LibStub("DruidGuardian")
local DruidRestoration  = LibStub("DruidRestoration")

function ClassManager.LoadRotation()
  local _, _, ClassID = UnitClass("player")
  local SpecID  = GetSpecialization()

  if ClassID == 0 then
    message("Class Error.")
  -- Warrior
  elseif ClassID == 1 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Paladin
  elseif ClassID == 2 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Hunter
  elseif ClassID == 3 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Rogue
  elseif ClassID == 4 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Priest
  elseif ClassID == 5 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Death Knight
  elseif ClassID == 6 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Shaman
  elseif ClassID == 7 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Mage
  elseif ClassID == 8 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Warlock
  elseif ClassID == 9 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Monk
  elseif ClassID == 10 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    end
  -- Druid
  elseif ClassID == 11 then
    -- Balance
    if SpecID == 1 then
      DruidBalance.Initialize()
      Pulse = DruidBalance.Pulse
      Interrupt = DruidBalance.Interrupt
      print("Balance Druid loaded. Have fun.")
    -- Feral
    elseif SpecID == 2 then
      DruidFeral.Initialize()
      Pulse = DruidFeral.Pulse
      Interrupt = DruidFeral.Interrupt
      print("Feral Druid loaded. Have fun.")
    -- Guardian
    elseif SpecID == 3 then
      DruidGuardian.Initialize()
      Pulse = DruidGuardian.Pulse
      Interrupt = DruidGuardian.Interrupt
      Taunt = DruidGuardian.Taunt
      print("Guardian Druid loaded. Have fun.")
    -- Restoration
    elseif SpecID == 4 then
      DruidRestoration.Initialize()
      Pulse = DruidRestoration.Pulse
      Dispell = DruidRestoration.Dispell
      print("Restoration Druid loaded. Have fun.")
    end
  -- Demon Hunter
  elseif ClassID == 12 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    end
  end
end
