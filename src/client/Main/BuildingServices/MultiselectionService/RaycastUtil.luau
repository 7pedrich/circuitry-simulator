local RaycastUtil = {}
RaycastUtil.__index = RaycastUtil

function RaycastUtil.pointInRect(point, min, max)
	return point.X >= min.X and point.X <= max.X and point.Y >= min.Y and point.Y <= max.Y
end

return RaycastUtil
