local LuaList = {}
LuaList.__index = LuaList

function LuaList:_newNode(v)
    return {value = v, _prev = 0, _next = 0, _list = self}
end

function LuaList:Clear()
    self._next = self
    self._prev = self
    self._length = 0
end

function LuaList:_nextNode(node)
    if node == self then
        return nil
    end
    return node._next
end

function LuaList:_prevNode(node)
    if node == self then
        return nil
    end
    return node._prev
end

function LuaList:First()
    return self._next
end

function LuaList:Last()
    return self._prev
end

function LuaList:Count()
    return self._length
end

function LuaList:AddLast(value)
    local node = self:_newNode(value)

    self._prev._next = node
    node._next = self
    node._prev = self._prev
    self._prev = node

    self._length = self._length + 1
    return node
end

function LuaList:AddNodeLast(node)
    if node._list ~= nil then
        error("invalid node")
        return
    end

    self._prev._next = node
    node._next = self
    node._prev = self._prev
    self._prev = node

    node._list = self
    self._length = self._length + 1
end

function LuaList:AddFirst(value)
    local node = self:_newNode(value)

    self._next._prev = node
    node._prev = self
    node._next = self._next
    self._next = node

    self._length = self._length + 1
    return node
end

function LuaList:AddNodeFirst(node)
    if node._list ~= nil then
        error("invalid node")
        return
    end

    self._next._prev = node
    node._prev = self
    node._next = self._next
    self._next = node

    node._list = self
    self._length = self._length + 1
end

function LuaList:Remove(value)
    local node = self:Find(value)
    if node then
        self:RemoveNode(node)
        return node
    end
    return nil
end

function LuaList:RemoveNode(node)
    if node._list ~= self then
        error("node not in list")
        return
    end

    local _prev = node._prev
    local _next = node._next
    _next._prev = _prev
    _prev._next = _next

    node._list = nil
    self._length = self._length - 1
end

function LuaList:RemoveFirst()
    local _next = self._next
    self:RemoveNode(_next)
    return _next.value
end

function LuaList:RemoveLast()
    local _prev = self._prev
    self:RemoveNode(_prev)
    return _prev.value
end

function LuaList:Find(value)
    local node = self:First()
    while node do
        if value == node.value then
            return node
        end
        node = self:_nextNode(node)
    end

    return nil
end

function LuaList:FindLast(value)
    local node = self:Last()
    while node do
        if value == node.value then
            return node
        end
        node = self:_prevNode(node)
    end
    return nil
end

function LuaList:AddAfter(node,value)
    local newNode = self:_newNode(value)

    if node._next then
        node._next._prev = newNode
        newNode._next = node._next
    else
        self.last = newNode
    end

    newNode._prev = node
    node._next = newNode
    self._length = self._length + 1
    return newNode
end

function LuaList:AddBefore(node,value)
    local newNode = self:_newNode(value)

    if node._prev then
        node._prev._next = newNode
        newNode._prev = node._prev
    else
        self.prev = newNode
    end

    newNode._next = node
    node._prev = newNode
    self._length = self._length + 1
    return newNode
end

function LuaList:__tostring()
    local str = "-----\n"
    local node = self._next
    local i = 1
    while node ~= self do
        str = string.format("%s%d %s\n", str , i, tostring(node.value))
        node = node._next
        i = i + 1
    end
    return str .. "-----"
end

function LuaList.New()
    local t = {_length = 0, _prev = 0, _next = 0}
    t._prev = t
    t._next = t
    return setmetatable(t, LuaList)
end

function LuaList.__call()
    return LuaList.New()
end

return LuaList
