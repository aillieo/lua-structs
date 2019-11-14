local LuaQueue = {}
LuaQueue.__index = LuaQueue


function LuaQueue:Enque(x)
    self._data[self._tail] = x
    self._tail = self._tail + 1
end

function LuaQueue:Deque()
    local count = self:Count()
    if count > 0 then
        local obj = self._data[self._head]
        self._data[self._head] = nil
        self._head = self._head + 1
        if count == 1 then
            self._head, self._tail = 1, 1
        end
        return obj
    end
end

function LuaQueue:Count()
    return self._tail - self._head
end

function LuaQueue:Clear()
    self._data = {}
    self._head, self._tail = 1, 1
end

function LuaQueue:__tostring()
    local str = "-----\n"
    for i = self._head, self._tail - 1 do
        str = string.format("%s%d %s\n", str, i - self._head + 1, tostring(self._data[i]))
    end
    return str .. "-----"
end

function LuaQueue.New()
    return setmetatable({_data = {}, _head = 1, _tail = 1}, LuaQueue)
end

function LuaQueue.__call()
    return LuaQueue.New()
end

return LuaQueue
