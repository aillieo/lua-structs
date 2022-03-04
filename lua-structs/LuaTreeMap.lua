local LuaTreeMap = {}
LuaTreeMap.__index = LuaTreeMap

local RED, BLACK = 1, 0
local defaultComparer = function(x,y)
    return x < y
end

function LuaTreeMap.New(comparer)
    comparer = comparer or defaultComparer
    local NIL = {}
    NIL.color = BLACK
    NIL.left = NIL
    NIL.right = NIL

    return setmetatable({
        _comparer = comparer,
        _count = 0,
        _root = NIL,
        _NIL = NIL,
    }, LuaTreeMap)
end

function LuaTreeMap.__call(comparer)
    return LuaTreeMap.New(comparer)
end

function LuaTreeMap:Add(key, value)
    self:_insert(key, value, true)
end

function LuaTreeMap:Set(key, value)
    self:_insert(key, value, false)
end

function LuaTreeMap:Get(key)
    local node = self:_find(self._root, key)
    if node ~= self._NIL then
        return node.value, true
    end
    return nil, false
end

function LuaTreeMap:HasKey(key)
    local node = self:_find(self._root, key)
    return node ~= self._NIL
end

function LuaTreeMap:Remove(key)
    local removed = self:_remove(self._root, key)
    if removed then
        self._count = self._count - 1
    end
    return removed
end

function LuaTreeMap:Pairs()
    return coroutine.wrap(function()
        local cur = self:_minimum(self._root)
        while cur ~= self._NIL and cur ~= nil do
            coroutine.yield(cur.key, cur.value)
            cur = self:_successor(cur)
        end
    end)
end

function LuaTreeMap:Clear()
    self._root = self._NIL
    self._count = 0
end

function LuaTreeMap:Count()
    return self._count
end

function LuaTreeMap:__tostring()
    local str = "-----\n"
    for key, value in self:Pairs() do
        str = string.format("%s%s %s\n", str, tostring(key), tostring(value))
    end
    return str .. "-----"
end

function LuaTreeMap:_newNode(key, value)
    return {
        key = key,
        value = value,
        parent = self._NIL,
        left = self._NIL,
        right = self._NIL,
        color = RED
    }
end

function LuaTreeMap:_find(node, key)
    if node == self._NIL or key == node.key then
        return node
    end
    if self._comparer(key, node.key) then
        return self:_find(node.left, key)
    end
    return self:_find(node.right, key)
end

function LuaTreeMap:_minimum(node)
    while node.left ~= self._NIL do
        node = node.left
    end
    return node
end

function LuaTreeMap:_maximum(node)
    while node.right ~= self._NIL do
        node = node.right
    end
    return node
end

function LuaTreeMap:_successor(node)
    if node.right ~= self._NIL then
        return self:_minimum(node.right)
    end
    local parent = node.parent
    while parent ~= self._NIL and node == parent.right do
        node = parent
        parent = parent.parent
    end
    return parent
end
function LuaTreeMap:_predecessor(node)
    if (node.left ~= self._NIL) then
        return self:_maximum(node.left)
    end
    local parent = node.parent
    while parent ~= self._NIL and node == parent.left do
        node = parent
        parent = parent.parent
    end
    return parent
end

function LuaTreeMap:_removeFixup(x)
    while x ~= self._root and x.color == BLACK do
        if x == x.parent.left then
            local sibling = x.parent.right
            if sibling.color == RED then
                -- 3.1
                sibling.color = BLACK
                x.parent.color = RED
                self:_leftRotate(x.parent)
                sibling = x.parent.right
            end
            if sibling.left.color == BLACK and sibling.right.color == BLACK then
                -- 3.2
                sibling.color = RED
                x = x.parent
            else
                if sibling.right.color == BLACK then
                    -- 3.3
                    sibling.left.color = BLACK
                    sibling.color = RED
                    self:_rightRotate(sibling)
                    sibling = x.parent.right
                end
                -- 3.4
                sibling.color = x.parent.color
                x.parent.color = BLACK
                sibling.right.color = BLACK
                self:_leftRotate(x.parent)
                x = self._root
            end
        else
            local sibling = x.parent.left
            if sibling.color == RED then
                -- 3.1
                sibling.color = BLACK
                x.parent.color = RED
                self:_rightRotate(x.parent)
                sibling = x.parent.left
            end
            if sibling.left.color == BLACK and sibling.right.color == BLACK then
                -- 3.2
                sibling.color = RED
                x = x.parent
            else
                if sibling.left.color == BLACK then
                    -- 3.3
                    sibling.right.color = BLACK
                    sibling.color = RED
                    self:_leftRotate(sibling)
                    sibling = x.parent.left
                end
                -- 3.4
                sibling.color = x.parent.color
                x.parent.color = BLACK
                sibling.left.color = BLACK
                self:_rightRotate(x.parent)
                x = self._root
            end
        end
    end
    x.color = BLACK
end

function LuaTreeMap:_insertFixup(x)
    while x.parent.color == RED do
        if x.parent == x.parent.parent.right then
            local uncle = x.parent.parent.left
            if uncle.color == RED then
                -- 3.1
                uncle.color = BLACK
                x.parent.color = BLACK
                x.parent.parent.color = RED
                x = x.parent.parent
            else
                if x == x.parent.left then
                    -- 3.2.2
                    x = x.parent
                    self:_rightRotate(x)
                end
                -- 3.2.1
                x.parent.color = BLACK
                x.parent.parent.color = RED
                self:_leftRotate(x.parent.parent)
            end
        else
            local uncle = x.parent.parent.right
            if uncle.color == RED then
                -- 3.1
                uncle.color = BLACK
                x.parent.color = BLACK
                x.parent.parent.color = RED
                x = x.parent.parent
            else
                if x == x.parent.right then
                    -- 3.2.2
                    x = x.parent
                    self:_leftRotate(x)
                end
                -- 3.2.1
                x.parent.color = BLACK
                x.parent.parent.color = RED
                self:_rightRotate(x.parent.parent)
            end
        end
        if x == self._root then
            break
        end
    end
    self._root.color = BLACK
end

function LuaTreeMap:_insert(key, value, errorOnKeyExists)
    local y = self._NIL
    local x = self._root
    while x ~= self._NIL do
        y = x
        if key == x.key then
            if errorOnKeyExists then
                error("key exists: " .. tostring(key))
            else
                x.value = value
                return
            end
        end
        if self._comparer(key, x.key) then
            x = x.left
        else
            x = x.right
        end
    end

    -- 没找到
    local node = self:_newNode(key, value)
    node.parent = y
    if y == self._NIL then
        self._root = node
    elseif self._comparer(node.key, y.key) then
        y.left = node
    else
        y.right = node
    end

    self._count = self._count + 1

    if node.parent == self._NIL then
        node.color = BLACK
        return
    end

    if node.parent.parent == self._NIL then
        return
    end

    self:_insertFixup(node)
end

function LuaTreeMap:_remove(node, key)
    local target = self._NIL
    while node ~= self._NIL do
        if node.key == key then
            target = node
            break
        end
        if self._comparer(node.key, key) then
            node = node.right
        else
            node = node.left
        end
    end
    if target == self._NIL then
        -- 不存在
        return false
    end
    local x = self._NIL
    local y = target
    local y_original_color = y.color
    if target.left == self._NIL then
        x = target.right
        self:_transplant(target, target.right)
    elseif (target.right == self._NIL) then
        x = target.left
        self:_transplant(target, target.left)
    else
        y = self:_minimum(target.right)
        y_original_color = y.color
        x = y.right
        if y.parent == target then
            x.parent = y
        else
            self:_transplant(y, y.right)
            y.right = target.right
            y.right.parent = y
        end
        self:_transplant(target, y)
        y.left = target.left
        y.left.parent = y
        y.color = target.color
    end
    if y_original_color == BLACK then
        self:_removeFixup(x)
    end
    return true
end

function LuaTreeMap:_transplant(u, v)
    if u.parent == self._NIL then
        self._root = v
    elseif u == u.parent.left then
        u.parent.left = v
    else
        u.parent.right = v
    end
    v.parent = u.parent
end

function LuaTreeMap:_leftRotate(node)
    local y = node.right
    node.right = y.left
    if y.left ~= self._NIL then
        y.left.parent = node
    end
    y.parent = node.parent
    if node.parent == self._NIL then
        self._root = y
    elseif node == node.parent.left then
        node.parent.left = y
    else
        node.parent.right = y
    end
    y.left = node
    node.parent = y
end

function LuaTreeMap:_rightRotate(node)
    local y = node.left
    node.left = y.right
    if y.right ~= self._NIL then
        y.right.parent = node
    end
    y.parent = node.parent
    if node.parent == self._NIL then
        self._root = y
    elseif node == node.parent.right then
        node.parent.right = y
    else
        node.parent.left = y
    end
    y.right = node
    node.parent = y
end

return LuaTreeMap
