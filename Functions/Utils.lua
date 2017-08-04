local Utils = LibStub("Utils")

-- returns the distance between x1,y1,z1 and x2,y2,z2
function Utils.GetDistanceBetweenPositions(x1, y1, z1, x2, y2, z2)
  return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2));
end

-- returns the z coordinate that is just above the ground at given position
function Utils.FindGroundAt(x, y, z)
  local hx, hy, hz = TraceLine(x, y, z, x, y, (z - 100), bit.bor(0x10, 0x20, 0x100))
  return hx, hy, hz
end

-- returns the x, y, z coordinates of the best spot to cast an aoe on
-- maxDistance: maximum distance from player
-- radius: radius of effect of the spell
function Utils.FindBestAoESpot(maxDistance, radius)
  -- TODO
end

-- http://wowwiki.wikia.com/wiki/Wait
local waitTable = {};
local waitFrame = nil;
function Utils.Wait(delay, func, ...)
   if(type(delay)~="number" or type(func)~="function") then
      return false;
   end
   if(waitFrame == nil) then
      waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
      waitFrame:SetScript("onUpdate",function (self,elapse)
            local count = #waitTable;
            local i = 1;
            while(i<=count) do
               local waitRecord = tremove(waitTable,i);
               local d = tremove(waitRecord,1);
               local f = tremove(waitRecord,1);
               local p = tremove(waitRecord,1);
               if(d>elapse) then
                  tinsert(waitTable,i,{d-elapse,f,p});
                  i = i + 1;
               else
                  count = count - 1;
                  f(unpack(p));
               end
            end
      end);
   end
   tinsert(waitTable,{delay,func,{...}});
   return true;
end
