local WorldUtil = {}

function WorldUtil.Distance(pA: Vector3, pB: Vector3)
    return (pA - pB).Magnitude
end

return WorldUtil