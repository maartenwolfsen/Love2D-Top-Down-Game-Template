Func = {}

Func.getTableLength = function(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    
    return count
end

Func.getAngleOfTwoPoints = function(t1, t2)
    return math.atan2(
        t1.x - t2.x,
        t1.y - t2.y
    )
end

Func.moveForward = function(transform, speed)
    local newTransform = {
        x = transform.x
            + -math.sin(transform.r)
            * speed,
        y = transform.y
            + -math.cos(transform.r)
            * speed,
        w = transform.w,
        h = transform.h,
        r = transform.r
    }

    if Colliders.isColliding(newTransform) then
        return transform
    end

    transform = newTransform

    return transform
end

Func.screenToWorldTransform = function(transform)
    transform.x = Camera.offset.x + transform.x
    transform.y = Camera.offset.y + transform.y

    return transform
end

return Func
