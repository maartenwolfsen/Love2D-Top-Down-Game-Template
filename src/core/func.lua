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

Func.moveForward = function(transform, speed, ignoreCollision)
    if ignoreCollision == nil then
        ignoreCollision = false
    end

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

    if ignoreCollision then
        transform = newTransform

        return newTransform
    end

    local newTransformX, newTransformY = {
        x = newTransform.x,
        y = transform.y,
        w = newTransform.w,
        h = newTransform.h,
        r = newTransform.r
    }, {
        x = transform.x,
        y = newTransform.y,
        w = newTransform.w,
        h = newTransform.h,
        r = newTransform.r
    }

    if Colliders.isColliding(newTransformX) then
        newTransform.x = transform.x
    elseif Colliders.isColliding(newTransformY) then
        newTransform.y = transform.y
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
