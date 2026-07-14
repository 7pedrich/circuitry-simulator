local CircuitLogic = {}
CircuitLogic.__index = CircuitLogic

function CircuitLogic.AND(a: boolean, b: boolean)
    return (a and b)
end

function CircuitLogic.NAND(a: boolean, b: boolean)
    return not (a and b)
end

function CircuitLogic.NOT(a: boolean)
    return not a
end

function CircuitLogic.OR(a: boolean, b: boolean)
    return a or b
end

function CircuitLogic.XOR(a: boolean, b: boolean)
    return a ~= b
end

function CircuitLogic.NOR(a: boolean, b: boolean)
    return (not a and not b)
end


return CircuitLogic