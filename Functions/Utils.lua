local Utils = LibStub("Utils")

-- returns the distance between x1,y1,z1 and x2,y2,z2
function Utils.GetDistanceBetweenPositions(x1, y1, z1, x2, y2, z2)
  return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2));
end

-- returns the z coordinate of the ground at position x, y
function Utils.FindGroundAtPosition(x, y)
  -- TODO
end
