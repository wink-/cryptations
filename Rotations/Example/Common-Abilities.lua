-- Same as for the Example.lua
-- But notice that you must check for the specID here,
-- since the common abilities is available for the whole class and not only a single spec
local _, _, ClassID = UnitClass("player")

if ClassID ~= 1 then return end
if FireHack == nil then return end

-- Here you can declare common abilities that are availabe to all specs of a class
-- Example: Rogues kick is availabe for every Rogue spec
function EXKick()

end
