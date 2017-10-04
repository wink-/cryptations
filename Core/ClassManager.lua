local ClassManager = LibStub("ClassManager")
local DruidBalance = LibStub("DruidBalance")

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
      message("Balance Druid loaded. Have fun.")
    elseif SpecID == 2 then
    elseif SpecID == 3 then
    elseif SpecID == 4 then
    end
  -- Demon Hunter
  elseif ClassID == 12 then
    if SpecID == 1 then
    elseif SpecID == 2 then
    end
  end
end
