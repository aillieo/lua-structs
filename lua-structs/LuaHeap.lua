local LuaHeap = {}
LuaHeap.__index = LuaHeap

local defaultComparer = function(x,y)
    return x < y
end

function LuaHeap:Clear()
    self._data = {}
end

function LuaHeap:Pop()
    local node = self._data[1]
    if node then
        local count = #self._data
        self._data[1] = self._data[count]
        self._data[count] = nil
        if self:Count() > 0 then
            self:_siftDown(1)
        end
        return node
    end
    return nil
end

function LuaHeap:Top()
    return self._data[1]
end

function LuaHeap:Push(value)
    local count = #self._data
    self._data[count + 1] = value
    self:_siftUp(count + 1)
end

function LuaHeap:Count()
    return #self._data
end

function LuaHeap:_siftUp(index)
    local parent = math.floor(index / 2)
    if self._data[parent] and self._comparer(self._data[index], self._data[parent]) then
        self._data[parent], self._data[index] = self._data[index], self._data[parent]
        return self:_siftUp(parent)
    end
end

function LuaHeap:_siftDown(index)
    local current  = index
    local left  = 2 * index
    local right = 2 * index + 1
    if self._data[left] and self._comparer(self._data[left], self._data[current]) then
        current = left
    end
    if self._data[right] and self._comparer(self._data[right], self._data[current]) then
        current = right
    end
    if current ~= index then
        self._data[index], self._data[current] = self._data[current], self._data[index]
        return self:_siftDown(current)
    end
end

-- 找到第一个匹配的值 并删除 然后保持heap
function LuaHeap:FindAndRemove(value)
    for i,v in ipairs(self._data) do
        if v == value then
            table.remove(self._data,i)
            if self:Count() > 0 then
                self:_siftDown(i)
            end
            return true
        end
    end
    return false
end

function LuaHeap.New(comparer)
    comparer = comparer or defaultComparer
    return setmetatable({
        _data = {},
        _comparer = comparer
    },LuaHeap)
end

function LuaHeap.__call(comparer)
    return LuaHeap.New(comparer)
end

return LuaHeap
