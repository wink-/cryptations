local Unit    = LibStub("Unit")
local Events  = LibStub("Events")

UNIT_TRACKER = {}
TTD_TABLE = {}

-- This keeps track of all of the valid units and their ttd
function Events.GetUnits()
  -- cache new units
  if UnitAffectingCombat("player") then
    local Units = GetObjectsOfType(ObjectTypes.Unit)
    for i = 1, #Units do
      local Object = Units[i]
      if Object ~= ObjectPointer("player")
      and not UNIT_TRACKER[Object]
      and (UnitAffectingCombat(Object) or Unit.IsDummy(Object)) then
        UNIT_TRACKER[Object] = GetTime()
        if TTD_TABLE[Object] == nil then
          TTD_TABLE[Object] = -1
        end
      end
    end

    -- update unit variables
    for Object, _ in pairs(UNIT_TRACKER) do
      local duration = GetTime() - UNIT_TRACKER[Object]
      local health = UnitHealth(Object)
      local diff = UnitHealthMax(Object) - health
      local dps = diff / duration
      local ttd = health / dps
      if ttd ~= math.huge and ttd >= 1 then
        TTD_TABLE[Object] = ttd
      end
    end
  end

  -- remove not existing units
  -- TODO: test if table.wipe(UNIT_TRACKER) is faster
  for Object,_ in pairs(UNIT_TRACKER) do
    if not ObjectExists(Object)
    or UnitHealth(Object) <= 1 then
      UNIT_TRACKER[Object] = nil
      TTD_TABLE[Object] = nil
    end
  end
end

Keys = {
  ["BACKSPACE"] = 0x08,
  ["TAB"] = 0x09,
  ["ENTER"] = 0x0D,
  ["SHIFT"] = 0x10,
  ["CTRL"] = 0x11,
  ["ALT"] = 0x12,
  ["PAUSE"] = 0x13,
  ["CAPSLOCK"] = 0x14,
  ["ESCAPE"]= 0x1B,
  ["SPACE"] = 0x20,
  ["PGUP"] = 0x21,
  ["PGDOWN"] = 0x22,
  ["END"] = 0x23,
  ["HOME"] = 0x24,
  ["LEFTARROW"] = 0x25,
  ["UPARROW"] = 0x26,
  ["RIGHTARROW"] = 0x27,
  ["DOWNARROW"] = 0x28,
  ["SELECT"] = 0x29,
  ["PRINT"] = 0x2A,
  ["INSERT"] = 0x2D,
  ["DELETE"] = 0x2E,
  ["0"] = 0x30,
  ["1"] = 0x31,
  ["2"] = 0x32,
  ["3"] = 0x33,
  ["4"] = 0x34,
  ["5"] = 0x35,
  ["6"] = 0x36,
  ["7"] = 0x37,
  ["8"] = 0x38,
  ["9"] = 0x39,
  ["A"] = 0x41,
  ["B"] = 0x42,
  ["C"] = 0x43,
  ["D"] = 0x44,
  ["E"] = 0x45,
  ["F"] = 0x46,
  ["G"] = 0x47,
  ["H"] = 0x48,
  ["I"] = 0x49,
  ["J"] = 0x4A,
  ["K"] = 0x4B,
  ["L"] = 0x4C,
  ["M"] = 0x4D,
  ["N"] = 0x4E,
  ["O"] = 0x4F,
  ["P"] = 0x50,
  ["Q"] = 0x51,
  ["R"] = 0x52,
  ["S"] = 0x53,
  ["T"] = 0x54,
  ["U"] = 0x55,
  ["V"] = 0x56,
  ["W"] = 0x57,
  ["X"] = 0x58,
  ["Y"] = 0x59,
  ["Z"] = 0x5A,
  ["NUM0"] = 0x60,
  ["NUM1"] = 0x61,
  ["NUM2"] = 0x62,
  ["NUM3"] = 0x63,
  ["NUM4"] = 0x64,
  ["NUM5"] = 0x65,
  ["NUM6"] = 0x66,
  ["NUM7"] = 0x67,
  ["NUM8"] = 0x68,
  ["NUM9"] = 0x69,
  ["MULTIPLY"] = 0x6A,
  ["ADD"] = 0x6B,
  ["SEPARATOR"] = 0x6C,
  ["SUBTRACT"] = 0x6D,
  ["DECIMAL"] = 0x6E,
  ["DIVIDE"] = 0x6F,
  ["F1"] = 0x70,
  ["F2"] = 0x71,
  ["F3"] = 0x72,
  ["F4"] = 0x73,
  ["F5"] = 0x74,
  ["F6"] = 0x75,
  ["F7"] = 0x76,
  ["F8"] = 0x77,
  ["F9"] = 0x78,
  ["F10"] = 0x79,
  ["F11"] = 0x7A,
  ["F12"] = 0x7B,
}

-- This function "listens" to any key input
-- If there is a Callback function assigned for a certain "HotKey" it will be executed
-- Every class must have a table called "KeyCallbacks" where this function can access to
function Events.KeyListener()
  for k, v in pairs(KeyCallbacks) do
    local KeysToCheck = {strsplit(",", k)}
    local AllPressed  = true
    for i = 1, #KeysToCheck do
      if not GetKeyState(Keys[KeysToCheck[i]]) then
        AllPressed = false
      end
    end

    if AllPressed then
      print("function is being executed")
    end
  end
end
