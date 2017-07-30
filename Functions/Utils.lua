local Utils = LibStub("Utils")

-- returns the distance between x1,y1,z1 and x2,y2,z2
function Utils.GetDistanceBetweenPositions(x1, y1, z1, x2, y2, z2)
  return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2));
end

-- returns the z coordinate that is just above the ground at given position
function Utils.FindGroundAt(x, y, z)
  local hx, hy, hz = TraceLine(x, y, z, x, y, z - 100, {0x100, 0x10, 0x20})
  return hx, hy, hz
end

-- returns the x, y, z coordinates of the best spot to cast an aoe on
-- maxDistance: maximum distance from player
-- radius: radius of effect of the spell
function Utils.FindBestAoESpot(maxDistance, radius)
  -- TODO
end
