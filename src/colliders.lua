Colliders = {}

Colliders.objects = {}

Colliders.add = function(collider)
	table.insert(
		Colliders.objects,
		collider
	)
end

Colliders.isColliding = function(obj)
    for index, collider in pairs(Colliders.objects) do
        if Colliders.isCollidingWith(obj, collider) then
            return true
        end
    end
    
    return false
end

Colliders.isCollidingWith = function(obj1, obj2)
	return obj1.x + obj1.w / 2 >= obj2.x
        and obj1.x - obj1.w / 2 <= obj2.x + obj2.w
        and obj1.y + obj1.h / 2 >= obj2.y
        and obj1.y <= obj2.y + obj2.h
end

return Colliders
