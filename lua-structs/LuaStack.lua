local LuaStack = {}
LuaStack.__index = LuaStack

function LuaStack:Push(x)
    table.insert(self._data,x)
end

function LuaStack:Pop()
    return table.remove(self._data)
end

function LuaStack:Peek()
    return self._data[#self._data]
end

function LuaStack:Count()
    return #self._data
end

function LuaStack:__tostring()
    local str = "-----\n"
    for i,v in ipairs(self._data) do
        str = string.format("%s%d %s\n", str, i , tostring(v))
    end
    return str .. "-----"
end

function LuaStack.New()
    return setmetatable({_data = {}},LuaStack)
end

function LuaStack.__call()
    return LuaStack.New()
end

return LuaStack