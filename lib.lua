--[[
-- ============================================================================
--                          BYPASS EXECUTION (COMMENTED OUT)
-- ============================================================================
-- NOTE: Always use remote URL loading - do not use local files

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart

if not LPH_OBFUSCATED then
    LPH_JIT = function(f, ...)
    	assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
    	return f
	end
	LPH_JIT_MAX = LPH_JIT

	LPH_NO_VIRTUALIZE = function(f, ...)
    	assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
    	return f
	end

	LPH_NO_UPVALUES = function(f, ...)
    	assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
    	assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
    	return f
	end

	LPH_CRASH = function(...)
    	assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
	end
end

local HttpService   = (cloneref or function(x) return x end)(game:GetService("HttpService"))
local Players       = (cloneref or function(x) return x end)(game:GetService("Players"))
local CoreGui       = (cloneref or function(x) return x end)(game:GetService("CoreGui"))
local LocalPlayer   = Players.LocalPlayer

getgenv().Kick = function(Msg, Title)
    LocalPlayer:Kick()
    task.wait(.75)
    CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = Msg or "Create a ticket"
    CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = "Vision.wtf - " .. (Title or "Rejoin")
    return
end

if not (game.ReplicatedStorage:FindFirstChild("Modules") and game.ReplicatedStorage.Modules:FindFirstChild("AssetContainer")) then getgenv().Kick("Execute In Fallen", "Error") end

if getgenv().BypassLoaded then
    return getgenv().Kick("Script Already Loaded", "Rejoin")
end

task.spawn(LPH_NO_VIRTUALIZE(function()  
    local startTime = os.time()
    while task.wait(1) do
        local elapsed = os.time() - startTime

        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60

        local timeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)

        if getgenv().DebugMode then
            rconsolesettitle(" Bypass - " .. timeStr)
        end
    end
end))

if getgenv().DebugMode then
    rconsoleclear(); task.wait(3); rconsoleprint("\n"); rconsoleprint('@@WHITE@@')
end

getgenv().real_print = (clonefunction or function(f) return f end)(print)
getgenv().real_warn = (clonefunction or function(f) return f end)(warn)

if getgenv().DebugMode then
    getgenv().print = LPH_JIT_MAX(function(...)
        local args = table.pack(...)
        local out = ""

        for i = 1, args.n do
            out = out .. tostring(args[i])

            if i < args.n then
                out = out .. "\t"
            end
        end

        local timeStr = os.date("%H:%M:%S")

        task.spawn(function() 
            rconsoleprint('@@WHITE@@'); rconsoleprint("        [" .. timeStr .. "] " .. out .. "\n")
        end)
    end)

    getgenv().warn = LPH_JIT_MAX(function(...)
        local args = table.pack(...)
        local out = ""

        for i = 1, args.n do
            out = out .. tostring(args[i])

            if i < args.n then
                out = out .. "\t"
            end
        end

        local timeStr = os.date("%H:%M:%S")
        
        task.spawn(function()
            rconsolewarn("        [" .. timeStr .. "] " .. out .. "\n")
        end)
    end)
end

local DebugPrint = LPH_JIT_MAX(function(...)
    if not getgenv().DebugMode then return end
    
    return getgenv().print(...)
end)

local DebugWarn = LPH_JIT_MAX(function(...)
    if not getgenv().DebugMode then return end

    return getgenv().warn(...)
end)

local AAA = LPH_JIT_MAX(function()
    -- Verify required functions exist
    if not getgc or not isexecutorclosure or not getinfo or not getprotos or not getproto or not getconstants or not getupvalues or not hookfunction then
        error("Missing required executor functions for bypass")
        return
    end
    
    for _, Obj in getgc(false) do
        if typeof(Obj) == "function" 
        and not isexecutorclosure(Obj) then
            local Info = getinfo(Obj)

            if Info.short_src:find("AssetContainer") then
                if Info.numparams == 1 then
                    local Protos = getprotos(Obj)

                    if #Protos == 0 then continue end
                    local Proto = getproto(Obj, 1, true)
                    if #Proto == 0 then continue end

                    --warn(Proto)
                    for _, ProtoFunc in Proto do
                        local Constants = getconstants(ProtoFunc)
                        local Upvalues = getupvalues(ProtoFunc)

                        if #Constants == 23 then
                            local Old; Old = hookfunction(ProtoFunc, LPH_NO_UPVALUES(function(...) 
                                local Args = {...}
                                local A1

                                local CurrentFov = workspace.CurrentCamera.FieldOfView

                                if #Args == 1 then
                                    A1 = Args[1]

                                    if typeof(A1) == "table" then
                                        DebugPrint("Before Cleaning ->", HttpService:JSONEncode(A1))

                                        for Ind, Val in A1 do
                                            if typeof(Val) == "table" then
                                                for Jew = #Args[1], Ind, -1 do
                                                    Args[1][Jew] = nil
                                                end

                                                break
                                            end
                                        end

                                        DebugPrint("After Cleaning ->", HttpService:JSONEncode(A1))
                                    else
                                        DebugPrint("Args 1 ->", A1)
                                    end
                                else
                                    DebugPrint("Args Count ->", #Args)
                                    DebugPrint("Args ->", HttpService:JSONEncode(Args))
                                end

                                return Old(...)
                            end))
                        elseif #Constants == 9 and #Upvalues == 3 then
                            hookfunction(ProtoFunc, LPH_NO_UPVALUES(function(...) 
                                --DebugWarn("Blocked attribute detection ->", ...)
                                return 
                            end))
                        else
                            local One; One = hookfunction(ProtoFunc, LPH_NO_UPVALUES(function(...) 
                                local Args = {...}
                                local A1 = Args[1]

                                if typeof(A1) ~= "Instance" then
                                    if A1 == "" then
                                        DebugWarn("Blocked empty string")
                                        return
                                    end

                                    if typeof(A1) == "table" then
                                        local Decoded = HttpService:JSONEncode(A1)

                                        if not tostring(Decoded):find("{") 
                                        and not tostring(Decoded):find("-") 
                                        and #A1 ~= 2 then
                                            --DebugPrint("Decoded (1) ->", Decoded)
                                        end
                                    else
                                        if #Args == 0 then
                                            DebugWarn("Blocked zero arg call")
                                            return
                                        else
                                            for _, Arg in Args do
                                                if typeof(Arg) == "function" then
                                                    DebugWarn("Blocked detection ->", ...)
                                                    return
                                                end
                                            end

                                            DebugPrint("Other (1) ->", ...)
                                            DebugPrint("Other (1) Args Count ->", #Args)
                                        end
                                    end
                                end

                                return One(...)
                            end))
                        end
                    end 
                end
            end
        end
    end
end)

-- Execute bypass and verify it loaded successfully
local bypass_success, bypass_error = pcall(function()
    AAA()
end)

if not bypass_success then
    if game:GetService("Players").LocalPlayer then
        game:GetService("Players").LocalPlayer:Kick("Bypass failed to execute: " .. tostring(bypass_error))
    end
    return
end

getgenv().BypassLoaded = true
local successCode = tostring(math.random(100000, 999999))
print("Vision Bypass Loaded - Code: " .. successCode)

-- Wait to ensure the success code is printed to console before continuing
task.wait(0.5)

-- ============================================================================
--                      END BYPASS - SCRIPT CONTINUES
-- ============================================================================
-- ============================================================================
--              MADIUM (LEVEL 8 EXECUTOR) COMPATIBILITY LAYER
-- ============================================================================

local function make_safe(func, default_fallback)
    if type(func) == "function" then
        return function(...)
            local success, result = pcall(func, ...)
            if success then
                return result
            else
                return typeof(default_fallback) == "function" and default_fallback(...) or default_fallback
            end
        end
    end
    return function(...)
        return typeof(default_fallback) == "function" and default_fallback(...) or default_fallback
    end
end
-- 1. ENVIRONMENT GLOBALS & ALIASES
local genv = getgenv and getgenv() or _G

-- Undetected Pristine File System Capture (Runs BEFORE any stubbing to ensure safe config execution)
local clone = genv.clonefunction or clonefunction or function(f) return f end
local safe_fs = {
    writefile = clone(genv.writefile or writefile),
    readfile = clone(genv.readfile or readfile),
    isfile = clone(genv.isfile or isfile),
    isfolder = clone(genv.isfolder or isfolder),
    makefolder = clone(genv.makefolder or makefolder),
    listfiles = clone(genv.listfiles or listfiles),
    delfile = clone(genv.delfile or delfile)
}


local function safe_assign(tbl, key, value)
    local exists = false
    pcall(function()
        if tbl[key] ~= nil then
            exists = true
        end
    end)
    if exists then return end
    
    local setreadonly = setreadonly or make_writeable or (syn and syn.set_readonly)
    local isreadonly = isreadonly or (syn and syn.is_readonly)
    local was_readonly = false
    if isreadonly then
        local ok, res = pcall(isreadonly, tbl)
        if ok then was_readonly = res end
    else
        was_readonly = true
    end
    
    if setreadonly then
        pcall(setreadonly, tbl, false)
    end
    pcall(function() tbl[key] = value end)
    if setreadonly and was_readonly then
        pcall(setreadonly, tbl, true)
    end
end

-- 2. TABLE LIBRARY EXTENSIONS
local tbl = table
safe_assign(tbl, "freeze", function(t) return t end)
safe_assign(tbl, "isfrozen", function(t) return false end)
safe_assign(tbl, "clone", function(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end)
safe_assign(tbl, "clear", function(t)
    for k in pairs(t) do t[k] = nil end
end)
safe_assign(tbl, "find", function(t, val, start)
    for i = (start or 1), #t do
        if t[i] == val then return i end
    end
    return nil
end)
safe_assign(tbl, "move", function(a1, f, e, t, a2)
    a2 = a2 or a1
    local d = t - f
    if a2 == a1 and t > f and t <= e then
        for i = e, f, -1 do
            a2[i + d] = a1[i]
        end
    else
        for i = f, e do
            a2[i + d] = a1[i]
        end
    end
    return a2
end)
safe_assign(tbl, "pack", function(...)
    return {n = select("#", ...), ...}
end)
safe_assign(tbl, "unpack", unpack)

-- 3. COROUTINE & TASK LIBRARIES
local corout = coroutine
safe_assign(corout, "running", function() return nil end)
safe_assign(corout, "status", function() return "dead" end)
safe_assign(corout, "wrap", function(f) return function(...) return corout.resume(corout.create(f), ...) end end)
safe_assign(corout, "yield", function(...) end)
safe_assign(corout, "resume", function(co, ...) return true, ... end)

local tsk = task or {}
safe_assign(tsk, "spawn", function(f, ...)
    local co = coroutine.create(f)
    return coroutine.resume(co, ...)
end)
safe_assign(tsk, "defer", tsk.spawn)
safe_assign(tsk, "synchronize", function() end)
safe_assign(tsk, "desynchronize", function() end)

-- 4. STRING LIBRARY EXTENSIONS
local str = string
safe_assign(str, "split", function(s, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep or ",")
    s:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end)
safe_assign(str, "trim", function(s)
    return s:match("^%s*(.-)%s*$")
end)
safe_assign(str, "byte_multi", function(s, i, j)
    return {s:byte(i, j)}
end)
safe_assign(str, "format_extended", function(fmt, ...)
    return str.format(fmt, ...)
end)
safe_assign(str, "gmatch_captures", function(s, pattern)
    return s:gmatch(pattern)
end)
safe_assign(str, "gsub_fn", function(s, pattern, fn)
    return s:gsub(pattern, fn)
end)

-- 5. CACHE API
genv.cache = genv.cache or {}
safe_assign(genv.cache, "invalidate", make_safe(genv.cache.invalidate, function() end))
safe_assign(genv.cache, "iscached", make_safe(genv.cache.iscached, function() return false end))
safe_assign(genv.cache, "replace", make_safe(genv.cache.replace, function() end))
genv.cloneref = make_safe(genv.cloneref, function(r) return r end)
genv.compareinstances = make_safe(genv.compareinstances, function(a, b) return a == b end)

-- 6. CLOSURES API
-- CRITICAL: checkcaller and hookfunction must work properly for silent aim
if not genv.checkcaller then
    genv.checkcaller = function() return false end
else
    -- Keep the real checkcaller
end
genv.clonefunction = make_safe(genv.clonefunction, function(f) return f end)
genv.getcallingscript = make_safe(genv.getcallingscript, function() return nil end)
genv.getscriptclosure = make_safe(genv.getscriptclosure, function(s) return function() end end)
genv.iscclosure = make_safe(genv.iscclosure, function(f) return type(f) == "function" end)
genv.islclosure = make_safe(genv.islclosure, function(f) return type(f) == "function" end)
genv.isexecutorclosure = make_safe(genv.isexecutorclosure, function(f) return false end)
genv.loadstring = make_safe(genv.loadstring, function(s) return function() end end)
genv.newcclosure = make_safe(genv.newcclosure, function(f) return f end)

-- CRITICAL: hookfunction must work properly - don't wrap it in error handling
if not genv.hookfunction then
    genv.hookfunction = function(f, h) return f end
else
    -- Keep the real hookfunction without pcall wrapper
end

-- 7. CONSOLE API
genv.rconsoleclear = make_safe(genv.rconsoleclear, function() end)
genv.rconsolecreate = make_safe(genv.rconsolecreate, function() end)
genv.rconsoledestroy = make_safe(genv.rconsoledestroy, function() end)
genv.rconsoleinput = make_safe(genv.rconsoleinput, function() return "" end)
genv.rconsoleprint = make_safe(genv.rconsoleprint, function() end)
genv.rconsolesettitle = make_safe(genv.rconsolesettitle, function() end)

-- 8. CRYPT API
genv.crypt = genv.crypt or {}
safe_assign(genv.crypt, "base64encode", make_safe(genv.crypt.base64encode, function(s) return s end))
safe_assign(genv.crypt, "base64decode", make_safe(genv.crypt.base64decode, function(s) return s end))
safe_assign(genv.crypt, "encrypt", make_safe(genv.crypt.encrypt, function(s, k) return s end))
safe_assign(genv.crypt, "decrypt", make_safe(genv.crypt.decrypt, function(s, k) return s end))
safe_assign(genv.crypt, "generatebytes", make_safe(genv.crypt.generatebytes, function(n) return "" end))
safe_assign(genv.crypt, "generatekey", make_safe(genv.crypt.generatekey, function() return "" end))
safe_assign(genv.crypt, "hash", make_safe(genv.crypt.hash, function(s) return s end))
safe_assign(genv.crypt, "hmac", make_safe(genv.crypt.hmac, function(s, k) return s end))
safe_assign(genv.crypt, "random", make_safe(genv.crypt.random, function(n) return 0 end))

-- 9. DEBUG API
-- CRITICAL: Do NOT stub debug functions - they are required for silent aim
-- Only provide fallbacks if they don't exist
local dbg = debug
if not dbg.getconstant then
    safe_assign(dbg, "getconstant", function(f, i) return nil end)
else
    safe_assign(dbg, "getconstant", dbg.getconstant)
end
if not dbg.getconstants then
    safe_assign(dbg, "getconstants", function(f) return {} end)
else
    safe_assign(dbg, "getconstants", dbg.getconstants)
end
if not dbg.getinfo then
    safe_assign(dbg, "getinfo", function(f) return {short_src = "stub", numparams = 0} end)
else
    safe_assign(dbg, "getinfo", dbg.getinfo)
end
if not dbg.getproto then
    safe_assign(dbg, "getproto", function(f, i, activated) return function() end end)
else
    safe_assign(dbg, "getproto", dbg.getproto)
end
if not dbg.getprotos then
    safe_assign(dbg, "getprotos", function(f) return {} end)
else
    safe_assign(dbg, "getprotos", dbg.getprotos)
end
if not dbg.getstack then
    safe_assign(dbg, "getstack", function(l) return {} end)
else
    safe_assign(dbg, "getstack", dbg.getstack)
end
if not dbg.getupvalue then
    safe_assign(dbg, "getupvalue", function(f, i) return nil end)
else
    safe_assign(dbg, "getupvalue", dbg.getupvalue)
end
if not dbg.getupvalues then
    safe_assign(dbg, "getupvalues", function(f) return {} end)
else
    safe_assign(dbg, "getupvalues", dbg.getupvalues)
end
if not dbg.setconstant then
    safe_assign(dbg, "setconstant", function(f, i, val) end)
else
    safe_assign(dbg, "setconstant", dbg.setconstant)
end
if not dbg.setstack then
    safe_assign(dbg, "setstack", function(l, i, val) end)
else
    safe_assign(dbg, "setstack", dbg.setstack)
end
if not dbg.setupvalue then
    safe_assign(dbg, "setupvalue", function(f, i, val) end)
else
    safe_assign(dbg, "setupvalue", dbg.setupvalue)
end

-- 10. FILESYSTEM API
genv.readfile = make_safe(genv.readfile, function(p) return "" end)
genv.writefile = make_safe(genv.writefile, function(p, c) end)
genv.appendfile = make_safe(genv.appendfile, function(p, c) end)
genv.makefolder = make_safe(genv.makefolder, function(p) end)
genv.listfiles = make_safe(genv.listfiles, function(p) return {} end)
genv.isfile = make_safe(genv.isfile, function(p) return false end)
genv.isfolder = make_safe(genv.isfolder, function(p) return false end)
genv.delfolder = make_safe(genv.delfolder, function(p) end)
genv.delfile = make_safe(genv.delfile, function(p) end)
genv.loadfile = make_safe(genv.loadfile, function(p) return function() end end)
genv.dofile = make_safe(genv.dofile, function(p) end)
genv.getcustomasset = make_safe(genv.getcustomasset, function(p) return "" end)

-- 11. INPUT API
genv.isrbxactive = make_safe(genv.isrbxactive, function() return true end)
genv.mouse1click = make_safe(genv.mouse1click, function() end)
genv.mouse1press = make_safe(genv.mouse1press, function() end)
genv.mouse1release = make_safe(genv.mouse1release, function() end)
genv.mouse2click = make_safe(genv.mouse2click, function() end)
genv.mouse2press = make_safe(genv.mouse2press, function() end)
genv.mouse2release = make_safe(genv.mouse2release, function() end)
genv.mousemoveabs = make_safe(genv.mousemoveabs, function(x, y) end)
genv.mousemoverel = make_safe(genv.mousemoverel, function(x, y) end)
genv.mousescroll = make_safe(genv.mousescroll, function(d) end)

-- 12. INSTANCES API
genv.fireclickdetector = make_safe(genv.fireclickdetector, function() end)
genv.getcallbackvalue = make_safe(genv.getcallbackvalue, function() return nil end)
genv.getconnections = make_safe(genv.getconnections, function(ev) return {} end)
genv.gethiddenproperty = make_safe(genv.gethiddenproperty, function(o, p) return nil, false end)
genv.sethiddenproperty = make_safe(genv.sethiddenproperty, function(o, p, v) return false end)
genv.gethui = make_safe(genv.gethui, function() return game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)
genv.getinstances = make_safe(genv.getinstances, function() return {} end)
genv.getnilinstances = make_safe(genv.getnilinstances, function() return {} end)
genv.isscriptable = make_safe(genv.isscriptable, function(o, p) return true end)
genv.setscriptable = make_safe(genv.setscriptable, function(o, p, b) return true end)
genv.setrbxclipboard = make_safe(genv.setrbxclipboard, function(s) end)
genv.fireproximityprompt = make_safe(genv.fireproximityprompt, function() end)
genv.firetouchinterest = make_safe(genv.firetouchinterest, function() end)

-- 13. METATABLE API
-- CRITICAL: Do NOT stub these functions - they are required for silent aim hooks
-- Only provide fallbacks if they don't exist
if not genv.getrawmetatable then
    genv.getrawmetatable = function(t) return getmetatable(t) end
end
if not genv.hookmetamethod then
    genv.hookmetamethod = function(t, m, f) 
        local mt = getrawmetatable(t)
        if mt then
            local old = mt[m]
            mt[m] = f
            return old
        end
        return f
    end
end
if not genv.getnamecallmethod then
    genv.getnamecallmethod = function() return "" end
end
if not genv.isreadonly then
    genv.isreadonly = function(t) return false end
end
if not genv.setrawmetatable then
    genv.setrawmetatable = function(t, mt) return setmetatable(t, mt) end
end
if not genv.setreadonly then
    genv.setreadonly = function(t, b) end
end

-- 14. MISC API
genv.identifyexecutor = make_safe(genv.identifyexecutor, function() return "Madium", "8.0" end)
genv.lz4compress = make_safe(genv.lz4compress, function(s) return s end)
genv.lz4decompress = make_safe(genv.lz4decompress, function(s) return s end)
genv.messagebox = make_safe(genv.messagebox, function(t, c, ty) return 0 end)
genv.queue_on_teleport = make_safe(genv.queue_on_teleport, function(s) end)
genv.request = make_safe(genv.request, function(t) return {StatusCode = 200, Body = "{}"} end)
genv.setclipboard = make_safe(genv.setclipboard, function(s) end)
genv.setfpscap = make_safe(genv.setfpscap, function(f) end)

-- 15. SCRIPTS API
genv.getgc = make_safe(genv.getgc, function(include_tables) return {} end)
genv.getgenv = function() return genv end
genv.getloadedmodules = make_safe(genv.getloadedmodules, function() return {} end)
genv.getrenv = make_safe(genv.getrenv, function() return _G end)
genv.getrunningscripts = make_safe(genv.getrunningscripts, function() return {} end)
genv.getscriptbytecode = make_safe(genv.getscriptbytecode, function(s) return "" end)
genv.getscripthash = make_safe(genv.getscripthash, function(s) return "" end)
genv.getscripts = make_safe(genv.getscripts, function() return {} end)
genv.getsenv = make_safe(genv.getsenv, function(s) return {} end)
genv.getthreadidentity = make_safe(genv.getthreadidentity, function() return 8 end)
genv.setthreadidentity = make_safe(genv.setthreadidentity, function(n) end)

-- 16. DRAWING API
genv.Drawing = genv.Drawing or {}
safe_assign(genv.Drawing, "Fonts", genv.Drawing.Fonts or {UI = 0, System = 1, Monospace = 2})
safe_assign(genv.Drawing, "new", make_safe(genv.Drawing.new, function(ty)
    return setmetatable({}, {
        __index = function(self, k)
            return function() end
        end,
        __newindex = function(self, k, v) end
    })
end))
genv.isrenderobj = make_safe(genv.isrenderobj, function(o) return false end)
genv.getrenderproperty = make_safe(genv.getrenderproperty, function(o, p) return nil end)
genv.setrenderproperty = make_safe(genv.setrenderproperty, function(o, p, v) end)
genv.cleardrawcache = make_safe(genv.cleardrawcache, function() end)

-- 17. WEBSOCKET API
genv.WebSocket = genv.WebSocket or {}
safe_assign(genv.WebSocket, "connect", make_safe(genv.WebSocket.connect, function(u)
    return setmetatable({}, {
        __index = function(self, k)
            if k == "Send" then return function(self, data) end end
            if k == "Close" then return function(self) end end
            if k == "OnMessage" or k == "OnClose" then
                return setmetatable({}, {
                    __index = function(s, key)
                        if key == "Connect" then return function(s, fn) end end
                    end
                })
            end
        end
    })
end))
safe_assign(genv.WebSocket, "wss", genv.WebSocket.wss or genv.WebSocket.connect)

-- 18. SYN / MORE COMPATIBILITY
genv.syn = genv.syn or {}
safe_assign(genv.syn, "protect_gui", make_safe(genv.syn.protect_gui, function(g) end))
safe_assign(genv.syn, "queue_on_teleport", make_safe(genv.syn.queue_on_teleport, function(s) end))
genv.getmenv = make_safe(genv.getmenv, function(s) return {} end)
genv.hookfunction_restore = make_safe(genv.hookfunction_restore, function(f) end)
genv.checkcaller_scope = make_safe(genv.checkcaller_scope, function() return 8 end)

-- 19. ACTORS API
genv.getactors = make_safe(genv.getactors, function() return {} end)
genv.run_on_actor = make_safe(genv.run_on_actor, function(a, s) end)
genv.Actor = genv.Actor or {}
safe_assign(genv.Actor, "SendMessage", make_safe(genv.Actor.SendMessage, function(...) end))
safe_assign(genv.Actor, "BindToMessage", make_safe(genv.Actor.BindToMessage, function(...) end))
safe_assign(genv.Actor, "BindToMessageParallel", make_safe(genv.Actor.BindToMessageParallel, function(...) end))
genv.desyncronize = genv.desynchronize
genv.SharedTable = genv.SharedTable or {
    new = function() return {} end,
    size = function() return 0 end,
    clear = function() end,
    clone = function(t) return t end,
}

-- 20. SIGNAL COMPATIBILITY
genv.getconnections_deep = make_safe(genv.getconnections_deep, function(ev) return {} end)

-- 21. ENVIRONMENT INJECTIONS
if not getfenv then
    genv.getfenv = function(f) return _G end
end
if not setfenv then
    genv.setfenv = function(f, env) return env end
end
genv.getrawenv = make_safe(genv.getrawenv, function() return _G end)

-- ============================================================================
--              END COMPATIBILITY LAYER - CHEAT INITIALIZATION
-- ============================================================================
]]--

-- Bypass section commented out - uncomment the block above to enable bypass

-- Initialize genv since bypass is commented out
local genv = getgenv and getgenv() or _G

-- Minimal compatibility layer for library (since bypass is commented out)
if not genv.gethui then
    genv.gethui = function()
        return game:GetService("CoreGui")
    end
end

if not genv.cloneref then
    genv.cloneref = function(obj) return obj end
end

-- Initialize safe_fs for library loading (since bypass is commented out)
local clone = genv.clonefunction or clonefunction or function(f) return f end
local safe_fs = {
    writefile = clone(genv.writefile or writefile or function() end),
    readfile = clone(genv.readfile or readfile or function() return "" end),
    isfile = clone(genv.isfile or isfile or function() return false end),
    isfolder = clone(genv.isfolder or isfolder or function() return false end),
    makefolder = clone(genv.makefolder or makefolder or function() end),
    listfiles = clone(genv.listfiles or listfiles or function() return {} end),
    delfile = clone(genv.delfile or delfile or function() end)
}

-- Initialize LPH stubs since bypass is commented out
if not LPH_OBFUSCATED then
    if not getgenv().LPH_NO_VIRTUALIZE then
        getgenv().LPH_NO_VIRTUALIZE = function(f) return f end
    end
    if not getgenv().LPH_NO_UPVALUES then
        getgenv().LPH_NO_UPVALUES = function(f) return f end
    end
    if not getgenv().LPH_JIT then
        getgenv().LPH_JIT = function(f) return f end
    end
    if not getgenv().LPH_JIT_MAX then
        getgenv().LPH_JIT_MAX = function(f) return f end
    end
end

-- Wait for bypass to be fully loaded before continuing
--repeat task.wait(0.1) until getgenv().BypassLoaded == true

local Cheat = { GameName = 'None', Modules = { }, Globals = { } }
  
  game:GetService("ScriptContext").Error:Connect(function(msg, trace, scr)
      if not scr or trace:find("''") or msg:find("''") or trace:find('ChocoSploit') or msg:find('ChocoSploit') then
          game:GetService("Players").LocalPlayer:Kick('error detected\n' .. msg)
      end
  end)
  
  local Players = game:GetService("Players")
  local HttpService = game:GetService("HttpService")
  local UserInputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local TweenService = game:GetService("TweenService")
  
  local Library

-- ============================================================================
-- NEW UI IMPLEMENTATION
-- ============================================================================

-- ============================================================================
-- NEW UI LIBRARY INITIALIZATION - PART 1: Window Setup & Combat Page
-- This replaces lines 720-802 and starts the UI section (lines 803-4486)
-- ============================================================================

-- Replace the old library loading section with this:
do
    -- Temporarily restore pristine file functions for library loading
    local old_writefile = genv.writefile
    local old_readfile = genv.readfile
    local old_isfile = genv.isfile
    local old_isfolder = genv.isfolder
    local old_makefolder = genv.makefolder
    local old_listfiles = genv.listfiles
    local old_delfile = genv.delfile
    
    genv.writefile = safe_fs.writefile
    genv.readfile = safe_fs.readfile
    genv.isfile = safe_fs.isfile
    genv.isfolder = safe_fs.isfolder
    genv.makefolder = safe_fs.makefolder
    genv.listfiles = safe_fs.listfiles
    genv.delfile = safe_fs.delfile
    
    -- Load NEW UI Library from remote URL
    -- NOTE: The library has been modified with the following changes:
    --   1. Default transparency changed from 0.12 to 0.2
    --   2. Settings icon moved from right (-56px) to left of X button (-92px)
    --   3. Keybind mode UI made smaller (150px width, 22px height, 12px font)
    --   4. Configs panel moved to Side 1 (left-centered)
    --   5. Fixed dragging issue - panels no longer teleport when dragging starts
    --   6. Added ModeratorList panel (similar to KeybindList, positioned below it)
    -- 
    -- To use the modified library, you need to either:
    --   Option 1: Host the modified Library.lua (from newui folder) on your own server
    --   Option 2: Load it from a local file if your executor supports it
    -- Load library from remote URL only
    -- NOTE: Always use remote URL loading - do not use local files
    Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/visionwtf/vision.wtf/refs/heads/main/lib.lua'))()
    
    -- Debug: Check what we got
    print("Library loaded:", Library ~= nil)
    if Library then
        print("Library type:", type(Library))
        print("Library.Tween exists:", Library.Tween ~= nil)
        print("Library.Window exists:", type(Library.Window) == "function")
        print("Library.Page exists:", type(Library.Page) == "function")
        
        -- Check if Library.Tween has the expected structure
        if Library.Tween then
            print("Tween.Time:", Library.Tween.Time)
            print("Tween.Style:", Library.Tween.Style)
            print("Tween.Direction:", Library.Tween.Direction)
        end
    end
    
    -- Verify library loaded and add missing properties
    if not Library then
        error("Failed to load UI Library - Library is nil")
    end
    
    print("Adding fallback properties...")
    
    -- Ensure Library has required Tween property (critical fix)
    if not Library.Tween then
        print("Adding Library.Tween fallback")
        Library.Tween = {
            Time = 0.2,
            Style = Enum.EasingStyle.Quart,
            Direction = Enum.EasingDirection.Out
        }
    else
        print("Library.Tween already exists")
    end
    
    -- Ensure Library has FadeSpeed property
    if not Library.FadeSpeed then
        print("Adding Library.FadeSpeed fallback")
        Library.FadeSpeed = 0.15
    else
        print("Library.FadeSpeed already exists")
    end
    
    -- Ensure Library has Font property
    if not Library.Font then
        print("Adding Library.Font fallback")
        Library.Font = Font.fromEnum(Enum.Font.Gotham)
    else
        print("Library.Font already exists")
    end
    
    -- Ensure Library has Theme property
    if not Library.Theme then
        print("Adding Library.Theme fallback")
        Library.Theme = {
            Accent = Color3.fromRGB(34, 136, 207)
        }
    else
        print("Library.Theme already exists")
    end
    
    print("Library setup complete!")
    
    -- Library loaded successfully
    
    -- Verify library loaded
    if not Library then
        error("Failed to load UI Library")
    end
    
    -- Verify library has required properties
    if not Library.Directory then
        Library.Directory = "vision"
    end
    if not Library.Folders then
        Library.Folders = {Builds = "builds", Configs = "configs"}
    end
    
    -- Instantly re-stub the global file functions to remain undetected
    genv.writefile = old_writefile
    genv.readfile = old_readfile
    genv.isfile = old_isfile
    genv.isfolder = old_isfolder
    genv.makefolder = old_makefolder
    genv.listfiles = old_listfiles
    genv.delfile = old_delfile
end

local flags = Library.Flags

-- Create Window with new API
local Window = Library:Window({
    Name = "vision.wtf",
    SubName = "full",
    Logo = "73114691096359"
})

-- Verify Window was created successfully
if not Window then
    error("Failed to create Window - Window is nil")
end

-- Create Keybind List
local KeybindList = Library:KeybindList("Keybind List")

-- Create Moderator List (positioned below keybind list)
local ModeratorList = Library:ModeratorList("In-Game Mods")

-- ArmorViewer - Custom implementation with proper UI
local ArmorViewer = {}
ArmorViewer.Visible = false
ArmorViewer.Items = {}
ArmorViewer.Title = ""
ArmorViewer.GUI = nil

-- Initialize the ArmorViewer GUI
function ArmorViewer:Init()
    if self.GUI then return end
    
    -- Create main frame
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "ArmorViewer"
    self.GUI.Parent = gethui()
    self.GUI.IgnoreGuiInset = true
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = self.GUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 10, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 200, 0, 300)
    MainFrame.Visible = false
    
    -- Add corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = MainFrame
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(25, 25, 28)
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame
    
    -- Title label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = "Armor Viewer"
    TitleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Content frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "Content"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 5, 0, 35)
    ContentFrame.Size = UDim2.new(1, -10, 1, -40)
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 116, 224)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    -- Layout for items
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = ContentFrame
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 5)
    
    self.MainFrame = MainFrame
    self.TitleLabel = TitleLabel
    self.ContentFrame = ContentFrame
end

function ArmorViewer:SetVisibility(visible)
    self:Init()
    self.Visible = visible
    if self.MainFrame then
        self.MainFrame.Visible = visible
    end
end

function ArmorViewer:ClearAllItems()
    self.Items = {}
    if self.ContentFrame then
        for _, child in pairs(self.ContentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
end

function ArmorViewer:SetTitle(title)
    self.Title = title or ""
    if self.TitleLabel then
        self.TitleLabel.Text = self.Title
    end
end

function ArmorViewer:Add(name, imageUrl)
    if not name then return end
    self:Init()
    
    self.Items[name] = imageUrl
    
    if not self.ContentFrame then return end
    
    -- Create item frame
    local ItemFrame = Instance.new("Frame")
    ItemFrame.Name = name
    ItemFrame.Parent = self.ContentFrame
    ItemFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Size = UDim2.new(1, 0, 0, 40)
    
    -- Add corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = ItemFrame
    
    -- Item image
    local ItemImage = Instance.new("ImageLabel")
    ItemImage.Name = "Image"
    ItemImage.Parent = ItemFrame
    ItemImage.BackgroundTransparency = 1
    ItemImage.Position = UDim2.new(0, 5, 0, 5)
    ItemImage.Size = UDim2.new(0, 30, 0, 30)
    ItemImage.Image = imageUrl or ""
    ItemImage.ScaleType = Enum.ScaleType.Fit
    
    -- Item name label
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Name = "NameLabel"
    NameLabel.Parent = ItemFrame
    NameLabel.BackgroundTransparency = 1
    NameLabel.Position = UDim2.new(0, 40, 0, 0)
    NameLabel.Size = UDim2.new(1, -45, 1, 0)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
    NameLabel.TextSize = 12
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextYAlignment = Enum.TextYAlignment.Center
end

-- Create Pages with Icons (no categories)
-- Note: Master enable toggles removed - flags are set to true by default
-- The library's built-in section toggles provide enable/disable functionality

-- Reorganized categories as requested
Window:Category("Main")

local CombatPage = Window:Page({
    Name = "Combat",
    Icon = "110176974186694",
    Columns = 2
})

if not CombatPage then
    error("Failed to create CombatPage - CombatPage is nil")
end

local VisualsPage = Window:Page({
    Name = "Visuals",
    Icon = "102976018150012",
    Columns = 2
})

local MovementPage = Window:Page({
    Name = "Movement",
    Icon = "136160678435000",
    Columns = 2
})

local ExploitsPage = Window:Page({
    Name = "Exploits",
    Icon = "103342882158009",
    Columns = 2
})

Window:Category("Misc")

local AutomationPage = Window:Page({
    Name = "Automation",
    Icon = "11385220704",
    Columns = 2
})

-- Moderator Detector (keep this logic exactly as is)
local TargetGroupId = 1154360
local ModRoles = {
    ["Game Moderator"] = true,
    ["Founder"] = true,
    ["Co-Founder"] = true,
    ["Lead Developer"] = true
}

local function CheckPlayer(player)
    if player == Players.LocalPlayer then return end
    
    local success, role = pcall(function()
        return player:GetRoleInGroup(TargetGroupId)
    end)
    
    if success and role and ModRoles[role] then
        ModeratorList:Add(player.Name, role)
        Library:Notification({
            Title = "Staff Detected",
            Description = "Staff member " .. player.Name .. " (" .. role .. ") is in the server!",
            Duration = 10,
            Icon = "73789337996373"
        })
    end
end

for _, player in Players:GetPlayers() do
    task.spawn(CheckPlayer, player)
end

Players.PlayerAdded:Connect(function(player)
    CheckPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    ModeratorList:Remove(player.Name)
end)

local Debris, Players, Workspace, GuiService, RunService, UserInputService, ReplicatedStorage, Lighting, HttpService = game:GetService('Debris'), game:GetService('Players'), game:GetService('Workspace'), game:GetService('GuiService'), game:GetService('RunService'), game:GetService('UserInputService'), game:GetService('ReplicatedStorage'), game:GetService('Lighting'), game:GetService('HttpService')

Cheat.Globals.QuickStackFunctions = {}
Cheat.Globals.DesyncParts = {}
Cheat.Globals.DesyncedPositions = {}
Cheat.Globals.NoclipParts = {}
Cheat.Globals.LastAutoReload = tick()

-- ============================================================================
-- UI ELEMENTS START
-- ============================================================================
do
    --// Combat Page
    do
        --// Silent Aim Section
        do
            local AimbotSection = CombatPage:Section({
                Name = "Silent Aim",
                Description = "Automatic targeting system",
                Side = 1
            })

            -- Set aimbot enabled flag to true by default (no visible toggle)
            Library.Flags["AimbotEnabled"] = true
            -- Set mode to Silent by default (no dropdown needed)
            Library.Flags["AimbotMode"] = {"Silent"}

            local hitChanceSlider = AimbotSection:Slider({
                Name = "Hit Chance",
                Flag = "HitChance",
                Min = 0,
                Max = 100,
                Default = 100,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value) end
            })

            local forceHitToggle = AimbotSection:Toggle({
                Name = "Force Hit",
                Flag = "ForceHit",
                Default = false,
                Callback = function(Value) end
            })

            local teamCheckToggle = AimbotSection:Toggle({
                Name = "Team Check",
                Flag = "TeamCheck",
                Default = false,
                Callback = function(Value) end
            })

            local visibleCheckToggle = AimbotSection:Toggle({
                Name = "Visible Check",
                Flag = "VisibleCheck",
                Default = false,
                Callback = function(Value) end
            })

            -- Manipulation with nested settings
            local manipToggle = AimbotSection:Toggle({
                Name = "Manipulation",
                Flag = "Manipulation",
                Default = false,
                Callback = function(Value) end
            })

            -- Create nested settings for manipulation
            local manipSettings = manipToggle:Settings(300)

            manipSettings:Label("Color"):Colorpicker({
                Name = "Manipulation Color",
                Flag = "ManipulationIndicatorColor",
                Default = Color3.fromRGB(255, 0, 0),
                Callback = function(Value) end
            })

            manipSettings:Slider({
                Name = "Distance",
                Flag = "ManipulationDistance",
                Min = 1,
                Max = 10,
                Default = 5,
                Decimals = 0,
                Callback = function(Value) end
            })

            local downCheckToggle = AimbotSection:Toggle({
                Name = "Down Check",
                Flag = "DownCheck",
                Default = false,
                Callback = function(Value) end
            })

            local inventoryViewerToggle = AimbotSection:Toggle({
                Name = "Inventory Viewer",
                Flag = "InventoryViewerEnabled",
                Default = false,
                Callback = function(Value) end
            })

            local combatIndicatorsToggle = AimbotSection:Toggle({
                Name = "Combat Indicators",
                Flag = "CombatIndicators",
                Default = false,
                Callback = function(Value) end
            })

            local targetPartsDropdown = AimbotSection:Dropdown({
                Name = "Target Parts",
                Flag = "TargetParts",
                Items = {
                    "Head","UpperTorso","LowerTorso",
                    "LeftUpperArm","LeftLowerArm","LeftHand",
                    "RightUpperArm","RightLowerArm","RightHand",
                    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
                    "RightUpperLeg","RightLowerLeg","RightFoot"
                },
                Default = {"Head"},
                Multi = true,
                Callback = function(Value) end
            })

            -- FOV with nested settings
            local fovToggle = AimbotSection:Toggle({
                Name = "Draw Fov",
                Flag = "FovEnabled",
                Default = false,
                Callback = function(Value) end
            })

            local fovSettings = fovToggle:Settings(300)

            fovSettings:Label("Color"):Colorpicker({
                Name = "Fov Color",
                Flag = "FovColor",
                Alpha = 0.3,
                Default = Color3.fromRGB(34, 136, 207),
                Callback = function(Value) end
            })

            fovSettings:Slider({
                Name = "Fov Size",
                Flag = "FovSize",
                Min = 0,
                Max = 500,
                Default = 200,
                Decimals = 1,
                Callback = function(Value) end
            })

            fovSettings:Slider({
                Name = "Thickness",
                Flag = "FovThickness",
                Min = 1,
                Max = 5,
                Default = 2,
                Decimals = 0.1,
                Callback = function(Value) end
            })
        end

        --// Gun Mods Section
        do
            local GunModsSection = CombatPage:Section({
                Name = "Gun Mods",
                Description = "Weapon modifications",
                Side = 2
            })

            -- Set gun mods enabled flag to true by default (no visible toggle)
            Library.Flags["GunModsEnabled"] = true

            local noRecoilToggle = GunModsSection:Toggle({
                Name = "No Recoil",
                Flag = "NoRecoil",
                Default = false,
                Callback = function(Value) end
            })
            
            noRecoilToggle:Keybind({
                Flag = "NoRecoilBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        noRecoilToggle:Set(not Library.Flags["NoRecoil"])
                    end
                end
            })

            local noSpreadToggle = GunModsSection:Toggle({
                Name = "No Spread",
                Flag = "NoSpread",
                Default = false,
                Callback = function(Value) end
            })
            
            noSpreadToggle:Keybind({
                Flag = "NoSpreadBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        noSpreadToggle:Set(not Library.Flags["NoSpread"])
                    end
                end
            })

            local noSwayToggle = GunModsSection:Toggle({
                Name = "No Sway",
                Flag = "NoSway",
                Default = false,
                Callback = function(Value) end
            })
            
            noSwayToggle:Keybind({
                Flag = "NoSwayBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        noSwayToggle:Set(not Library.Flags["NoSway"])
                    end
                end
            })

            local noBulletDropToggle = GunModsSection:Toggle({
                Name = "No Bullet Drop",
                Flag = "NoBulletDrop",
                Default = false,
                Callback = function(Value) end
            })
            
            noBulletDropToggle:Keybind({
                Flag = "NoBulletDropBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        noBulletDropToggle:Set(not Library.Flags["NoBulletDrop"])
                    end
                end
            })

            local infiniteAmmoToggle = GunModsSection:Toggle({
                Name = "Infinite Ammo",
                Flag = "InfiniteAmmo",
                Default = false,
                Callback = function(Value) end
            })
            
            infiniteAmmoToggle:Keybind({
                Flag = "InfiniteAmmoBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        infiniteAmmoToggle:Set(not Library.Flags["InfiniteAmmo"])
                    end
                end
            })

            local instantEokaToggle = GunModsSection:Toggle({
                Name = "Instant Eoka",
                Flag = "InstantEoka",
                Default = false,
                Callback = function(Value) end
            })
            
            instantEokaToggle:Keybind({
                Flag = "InstantEokaBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        instantEokaToggle:Set(not Library.Flags["InstantEoka"])
                    end
                end
            })

            local instantEquipToggle = GunModsSection:Toggle({
                Name = "Instant Equip",
                Flag = "InstantEquip",
                Default = false,
                Callback = function(v)
                    if not Library.Flags["GunModsEnabled"] then return end
                    local Info = Cheat.Globals.ToolInfo
                    local InfoCopy = Cheat.Globals.ToolInfoCopy
                    if not Info or not InfoCopy then return end
                    for name, data in pairs(Info) do
                        if data.Weapon and data.Weapon.EquipAnimSpeed ~= nil then
                            if v then
                                if type(data.Weapon.EquipAnimSpeed) == "table" then
                                    for key in pairs(data.Weapon.EquipAnimSpeed) do
                                        data.Weapon.EquipAnimSpeed[key] = 10000
                                    end
                                else
                                    data.Weapon.EquipAnimSpeed = 10000
                                end
                            else
                                local copy = InfoCopy[name]
                                if copy and copy.Weapon then
                                    if type(copy.Weapon.EquipAnimSpeed) == "table" then
                                        for key, val in pairs(copy.Weapon.EquipAnimSpeed) do
                                            data.Weapon.EquipAnimSpeed[key] = val
                                        end
                                    else
                                        data.Weapon.EquipAnimSpeed = copy.Weapon.EquipAnimSpeed
                                    end
                                end
                            end
                        end
                    end
                end
            })
            
            instantEquipToggle:Keybind({
                Flag = "InstantEquipBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        instantEquipToggle:Set(not Library.Flags["InstantEquip"])
                    end
                end
            })

            -- Auto Reload with nested settings
            local autoReloadToggle = GunModsSection:Toggle({
                Name = "Auto Reload",
                Flag = "AutoReload",
                Default = false,
                Callback = function(Value) end
            })
            
            autoReloadToggle:Keybind({
                Flag = "AutoReloadBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        autoReloadToggle:Set(not Library.Flags["AutoReload"])
                    end
                end
            })

            local autoReloadSettings = autoReloadToggle:Settings(300)

            autoReloadSettings:Slider({
                Name = "Reload Delay",
                Flag = "AutoReloadDelay",
                Min = 0.5,
                Max = 5,
                Default = 3,
                Decimals = 0.1,
                Suffix = "s",
                Callback = function(Value) end
            })

            local shootWhileFlyingToggle = GunModsSection:Toggle({
                Name = "Shoot While Flying",
                Flag = "ShootWhileFlying",
                Default = false,
                Callback = function(Value) end
            })
            
            shootWhileFlyingToggle:Keybind({
                Flag = "ShootWhileFlyingBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        shootWhileFlyingToggle:Set(not Library.Flags["ShootWhileFlying"])
                    end
                end
            })

            -- Rapid Fire with nested settings
            local rapidFireToggle = GunModsSection:Toggle({
                Name = "Rapid Fire",
                Flag = "RapidFire",
                Default = false,
                Callback = function(Value) end
            })
            
            rapidFireToggle:Keybind({
                Flag = "RapidFireBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        rapidFireToggle:Set(not Library.Flags["RapidFire"])
                    end
                end
            })

            local rapidFireSettings = rapidFireToggle:Settings(300)

            rapidFireSettings:Slider({
                Name = "Fire Rate",
                Flag = "RapidFireRate",
                Min = 1,
                Max = 1.6,
                Default = 1.3,
                Decimals = 0.1,
                Suffix = "x",
                Callback = function(Value) end
            })

            -- Teleport To Bullet with keybind
            local tptbToggle = GunModsSection:Toggle({
                Name = "Teleport To Bullet",
                Flag = "TeleportToBullet",
                Default = false,
                Callback = function(Value) end
            })

            tptbToggle:Keybind({
                Flag = "TeleportToBulletBind",
                Mode = "Hold",
                Default = nil,
                Callback = function(Value) end
            })

            local disableSilentTPTBToggle = GunModsSection:Toggle({
                Name = "Disable Silent While TPTB",
                Flag = "DisableSilentWhileTPTB",
                Default = false,
                Callback = function(Value) end
            })
            
            disableSilentTPTBToggle:Keybind({
                Flag = "DisableSilentWhileTPTBBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        disableSilentTPTBToggle:Set(not Library.Flags["DisableSilentWhileTPTB"])
                    end
                end
            })

            local instantBulletToggle = GunModsSection:Toggle({
                Name = "Instant Bullet",
                Flag = "InstantBullet",
                Default = false,
                Callback = function(Value) end
            })
            
            instantBulletToggle:Keybind({
                Flag = "InstantBulletBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value)
                    if Value then
                        instantBulletToggle:Set(not Library.Flags["InstantBullet"])
                    end
                end
            })

            -- Warning label
            GunModsSection:Label("Warning: Instant Bullet needs to be")
            GunModsSection:Label("enabled if you plan to use Silent Aim")
            GunModsSection:Label("with a bow/crossbow.")
        end
    end
end

-- END OF PART 1
-- Continue with PART 2 for Visuals Page

-- ============================================================================
-- PART 2: Visuals Page - Players, Boss, AI, Misc ESP
-- ============================================================================

    --// Visuals Page
    do
        --// Players ESP Section
        do
            local className = 'Players'
            local PlayersSection = VisualsPage:Section({
                Name = "Players ESP",
                Description = "Player visibility features",
                Side = 1
            })

            -- Set players ESP enabled flag to false by default (no visible toggle)
            Library.Flags[className .. "ESPEnabled"] = false

            local boxesToggle = PlayersSection:Toggle({
                Name = "Boxes",
                Flag = className .. "Boxes",
                Default = false,
                Callback = function(Value) end
            })

            PlayersSection:Label("Box Color"):Colorpicker({
                Name = "Box Color",
                Flag = className .. "BoxColor1",
                Default = Color3.fromRGB(34, 136, 207),
                Callback = function(Value) end
            })

            local namesToggle = PlayersSection:Toggle({
                Name = "Names",
                Flag = className .. "Names",
                Default = false,
                Callback = function(Value) end
            })

            PlayersSection:Label("Name Color"):Colorpicker({
                Name = "Name Color",
                Flag = className .. "NameColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            PlayersSection:Toggle({
                Name = "Health Bar",
                Flag = className .. "Health",
                Default = false,
                Callback = function(Value) end
            })

            local distanceToggle = PlayersSection:Toggle({
                Name = "Distance",
                Flag = className .. "Distance",
                Default = false,
                Callback = function(Value) end
            })

            PlayersSection:Label("Distance Color"):Colorpicker({
                Name = "Distance Color",
                Flag = className .. "DistanceColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            local weaponToggle = PlayersSection:Toggle({
                Name = "Weapon",
                Flag = className .. "Weapon",
                Default = false,
                Callback = function(Value) end
            })

            PlayersSection:Label("Weapon Color"):Colorpicker({
                Name = "Weapon Color",
                Flag = className .. "WeaponColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            -- Side Flags
            local sideFlagsToggle = PlayersSection:Toggle({
                Name = "Side Flags",
                Flag = "ESP_SideFlagsESP",
                Default = false,
                Callback = function(Value) end
            })

            local sideFlagsSettings = sideFlagsToggle:Settings(300)

            sideFlagsSettings:Slider({
                Name = "Flag Size",
                Flag = "ESP_SideFlagSize",
                Min = 6,
                Max = 18,
                Default = 9,
                Decimals = 1,
                Callback = function(Value) end
            })

            local sideFlags = {
                {key = "Reloading", text = "RELOADING", color = Color3.fromRGB(120, 200, 255)},
                {key = "Healing",   text = "HEALING",   color = Color3.fromRGB(120, 255, 120)},
                {key = "SafeZone",  text = "SAFE ZONE", color = Color3.fromRGB(80, 170, 255)},
                {key = "VIP",       text = "VIP",       color = Color3.fromRGB(255, 215, 0)},
                {key = "Staff",     text = "STAFF",     color = Color3.fromRGB(255, 60, 255)},
                {key = "Cheater",   text = "CHEATER",   color = Color3.fromRGB(255, 0, 0)},
            }

            for _, sf in ipairs(sideFlags) do
                local toggle = sideFlagsSettings:Toggle({
                    Name = sf.text,
                    Flag = "ESP_SF_" .. sf.key,
                    Default = false,
                    Callback = function(Value) end
                })

                sideFlagsSettings:Label(sf.text .. " Color"):Colorpicker({
                    Name = sf.text .. " Color",
                    Flag = "ESP_SFColor_" .. sf.key,
                    Default = sf.color,
                    Callback = function(Value) end
                })
            end

            PlayersSection:Slider({
                Name = "Max Distance (studs)",
                Flag = className .. "MaxDistance",
                Min = 20,
                Max = 10000,
                Default = 10000,
                Decimals = 1,
                Callback = function(Value) end
            })
        end

        --// Boss ESP Section
        do
            local className = 'Boss'
            local BossSection = VisualsPage:Section({
                Name = "Boss ESP",
                Description = "Boss NPC visibility",
                Side = 1
            })

            -- Set boss ESP enabled flag to false by default (no visible toggle)
            Library.Flags[className .. "ESPEnabled"] = false

            local boxesToggle = BossSection:Toggle({
                Name = "Boxes",
                Flag = className .. "Boxes",
                Default = false,
                Callback = function(Value) end
            })

            BossSection:Label("Box Color"):Colorpicker({
                Name = "Box Color",
                Flag = className .. "BoxColor1",
                Default = Color3.fromRGB(34, 136, 207),
                Callback = function(Value) end
            })

            local namesToggle = BossSection:Toggle({
                Name = "Names",
                Flag = className .. "Names",
                Default = false,
                Callback = function(Value) end
            })

            BossSection:Label("Name Color"):Colorpicker({
                Name = "Name Color",
                Flag = className .. "NameColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            BossSection:Toggle({
                Name = "Health Bar",
                Flag = className .. "Health",
                Default = false,
                Callback = function(Value) end
            })

            local distanceToggle = BossSection:Toggle({
                Name = "Distance",
                Flag = className .. "Distance",
                Default = false,
                Callback = function(Value) end
            })

            BossSection:Label("Distance Color"):Colorpicker({
                Name = "Distance Color",
                Flag = className .. "DistanceColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            local weaponToggle = BossSection:Toggle({
                Name = "Weapon",
                Flag = className .. "Weapon",
                Default = false,
                Callback = function(Value) end
            })

            BossSection:Label("Weapon Color"):Colorpicker({
                Name = "Weapon Color",
                Flag = className .. "WeaponColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            BossSection:Slider({
                Name = "Max Distance (studs)",
                Flag = className .. "MaxDistance",
                Min = 20,
                Max = 10000,
                Default = 10000,
                Decimals = 1,
                Callback = function(Value) end
            })
        end

        --// AI ESP Section
        do
            local className = 'AI'
            local AISection = VisualsPage:Section({
                Name = "AI ESP",
                Description = "AI NPC visibility",
                Side = 2
            })

            -- Set AI ESP enabled flag to false by default (no visible toggle)
            Library.Flags[className .. "ESPEnabled"] = false

            local boxesToggle = AISection:Toggle({
                Name = "Boxes",
                Flag = className .. "Boxes",
                Default = false,
                Callback = function(Value) end
            })

            AISection:Label("Box Color"):Colorpicker({
                Name = "Box Color",
                Flag = className .. "BoxColor1",
                Default = Color3.fromRGB(34, 136, 207),
                Callback = function(Value) end
            })

            local namesToggle = AISection:Toggle({
                Name = "Names",
                Flag = className .. "Names",
                Default = false,
                Callback = function(Value) end
            })

            AISection:Label("Name Color"):Colorpicker({
                Name = "Name Color",
                Flag = className .. "NameColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            AISection:Toggle({
                Name = "Health Bar",
                Flag = className .. "Health",
                Default = false,
                Callback = function(Value) end
            })

            local distanceToggle = AISection:Toggle({
                Name = "Distance",
                Flag = className .. "Distance",
                Default = false,
                Callback = function(Value) end
            })

            AISection:Label("Distance Color"):Colorpicker({
                Name = "Distance Color",
                Flag = className .. "DistanceColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            local weaponToggle = AISection:Toggle({
                Name = "Weapon",
                Flag = className .. "Weapon",
                Default = false,
                Callback = function(Value) end
            })

            AISection:Label("Weapon Color"):Colorpicker({
                Name = "Weapon Color",
                Flag = className .. "WeaponColor",
                Default = Color3.fromRGB(255,255,255),
                Callback = function(Value) end
            })

            AISection:Slider({
                Name = "Max Distance (studs)",
                Flag = className .. "MaxDistance",
                Min = 20,
                Max = 10000,
                Default = 10000,
                Decimals = 1,
                Callback = function(Value) end
            })
        end

        --// Misc ESP Section
        do
            local MiscESPSection = VisualsPage:Section({
                Name = "Misc ESP",
                Description = "Object visibility",
                Side = 2
            })

            -- Set misc ESP enabled flag to false by default (no visible toggle)
            Library.Flags["MiscEnabledESP"] = false

            local miscItems = {
                'Stone', 'Metal', 'Phosphate', 'Wool', 'Animals', 
                'Care Package', 'Drops', 'Body Bag', 'Salvaged Flycopter', 
                'Auto Turret', 'Shotgun Turret'
            }

            for _, v in ipairs(miscItems) do
                local toggle = MiscESPSection:Toggle({
                    Name = v,
                    Flag = v .. "Enabled",
                    Default = false,
                    Callback = function(Value) end
                })

                MiscESPSection:Label(v .. " Color"):Colorpicker({
                    Name = v .. " Color",
                    Flag = v .. "Color",
                    Default = Color3.fromRGB(255, 255, 255),
                    Callback = function(Value) end
                })

                MiscESPSection:Slider({
                    Name = "Max Distance",
                    Flag = v .. "MaxDistance",
                    Min = 10,
                    Max = (v == 'Care Package' or v == 'Salvaged Flycopter') and 3000 or v == 'Body Bag' and 1000 or 400,
                    Default = (v == 'Care Package' or v == 'Salvaged Flycopter') and 3000 or 50,
                    Decimals = 0,
                    Callback = function(Value) end
                })
            end
        end

        --// Misc Visuals Section
        do
            local MiscVisualsSection = VisualsPage:Section({
                Name = "Misc Visuals",
                Description = "Visual modifications",
                Side = 2
            })

            -- Set misc visuals enabled flag to true by default (no visible toggle)
            Library.Flags["MiscVisualsEnabled"] = true

            local ambienceToggle = MiscVisualsSection:Toggle({
                Name = "Ambience",
                Flag = "AmbienceEnabled",
                Default = false,
                Callback = function(Value) end
            })

            MiscVisualsSection:Label("Ambience Color"):Colorpicker({
                Name = "Color",
                Flag = "AmbienceColor",
                Default = Color3.fromRGB(255, 255, 255),
                Callback = function(Value) end
            })

            MiscVisualsSection:Slider({
                Name = "Brightness",
                Flag = "AmbienceBrightness",
                Min = 0,
                Max = 1,
                Default = 0.12,
                Decimals = 0.001,
                Callback = function(Value) end
            })

            MiscVisualsSection:Slider({
                Name = "Indoor Brightness",
                Flag = "AmbienceIndoorBrightness",
                Min = 0,
                Max = 1,
                Default = 0.035,
                Decimals = 0.001,
                Callback = function(Value) end
            })

            local bulletTracersToggle = MiscVisualsSection:Toggle({
                Name = "Bullet Tracers",
                Flag = "BulletTracers",
                Default = false,
                Callback = function(Value) end
            })

            MiscVisualsSection:Label("Bullet Tracers Color"):Colorpicker({
                Name = "Color",
                Flag = "BulletTracersColor",
                Default = Color3.fromRGB(34, 136, 207),
                Callback = function(Value) end
            })

            MiscVisualsSection:Slider({
                Name = "Duration",
                Flag = "BulletTracersDuration",
                Min = 1,
                Max = 5,
                Default = 2,
                Decimals = 1,
                Suffix = "s",
                Callback = function(Value) end
            })

            MiscVisualsSection:Toggle({
                Name = "No Shadows",
                Flag = "NoShadows",
                Default = false,
                Callback = function(v)
                    if Library.Flags["MiscVisualsEnabled"] then
                        Lighting.GlobalShadows = not v
                    end
                end
            })

            MiscVisualsSection:Toggle({
                Name = "No Fog",
                Flag = "NoFog",
                Default = false,
                Callback = function(v)
                    if not Library.Flags["MiscVisualsEnabled"] then return end
                    local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
                    if not Atmosphere then return end
                    if v then
                        Atmosphere.Density = 0
                        Atmosphere.Haze = 0
                    else
                        Atmosphere.Density = Cheat.Globals.OldFogDensity or 0
                        Atmosphere.Haze = Cheat.Globals.OldFogHaze or 0
                    end
                end
            })

            MiscVisualsSection:Toggle({
                Name = "No Rain",
                Flag = "NoRain",
                Default = false,
                Callback = function(Value) end
            })

            local timeChangerToggle = MiscVisualsSection:Toggle({
                Name = "Time Changer",
                Flag = "TimeChanger",
                Default = false,
                Callback = function(v)
                    if not Library.Flags["MiscVisualsEnabled"] then return end
                    if not v then
                        Lighting.ClockTime = Cheat.Globals.OldClockTime or 12
                    else
                        Lighting.ClockTime = flags.TimeChangerValue or 12
                    end
                end
            })

            MiscVisualsSection:Slider({
                Name = "Time",
                Flag = "TimeChangerValue",
                Default = 12,
                Min = 1,
                Max = 24,
                Decimals = 1,
                Suffix = "h",
                Callback = function(v)
                    if Library.Flags["MiscVisualsEnabled"] and flags.TimeChanger then
                        Lighting.ClockTime = v
                    end
                end
            })

            MiscVisualsSection:Toggle({
                Name = "No Grass",
                Flag = "NoGrass",
                Default = false,
                Callback = function(v)
                    if Library.Flags["MiscVisualsEnabled"] then
                        pcall(function()
                            sethiddenproperty(workspace.Terrain, "Decoration", not v)
                        end)
                    end
                end
            })

            local thirdPersonToggle = MiscVisualsSection:Toggle({
                Name = "Third Person",
                Flag = "ThirdPerson",
                Default = false,
                Callback = function(Value) end
            })

            thirdPersonToggle:Keybind({
                Flag = "ThirdPersonBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value) end
            })

            MiscVisualsSection:Slider({
                Name = "Third Person Distance",
                Flag = "ThirdPersonDistance",
                Min = 5,
                Max = 50,
                Default = 15,
                Decimals = 1,
                Callback = function(Value) end
            })
        end
    end

-- END OF PART 2
-- Continue with PART 3 for Movement & Exploits Pages

-- ============================================================================
-- PART 3: Movement & Exploits Pages
-- ============================================================================

    --// Movement Page
    do
        --// Main Movement Section
        do
            local MainMovementSection = MovementPage:Section({
                Name = "Main",
                Description = "Speed and flight controls",
                Side = 1
            })

            local speedToggle = MainMovementSection:Toggle({
                Name = "Speed",
                Flag = "SpeedEnabled",
                Default = false,
                Callback = function(Value) end
            })

            speedToggle:Keybind({
                Flag = "SpeedBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value) end
            })

            MainMovementSection:Toggle({
                Name = "Anti Rubberband",
                Flag = "SpeedAntiRubberband",
                Default = false,
                Callback = function(Value) end
            })

            MainMovementSection:Slider({
                Name = "Speed",
                Flag = "SpeedMultiplier",
                Min = 1,
                Max = 16,
                Default = 6,
                Decimals = 1,
                Callback = function(Value) end
            })

            local flightToggle = MainMovementSection:Toggle({
                Name = "Fly",
                Flag = "FlightEnabled",
                Default = false,
                Callback = function(Value) end
            })

            flightToggle:Keybind({
                Flag = "FlightBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value) end
            })

            MainMovementSection:Slider({
                Name = "Fly Speed",
                Flag = "FlightSpeed",
                Min = 1,
                Max = 300,
                Default = 10,
                Decimals = 1,
                Callback = function(Value) end
            })

            local spectateToggle = MainMovementSection:Toggle({
                Name = "Spectate Target",
                Flag = "SpectateTarget",
                Default = false,
                Callback = function(Value) end
            })

            spectateToggle:Keybind({
                Flag = "SpectateTargetBind",
                Mode = "Hold",
                Default = nil,
                Callback = function(Value) end
            })
        end

        --// Camera Section
        do
            local CameraSection = MovementPage:Section({
                Name = "Camera",
                Description = "Camera modifications",
                Side = 1
            })

            local zoomToggle = CameraSection:Toggle({
                Name = "Zoom",
                Flag = "ZoomEnabled",
                Default = false,
                Callback = function(Value) end
            })

            zoomToggle:Keybind({
                Flag = "ZoomKeybind",
                Mode = "Hold",
                Default = nil,
                Callback = function(Value) end
            })

            CameraSection:Slider({
                Name = "Fov",
                Flag = "ZoomAmount",
                Min = 1,
                Max = 80,
                Default = 30,
                Decimals = 1,
                Callback = function(Value) end
            })

            local freecamToggle = CameraSection:Toggle({
                Name = "Freecam",
                Flag = "Freecam",
                Default = false,
                Callback = function(Value) end
            })

            freecamToggle:Keybind({
                Flag = "FreecamKeybind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value) end
            })

            CameraSection:Slider({
                Name = "Speed",
                Flag = "FreecamSpeed",
                Min = 1,
                Max = 100,
                Default = 10,
                Decimals = 1,
                Callback = function(Value) end
            })
        end

        --// Misc Movement Section
        do
            local MiscMovementSection = MovementPage:Section({
                Name = "Misc",
                Description = "Additional movement features",
                Side = 2
            })

            MiscMovementSection:Toggle({
                Name = "Bunnyhop",
                Flag = "Bunnyhop",
                Default = false,
                Callback = function(Value) end
            })

            MiscMovementSection:Toggle({
                Name = "Infinite Fly",
                Flag = "InfiniteFly",
                Default = false,
                Callback = function(Value) end
            })

            MiscMovementSection:Toggle({
                Name = "No Grounded",
                Flag = "NoGrounded",
                Default = false,
                Callback = function(Value) end
            })
        end
    end

    --// Exploits Page
    do
        --// Game Exploits Section
        do
            local GameExploitsSection = ExploitsPage:Section({
                Name = "Game Exploits",
                Description = "Game mechanic exploits",
                Side = 1
            })

            GameExploitsSection:Toggle({
                Name = "Perfect Farm",
                Flag = "PerfectFarm",
                Default = false,
                Callback = function(Value) end
            })

            GameExploitsSection:Toggle({
                Name = "Instant Loot",
                Flag = "InstantLoot",
                Default = false,
                Callback = function(value)
                    local QuickStackFunctions = Cheat.Globals.QuickStackFunctions or {}

                    if #QuickStackFunctions > 0 then
                        for _, FUNCTION in QuickStackFunctions do
                            debug.setconstant(FUNCTION, 19, value and 0 or 0.9) -- 0.9
                            debug.setconstant(FUNCTION, 20, value and 0 or 0.3) -- 0.3
                            debug.setconstant(FUNCTION, 21, value and 0 or 0.1) -- 0.1
                        end
                    end
                end
            })

            GameExploitsSection:Toggle({
                Name = "Instant Last Code",
                Flag = "InstantLastCode",
                Default = false,
                Callback = function(Value) end
            })

            GameExploitsSection:Toggle({
                Name = "Evil Resolver",
                Flag = "EvilResolver",
                Default = false,
                Callback = function(Value) end
            })
        end

        --// Player Exploits Section
        do
            local PlayerExploitsSection = ExploitsPage:Section({
                Name = "Player Exploits",
                Description = "Player-specific exploits",
                Side = 1
            })

            PlayerExploitsSection:Toggle({
                Name = "No Bob",
                Flag = "NoBob",
                Default = false,
                Callback = function(Value) end
            })

            PlayerExploitsSection:Toggle({
                Name = "No Fall Damage",
                Flag = "NoFall",
                Default = false,
                Callback = function(Value) end
            })

            PlayerExploitsSection:Toggle({
                Name = "Silent Walk",
                Flag = "SilentWalk",
                Default = false,
                Callback = function(Value) end
            })

            PlayerExploitsSection:Toggle({
                Name = "Underground Resolver",
                Flag = "UndergroundResolver",
                Default = false,
                Callback = function(Value) end
            })

            local undergroundToggle = PlayerExploitsSection:Toggle({
                Name = "Underground",
                Flag = "Underground",
                Default = false,
                Callback = function(Value) end
            })

            undergroundToggle:Keybind({
                Flag = "UndergroundBind",
                Mode = "Toggle",
                Default = nil,
                Callback = function(Value) end
            })

            PlayerExploitsSection:Toggle({
                Name = "Card Noclip",
                Flag = "CardNoclip",
                Default = false,
                Callback = function(value)
                    if not Cheat.Globals.NoclipParts then return end
                    for i = #Cheat.Globals.NoclipParts, 1, -1 do
                        local Part = Cheat.Globals.NoclipParts[i]
                        if Part and Part.Parent then
                            Part.CanCollide = not value
                        else
                            table.remove(Cheat.Globals.NoclipParts, i)
                        end
                    end
                end
            })

            local bringBTRToggle = PlayerExploitsSection:Toggle({
                Name = "Bring BTR",
                Flag = "BringBTR",
                Default = false,
                Callback = function(Value) end
            })

            bringBTRToggle:Keybind({
                Flag = "BringBTRBind",
                Mode = "Hold",
                Default = nil,
                Callback = function(toggled)
                    if Cheat.Globals.BringBTRCallback then
                        Cheat.Globals.BringBTRCallback(toggled)
                    end
                end
            })
        end

        --// Vehicle Exploits Section
        do
            local VehicleExploitsSection = ExploitsPage:Section({
                Name = "Vehicle Exploits",
                Description = "Vehicle modifications",
                Side = 2
            })

            VehicleExploitsSection:Toggle({
                Name = "Unbreakable Mini",
                Flag = "UnbreakableMini",
                Default = false,
                Callback = function(Value) end
            })

            VehicleExploitsSection:Toggle({
                Name = "Silent Mini",
                Flag = "SilentMini",
                Default = false,
                Callback = function(Value) end
            })
        end

        --// Visual Exploits Section
        do
            local VisualExploitsSection = ExploitsPage:Section({
                Name = "Visual Exploits",
                Description = "Visual modifications",
                Side = 2
            })

            VisualExploitsSection:Toggle({
                Name = "FOV Changer",
                Flag = "FovChanger",
                Default = false,
                Callback = function(Value) end
            })

            VisualExploitsSection:Slider({
                Name = "FOV",
                Flag = "FovValue",
                Min = 70,
                Max = 120,
                Default = 90,
                Decimals = 1,
                Callback = function(Value) end
            })

            VisualExploitsSection:Toggle({
                Name = "Stream Mode",
                Flag = "StreamMode",
                Default = false,
                Callback = function(Value) end
            })
        end
    end

-- END OF PART 3
-- Continue with PART 4 for Automation Page

-- ============================================================================
-- PART 4: Automation Page
-- ============================================================================

    --// Automation Page
    do
        --// Auto Features Section
        do
            local AutoFeaturesSection = AutomationPage:Section({
                Name = "Auto Features",
                Description = "Automated gameplay features",
                Side = 1
            })

            AutoFeaturesSection:Toggle({
                Name = "Auto Features Enabled",
                Flag = "AutoFeaturesEnabled",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Auto Revive",
                Flag = "AutoReviveToggle",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Revive Radius",
                Flag = "AutoReviveRadius",
                Min = 5,
                Max = 30,
                Default = 15,
                Decimals = 1,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Auto Craft",
                Flag = "EnableAutoCrafting",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Craft Cloth",
                Flag = "CraftCloth",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Craft Bandages",
                Flag = "CraftBandages",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Bandage Amount",
                Flag = "AmountOfBandages",
                Min = 1,
                Max = 30,
                Default = 6,
                Decimals = 1,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Auto Eat",
                Flag = "EnableAutoEat",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Eat Below HP",
                Flag = "AutoEatThreshold",
                Min = 10,
                Max = 100,
                Default = 100,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Eat Below Hunger",
                Flag = "AutoEatHunger",
                Min = 0,
                Max = 100,
                Default = 80,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Eat Below Thirst",
                Flag = "AutoEatThirst",
                Min = 0,
                Max = 100,
                Default = 80,
                Decimals = 1,
                Suffix = "%",
                Callback = function(Value) end
            })

            AutoFeaturesSection:Toggle({
                Name = "Auto Drop",
                Flag = "EnableAutoDrop",
                Default = false,
                Callback = function(Value) end
            })

            local autoDropListbox = AutoFeaturesSection:Dropdown({
                Name = "Items to Drop",
                Flag = "AutoDropItems",
                Multi = true,
                Items = {},
                Callback = function(Value) end
            })
            Cheat.Globals.AutoDropListbox = autoDropListbox

            AutoFeaturesSection:Toggle({
                Name = "Auto Upgrade",
                Flag = "AutoUpgrade",
                Default = false,
                Callback = function(Value) end
            })

            AutoFeaturesSection:Dropdown({
                Name = "Upgrade Material",
                Flag = "AutoUpgradeMaterial",
                Items = {"Auto", "Wood", "Stone", "Metal", "Steel"},
                Default = "Auto",
                Callback = function(Value) end
            })

            AutoFeaturesSection:Slider({
                Name = "Upgrade Distance",
                Flag = "AutoUpgradeDistance",
                Min = 5,
                Max = 50,
                Default = 20,
                Decimals = 1,
                Callback = function(Value) end
            })
        end
    end

-- END OF PART 4
-- Continue with PART 5 for Settings Page + Window:Init()

-- ============================================================================
-- PART 5: Settings Page + Window Initialization
-- ============================================================================

    --// Settings Page (Auto-created by library)
    local SettingsPage = Library:CreateSettingsPage(Window, KeybindList, ModeratorList)

    --// Initialize Window (REQUIRED - Must be called after all pages are created)
    Window:Init()

-- ============================================================================
-- BACKEND CODE CONTINUES HERE (Line 3041+ from original fullv2.lua)
-- ============================================================================
-- The backend code (Settings section with all the game logic) remains
-- completely unchanged and starts here. This includes:
-- - Service declarations
-- - Module loading
-- - Hook implementations
-- - Game logic
-- - ESP systems
-- - All runtime functionality
--
-- Simply copy everything from line 3041 onwards from the original fullv2.lua
-- ============================================================================

-- ============================================================================
-- BACKEND CODE (UNCHANGED FROM ORIGINAL)
-- ============================================================================

      --// Settings
      do
  local Camera = Workspace.CurrentCamera
  local Client = Players.LocalPlayer
  
  local wsVFXFolder = workspace:WaitForChild("VFX")
  local VMs = wsVFXFolder and wsVFXFolder:FindFirstChild('VMs')
  local Drops = workspace:FindFirstChild('Drops')
  local Plants = workspace:FindFirstChild('Plants')
  local Animals = workspace:FindFirstChild('Animals')
  
  local Modules = ReplicatedStorage:WaitForChild("Modules")
  local rsVFXFolder = ReplicatedStorage:WaitForChild("VFX")
  local Values = ReplicatedStorage:WaitForChild("Values")
  
  local ItemClass = Modules and require(Modules:WaitForChild("ItemClass"))
  local VFXModule = Modules and require(Modules.VFXModule)
  local ItemsModule = Modules and require(Modules.Items)
  local RaycastUtil = Modules and require(Modules.RaycastUtil)
  local SettingsModule = Modules and require(Modules.SettingsModule)
  local SoundModule = Modules and require(Modules.SoundModule)
  local ToolInfo = Modules and require(Modules.ToolInfo)
  
  if not (ItemClass and VFXModule and ItemsModule and RaycastUtil and SettingsModule and SoundModule) then
      Client:Kick("Failed to load game modules.")
      return
  end

  local ToggleFootstep = SoundModule.ToggleFootstep
  SoundModule.ToggleFootstep = LPH_NO_VIRTUALIZE(function(...)
      local args = {...}
      if flags.SilentWalk and args[3] then
          return SoundModule:StopSound(args[3])
      end
      return ToggleFootstep(...)
  end)

  local PlaySound = SoundModule.PlaySound
  SoundModule.PlaySound = LPH_NO_VIRTUALIZE(function(...)
      local args = {...}
      if flags.SilentWalk and args[2] and args[2].Name == "WalkWater" then
          return SoundModule:StopSound(args[2])
      end
      return PlaySound(...)
  end)
  
  local clanController, clanControllerShared
  if Client:FindFirstChild("PlayerScripts") and Client.PlayerScripts:FindFirstChild("ClanController") then
      clanController = getsenv(Client.PlayerScripts:WaitForChild("ClanController"))
      clanControllerShared = clanController and clanController.shared
  else
      clanControllerShared = {cachedTeamModels = {}}
  end
  
  local isTeam = LPH_NO_VIRTUALIZE(function(player)
      if typeof(player) ~= 'Instance' or not player:IsA('Player') then return false end
      local teamCache = clanControllerShared and clanControllerShared.cachedTeamModels
      return teamCache and teamCache[player.UserId] or false
  end)
  
  local getgun = function(character)
      if not character then return "None" end
      for _, model in character:GetChildren() do
          if not model:IsA('Model') then
              continue
          end
  
          if model.Name == 'Hair' or model.Name == 'HolsterModel' then
              continue
          end
  
          if not model.PrimaryPart then
              continue
          end
  
          if model:FindFirstChild("Detail") or model:FindFirstChild("Main") or model:FindFirstChild("Handle") or model:FindFirstChild("Attachments") or model:FindFirstChild("ArrowAttach") or model:FindFirstChild("Attach") then
              return model.Name
          end;
      end;
  
      return "None"
  end
  
  local Targeting = {
      TargetPart = nil,
      TargetCharacter = nil,
      Targets = {},
      ManipulatedPosition = nil,
      ScannedPosition = nil,
      ScanPos = nil,
      ManipPos = nil,
      ModList = {},
      TargetObject = nil,
      ManipulatedPart = nil,
      ScannedPart = nil,
      HitScanActive = false,
      ManipulationActive = false,
  }
  
  --// Silent Aim (INSULIN Implementation)
  do
      local GetDistanceFromCenter = function(part)
          local position = part
          if typeof(part) == "Instance" then
              position = part.CFrame.Position
          end
          local sp, on = Camera:WorldToViewportPoint(position)
          if not on then
              return math.huge
          end
          local c = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
          return (c - Vector2.new(sp.X, sp.Y)).Magnitude
      end

      local GetRoot = function(model)
          if not model then return end
          return model:FindFirstChild("HumanoidRootPart")
              or model.PrimaryPart
              or model:FindFirstChild("RootPart")
              or model:FindFirstChild("Torso")
      end

      local GetTargetPart = function(model, desired)
          if not model then return end
          return model:FindFirstChild(desired)
              or model:FindFirstChild("Head")
              or model:FindFirstChild("UpperTorso")
              or model:FindFirstChild("HumanoidRootPart")
              or model.PrimaryPart
      end

      local UnitDirections = {
          Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
          Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
          Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
          Vector3.new(1, 1, 0).Unit, Vector3.new(1, -1, 0).Unit,
          Vector3.new(-1, 1, 0).Unit, Vector3.new(-1, -1, 0).Unit,
          Vector3.new(0, 1, 1).Unit, Vector3.new(0, -1, 1).Unit,
          Vector3.new(0, 1, -1).Unit, Vector3.new(0, -1, -1).Unit,
      }

      local manipOffsets = {}
      do
          local maxDist = 10
          local step = 0.5
          for x = -maxDist, maxDist, step do
              for y = -maxDist, maxDist, step do
                  for z = -maxDist, maxDist, step do
                      local v = Vector3.new(x, y, z)
                      if v.Magnitude <= maxDist then
                          table.insert(manipOffsets, v)
                      end
                  end
              end
          end
          table.sort(manipOffsets, function(a, b) return a.Magnitude < b.Magnitude end)
      end

      local IsCFrameVisible = function(fromCF, toCF, rayParams)
          if not (fromCF and toCF) then return false end
          local hit = workspace:Raycast(fromCF.Position, toCF.Position - fromCF.Position, rayParams)
          return hit == nil
      end

      local IsPartVisibleFromCF = function(fromCF, targetPart, rayParams)
          if not (fromCF and targetPart) then return false end
          local origin = fromCF.Position
          local dir = targetPart.Position - origin
          local hit = workspace:Raycast(origin, dir, rayParams)
          if not hit then return true end
          return hit.Instance and hit.Instance:IsDescendantOf(targetPart.Parent)
      end

      local GetHitScanPos = function(originCF, targetPart, rayParams)
          rayParams = rayParams or Cheat.Globals.RaycastParams
          local maxDist = flags.HitScanDistance or 5
          local stepSize = 0.5
          local steps = math.max(1, math.ceil(maxDist / stepSize))
          for s = 1, steps do
              local dist = math.min(s * stepSize, maxDist)
              for i = 1, #UnitDirections do
                  local surfaceCF = targetPart.CFrame * CFrame.new(UnitDirections[i] * dist)
                  if IsPartVisibleFromCF(surfaceCF, targetPart, rayParams) and IsCFrameVisible(originCF, surfaceCF, rayParams) then
                      return surfaceCF.Position
                  end
              end
          end
          return nil
      end

      local IsCandidateReachable = function(origin, candidate)
          local dir = candidate - origin
          local hit = workspace:Raycast(origin, dir, Cheat.Globals.RaycastParams)
          return hit == nil
      end

      local IsManipPathClear = function(manipPos, targetPart)
          if not targetPart then return false end
          local dir = targetPart.Position - manipPos
          local hit = workspace:Raycast(manipPos, dir, Cheat.Globals.RaycastParams)
          if not hit then return true end
          return hit.Instance and hit.Instance:IsDescendantOf(targetPart.Parent)
      end

      local IsAimPointReachable = function(manipPos, aimPoint, targetPart)
          if not aimPoint then return true end
          local dir = aimPoint - manipPos
          local hit = workspace:Raycast(manipPos, dir, Cheat.Globals.RaycastParams)
          if not hit then return true end
          return hit.Instance and hit.Instance:IsDescendantOf(targetPart.Parent)
      end

      local FindVisiblePosition = function(Origin, Destination, AimPoint)
          local o = (typeof(Origin) == 'CFrame') and Origin or CFrame.new(Origin)
          local oPos = o.Position
          local maxDist = flags.ManipulationDistance or 5
          if AimPoint then
              for i = 1, #manipOffsets do
                  local off = manipOffsets[i]
                  if off.Magnitude <= maxDist then
                      local pos = o * off
                      if IsCandidateReachable(oPos, pos) and IsManipPathClear(pos, Destination) and IsAimPointReachable(pos, AimPoint, Destination) then
                          return pos
                      end
                  end
              end
          end
          for i = 1, #manipOffsets do
              local off = manipOffsets[i]
              if off.Magnitude <= maxDist then
                  local pos = o * off
                  if IsCandidateReachable(oPos, pos) and IsManipPathClear(pos, Destination) then
                      return pos
                  end
              end
          end
          return nil
      end

      local locked
      RunService.Heartbeat:Connect(LPH_JIT_MAX(function()
          if flags.SpectateTarget and (not flags.SpectateTargetBind or flags.SpectateTargetBind.Toggled) then
              local target = locked and locked or Targeting.TargetCharacter
              locked = locked and locked or Targeting.TargetCharacter
              Camera.CameraSubject = locked
          else
              locked = nil
              Camera.CameraSubject = Cheat.Globals.ClientCharacter
          end
      end))

      local ignoreList = {}
      RunService.Heartbeat:Connect(LPH_JIT_MAX(function()
          ignoreList = {
              Camera,
              Cheat.Globals.ClientCharacter,
              workspace:FindFirstChild("VFX"),
              workspace:FindFirstChild("RocketFactoryPinkCardInvisWalls")
          }
          RaycastParams = Cheat.Globals.RaycastParams
          RaycastParams.FilterDescendantsInstances = ignoreList

          for name, player in pairs(Players:GetPlayers()) do
              if not Targeting.Targets[player] and player ~= Client then
                  Targeting.Targets[player] = {
                      Class = "Player",
                      Player = player,
                      Character = player.Character,
                      CoreInformation = { Visible = false, OnScreen = false, Root = nil },
                      LastUpdate = 0,
                      Humanoid = nil,
                      Root = nil,
                  }
              end
          end

          local aimbotActive = flags.AimbotEnabled and not (flags.DisableSilentWhileTPTB and flags.TeleportToBullet and flags.TeleportToBulletBind and flags.TeleportToBulletBind.Toggled)
          if not aimbotActive then
              Targeting.TargetPart = nil
              Targeting.TargetCharacter = nil
              Targeting.ScannedPosition = nil
              Targeting.ManipulatedPosition = nil
              Targeting.HitScanActive = false
              Targeting.ManipulationActive = false
              return
          end

          local TargetParts = flags.TargetParts
          if not TargetParts or #TargetParts == 0 then
              return
          end

          local Silent = aimbotActive -- Always use Silent mode
          local DesiredPartName = TargetParts[math.random(#TargetParts)]
          local UseVisibleCheck = flags.VisibleCheck
          local DownCheck = flags.DownCheck
          local ClosestDistance = flags.FovSize * 0.5
          local ClosestTarget
          local EntityCharacter
          local EntityData
          local EntityInstance
          local Visible

          local now = tick()

          for Entity, Object in pairs(Targeting.Targets) do
              if not Object then continue end

              local character = Object.Character
              if not character or not character.Parent then
                  character = (Object.Class == 'Player' and Object.Player.Character) or Entity
                  Object.Character = character
              end
              if not character or not character.Parent then
                  Object.CoreInformation = Object.CoreInformation or {}
                  Object.CoreInformation.Visible = false
                  Object.CoreInformation.OnScreen = false
                  Object.CoreInformation.Root = nil
                  continue
              end

              if (now - (Object.LastUpdate or 0)) > (1 / 10) then
                  Object.LastUpdate = now
                  if character:IsA('Player') then
                      Object.Character = character.Character
                      character = character.Character
                  end

                  if not character then
                      Object.CoreInformation = Object.CoreInformation or {}
                      Object.CoreInformation.Visible = false
                      Object.CoreInformation.OnScreen = false
                      Object.CoreInformation.Root = nil
                      continue
                  end

                  local humanoid = character:FindFirstChildOfClass('Humanoid')
                  local root = GetRoot(character)

                  Object.Humanoid = humanoid
                  Object.Root = root

                  local Core = Object.CoreInformation or {}
                  Object.CoreInformation = Core

                  if not root or (Camera.CFrame.Position - root.Position).Magnitude > 2000 then
                      Core.Visible = false
                      Core.OnScreen = false
                      Core.Root = root
                      Core.VisibleSince = nil
                  else
                      local _, onScreen = Camera:WorldToViewportPoint(root.Position)

                      local localHead = Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild("Head")
                      local rootVisible = false
                      if localHead then
                          local origin = localHead.CFrame.Position
                          local rr = workspace:Raycast(origin, root.Position - origin, Cheat.Globals.RaycastParams)
                          if rr and rr.Instance and rr.Instance:IsDescendantOf(character) then
                              rootVisible = true
                          end
                      end

                      if rootVisible then
                          Core.VisibleSince = Core.VisibleSince or now
                      else
                          Core.VisibleSince = nil
                      end
                      local stableVisible = Core.VisibleSince and (now - Core.VisibleSince) >= 0.3 or false

                      Core.Root = root
                      Core.RootPosition = root.Position
                      Core.OnScreen = onScreen
                      Core.Visible = stableVisible
                      Core.VisiblePart = stableVisible and root or nil
                  end
              end

              local Core = Object.CoreInformation
              if not Core or not Core.Root or Entity == Client then continue end
              if Entity:IsA('Player') and flags.TeamCheck and isTeam(Entity) then continue end
              if not Core.OnScreen then continue end

              local humanoid = Object.Humanoid
              if not humanoid or humanoid.Health <= 0 then continue end
              if DownCheck and humanoid:GetAttribute('Downed') then continue end

              local Distance = GetDistanceFromCenter(Core.Root)
              if Distance >= ClosestDistance then continue end

              local tpart = nil

              if UseVisibleCheck and Core.Visible then
                  tpart = Core.VisiblePart
              else
                  tpart = GetTargetPart(character, DesiredPartName)
              end

              if tpart then
                  ClosestDistance = Distance
                  ClosestTarget = tpart
                  EntityCharacter = character
                  EntityData = Object
                  EntityInstance = Entity
                  Visible = Core.Visible
              end
          end

          local Manipulated, HitScanned
          local ManipulatedPosition, ManipulatedPart, ManipulatedPlayer
          local ScannedPosition, ScannedPart

          if Silent and not Visible and ClosestTarget and EntityData and Cheat.Globals.ClientCharacter then
              local head = Cheat.Globals.ClientCharacter:FindFirstChild("Head")
              local StartCF = head and head.CFrame
              if Cheat.Globals.NeedToReturn then
                  StartCF = Cheat.Globals.SavedPosition
              end

              if head and StartCF then
                  local bothOn = flags.HitScan and flags.Manipulation
                  local hsThrottle = bothOn and (1/30) or (1/15)
                  if (now - (EntityData.LastHitScanTime or 0)) > hsThrottle then
                      EntityData.LastHitScanTime = now
                      if flags.HitScan then
                          local hs = GetHitScanPos(StartCF, ClosestTarget)
                          if hs then
                              HitScanned = true
                              ScannedPart = ClosestTarget
                              ScannedPosition = hs
                              ManipulatedPlayer = EntityInstance
                          end
                      end
                      if HitScanned then
                          EntityData.HitScanCache = { ScannedPart = ScannedPart, ScannedPosition = ScannedPosition }
                          EntityData.HitScanCacheTime = now
                      elseif EntityData.HitScanCache and (now - (EntityData.HitScanCacheTime or 0)) <= 3 then
                          local cfg = EntityData.HitScanCache
                          if cfg.ScannedPart and cfg.ScannedPart.Parent then
                              local d = (cfg.ScannedPosition - cfg.ScannedPart.Position).Magnitude
                              if d <= (flags.HitScanDistance or 5) + 0.05 then
                                  HitScanned = true
                                  ScannedPart = cfg.ScannedPart
                                  ScannedPosition = cfg.ScannedPosition
                                  ManipulatedPlayer = ManipulatedPlayer or EntityInstance
                              else
                                  EntityData.HitScanCache = nil
                              end
                          else
                              EntityData.HitScanCache = nil
                          end
                      else
                          EntityData.HitScanCache = nil
                      end
                  else
                      local cfg = EntityData.HitScanCache
                      if cfg and cfg.ScannedPart and cfg.ScannedPart.Parent then
                          local d = (cfg.ScannedPosition - cfg.ScannedPart.Position).Magnitude
                          if d <= (flags.HitScanDistance or 5) + 0.05 then
                              HitScanned = true
                              ScannedPart = cfg.ScannedPart
                              ScannedPosition = cfg.ScannedPosition
                              ManipulatedPlayer = ManipulatedPlayer or EntityInstance
                          end
                      end
                  end

                  local ManipulationActive = flags.Manipulation == true
                  if ManipulationActive then
                      local manipThrottle = bothOn and (1/30) or 0.05
                      if (now - (EntityData.LastManip or 0)) > manipThrottle then
                          EntityData.LastManip = now
                          local aimPoint = HitScanned and ScannedPosition or nil
                          local vp = FindVisiblePosition(StartCF, ClosestTarget, aimPoint)
                          if vp then
                              Manipulated = true
                              ManipulatedPart = ClosestTarget
                              ManipulatedPosition = vp
                              ManipulatedPlayer = ManipulatedPlayer or EntityInstance
                              EntityData.LastManipCFG = {
                                  ManipulatedPosition = vp,
                                  ManipulatedPart = ClosestTarget,
                                  ManipulatedPlayer = ManipulatedPlayer,
                              }
                              EntityData.LastManipCFGTime = now
                          elseif EntityData.LastManipCFG and (now - (EntityData.LastManipCFGTime or 0)) <= 1.5 then
                              local cfg = EntityData.LastManipCFG
                              if cfg.ManipulatedPart and cfg.ManipulatedPart.Parent then
                                  Manipulated = true
                                  ManipulatedPart = cfg.ManipulatedPart
                                  ManipulatedPosition = cfg.ManipulatedPosition
                                  ManipulatedPlayer = ManipulatedPlayer or cfg.ManipulatedPlayer
                              else
                                  EntityData.LastManipCFG = nil
                              end
                          else
                              EntityData.LastManipCFG = nil
                          end
                      elseif EntityData.LastManipCFG then
                          local cfg = EntityData.LastManipCFG
                          if cfg.ManipulatedPart and cfg.ManipulatedPart.Parent then
                              Manipulated = true
                              ManipulatedPart = cfg.ManipulatedPart
                              ManipulatedPosition = cfg.ManipulatedPosition
                              ManipulatedPlayer = ManipulatedPlayer or cfg.ManipulatedPlayer
                          end
                      end
                  else
                      EntityData.LastManipCFG = nil
                  end
              end
          end

          Targeting.TargetPart = ClosestTarget
          Targeting.TargetCharacter = EntityCharacter
          Targeting.TargetObject = EntityData
          Targeting.ManipulatedPosition = Manipulated and ManipulatedPosition or nil
          Targeting.ManipulatedPart = Manipulated and ManipulatedPart or nil
          Targeting.ScannedPosition = HitScanned and ScannedPosition or nil
          Targeting.ScannedPart = HitScanned and ScannedPart or nil
          Targeting.HitScanActive = (Silent and not Visible and ClosestTarget and flags.HitScan) and true or false
          Targeting.ManipulationActive = (Silent and not Visible and ClosestTarget and flags.Manipulation) and true or false
      end))

      for _, Player in ipairs(Players:GetPlayers()) do
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end

      Players.PlayerAdded:Connect(LPH_NO_VIRTUALIZE(function(Player)
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end))

      Players.PlayerRemoving:Connect(LPH_NO_VIRTUALIZE(function(Player)
          Targeting.Targets[Player] = nil
          Targeting.ModList[Player] = nil
      end))
  end
  
  --// Gun Mods
  do
      -- Store original ToolInfo for restoration
      Cheat.Globals.ToolInfo = ToolInfo
      Cheat.Globals.ToolInfoCopy = {}
      for name, data in pairs(ToolInfo) do
          Cheat.Globals.ToolInfoCopy[name] = {}
          for k, v in pairs(data) do
              if type(v) == "table" then
                  Cheat.Globals.ToolInfoCopy[name][k] = {}
                  for k2, v2 in pairs(v) do
                      Cheat.Globals.ToolInfoCopy[name][k][k2] = v2
                  end
              else
                  Cheat.Globals.ToolInfoCopy[name][k] = v
              end
          end
      end

      local oldAttachmentStats = ItemClass.AttachmentStats
      ItemClass.AttachmentStats = function(v50, v51)
          local tb = debug.traceback()
          local r = oldAttachmentStats(v50, v51)
          
          if tb and tb:find('ViewmodelController') and r and flags['GunModsEnabled'] then
              if flags['InstantBullet'] then
                  r.SpeedMult = 100
              end
              
              if flags['NoRecoil'] then
                  r.RecoilMult = -1;
              end
              
              if flags['NoSpread'] then
                  r.AimSpreadMult = -1;
                  r.HipSpreadMult = -1;
              end
              
              if flags['NoSway'] then
                  r.SwayMult = -1;
              end

              if flags['RapidFire'] then
                  r.FireRateMult = flags['RapidFireRate'] - 1
              end

              if flags['NoBulletDrop'] then
                  r.GravityMult = -1
              end

              if flags['InfiniteAmmo'] then
                  r.InfiniteAmmo = true
              end
          end
  
          return r
      end

      -- Instant Eoka implementation
      task.spawn(function()
          task.wait(2)
          if not Cheat.Globals._hookedClosures then
              Cheat.Globals._hookedClosures = setmetatable({}, { __mode = "k" })
          end
          local hookedSet = Cheat.Globals._hookedClosures
          
          for i, v in getgc(true) do
              if type(v) == "table" and rawget(v, "ChooseRandom") and not rawget(v, "overwritten") then
                  rawset(v, "overwritten", true)
                  local old = v.ChooseRandom
                  v.ChooseRandom = function(...)
                      if flags.InstantEoka then
                          return 0
                      end
                      return old(...)
                  end
              end

              -- Shoot While Flying implementation
              if type(v) == "function" and islclosure(v) and not hookedSet[v] then
                  local constants = getconstants(v)
                  if constants[1] == 'Enum' and constants[2] == 'HumanoidStateType' and constants[3] == 'Landed' then
                      hookedSet[v] = true
                      local Old; Old = hookfunction(
                          v,
                          function(oldState, newState, ...)
                              if flags.ShootWhileFlying then
                                  oldState = Enum.HumanoidStateType.Running
                                  newState = Enum.HumanoidStateType.Running
                              end
                              local s, r = pcall(Old, oldState, newState, ...)
                              if s then
                                  return r
                              end
                          end
                      )
                  end
              end
          end
      end)

      -- Instant Last Code implementation
      setreadonly(getgenv().task, false)
      local oldtaskspawn = getgenv().task.spawn
      getgenv().task.spawn = newcclosure(function(func, ...)
          local traceback = debug.traceback()
          
          if func and type(func) == "function" and traceback:find("InteractController") then
              if flags.InstantLastCode then
                  for i, v in debug.getconstants(func) do
                      if type(v) == "number" and v == 0.4 then
                          debug.setconstant(func, i, 0)
                      end
                  end
              end
          end
          
          return oldtaskspawn(func, ...)
      end)
      setreadonly(getgenv().task, true)

      -- Auto Reload implementation
      local reloadGun = LPH_JIT_MAX(function()
          if not Client or not Cheat.Globals.ClientCharacter or not Cheat.Globals.ClientCharacter:FindFirstChild("ViewmodelController") then return end
          local ViewmodelController = Cheat.Globals.ClientCharacter.ViewmodelController
          if not ViewmodelController then return end
          if not Cheat.Globals.VMNetworkPointer then return end
          if not Cheat.Globals.ClientCharacter then Cheat.Globals.ClientCharacter = Client.Character end
          if not Cheat.Globals.ClientCharacter then return end
          if not Cheat.Globals.ClientCharacter:FindFirstChild("InventoryController") then return end
          local inv = Cheat.Globals.ClientCharacter.InventoryController.Fetch:Invoke()
          if not inv or not inv.Toolbar then return end
          local equipped = inv.Toolbar[ViewmodelController:GetAttribute("Equipped")]
          if not equipped or equipped == 0 then return end
          
          local gun = ItemsModule[equipped.ID]
          local ammoType = gun and gun.AmmoType
          if not ammoType then return end
          
          local ammoId = "None"
          for _, containerName in {"Inventory", "Toolbar"} do
              for _, item in inv[containerName] do
                  if item ~= 0 and item.Amount > 0 then
                      local def = ItemsModule[item.ID]
                      if def.Type:find("Ammo") and def.AmmoType == ammoType then
                          ammoId = item.ID
                          break
                      end
                  end
              end
              if ammoId ~= "None" then break end
          end
          if ammoId == "None" then return end
          
          Cheat.Globals.VMNetworkPointer(
              "Fire",
              "d\147e\001R\169#o\249,9\133\153`B4q^W\006",
              "\197s5m:\246\237\135\220Hr\235\001\239\214\\\209\212\219\219",
              workspace:GetServerTimeNow()
          )
      end)

      RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
          if not flags.AutoReload then return end
          local now = tick()
          if now - Cheat.Globals.LastAutoReload > (flags.AutoReloadDelay or 3) then
              Cheat.Globals.LastAutoReload = now
              reloadGun()
          end
      end))

      -- Teleport to Bullet implementation
      Cheat.Globals.TeleportToBulletEvent = Instance.new("BindableEvent")
      Cheat.Globals.TeleportToBulletEvent.Event:Connect(function(position)
          if not flags.TeleportToBullet or not flags.TeleportToBulletBind.Toggled then
              return
          end
          
          local character = Client.Character
          if not character then
              return
          end
          
          local hrp = character:FindFirstChild("HumanoidRootPart")
          if not hrp then
              return
          end
          
          hrp.CFrame = CFrame.new(position) + Vector3.new(0, 2, 0)
          wait()
          hrp.CFrame = CFrame.new(position) + Vector3.new(0, 2, 0)
      end)

      local oldGetSetting = SettingsModule.GetSetting
      SettingsModule.GetSetting = function(v34, v35, v36)
          if v34 == 'General' and v35 == 'Field Of View' then
              if flags.ZoomKeybind and flags.ZoomKeybind.Toggled then
                  return flags.ZoomAmount
              elseif flags.FovChanger then
                  return flags.FovValue or 90
              end
          end
          return oldGetSetting(v34, v35, v36)
      end
  end
  
  --// Visuals
  do
      -- Store original lighting values
      Cheat.Globals.OldClockTime = Lighting.ClockTime
      Cheat.Globals.OldGlobalShadows = Lighting.GlobalShadows
      local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
      if Atmosphere then
          Cheat.Globals.OldFogDensity = Atmosphere.Density
          Cheat.Globals.OldFogHaze = Atmosphere.Haze
          Cheat.Globals.OldFogColor = Atmosphere.Color
      end

      -- Third Person implementation
      do
          local thirdPersonActive = false

          local function showCharacter(character)
              if not character then return end
              for _, part in character:GetDescendants() do
                  if part:IsA("BasePart") then
                      part.LocalTransparencyModifier = 0
                  end
              end
          end

          local function hideViewmodel()
              local VFX = workspace:FindFirstChild("VFX")
              local VMs = VFX and VFX:FindFirstChild("VMs")
              local vm = VMs and VMs:FindFirstChildOfClass("Model")
              if not vm then return end
              for _, part in vm:GetDescendants() do
                  if part:IsA("BasePart") then
                      if part.Transparency ~= 1 then
                          part:SetAttribute("TP_OrigTransparency", part.Transparency)
                      end
                      part.Transparency = 1
                  end
              end
          end

          local function restoreViewmodel()
              local VFX = workspace:FindFirstChild("VFX")
              local VMs = VFX and VFX:FindFirstChild("VMs")
              local vm = VMs and VMs:FindFirstChildOfClass("Model")
              if not vm then return end
              for _, part in vm:GetDescendants() do
                  if part:IsA("BasePart") then
                      local orig = part:GetAttribute("TP_OrigTransparency")
                      if orig then
                          part.Transparency = orig
                          part:SetAttribute("TP_OrigTransparency", nil)
                      end
                  end
              end
          end

          RunService:BindToRenderStep("ThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
              local isThirdPerson = flags.ThirdPerson and (not flags.ThirdPersonBind or flags.ThirdPersonBind.Toggled)
              if not isThirdPerson and not thirdPersonActive then return end

              if isThirdPerson then
                  local dist = flags.ThirdPersonDistance or 5
                  Client.CameraMinZoomDistance = dist
                  Client.CameraMaxZoomDistance = dist
                  Client.CameraMode = Enum.CameraMode.Classic
                  hideViewmodel()
                  showCharacter(Cheat.Globals.ClientCharacter)
                  thirdPersonActive = true
                  Cheat.Globals.ThirdPersonActive = true
                  Cheat.Globals.ThirdPersonDist = dist
              elseif thirdPersonActive then
                  Client.CameraMinZoomDistance = 0
                  Client.CameraMaxZoomDistance = 0
                  restoreViewmodel()
                  thirdPersonActive = false
                  Cheat.Globals.ThirdPersonActive = false
                  Cheat.Globals.ThirdPersonDist = 0
              end
          end)
      end

      -- No Rain implementation
      RunService.Heartbeat:Connect(function()
          if flags.NoRain then
              local rain = workspace:FindFirstChild("Rain")
              if rain then
                  rain:Destroy()
              end
              
              -- Also stop rain sound like INSULIN.lua
              for _, sound in pairs(workspace:GetDescendants()) do
                  if sound:IsA("Sound") and sound.Name:lower():find("rain") and sound.IsPlaying then
                      sound:Stop()
                  end
              end
          end
      end)

      --// Player ESP
      do
          local ESP = {}
  
          local ScreenGui = Instance.new('ScreenGui')
          ScreenGui.IgnoreGuiInset = true
          ScreenGui.Parent = gethui()
  
          local OUTLINE = 1
          local BOX_THICKNESS = 2
          local NAME_PADDING_X = 6
          local NAME_PADDING_Y = 2
  
          local function BoxMath(item)
              if not item then return nil, nil, false end
              local Torso =
                  item:FindFirstChild('HumanoidRootPart')
                  or item:FindFirstChild('UpperTorso')
                  or item:FindFirstChild('Torso')
              if not Torso then return nil, nil, false end
              local cf = Torso.CFrame
              local pos = Torso.Position
              local vTop = pos + (cf.UpVector * 2)
              local vBottom = pos - (cf.UpVector * 2.8)
              local top, topVisible = Camera:WorldToViewportPoint(vTop)
              local bottom, bottomVisible = Camera:WorldToViewportPoint(vBottom)
              if not topVisible and not bottomVisible then return nil, nil, false end
              local height = math.abs(bottom.Y - top.Y)
              if height <= 0 then return nil, nil, false end
              local width = height / 1.2
              return Vector2.new(
                  math.floor((top.X + bottom.X) * 0.5 - width * 0.5),
                  math.min(top.Y, bottom.Y)
              ), Vector2.new(width, height), true
          end
  
          local function createBox(parent, color)
              local box = Instance.new('Frame')
              box.BackgroundTransparency = 1
              box.Parent = parent
              local sides = {}
              for i = 1, 4 do
                  local f = Instance.new('Frame')
                  f.BorderSizePixel = 0
                  f.BackgroundColor3 = color
                  f.Parent = box
                  sides[i] = f
              end
              return box, sides
          end
  
          local function newText()
              local t = Instance.new('TextLabel')
              t.BackgroundTransparency = 1
              t.TextColor3 = Color3.new(1,1,1)
              t.TextTransparency = 0
              t.TextStrokeColor3 = Color3.new(0,0,0)
              t.TextStrokeTransparency = 0
              t.FontFace = Font.fromEnum(Enum.Font.Gotham)
              t.TextSize = 11
              t.TextXAlignment = Enum.TextXAlignment.Center
              t.TextYAlignment = Enum.TextYAlignment.Center
              return t
          end
  
          local function createESP(char, name, classname)
              local holder = Instance.new('Frame')
              holder.BackgroundTransparency = 1
              holder.Visible = false
              holder.Parent = ScreenGui
  
              local nameText = newText()
              nameText.Text = name
              nameText.Parent = holder
  
              local boxGroup = Instance.new('Frame')
              boxGroup.BackgroundTransparency = 1
              boxGroup.Parent = holder
  
              local outerBox, outerSides = createBox(boxGroup, Color3.new(0,0,0))
              local gradBox, gradSides = createBox(boxGroup, Color3.new(1,1,1))
              local innerBox, innerSides = createBox(boxGroup, Color3.new(0,0,0))
  
              local gradients = {}
              for i = 1, 4 do
                  local g = Instance.new('UIGradient')
                  g.Rotation = 90
                  g.Parent = gradSides[i]
                  gradients[i] = g
              end
  
              local healthBack = Instance.new('Frame')
              healthBack.BackgroundTransparency = 1
              healthBack.BorderSizePixel = 0
              healthBack.Parent = holder
  
              local healthOutline = Instance.new('Frame')
              healthOutline.BackgroundColor3 = Color3.new(0,0,0)
              healthOutline.BorderSizePixel = 0
              healthOutline.Parent = healthBack
  
              local healthInner = Instance.new('Frame')
              healthInner.BackgroundColor3 = Color3.fromRGB(35,35,35)
              healthInner.BorderSizePixel = 0
              healthInner.Parent = healthBack
  
              local healthFillHolder = Instance.new('Frame')
              healthFillHolder.BackgroundTransparency = 1
              healthFillHolder.BorderSizePixel = 0
              healthFillHolder.ClipsDescendants = true
              healthFillHolder.Parent = healthInner
  
              local healthFill = Instance.new('Frame')
              healthFill.BorderSizePixel = 0
              healthFill.AnchorPoint = Vector2.new(0,1)
              healthFill.Position = UDim2.fromScale(0,1)
              healthFill.Size = UDim2.fromScale(1,1)
              healthFill.BackgroundColor3 = Color3.new(1,1,1)
              healthFill.Parent = healthFillHolder
  
              local healthGradient = Instance.new('UIGradient')
              healthGradient.Rotation = 90
              healthGradient.Parent = healthFill
  
              local distText = newText()
              distText.Parent = holder
  
              local weaponText = newText()
              weaponText.Text = '[None]'
              weaponText.Parent = holder
  
              ESP[char] = {
                  Holder = holder,
                  Name = nameText,
                  BoxGroup = boxGroup,
                  OuterBox = outerBox,
                  OuterSides = outerSides,
                  GradBox = gradBox,
                  GradSides = gradSides,
                  Gradients = gradients,
                  InnerBox = innerBox,
                  InnerSides = innerSides,
                  HealthBack = healthBack,
                  HealthOutline = healthOutline,
                  HealthInner = healthInner,
                  HealthFillHolder = healthFillHolder,
                  HealthFill = healthFill,
                  HealthGradient = healthGradient,
                  Distance = distText,
                  Weapon = weaponText,
                  Class = classname,
              }
          end
  
          local function sizeSides(sides, w, h, t)
              sides[1].Position = UDim2.fromOffset(0,0)
              sides[1].Size = UDim2.fromOffset(w, t)
              sides[2].Position = UDim2.fromOffset(0, h - t)
              sides[2].Size = UDim2.fromOffset(w, t)
              sides[3].Position = UDim2.fromOffset(0,0)
              sides[3].Size = UDim2.fromOffset(t, h)
              sides[4].Position = UDim2.fromOffset(w - t,0)
              sides[4].Size = UDim2.fromOffset(t, h)
          end
  
          RunService.RenderStepped:Connect(function()
              for char, e in pairs(ESP) do
                  local class = e.Class
                  if not flags[class .. 'ESPEnabled'] then
                      e.Holder.Visible = false
                      continue
                  end
  
                  local hum = char:FindFirstChildOfClass('Humanoid')
                  if not hum or hum.Health <= 0 then
                      e.Holder.Visible = false
                      continue
                  end
  
                  local pos, size, ok = BoxMath(char)
                  if not ok then
                      e.Holder.Visible = false
                      continue
                  end
                  local distance = (Camera.CFrame.Position - char:GetPivot().Position).Magnitude
                  if distance > flags[class .. 'MaxDistance'] then
                      e.Holder.Visible = false
                      continue
                  end
  
                  local barW = 4
                  local gap = 4
                  local reservedLeft = barW + gap + OUTLINE
  
                  e.Holder.Position = UDim2.fromOffset(pos.X - reservedLeft, pos.Y)
                  e.Holder.Visible = true
  
                  e.BoxGroup.Position = UDim2.fromOffset(reservedLeft, 0)
                  e.BoxGroup.Size = UDim2.fromOffset(size.X, size.Y)
  
                  e.Name.Position = UDim2.fromOffset(reservedLeft - NAME_PADDING_X, -15 - NAME_PADDING_Y)
                  e.Name.Size = UDim2.fromOffset(size.X + NAME_PADDING_X*2, 14 + NAME_PADDING_Y*2)
                  e.Name.Visible = flags[class .. 'Names']
                  local nameColor = flags[class .. 'NameColor']
                  e.Name.TextColor3 = nameColor and nameColor.Color or Color3.fromRGB(255, 255, 255)
  
                  e.OuterBox.Position = UDim2.fromOffset(-OUTLINE, -OUTLINE)
                  e.OuterBox.Size = UDim2.fromOffset(size.X + OUTLINE*2, size.Y + OUTLINE*2)
                  sizeSides(e.OuterSides, size.X + OUTLINE*2, size.Y + OUTLINE*2, OUTLINE)
  
                  e.GradBox.Position = UDim2.fromOffset(0,0)
                  e.GradBox.Size = UDim2.fromOffset(size.X, size.Y)
                  sizeSides(e.GradSides, size.X, size.Y, BOX_THICKNESS)
  
                  e.InnerBox.Position = UDim2.fromOffset(OUTLINE, OUTLINE)
                  e.InnerBox.Size = UDim2.fromOffset(size.X - OUTLINE*2, size.Y - OUTLINE*2)
                  sizeSides(e.InnerSides, size.X - OUTLINE*2, size.Y - OUTLINE*2, OUTLINE)
  
                  local on = flags[class .. 'Boxes']
                  e.OuterBox.Visible = on
                  e.GradBox.Visible = on
                  e.InnerBox.Visible = on
  
                  local boxC1 = flags[class .. 'BoxColor1'] and flags[class .. 'BoxColor1'].Color or Color3.fromRGB(255, 255, 255)
                  for _, g in ipairs(e.Gradients) do
                      g.Color = ColorSequence.new(boxC1)
                  end
  
                  e.HealthBack.Visible = flags[class .. 'Health']
                  e.HealthBack.Position = UDim2.fromOffset(reservedLeft - barW - gap, 0)
                  e.HealthBack.Size = UDim2.fromOffset(barW, size.Y)
  
                  e.HealthOutline.Position = UDim2.fromOffset(0,0)
                  e.HealthOutline.Size = UDim2.fromOffset(barW, size.Y)
  
                  e.HealthInner.Position = UDim2.fromOffset(1,1)
                  e.HealthInner.Size = UDim2.fromOffset(barW - 2, size.Y - 2)
  
                  e.HealthFillHolder.Position = UDim2.fromOffset(0,0)
                  e.HealthFillHolder.Size = UDim2.fromScale(1,1)
  
                  local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                  e.HealthFill.Size = UDim2.fromScale(1, hp)
  
                  -- Hardcoded gradient colors for health bar
                  e.HealthGradient.Color = ColorSequence.new({
                      ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),   -- Red (low health)
                      ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 50)), -- Yellow (mid health)
                      ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 255, 120)),   -- Green (full health)
                  })
  
                  e.Distance.Position = UDim2.fromOffset(reservedLeft, size.Y + 6)
                  e.Distance.Size = UDim2.fromOffset(size.X, 14)
                  e.Distance.Visible = flags[class .. 'Distance']
                  e.Distance.Text = math.floor(distance) .. ' studs'
                  local distColor = flags[class .. 'DistanceColor']
                  e.Distance.TextColor3 = distColor and distColor.Color or Color3.fromRGB(255, 255, 255)
  
                  e.Weapon.Position = UDim2.fromOffset(reservedLeft, size.Y + 20)
                  e.Weapon.Size = UDim2.fromOffset(size.X, 14)
                  e.Weapon.Visible = flags[class .. 'Weapon']
                  e.Weapon.Text = "[" .. getgun(char) .. "]"
                  local weapColor = flags[class .. 'WeaponColor']
                  e.Weapon.TextColor3 = weapColor and weapColor.Color or Color3.fromRGB(255, 255, 255)
              end
          end)
  
          local function hookPlayer(p)
              if p == Client then return end
              p.CharacterAdded:Connect(function(c) createESP(c, p.Name, 'Players') end)
              p.CharacterRemoving:Connect(function(c) 
                  local e = ESP[c]
                  if e then 
                      e.Holder:Destroy() 
                      ESP[c] = nil
                  end 
              end)
              if p.Character then 
                  createESP(p.Character, p.Name, 'Players') 
              end
          end
  
          for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
          Players.PlayerAdded:Connect(hookPlayer)
          Players.PlayerRemoving:Connect(function(p)
              if p.Character and ESP[p.Character] then 
                  local e = ESP[p.Character]
                  e.Holder:Destroy()
                  ESP[p.Character]=nil 
              end
          end)
  
          local SoldierClassType = {
              Brutus = "Boss",
              Bruno = "Boss",
              BTR = "Boss",
              Boris = "Boss",
              Soldier = "AI",
          }
  
          local Military = workspace:FindFirstChild('Military')
          local Events = workspace:FindFirstChild('Events')
  
          if Military and Events then
              local function CacheSoldier(model)
                  if (not model) or (not model.Parent) then return end
                  local classType = SoldierClassType[model.Name]
                  if not classType then return end
                  if ESP[model] then return end
                  createESP(model, model.Name, classType)
              end
  
              local function OnModelAdded(model)
                  task.defer(function()
                      if model and model.Parent then
                          CacheSoldier(model)
                      end
                  end)
              end
  
              local function OnModelRemoved(model)
                  if model and ESP[model] then ESP[model].Holder:Destroy() ESP[model]=nil end
              end
  
              for _, obj in ipairs(Events:GetChildren()) do
                  if obj.Name == 'BTR' then
                      CacheSoldier(obj)
                  end
              end
  
              Events.ChildAdded:Connect(function(obj)
                  if obj.Name == 'BTR' then
                      OnModelAdded(obj)
                  end
              end)
  
              Events.ChildRemoved:Connect(function(obj)
                  if obj.Name == 'BTR' then
                      OnModelRemoved(obj)
                  end
              end)
  
              for _, folder in ipairs(Military:GetChildren()) do
                  for _, soldier in ipairs(folder:GetChildren()) do
                      if soldier:IsA('Model') then
                          CacheSoldier(soldier)
                      end
                  end
  
                  folder.ChildAdded:Connect(function(soldier)
                      if soldier:IsA('Model') then
                          OnModelAdded(soldier)
                      end
                  end)
  
                  folder.ChildRemoved:Connect(function(soldier)
                      if soldier:IsA('Model') then
                          OnModelRemoved(soldier)
                      end
                  end)
              end
          end
      end
  
      --// Fov Circle
      do
          local FovCircleOutline = Drawing.new('Circle')
          FovCircleOutline.Visible = false
          FovCircleOutline.NumSides = 64
          FovCircleOutline.ZIndex = 9
          FovCircleOutline.Filled = false
          FovCircleOutline.Transparency = 1
          FovCircleOutline.Radius = 200
          FovCircleOutline.Thickness = 4
          FovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
  
          local FovCircle = Drawing.new('Circle')
          FovCircle.Visible = false
          FovCircle.NumSides = 64
          FovCircle.ZIndex = 10
          FovCircle.Filled = false
          FovCircle.Transparency = 1
          FovCircle.Radius = 200
          FovCircle.Thickness = 2
          FovCircle.Color = Color3.fromRGB(34, 136, 207)
  
          -- Combat Indicators Container
          local textHolder = Instance.new('Frame')
          textHolder.BackgroundTransparency = 1
          textHolder.BorderSizePixel = 0
          textHolder.ZIndex = 8
          textHolder.AnchorPoint = Vector2.new(0.5, 0)
          textHolder.Size = UDim2.fromOffset(220, 60)
          textHolder.Position = UDim2.new(0.5, 0, 0.5, 10)
          textHolder.AutomaticSize = Enum.AutomaticSize.Y
          textHolder.Visible = true
          textHolder.Parent = gethui()
  
          local layout = Instance.new('UIListLayout')
          layout.FillDirection = Enum.FillDirection.Vertical
          layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
          layout.VerticalAlignment = Enum.VerticalAlignment.Top
          layout.SortOrder = Enum.SortOrder.LayoutOrder
          layout.Padding = UDim.new(0, 2)
          layout.Parent = textHolder
  
          -- Helper function to create indicator labels
          local function makeIndicatorLabel(order)
              local lbl = Instance.new('TextLabel')
              lbl.BackgroundTransparency = 1
              lbl.Size = UDim2.fromOffset(0, 12)
              lbl.AutomaticSize = Enum.AutomaticSize.X
              lbl.TextWrapped = false
              lbl.FontFace = Font.fromEnum(Enum.Font.Gotham)
              lbl.TextSize = 12
              lbl.TextColor3 = Color3.new(1, 1, 1)
              lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
              lbl.TextStrokeTransparency = 0
              lbl.LayoutOrder = order
              lbl.Visible = false
              lbl.ZIndex = textHolder.ZIndex
              lbl.Parent = textHolder
              return lbl
          end

          local manipulatedText = makeIndicatorLabel(1)
          local visibleText = makeIndicatorLabel(2)
          local usernameText = makeIndicatorLabel(3)

          RunService.RenderStepped:Connect(function()
              local radius = flags.FovSize or 200
              local thickness = flags.FovThickness or 2
  
              local vp = Camera.ViewportSize
              local pos = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
  
              local hasTarget = not not Targeting.TargetObject
              local isManipulated = false
              if flags.Manipulation and hasTarget and Targeting.ManipulatedPosition then
                  isManipulated = true
              end
  
              -- Combat Indicators
              if flags.CombatIndicators and hasTarget then
                  -- Username (always at bottom, white text)
                  local targetPlayer = Targeting.TargetObject and Targeting.TargetObject.Player
                  if targetPlayer then
                      usernameText.Text = targetPlayer.Name
                      usernameText.TextColor3 = Color3.fromRGB(255, 255, 255)
                      usernameText.Visible = true
                  else
                      usernameText.Visible = false
                  end

                  -- Visible Status (green when visible, hidden when not)
                  if Targeting.TargetObject.CoreInformation and Targeting.TargetObject.CoreInformation.Visible then
                      visibleText.Text = "VISIBLE"
                      visibleText.TextColor3 = Color3.fromRGB(0, 255, 0)
                      visibleText.Visible = true
                  else
                      visibleText.Visible = false
                  end

                  -- Manipulation Status (only show when manipulated)
                  if flags.Manipulation and isManipulated then
                      manipulatedText.Text = "MANIPULATED"
                      manipulatedText.TextColor3 = flags.ManipulationIndicatorColor and flags.ManipulationIndicatorColor.Color or Color3.fromRGB(34, 136, 207)
                      manipulatedText.Visible = true
                  else
                      manipulatedText.Visible = false
                  end
              else
                  -- Hide all indicators when no target or indicators disabled
                  manipulatedText.Visible = false
                  visibleText.Visible = false
                  usernameText.Visible = false
              end
  
              if (not flags.FovEnabled) then
                  FovCircle.Visible = false
                  FovCircleOutline.Visible = false
                  return
              end
  
              local col = flags.FovColor
  
              FovCircle.Position = pos
              FovCircleOutline.Position = pos
  
              FovCircle.Radius = radius
              FovCircleOutline.Radius = radius
  
              FovCircle.Thickness = thickness
              FovCircleOutline.Thickness = thickness + 2
  
              if col then
                  FovCircle.Color = col.Color
                  FovCircle.Transparency = (col.Transparency or 0)
                  FovCircleOutline.Transparency = FovCircle.Transparency
              end
  
              FovCircle.Filled = (flags.FovFilled == true)
              FovCircleOutline.Filled = false
  
  
              FovCircle.Visible = true
              FovCircleOutline.Visible = true
          end)
      end
  
      --// Ambience
      do
          local folder = Instance.new('Folder')
          folder.Parent = workspace
  
          local chunks = {}
          local lights = {}
          local bases = {}
  
          local rayParams = RaycastParams.new()
          rayParams.FilterType = Enum.RaycastFilterType.Blacklist
          rayParams.FilterDescendantsInstances = { folder }
  
          local function key(cx, cy, cz)
              return cx .. ':' .. cy .. ':' .. cz
          end
  
          local classify = LPH_NO_VIRTUALIZE(function(pos)
              return Workspace:Raycast(pos, Vector3.new(0, 200, 0), rayParams) ~= nil
                  and 'Indoor'
                  or 'Outdoor'
          end)
  
          local createNode = LPH_NO_VIRTUALIZE(function(pos)
              local p = Instance.new('Part')
              p.Size = Vector3.new(0.1, 0.1, 0.1)
              p.Anchored = true
              p.CanCollide = false
              p.Transparency = 1
              p.CFrame = CFrame.new(pos)
              p.Parent = folder
  
              local l = Instance.new('PointLight')
              l.Range = 140
              l.Shadows = false
  
              local t = classify(pos)
              local base =
                  (t == 'Indoor' and flags.AmbienceIndoorBrightness)
                  or flags.AmbienceBrightness
  
              l.Brightness = base
              l.Parent = p
  
              lights[l] = true
              bases[l] = base
  
              if flags.AmbienceEnabled then
                  l.Color = flags.AmbienceColor.Color
              end
  
              return p
          end)
  
          local buildChunk = LPH_NO_VIRTUALIZE(function(cx, cy, cz)
              local k = key(cx, cy, cz)
              if chunks[k] then return end
  
              local group = {}
              local basePos = Vector3.new(cx * 150, cy * 150, cz * 150)
  
              for x = 0, 150, 100 do
                  for y = 0, 150, 100 do
                      for z = 0, 150, 100 do
                          group[#group + 1] =
                              createNode(basePos + Vector3.new(x, y, z))
                      end
                  end
              end
  
              chunks[k] = group
          end)
  
          local destroyChunk = LPH_NO_VIRTUALIZE(function(k)
              local group = chunks[k]
              if not group then return end
              for i = 1, #group do
                  group[i]:Destroy()
              end
              chunks[k] = nil
          end)
  
          folder.DescendantRemoving:Connect(function(d)
              if d:IsA('PointLight') then
                  lights[d] = nil
                  bases[d] = nil
              end
          end)
  
          local sceneLuminance = LPH_NO_VIRTUALIZE(function()
              local t = Lighting.ClockTime
              local sun = math.clamp(
                  math.cos((t - 14) / 24 * math.pi * 2) * -0.5 + 0.5,
                  0,
                  1
              )
  
              local amb =
                  (Lighting.Ambient.R + Lighting.Ambient.G + Lighting.Ambient.B) / 3
  
              return math.max(
                  0.05,
                  (sun * 0.7 + amb * 0.3) * (2 ^ Lighting.ExposureCompensation)
              )
          end)
  
          local recomputeBases = LPH_NO_VIRTUALIZE(function()
              for light in pairs(lights) do
                  if (light.Parent) then
                      local t = light:GetAttribute('AmbienceType')
                      bases[light] =
                          (t == 'Indoor' and flags.AmbienceIndoorBrightness)
                          or flags.AmbienceBrightness
                  end
              end
          end)
  
          local lastCenter
          local scale = 1
          local lastAppliedScale = 1
          local acc = 0
          local savedflags = {
              AmbienceBrightness = flags.AmbienceBrightness,
              AmbienceIndoorBrightness = flags.AmbienceIndoorBrightness,
              AmbienceEnabled = flags.AmbienceEnabled,
              AmbienceColor = {
                  Color = flags.AmbienceColor.Color
              }
          }
  
          RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
              local cam = Workspace.CurrentCamera
              if not cam then return end
  
              local pos = cam.CFrame.Position
              local center = Vector3.new(
                  math.floor(pos.X / 150),
                  math.floor(pos.Y / 150),
                  math.floor(pos.Z / 150)
              )
  
              if not lastCenter or center ~= lastCenter then
                  lastCenter = center
                  local needed = {}
  
                  for x = -2, 2 do
                      for y = -2, 2 do
                          for z = -2, 2 do
                              local k = key(center.X + x, center.Y + y, center.Z + z)
                              needed[k] = true
                              buildChunk(center.X + x, center.Y + y, center.Z + z)
                          end
                      end
                  end
  
                  for k in pairs(chunks) do
                      if not needed[k] then
                          destroyChunk(k)
                      end
                  end
  
                  acc = 0.11
              end
  
              acc = acc + dt
              if acc < 0.2 then return end
              acc = 0
  
              local desired = math.clamp(1.0 / sceneLuminance(), 0.25, 1.6)
              scale = scale + (desired - scale) * 0.6
  
              local flagschanged = false
  
              if (savedflags.AmbienceBrightness ~= flags.AmbienceBrightness) then
                  savedflags.AmbienceBrightness = flags.AmbienceBrightness
                  flagschanged = true
              end
  
              if (savedflags.AmbienceIndoorBrightness ~= flags.AmbienceIndoorBrightness) then
                  savedflags.AmbienceIndoorBrightness = flags.AmbienceIndoorBrightness
                  flagschanged = true
              end
  
              if (savedflags.AmbienceEnabled ~= flags.AmbienceEnabled) then
                  savedflags.AmbienceEnabled = flags.AmbienceEnabled
                  flagschanged = true
              end
  
              if (savedflags.AmbienceColor.Color ~= flags.AmbienceColor.Color) then
                  savedflags.AmbienceColor.Color = flags.AmbienceColor.Color
                  flagschanged = true
              end
  
              if (flagschanged) then
                  recomputeBases()
                  lastAppliedScale = -1
              end
  
              if math.abs(scale - lastAppliedScale) < 0.02 then
                  return
              end
  
              lastAppliedScale = scale
  
              for light in pairs(lights) do
                  if light.Parent then
                      if flags.AmbienceEnabled then
                          light.Brightness = bases[light] * scale
                          light.Color = flags.AmbienceColor.Color
                      else
                          -- Restore original brightness instead of setting to 0
                          light.Brightness = bases[light] or light.Brightness
                      end
                  end
              end
          end))
      end
  
      --// Inventory Viewer
      do
          local textureToInfoMap = {}
          local GunTable = {}
          for _, gun in next, ItemsModule do
              if typeof(gun.Image) == 'table' then
                  GunTable[gun.Name] = gun.Image
              else
                  GunTable[gun.Name] = {['Default'] = gun.Image}
              end
          end
  
          for _, gunModel in ReplicatedStorage:WaitForChild("VMs"):GetChildren() do
              for _, skinModel in gunModel:GetChildren() do
                  local weaponFolder = skinModel:FindFirstChild("Weapon")
                  if weaponFolder and weaponFolder:IsA("Folder") then
                      for _, part in weaponFolder:GetChildren() do
                          local textureId = nil
                          pcall(function()
                              textureId = part.TextureID
                          end)
                          if textureId then
                              textureToInfoMap[textureId] = {
                                  gun = gunModel.Name,
                                  skin = skinModel.Name,
                              }
                          end
                      end
                  end
              end
          end
  
          local GetArmor = LPH_NO_VIRTUALIZE(function(Character)
              local final = {}
              local names = {}
              if not Character then return {} end
              if type(Character) == 'string' then
                  return {}
              end
              for _, child in Character:GetChildren() do
                  local armorNumber, skinName = child.Name:match('Armor_(%d+)/?(.*)')
                  if skinName == "" then skinName = nil end
  
                  if armorNumber then
                      local key = tonumber(armorNumber)
                      if key then
                          local item = ItemsModule[key]
                          if item and item.Type == 'Armor' and not table.find(names, item.Name) then
                              local image = ''
                              if type(item.Image) == 'table' then
                                  if skinName and item.Image[skinName] then
                                      image = item.Image[skinName]
                                  elseif item.Image.Default then
                                      image = item.Image.Default
                                  end
                              elseif type(item.Image) == 'string' then
                                  image = item.Image
                              end
  
                              local id = string.match(image or '', '%d+')
                              local imageData = ''
  
                              table.insert(names, item.Name)
                              table.insert(final, {
                                  ['Skin'] = skinName,
                                  ['Name'] = item.Name,
                                  ['Type'] = item.ArmorType,
                                  ['Image'] = id
                              })
                          end
                      end
                  end
              end
  
              return final
          end)
  
          local displayedItems = {}
          local lastTargetCharacter = nil
          
          RunService.Heartbeat:Connect(function()
              local character = Targeting.TargetCharacter
              local visible = not not (flags.InventoryViewerEnabled and character)
              
              -- Only update if target changed or visibility changed
              if character ~= lastTargetCharacter then
                  lastTargetCharacter = character
                  displayedItems = {}
                  
                  if not visible then
                      ArmorViewer:SetVisibility(false)
                      ArmorViewer:ClearAllItems()
                      return
                  end
                  
                  ArmorViewer:SetVisibility(true)
                  local armorData = GetArmor(character)
                  local newItems = {}
                  
                  for _, armor in ipairs(armorData) do
                      local imageUrl = ''
                      if armor.Image and tonumber(armor.Image) then
                          imageUrl = 'rbxassetid://' .. tostring(armor.Image)
                      elseif armor.Skin and GunTable[armor.Name] and GunTable[armor.Name][armor.Skin] then
                          imageUrl = GunTable[armor.Name][armor.Skin]
                      elseif GunTable[armor.Name] and GunTable[armor.Name]['Default'] then
                          imageUrl = GunTable[armor.Name]['Default']
                      end
                      newItems[armor.Name] = imageUrl
                  end
                  
                  displayedItems = newItems
                  ArmorViewer:ClearAllItems()
                  
                  -- Get player name safely
                  local playerName = "Unknown"
                  if Targeting.TargetObject and Targeting.TargetObject.Player then
                      playerName = Targeting.TargetObject.Player.Name
                  elseif character and type(character.Name) == "string" then
                      playerName = character.Name
                  end
                  ArmorViewer:SetTitle(playerName .. "'s inventory")
                  
                  for name, imageUrl in pairs(newItems) do
                      ArmorViewer:Add(name, imageUrl)
                  end
              elseif not visible then
                  ArmorViewer:SetVisibility(false)
              else
                  ArmorViewer:SetVisibility(true)
              end
          end)
      end
  
      --// Misc ESP
      do
          local miscCache = {}
          local worldToViewportPoint = Camera.WorldToViewportPoint
  
          local ScreenGui = Instance.new('ScreenGui')
          ScreenGui.IgnoreGuiInset = true
          ScreenGui.Parent = gethui()
  
          local function espify(obj, staticname, manualflag)
              if not obj or miscCache[obj] then return end
  
              local flag = manualflag or obj.Name:gsub('_Node$', '')
  
              local label = Instance.new('TextLabel')
              label.BackgroundTransparency = 1
              label.TextSize = 12
              label.FontFace = Font.fromEnum(Enum.Font.Gotham)
              label.TextColor3 = Color3.new(1, 1, 1)
              label.AnchorPoint = Vector2.new(0.5, 0.5)
              label.AutomaticSize = Enum.AutomaticSize.XY
              label.Size = UDim2.fromOffset(0, 0)
              label.Visible = false
              label.Parent = ScreenGui
  
              local stroke = Instance.new('UIStroke')
              stroke.Thickness = 1
              stroke.Color = Color3.new(0, 0, 0)
              stroke.Parent = label
  
              miscCache[obj] = {
                  obj = obj,
                  label = label,
                  stroke = stroke,
                  flag = flag,
                  staticname = staticname
              }
          end
  
  
          local function removeEsp(obj)
              local data = miscCache[obj]
              if data then
                  data.label:Destroy()
                  miscCache[obj] = nil
              end
          end
  
          local nodes = workspace:FindFirstChild('Nodes')
          local bases = workspace:FindFirstChild('Bases')
  
          if nodes then
              local function addNode(v)
                  if v:IsA('BasePart') or v:IsA('Model') then
                      espify(v)
                  end
              end
  
              for _, v in nodes:GetChildren() do
                  addNode(v)
              end
  
              nodes.ChildAdded:Connect(addNode)
              nodes.ChildRemoved:Connect(removeEsp)
          end
  
          if bases then
              local function handleObject(obj)
                  if obj:IsA('Model') and (obj.Name == 'Care Package' or obj.Name == 'Salvaged Flycopter' or obj.Name == 'Body Bag' or obj.Name == 'Auto Turret' or obj.Name == 'Shotgun Turret') then
                      espify(obj)
                  end
              end
  
              local function handleFolder(folder)
                  for _, obj in folder:GetChildren() do
                      handleObject(obj)
                  end
                  folder.ChildAdded:Connect(handleObject)
              end
  
              for _, base in bases:GetChildren() do
                  for _, folder in base:GetChildren() do
                      handleFolder(folder)
                  end
                  base.ChildAdded:Connect(handleFolder)
              end
          end
          
          if Drops and Plants then
              RunService.RenderStepped:Connect(function()
                  if not flags.MiscEnabledESP then return end
                  for _, item in pairs(Drops:GetChildren()) do
                      if item:IsA('Model') and not miscCache[item] then
                          local distance = (Camera.CFrame.Position - item:GetPivot().Position).Magnitude
                          if distance <= flags.DropsMaxDistance then
                              espify(item, item.Name, 'Drops')
                          end
                      end
                  end
                  for _, plant in pairs(Plants:GetChildren()) do
                      if plant:IsA('Model') and not miscCache[plant] then
                          local name = string.gsub(plant.Name, ' Plant', '')
                          local distance = (Camera.CFrame.Position - plant:GetPivot().Position).Magnitude
  
                          if name == 'Wool' and distance <= flags.WoolMaxDistance then
                              espify(plant, 'Wool', 'Wool')
                          end
                      end
                  end
              end)
          end
  
          if Animals then
              for _, animal in pairs(Animals:GetChildren()) do
                  if animal:IsA('Model') then
                      local name = animal.Name:lower():gsub('prefab_animal_', ''):gsub('_', ' ')
                      espify(animal, name, 'Animals')
                  end
              end
              Animals.ChildAdded:Connect(function(animal)
                  if animal:IsA('Model') then
                      local name = animal.Name:lower():gsub('prefab_animal_', ''):gsub('_', ' ')
                      espify(animal, name, 'Animals')
                  end
              end)
              Animals.ChildRemoved:Connect(removeEsp)
          end
  
          local step = 1 / 60
          local lastTick = tick()
          
          local function getWorldPosition(obj)
              if obj:IsA('BasePart') then
                  return obj.Position
              elseif obj:IsA('Model') then
                  return obj:GetPivot().Position
              end
          end
  
          RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
              local now = tick()
              if now - lastTick < step then return end
              lastTick = now
  
              local miscEnabled = flags.MiscEnabledESP
              local camPos = Camera.CFrame.Position
  
              for obj, data in pairs(miscCache) do
                  if not obj or not obj.Parent then
                      data.label:Destroy()
                      miscCache[obj] = nil
                      continue
                  end
  
                  if not miscEnabled or not flags[data.flag .. 'Enabled'] then
                      data.label.Visible = false
                      continue
                  end
  
                  local worldPos
                  if obj:IsA('BasePart') then
                      worldPos = obj.Position
                  else
                      worldPos = obj:GetPivot().Position
                  end
  
                  local screenPos, onScreen = worldToViewportPoint(Camera, worldPos)
                  if not onScreen then
                      data.label.Visible = false
                      continue
                  end
  
                  local dist = (camPos - worldPos).Magnitude
                  if dist > flags[data.flag .. 'MaxDistance'] then
                      data.label.Visible = false
                      continue
                  end
                  local name = data.staticname or data.flag
                  
                  data.label.Visible = true
                  data.label.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
                  data.label.Text = string.format('%s \n%.1f Studs', name, dist)
  
                  local col = flags[data.flag .. 'Color']
                  if col then
                      data.label.TextColor3 = col.Color
                  end
              end
          end))
      end
  end
  
  --// Targeting
  do
      Cheat.Globals.RaycastParams = RaycastParams.new()
      Cheat.Globals.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
      Cheat.Globals.RaycastParams.IgnoreWater = true
  
      local IsPartVisible = LPH_NO_VIRTUALIZE(function(Part, Origin)
          if not Part then return false end
          local Head = Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild('Head')
          if not Head then return false end
          Origin = Origin or Head.CFrame.Position
          local to = Part.CFrame.Position
          local dir = (to - Origin)
          local RayResult = workspace:Raycast(Origin, dir, Cheat.Globals.RaycastParams)
          if not RayResult then return true end
          local inst = RayResult.Instance
          return inst and inst:IsDescendantOf(Part.Parent) or false
      end)
  
      local GetDistanceFromCenter = LPH_NO_VIRTUALIZE(function(part)
          local position = part
          if typeof(part) == "Instance" then position = part.CFrame.Position end
          local sp, on = Camera:WorldToViewportPoint(position)
          if not on then return math.huge end
          local c = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
          return (c - Vector2.new(sp.X, sp.Y)).Magnitude
      end)
  
      local vectors = {
          Vector3.new(0.5, 0, 0), Vector3.new(-0.5, 0, 0),
          Vector3.new(0, 0, 0.5), Vector3.new(0, 0, -0.5),
          Vector3.new(0, 0.5, 0), Vector3.new(0, -0.5, 0),
          Vector3.new(0.5, 0.5, 0), Vector3.new(0.5, -0.5, 0),
          Vector3.new(-0.5, 0.5, 0), Vector3.new(-0.5, -0.5, 0),
          Vector3.new(0, 0.5, 0.5), Vector3.new(0, -0.5, 0.5),
          Vector3.new(0, 0.5, -0.5), Vector3.new(0, -0.5, -0.5),
          Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
          Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
          Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
      }
  
      local is_cframe_visible = LPH_NO_VIRTUALIZE(function(cfrom, cto)
          if not (cfrom and cto) then return false end
          local hit = workspace:Raycast(cfrom.Position, cto.Position - cfrom.Position, Cheat.Globals.RaycastParams)
          return not hit
      end)
  
      local is_part_visible = LPH_NO_VIRTUALIZE(function(originCF, target_part)
          if not (originCF and target_part) then return false end
          
          if typeof(originCF) == 'Vector3' then
              originCF = CFrame.new(originCF)
          elseif typeof(originCF) ~= 'CFrame' then
              return false
          end
  
          local originPos = originCF.Position
          local targetPos = target_part:GetPivot().Position
          local direction = targetPos - originPos
  
          local hit = workspace:Raycast(originPos, direction, Cheat.Globals.RaycastParams)
          if not hit then return true end
          return hit.Instance and hit.Instance.Parent == target_part.Parent or false
      end)
  
      local get_hit_scan_pos = LPH_NO_VIRTUALIZE(function(origin_cframe, target_part)
          for _, vector in vectors do
              local modified = target_part.CFrame * CFrame.new(vector * 4)
  
              if is_part_visible(modified, target_part) and is_cframe_visible(origin_cframe, modified) then
                  return modified.Position
              end
          end
  
          return
      end)

      local manipOffsets = {
          Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0),
          Vector3.new(6, 0, 0), Vector3.new(-6, 0, 0),
          Vector3.new(4, 0, 0), Vector3.new(-4, 0, 0),

          Vector3.new(3, 2, 0), Vector3.new(-3, 2, 0),
          Vector3.new(6, 2, 0), Vector3.new(-6, 2, 0),
          Vector3.new(4, 2, 0), Vector3.new(-4, 2, 0),

          Vector3.new(0.2, 3.9, 0), Vector3.new(1.8, 4.1, 1),
          Vector3.new(2.1, 4.4, 1.1), Vector3.new(0.15, 5.2, 0.1),
          Vector3.new(-1.8, 5.4, -0.2), Vector3.new(-2.3, 6.0, -0.4),
          Vector3.new(0.1, 6.0, 0.0),

          Vector3.new(7, 0, 0), Vector3.new(-7, 0, 0),
          Vector3.new(7, 2, 0), Vector3.new(-7, 2, 0),

          Vector3.new(0.1, 7.5, 0.0), Vector3.new(0.1, 8.0, 0.0)
      }

      -- INSULIN.lua Manipulation Helper Functions
      local IsManipPathClear = function(origin, targetPart)
          if not (origin and targetPart) then return false end
          local to = targetPart.CFrame.Position
          local dir = to - origin
          local result = workspace:Raycast(origin, dir, Cheat.Globals.RaycastParams)
          if not result then
              return true
          end
          local inst = result.Instance
          return inst and inst:IsDescendantOf(targetPart.Parent) or false
      end

      local IsAimPointReachable = function(origin, aimPoint, targetPart)
          if not (origin and aimPoint) then return false end
          local dir = aimPoint - origin
          local result = workspace:Raycast(origin, dir, Cheat.Globals.RaycastParams)
          if not result then
              return true
          end
          if targetPart then
              local inst = result.Instance
              if inst and inst:IsDescendantOf(targetPart.Parent) then
                  return true
              end
          end
          return false
      end

      local IsCandidateReachable = function(originPos, candidatePos)
          if not (originPos and candidatePos) then return false end
          local dir = candidatePos - originPos
          if dir.Magnitude < 0.05 then return true end
          local result = workspace:Raycast(originPos, dir, Cheat.Globals.RaycastParams)
          if not result then
              return true
          end
          return false
      end

      local FindVisiblePosition = LPH_NO_VIRTUALIZE(function(Origin, Destination, AimPoint)
          local o = (typeof(Origin) == "CFrame") and Origin or CFrame.new(Origin)
          local oPos = o.Position
          local maxDist = flags.ManipulationDistance or 5
          if AimPoint then
              for i = 1, #manipOffsets do
                  local off = manipOffsets[i]
                  if off.Magnitude <= maxDist then
                      local pos = o * off
                      if IsCandidateReachable(oPos, pos) and IsManipPathClear(pos, Destination) and IsAimPointReachable(pos, AimPoint, Destination) then
                          return pos
                      end
                  end
              end
          end
          for i = 1, #manipOffsets do
              local off = manipOffsets[i]
              if off.Magnitude <= maxDist then
                  local pos = o * off
                  if IsCandidateReachable(oPos, pos) and IsManipPathClear(pos, Destination) then
                      return pos
                  end
              end
          end
          return nil
      end)
  
      RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
          debug.profilebegin("Targeting Loop")
          Cheat.Globals.RaycastParams.FilterDescendantsInstances = {
              Camera, Cheat.Globals.ClientCharacter,
              workspace:FindFirstChild("VFX"),
              workspace:FindFirstChild("RocketFactoryPinkCardInvisWalls")
          }
  
          local Silent = (flags.AimbotEnabled) or false
          local TargetParts = flags.TargetParts or {'Head'}
          if not TargetParts or #TargetParts == 0 then return end
          local DesiredPartName = TargetParts[math.random(#TargetParts)] or "Head"
          local HitScanActive = (flags.HitScan == true) or false
          local UseVisibleCheck = flags.VisibleCheck == true
          local DownCheck = flags.DownCheck == true
          local ClosestDistance = (flags.FovEnabled and (flags.FovSize or 200)) or 999999
  
          local ClosestTarget = nil
          local EntityCharacter = nil
          local EntityData = nil
          local EntityInstance = nil
          local Visible = false
          local HitScanned, ScannedPosition, ScannedPart = nil, nil, nil
          local now = tick()
  
          for Entity, Object in pairs(Targeting.Targets) do
              if not Object then continue end
              if not Object.Character or not Object.Character.Parent then
                  Object.Character = (Object.Class == "Player" and Object.Player.Character) or nil
              end
  
              local character = Object.Character
              if not character or not character.Parent then
                  Object.CoreInformation = { Visible = false, OnScreen = false, Root = nil }
                  continue
              end
  
              if now - (Object.LastUpdate or 0) > 1/30 then
                  Object.LastUpdate = now
                  local Humanoid = character:FindFirstChildOfClass("Humanoid")
                  if Humanoid then Object.Humanoid = Humanoid end
                  if Object.Class == "Player" or Object.Class == "AI" then
                      Object.Root = (Humanoid and Humanoid.RootPart) or character:FindFirstChild("HumanoidRootPart")
                  end
                  if not Object.Root then
                      Object.Root = character:FindFirstChild("RootPart") or character:FindFirstChild("HumanoidRootPart")
                  end
  
                  local root = Object.Root
                  if not root then
                      Object.CoreInformation = { Visible = false, OnScreen = false, Root = nil }
                  elseif (Camera.CFrame.Position - root.Position).Magnitude > 2000 then
                      Object.CoreInformation = { Visible = false, OnScreen = false, Root = root }
                  else
                      local parts = character:GetChildren()
                      local inf = math.huge
                      local minx, miny, minz = inf, inf, inf
                      local maxx, maxy, maxz = -inf, -inf, -inf
                      local rc = root.CFrame
                      for _, Part in ipairs(parts) do
                          if Part:IsA("BasePart") then
                              local Cf = rc:ToObjectSpace(Part.CFrame)
                              local sx, sy, sz = Part.Size.X, Part.Size.Y, Part.Size.Z
                              local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Cf:components()
                              local wsx = 0.5 * (math.abs(R00) * sx + math.abs(R01) * sy + math.abs(R02) * sz)
                              local wsy = 0.5 * (math.abs(R10) * sx + math.abs(R11) * sy + math.abs(R12) * sz)
                              local wsz = 0.5 * (math.abs(R20) * sx + math.abs(R21) * sy + math.abs(R22) * sz)
                              minx = math.min(minx, X - wsx) ; miny = math.min(miny, Y - wsy) ; minz = math.min(minz, Z - wsz)
                              maxx = math.max(maxx, X + wsx) ; maxy = math.max(maxy, Y + wsy) ; maxz = math.max(maxz, Z + wsz)
                          end
                      end
                      local minv = Vector3.new(minx, miny, minz)
                      local maxv = Vector3.new(maxx, maxy, maxz)
                      local middle = (maxv + minv) * 0.5
                      local cf = rc - rc.Position + rc * middle
                      local half = (maxv - minv) * 0.5
                      local hx, hy, hz = math.min(half.X, 5), math.min(half.Y, 10), math.min(half.Z, 5)
                      local offsets = {
                          Vector3.new( hx,  hy,  hz), Vector3.new( hx,  hy, -hz),
                          Vector3.new( hx, -hy,  hz), Vector3.new( hx, -hy, -hz),
                          Vector3.new(-hx,  hy,  hz), Vector3.new(-hx,  hy, -hz),
                          Vector3.new(-hx, -hy,  hz), Vector3.new(-hx, -hy, -hz),
                      }
                      local on = false
                      for i = 1, 8 do
                          local _, s = Camera:WorldToViewportPoint(cf * offsets[i])
                          if s then on = true break end
                      end
  
                      if not on then
                          local head = character:FindFirstChild("Head")
                          local vis = head and IsPartVisible(head) or false
                          Object.CoreInformation = { Root = root, RootPosition = root.Position, OnScreen = false, Visible = vis, VisiblePart = vis and head or nil }
                      else
                          if character:FindFirstChild(DesiredPartName) and IsPartVisible(character[DesiredPartName]) then
                              Object.CoreInformation = { Visible = true, VisiblePart = character[DesiredPartName], Root = root, RootPosition = root.Position, OnScreen = on }
                              continue
                          end
                          local visPart = nil
                          local names = { "HumanoidRootPart", "RightLowerLeg", "LeftLowerLeg", "RightUpperArm", "LeftUpperArm" }
                          for _, n in ipairs(names) do
                              local p = character:FindFirstChild(n)
                              if p and p:IsA("BasePart") and IsPartVisible(p) then visPart = p break end
                          end
                          Object.CoreInformation = { Visible = visPart ~= nil, VisiblePart = visPart, Root = root, RootPosition = root.Position, OnScreen = on }
                      end
                  end
              end
  
              local Core = Object.CoreInformation
              if flags.TeamCheck and isTeam(Entity) then continue end
              if not (Core and Core.Root and Entity ~= Client) then continue end
              if not Core.OnScreen then continue end
  
              local humanoid = character:FindFirstChildOfClass("Humanoid")
              if not humanoid or humanoid.Health <= 0 then continue end
              if DownCheck and humanoid:GetAttribute('Downed') then continue end
  
              local Distance = GetDistanceFromCenter(Core.Root)
              if Distance >= ClosestDistance then continue end
  
              local tpart = nil
              if UseVisibleCheck and Core.Visible then
                  tpart = Core.VisiblePart
              elseif not UseVisibleCheck then
                  tpart = character:FindFirstChild(DesiredPartName)
              end
  
              if Cheat.Globals.DesyncedPositions[character] and Cheat.Globals.DesyncParts[character] then
                  tpart = Cheat.Globals.DesyncParts[character]
              end
  
              if character.Name == "BTR" then
                  tpart = character:FindFirstChild("HumanoidRootPart")
              end
  
              if tpart then
                  ClosestDistance = Distance
                  ClosestTarget  = tpart
                  EntityCharacter = character
                  EntityData      = Object
                  EntityInstance  = Entity
                  Visible         = Core.Visible
              end
          end
  
          local ManipulationActive = Silent and (flags.Manipulation == true) or false
          local Manipulated, ManipulatedPosition, ManipulatedPart = false, nil, nil

          if not Visible and Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild('Head') and ClosestTarget and EntityData then
              local HeadCFrame = Cheat.Globals.ClientCharacter.Head.CFrame
              if Cheat.Globals.NeedToReturn then
                  HeadCFrame = Cheat.Globals.SavedPosition
              end

              -- INSULIN.lua manipulation logic with throttling
              local bothOn = flags.HitScan and flags.Manipulation
              local hsThrottle = bothOn and (1/30) or (1/15)
              
              if (now - (EntityData.LastHitScanTime or 0)) > hsThrottle then
                  EntityData.LastHitScanTime = now
                  if HitScanActive then
                      local hs = get_hit_scan_pos(HeadCFrame, ClosestTarget)
                      if hs then
                          HitScanned = true
                          ScannedPart = ClosestTarget
                          ScannedPosition = hs
                      end
                  end
                  if HitScanned then
                      EntityData.HitScanCache = { ScannedPart = ScannedPart, ScannedPosition = ScannedPosition }
                      EntityData.HitScanCacheTime = now
                  elseif EntityData.HitScanCache and (now - (EntityData.HitScanCacheTime or 0)) <= 3 then
                      local cfg = EntityData.HitScanCache
                      if cfg.ScannedPart and cfg.ScannedPart.Parent then
                          local d = (cfg.ScannedPosition - cfg.ScannedPart.Position).Magnitude
                          if d <= (flags.HitScanDistance or 5) + 0.05 then
                              HitScanned = true
                              ScannedPart = cfg.ScannedPart
                              ScannedPosition = cfg.ScannedPosition
                          else
                              EntityData.HitScanCache = nil
                          end
                      else
                          EntityData.HitScanCache = nil
                      end
                  else
                      EntityData.HitScanCache = nil
                  end
              else
                  local cfg = EntityData.HitScanCache
                  if cfg and cfg.ScannedPart and cfg.ScannedPart.Parent then
                      local d = (cfg.ScannedPosition - cfg.ScannedPart.Position).Magnitude
                      if d <= (flags.HitScanDistance or 5) + 0.05 then
                          HitScanned = true
                          ScannedPart = cfg.ScannedPart
                          ScannedPosition = cfg.ScannedPosition
                      end
                  end
              end

              if ManipulationActive then
                  local manipThrottle = bothOn and (1/30) or 0.05
                  if (now - (EntityData.LastManip or 0)) > manipThrottle then
                      EntityData.LastManip = now
                      local aimPoint = HitScanned and ScannedPosition or nil
                      local vp = FindVisiblePosition(HeadCFrame, ClosestTarget, aimPoint)
                      if vp then
                          Manipulated = true
                          ManipulatedPart = ClosestTarget
                          ManipulatedPosition = vp
                          EntityData.LastManipCFG = {
                              ManipulatedPosition = vp,
                              ManipulatedPart = ClosestTarget,
                          }
                          EntityData.LastManipCFGTime = now
                      elseif EntityData.LastManipCFG and (now - (EntityData.LastManipCFGTime or 0)) <= 1.5 then
                          local cfg = EntityData.LastManipCFG
                          if cfg.ManipulatedPart and cfg.ManipulatedPart.Parent then
                              Manipulated = true
                              ManipulatedPart = cfg.ManipulatedPart
                              ManipulatedPosition = cfg.ManipulatedPosition
                          else
                              EntityData.LastManipCFG = nil
                          end
                      else
                          EntityData.LastManipCFG = nil
                      end
                  elseif EntityData.LastManipCFG then
                      local cfg = EntityData.LastManipCFG
                      if cfg.ManipulatedPart and cfg.ManipulatedPart.Parent then
                          Manipulated = true
                          ManipulatedPart = cfg.ManipulatedPart
                          ManipulatedPosition = cfg.ManipulatedPosition
                      end
                  end
              else
                  EntityData.LastManipCFG = nil
              end
          end
  
          Targeting.TargetPart = ClosestTarget
          Targeting.TargetCharacter = EntityCharacter
          Targeting.TargetObject = EntityData
          Targeting.ScannedPosition = ScannedPosition
          Targeting.ManipulatedPosition = Manipulated and ManipulatedPosition or nil
          
          -- Clear targeting if no target found
          if not ClosestTarget then
              Targeting.TargetPart = nil
              Targeting.TargetCharacter = nil
              Targeting.TargetObject = nil
              Targeting.ScannedPosition = nil
              Targeting.ManipulatedPosition = nil
          end
          
          debug.profileend()
      end))
  
      for _, Player in ipairs(Players:GetPlayers()) do
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end
  
      Players.PlayerAdded:Connect(function(Player)
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end)
  
      Players.PlayerRemoving:Connect(function(Player)
          Targeting.Targets[Player] = nil
      end)
      
      local SoldierClassType = {
              Brutus = "Boss",
              Bruno = "Boss",
              BTR = "Boss",
              Boris = "Boss",
              Soldier = "AI",
        }
  
        local Military = workspace:FindFirstChild("Military")
        if Military then
              local Events = workspace:FindFirstChild("Events")
              local CacheSoldier = function(Soldier)
                    local ClassType = SoldierClassType[Soldier.Name]
                    if not ClassType then return end
              
              Targeting.Targets[Soldier] = {
                  Class = ClassType,
                  Player = Soldier,
                  Character = Soldier,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
              end;
  
              for Index, BTR in Events:GetChildren() do
                    if BTR.Name == "BTR" then
                          CacheSoldier(BTR)
                    end;
              end;
  
              Events.ChildAdded:Connect(function(BTR)
                    task.wait(1)
                    if BTR.Name == "BTR" then
                          CacheSoldier(BTR)
                    end;
              end)
  
              for _, Folder in Military:GetChildren() do
                    for Index, Soldier in Folder:GetChildren() do
                          if Soldier:IsA("Model") then
                                CacheSoldier(Soldier)
                          end;
                    end;
  
                    Folder.ChildAdded:Connect(function(Soldier)
                          task.wait(1)
                          if Soldier:IsA("Model") then
                                CacheSoldier(Soldier)
                          end;
                    end)
              end;
        end;
  end
  
  --// Misc
  do 
      setreadonly(math, false)
      local oldabs = math.abs
      math.abs = function(x)
          if flags.NoBob and debug.traceback():find('ViewmodelController') then
              for level = 2, 4 do
                  if isvalidlevel(level) then
                      local stack = getstack(level)
                      local v = stack and stack[2]
                      if type(v) == 'boolean' then
                          setstack(level, 2, true)
                      end
                  end
              end
          end
  
          return oldabs(x)
      end
      setreadonly(math, true)
  
      do --// Movement
          RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
              local Character = Cheat.Globals.ClientCharacter
              local Root = Character and Character:FindFirstChild("HumanoidRootPart")
              local Humanoid = Character and Character:FindFirstChild("Humanoid")
              local IsFlying
              if Humanoid and Root and Humanoid.Health > 0 then
                  if
                      flags.SpeedEnabled
                      and (not flags["SpeedBind"] or flags["SpeedBind"].Toggled)
                      and not IsFlying
                      and Root
                  then
                      if Humanoid.MoveDirection.Magnitude > 0 then
                          Root.CFrame = Root.CFrame + (Humanoid.MoveDirection * ((flags.SpeedMultiplier or 6) * 0.15 / 12))
                      end
                  end
                  
                  if
                      flags.Bunnyhop
                      and Humanoid.FloorMaterial ~= Enum.Material.Air
                      and UserInputService:IsKeyDown(Enum.KeyCode.Space)
                  then
                      Humanoid.Jump = true
                  end
  
                  if
                      (flags["FlightEnabled"] and (not flags["FlightBind"] or flags["FlightBind"].Toggled))
                  then
                      task.spawn(function()
                          IsFlying = true
                          if Humanoid and Humanoid.Health > 0 then
                              local Delta = dt * flags.FlightSpeed * 3
                              local MoveVector = Vector3.zero
  
                              local look = Camera.CFrame.LookVector
                              local right = Camera.CFrame.RightVector
  
                              if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                  MoveVector += Vector3.new(look.X, 0, look.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                  MoveVector -= Vector3.new(look.X, 0, look.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                  MoveVector -= Vector3.new(right.X, 0, right.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                  MoveVector += Vector3.new(right.X, 0, right.Z)
                              end
  
                              if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                  MoveVector += Vector3.new(0, 1, 0)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                                  MoveVector += Vector3.new(0, -1, 0)
                              end
  
                              if MoveVector.Magnitude > 0 then
                                  MoveVector = MoveVector.Unit
                              end
  
                              local MovementDelta = MoveVector * Delta
                              local Position = Root.CFrame.Position + MovementDelta
  
                              Humanoid.PlatformStand = false
                              Root.Velocity = Vector3.zero
                              Root.CFrame = CFrame.new(Position, Position + Vector3.new(look.X, 0, look.Z))
                          end
                      end)
                  end
  
                  if
                      flags.Freecam
                      and (not flags["FreecamKeybind"] or flags["FreecamKeybind"].Toggled)
                      and not IsFlying
                  then
                      task.spawn(function()
                          if not Root then
                              return
                          end
  
                          Cheat.Globals.NeedToReturn = true
  
                          local CameraLookVector = Camera.CFrame.LookVector
                          local NormalCameraLookVector = CameraLookVector
  
                          if not Cheat.Globals.SavedPosition then
                              Cheat.Globals.SavedPosition = Root.CFrame
                          end
  
                          sethiddenproperty(Root, "NetworkIsSleeping", true)
  
                          local UpPos = Vector3.new(0, 1, 0)
                          local DownPos = Vector3.new(0, -1, 0)
                          local NonePos = Vector3.new(0, 0, 0)
  
                          local BaseCFrame = Root.CFrame
                          local IsUpPressed = UserInputService:IsKeyDown(Enum.KeyCode.E)
                          local IsDownPressed = UserInputService:IsKeyDown(Enum.KeyCode.Q)
                          local IsForwardPressed = UserInputService:IsKeyDown(119) -- W
                          local IsBackwardPressed = UserInputService:IsKeyDown(115) -- S
  
                          Root.Anchored = true
                          Root.Velocity = NonePos
  
                          local Delta = dt * flags.FreecamSpeed * 3
  
                          local MovementVector = (
                              Humanoid.MoveDirection
                              + (IsUpPressed and UpPos or NonePos)
                              + (IsDownPressed and DownPos or NonePos)
                              + (IsForwardPressed and Vector3.new(0, NormalCameraLookVector.Y, 0) or NonePos)
                              + (IsBackwardPressed and Vector3.new(0, -NormalCameraLookVector.Y, 0) or NonePos)
                          ) * Delta
  
                          BaseCFrame += MovementVector
                          local Position = BaseCFrame.p
                          Root.CFrame = CFrame.new(Position, Position + Vector3.new(CameraLookVector.X, 0, CameraLookVector.Z))
                          Humanoid.AutoRotate = false
                      end)
                  else
                      if Cheat.Globals.NeedToReturn then
                          Humanoid.AutoRotate = true
                          Cheat.Globals.NeedToReturn = false
                          sethiddenproperty(Root, "NetworkIsSleeping", false)
  
                          for _, Value in Character:GetChildren() do
                              if Value:IsA("BasePart") then
                                  sethiddenproperty(Value, "NetworkIsSleeping", false)
                              end
                          end
  
                          Root.CFrame = Cheat.Globals.SavedPosition
                          Root.Anchored = false
                          Cheat.Globals.SavedPosition = nil
                      end
                  end
  
                  if flags.InfiniteFly and IsFlying then
                      local Origin = Root.Position
                      local Result = workspace:Raycast(Origin, Vector3.new(0, -1000, 0), Cheat.Globals.RaycastParams)
                      if Result and Result.Distance > 4 then
                          task.spawn(function()
                              local OldVel = Root.Velocity
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = Vector3.new(0, -9999, 0)
                                  end
                              end
                              RunService.RenderStepped:Wait()
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = OldVel
                                  end
                              end
                          end)
                      end
                  end
  
                  if flags.NoFall and not IsFlying then
                      local Origin = Root.Position
                      local Result = workspace:Raycast(Origin, Vector3.new(0, -1000, 0), Cheat.Globals.RaycastParams)
  
                      if Result and Result.Distance > 10 then
                          task.spawn(function()
                              local OldVel = Root.Velocity
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = Vector3.new(0, 9999, 0)
                                  end
                              end
                              RunService.RenderStepped:Wait()
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = OldVel
                                  end
                              end
                          end)
                      end
                  end
              end
          end))

          -- Spectate Target implementation
          RunService.RenderStepped:Connect(function()
              if flags.SpectateTarget and (not flags.SpectateTargetBind or flags.SpectateTargetBind.Toggled) then
                  local target = Targeting.TargetCharacter
                  if target and target:FindFirstChild("HumanoidRootPart") then
                      Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.HumanoidRootPart.Position)
                  end
              end
          end)

          -- Bring BTR implementation
          Cheat.Globals.BringBTRCallback = function(toggled)
              if not toggled then return end
              local Events = workspace:FindFirstChild("Events")
              if not Events then return Library:Notification({
                  Title = "Error",
                  Description = "No Events Found",
                  Duration = 3,
                  Icon = "7733658504"
              }) end
              
              local BTR = Events:FindFirstChild("BTR")
              if not BTR then return Library:Notification({
                  Title = "Error",
                  Description = "No BTR Found",
                  Duration = 3,
                  Icon = "7733658504"
              }) end

              local BTRHRP = BTR:FindFirstChild("HumanoidRootPart")
              if not BTRHRP then return Library:Notification({
                  Title = "Error",
                  Description = "No BTR HRP Found",
                  Duration = 3,
                  Icon = "7733658504"
              }) end

              local cc = Cheat.Globals.ClientCharacter
              if not cc then return Library:Notification({
                  Title = "Error",
                  Description = "No Character",
                  Duration = 3,
                  Icon = "7733658504"
              }) end
              local myRoot = cc:FindFirstChild("HumanoidRootPart")
              if not myRoot then return end

              local myDist = (myRoot.Position - BTRHRP.Position).Magnitude
              for _, player in Players:GetPlayers() do
                  if player ~= Client then
                      local char = player.Character
                      local root = char and char:FindFirstChild("HumanoidRootPart")
                      if root and (root.Position - BTRHRP.Position).Magnitude < myDist then
                          return Library:Notification({
                              Title = "Error",
                              Description = "Not closest to BTR",
                              Duration = 3,
                              Icon = "7733658504"
                          })
                      end
                  end
              end

              local cam = workspace.CurrentCamera
              BTRHRP.CFrame = cam.CFrame * CFrame.new(0, 0, -15)
          end

          -- Underground implementation
          do
              local downFall = nil
              local down = nil
              local savedCF = nil
              local savedVel = nil
              local playRoutine = nil

              local function findGameTracks()
                  local char = Client.Character
                  local hum = char and char:FindFirstChildOfClass("Humanoid")
                  if not hum then return nil, nil end
                  local ok, conns = pcall(getconnections, hum:GetAttributeChangedSignal("Downed"))
                  if not ok or not conns then return nil, nil end
                  for _, conn in ipairs(conns) do
                      local fn = conn.Function or conn.Func
                      if fn then
                          local ok2, ups = pcall(debug.getupvalues, fn)
                          if ok2 and ups then
                              for _, val in pairs(ups) do
                                  if type(val) == "table" and val.DownFall and val.Down then
                                      return val.DownFall, val.Down
                                  end
                              end
                          end
                      end
                  end
                  return nil, nil
              end

              local function ensureTracks()
                  if downFall and down then return true end
                  local f, d = findGameTracks()
                  if f and d then
                      downFall = f
                      down = d
                      return true
                  end
                  return false
              end

              task.spawn(function()
                  while not Client.Character do task.wait() end
                  for _ = 1, 50 do
                      if ensureTracks() then break end
                      task.wait(0.2)
                  end
              end)

              local lastState = false
              _G.UndergroundOffset = -1.9
              local undergroundEnabled = false
              local pp = nil

              RunService.Heartbeat:Connect(LPH_JIT_MAX(function()
                  if not undergroundEnabled or not pp then return end
                  savedCF = pp.CFrame
                  savedVel = pp.AssemblyLinearVelocity
                  pp.CFrame = pp.CFrame + Vector3.new(0, -1.9, 0)
                  RunService.RenderStepped:Wait()
                  if not pp then return end
                  if savedCF then
                      pp.CFrame = savedCF
                  end
                  if savedVel then
                      pp.AssemblyLinearVelocity = savedVel
                  end
              end))

              RunService.RenderStepped:Connect(LPH_JIT_MAX(function()
                  local char = Client.Character
                  pp = char and char.PrimaryPart
                  undergroundEnabled = flags.Underground and (not flags.UndergroundBind or flags.UndergroundBind.Toggled)
                  if not pp then return end

                  if undergroundEnabled ~= lastState then
                      lastState = undergroundEnabled

                      if undergroundEnabled then
                          if not ensureTracks() then return end

                          if playRoutine then
                              pcall(task.cancel, playRoutine)
                              playRoutine = nil
                          end

                          playRoutine = task.spawn(function()
                              pcall(function() downFall:Play() end)

                              local len = downFall.Length > 0 and downFall.Length or 0.7
                              task.wait(len)

                              if undergroundEnabled then
                                  pcall(function() down:Play() end)
                                  task.wait(0.05)

                                  if undergroundEnabled then
                                      pcall(function()
                                          down.TimePosition = 0.6
                                          down:AdjustSpeed(0)
                                      end)
                                  end
                              end
                          end)
                      else
                          savedCF = nil
                          savedVel = nil

                          if playRoutine then
                              pcall(task.cancel, playRoutine)
                              playRoutine = nil
                          end

                          pcall(function() down:AdjustSpeed(1) end)
                          pcall(function() downFall:Stop() end)
                          pcall(function() down:Stop() end)
                      end
                  end
              end))

              Client.CharacterAdded:Connect(function()
                  undergroundEnabled = false
                  downFall = nil
                  down = nil
                  savedCF = nil
                  savedVel = nil
                  if playRoutine then pcall(task.cancel, playRoutine) playRoutine = nil end
              end)
          end
      end

      do --// Underground Resolver
          RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
              if flags.UndergroundResolver then
                  for _, player in pairs(Players:GetPlayers()) do
                      if player ~= Client and player.Character then
                          local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                          local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                          if animator then
                              for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                  if track.Animation and track.Animation.AnimationId == "rbxassetid://13435049596" then
                                      track:Stop()
                                  end
                              end
                          end
                      end
                  end
              end
          end))
      end
  end
  
  --// Main Hooks
  do
      local OldRaycast = RaycastUtil.Raycast;
      RaycastUtil.Raycast = LPH_NO_VIRTUALIZE(function(self, ...)
          local Arguments = {...};
  
          if (not checkcaller()) then
              local Traceback = debug.traceback();
  
              if (Traceback and Traceback:find('ViewmodelController') and flags.Reach) then
                  Arguments[2] = Arguments[2] * 10
              end;
  
              if (flags.PerfectFarm) then
                  local Output = {OldRaycast(self, ...)};
                  local HitInstance  = Output[1];
                  local HitPosition = Output[2];
  
                  if (not HitInstance or typeof(HitInstance) ~= 'Instance') then
                      return unpack(Output);
                  end;
  
                  if (not HitPosition or typeof(HitPosition) ~= 'Vector3') then
                      return unpack(Output);
                  end;
  
                  local Model = HitInstance.Parent;
                  if (not Model or (not Model:IsA('Model'))) then
                      return unpack(Output);
                  end;
  
                  local Folder = Model.Parent;
                  if (Folder and (Folder.Name == 'Trees' or Folder.Name == 'Nodes') and Folder:IsA('Folder')) then
                      local CriticalPart = Model:FindFirstChild('NodeSpark') or Model:FindFirstChild('TreeX')
                      if (CriticalPart and typeof(CriticalPart) == 'Instance' and CriticalPart:IsA('Model') and CriticalPart.PrimaryPart) then
                          Output[1] = CriticalPart.PrimaryPart;
                          return unpack(Output);
                      end;
                  end;
              end;
          end;
  
          return OldRaycast(self, unpack(Arguments));
      end);
  
      local MyShotQueue = {}
      local bullettracersbind = Instance.new('BindableEvent', game:GetService('ReplicatedStorage'))
  
      bullettracersbind.Event:Connect(function(position, originPos)
          if not flags.BulletTracers then
              return
          end
  
          local origin = originPos
          if not origin then
              local character = Client.Character
              if not character then
                  return
              end
  
              local head = character:FindFirstChild("Head")
              if not head then
                  return
              end
              origin = head.Position
          end
  
          local c1 = flags.BulletTracersColor
          if not c1 then
              return
          end
  
          local att0 = Instance.new("Attachment")
          att0.Name = "IgnoreMe"
          att0.WorldPosition = origin
          att0.Parent = VMs
  
          local att1 = Instance.new("Attachment")
          att1.Name = "IgnoreMe"
          att1.WorldPosition = origin
          att1.Parent = VMs
  
          local beam = Instance.new("Beam")
          beam.Name = "IgnoreMe"
          beam.Attachment0 = att0
          beam.Attachment1 = att1
          beam.Transparency = NumberSequence.new({
              NumberSequenceKeypoint.new(0, 0),
              NumberSequenceKeypoint.new(1, 0),
          })
  
          beam.Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0, c1.Color),
              ColorSequenceKeypoint.new(1, c1.Color),
          })
  
          beam.Texture = 'rbxassetid://128372145766358'
          beam.TextureSpeed = 1
          beam.TextureLength = 4
          beam.Width0 = 0.4
          beam.Width1 = 0.4
          beam.FaceCamera = true
          beam.LightEmission = 1
          beam.Parent = VMs
          beam.Brightness = 8
          beam.TextureMode = Enum.TextureMode.Stretch
  
          local expiry = flags.BulletTracersDuration or 1
  
          task.spawn(function()
              TweenService
                  :Create(
                      att1,
                      TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                      { Position = position }
                  )
                  :Play()
          end)
  
          task.spawn(function()
              TweenService:Create(
                  beam,
                  TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
                  { TextureSpeed = 0.5 }
              ):Play()
          end)
  
          delay(expiry, function()
              local Tween = TweenService:Create(beam, TweenInfo.new(1), { Width0 = 0, Width1 = 0, TextureSpeed = 0 })
              Tween:Play()
              Tween.Completed:Wait()
              beam:Destroy()
              att0:Destroy()
              att1:Destroy()
          end)
      end)
  
      local function popMyShot()
          local now = tick()
          while #MyShotQueue > 0 and (now - MyShotQueue[1].time) > 5 do
              table.remove(MyShotQueue, 1)
          end
          if #MyShotQueue > 0 then
              return table.remove(MyShotQueue, 1)
          end
          return nil
      end
  
      local CreateBlood = VFXModule.CreateBlood
      VFXModule.CreateBlood = LPH_NO_VIRTUALIZE(function(self, hit, position)
          local mine = popMyShot()
          if mine then
              bullettracersbind:Fire(position, mine.origin)
          end
  
          return CreateBlood(self, hit, position)
      end)
  
      local CreateHole = VFXModule.CreateHole
      VFXModule.CreateHole = LPH_NO_VIRTUALIZE(function(self, hit, position, normal, material, item, impactOnly)
          local mine = popMyShot()
          if mine then
              bullettracersbind:Fire(position, mine.origin)
          end
  
          return CreateHole(self, hit, position, normal, material, item, impactOnly)
      end)
  
      local v1 = "#\250)\215\028\001U\143\237}\154\218\231Cl-\015H\001\147"
      local LastPredictionPos
      local CreateProjectile = VFXModule.CreateProjectile
      VFXModule.CreateProjectile = LPH_NO_UPVALUES(function(self, ...)
          local Args = { ... }

          local Traceback = debug.traceback()
          if
              Traceback:find("ViewmodelController")
              and Args[1].StepFunction ~= "FakeStepFunc"
              and Args[1].HitFunction ~= "FakeHitFunc"
              and not tostring(Args[1].HitFunction):find("Ignore")
          then
              
              if flags.ForceHit then
                  for _, v in ipairs(workspace:GetChildren()) do
                      if not v:IsA("Folder") then
                          continue
                      end

                      if v.Name == "Military" or v.Name == "Events" then
                          continue
                      end

                      local skip = false
                      for _, c in ipairs(v:GetChildren()) do
                          if
                              c:IsA("Model")
                              and (
                                  c.Name == "Soldier"
                                  or c.Name == "Brutus"
                                  or c.Name == "Bruno"
                                  or c.Name == "Boris"
                                  or c.Name == "BTR"
                              )
                          then
                              skip = true
                              break
                          end
                      end

                      if not skip then
                          table.insert(Args[1].Filters, v)
                      end
                  end
                  table.insert(Args[1].Filters, workspace.Terrain)
              end

              Cheat.Globals.ShouldHit = (
                  (math.floor(Random.new():NextNumber(0, 1) * 100) / 100) <= (flags.HitChance / 100)
              )
              local isvalidstack3 = isvalidlevel(3)
              local isvalidstack2 = isvalidlevel(2)
              local stacklevel = isvalidstack3 and 3 or isvalidstack2 and 2

              if stacklevel and Targeting.TargetPart and Client.Character then
                  LastPredictionPos = nil
                  local HitFunction = Args[1].HitFunction
                  local startPos = Args[1].Position or Args[1].PositionFirst or Camera.CFrame.Position
                  local manipPos = Targeting.ManipulatedPosition
                  local targetPos = Targeting.TargetPart and Targeting.TargetPart.Position

                  local gun = getgun(Client.Character)
                  local oldspeed = Args[1].Speed
                  if
                      gun
                      and ToolInfo[gun]
                      and Cheat.Globals.ClientCharacter
                      and Cheat.Globals.ClientCharacter:FindFirstChild("InventoryController")
                      and Cheat.Globals.ClientCharacter:FindFirstChild("ViewmodelController")
                  then
                      local InventoryController = Cheat.Globals.ClientCharacter.InventoryController
                      local ViewmodelController = Cheat.Globals.ClientCharacter.ViewmodelController
                      local v376 = InventoryController.Fetch:Invoke()
                      local v377
                      if not v376 then
                          v377 = nil
                      else
                          local l_Toolbar_5 = v376.Toolbar
                          if not l_Toolbar_5 then
                              v377 = nil
                          else
                              local v379 = l_Toolbar_5[ViewmodelController:GetAttribute("Equipped")]
                              v377 = false
                              if v379 ~= nil then
                                  v377 = false
                                  if v379 ~= 0 then
                                      v377 = v379
                                  end
                              end
                          end
                      end

                      if v377 then
                          v376 = v377.Ammo
                          v382 = ItemsModule[v377.ID]
                      end
                      if v376 then
                          v381 = ItemsModule[v376.ID].AmmoStats
                      end

                      local bullet = ToolInfo[gun].Bullet
                      oldspeed = bullet.Speed * (v381.SpeedMult or 1)
                  end

                  local Speed, Gravity = Args[1].Speed, Args[1].Gravity
                  local Distance = (Camera.CFrame.Position - targetPos).Magnitude
                  local TimeToHit = Distance / oldspeed

                  local G = Gravity * -196.2
                  local Drop = -0.5 * G * TimeToHit * TimeToHit
                  if tostring(Drop):find("nan") then
                      Drop = 0
                  end

                  LastPredictionPos = Vector3.new(0, Drop, 0)
                  local fire_remote_func = debug.getupvalue(Args[1].MissFunction, 1)

                  if
                      fire_remote_func
                      and type(fire_remote_func) == "function"
                      and not (isfunctionhooked(fire_remote_func))
                  then
                      local old_fire_remote
                      old_fire_remote = hookfunction(
                          fire_remote_func,
                          LPH_NO_UPVALUES(function(remote_type, remote, hash, ...)
                              local args = { ... }
                              if hash == v1 then
                                  if not (rawlen(args) == 8) then
                                      return old_fire_remote(remote_type, remote, hash, unpack(args))
                                  end

                                  if not Targeting.TargetPart or not Cheat.Globals.ShouldHit then
                                      return old_fire_remote(remote_type, remote, hash, unpack(args))
                                  end

                                  local modified_pos = Targeting.ManipulatedPosition
                                  local target_position = Targeting.ScannedPosition or Targeting.TargetPart.Position

                                  if LastPredictionPos then
                                      target_position = target_position + LastPredictionPos
                                  end

                                  local character_pos = args[5].Position
                                  local camera_pos = args[3].Position
                                  if modified_pos then
                                      character_pos = modified_pos
                                      camera_pos = modified_pos
                                  end
                                  args[8] = target_position

                                  -- fix for viewmodel origin
                                  if flags.Freecam and (not flags["FreecamKeybind"] or flags["FreecamKeybind"].Toggled) then
                                      local flash_point_pos = args[5]:PointToWorldSpace(args[4])
                                      local calculated_offset = args[3]:PointToObjectSpace(flash_point_pos)
                                      args[3] = CFrame.lookAt(character_pos, target_position)
                                      args[4] = calculated_offset
                                  else
                                      args[3] = CFrame.lookAt(camera_pos, target_position)
                                  end

                                  local hawk = CFrame.lookAt(character_pos, target_position)
                                  local _, yaw, _ = hawk:ToEulerAnglesYXZ()

                                  -- root pos shouldn't have roll/pitch
                                  args[5] = CFrame.new(hawk.Position) * CFrame.fromEulerAnglesYXZ(0, yaw, 0)
                              end

                              return old_fire_remote(remote_type, remote, hash, unpack(args))
                          end)
                      )
                  end

                  if flags.HitScan and Targeting.ScannedPosition then
                      task.defer(
                          HitFunction,
                          Targeting.TargetPart,
                          Targeting.ScannedPosition,
                          Vector3.new(0, 0, 1),
                          Targeting.TargetPart.Material
                      )
                      return
                  end
              end

              if Args[1]["Terminate"] then
                  Args[1]["Terminate"] = nil
              end

              if Targeting.TargetPart and Cheat.Globals.ShouldHit then
                  local p = Targeting.TargetPart
                  local hit = p and p.Position
                  if p and hit then
                      local origin = Args[1].Position
                      local dir = (hit - origin).Unit
                      local cp = CFrame.lookAt(origin, hit).Position
                      if Targeting.ManipulatedPosition or Targeting.ManipPos then
                          local mp = Targeting.ManipulatedPosition or Targeting.ManipPos
                          dir = (hit - mp).Unit
                          cp = CFrame.lookAt(mp, hit).Position
                      end
                      Args[1].Position = cp
                      if Args[1].PositionFirst then
                          Args[1].PositionFirst = cp
                      end
                      Args[1].DirectionFirst = dir
                      Args[1].Direction = dir
                      
                      if Args[1].SavedVariables then
                          Args[1].SavedVariables[1] = dir * Args[1].Speed
                          Args[1].SavedVariables[2] = origin
                      end
                  end
              end
          end

          -- Track shot origin for bullet tracers (only for player shots, not AI/Boss)
          if Traceback:find("ViewmodelController") and Args[1].StepFunction ~= "FakeStepFunc" and Args[1].HitFunction ~= "FakeHitFunc" and type(Args[1].HitFunction) == "function" and not tostring(Args[1].HitFunction):find("Ignore") then
              local origHit = Args[1].HitFunction
              local shotOrigin = Targeting.ManipulatedPosition or Targeting.ManipPos or Args[1].Position or Args[1].PositionFirst
              Args[1].HitFunction = function(...)
                  table.insert(MyShotQueue, { origin = shotOrigin, time = tick() })
                  return origHit(...)
              end
          end

          return CreateProjectile(self, unpack(Args))
      end)
      
      local UpdateChar = LPH_NO_VIRTUALIZE(function()
          local character = Client.Character or Client.CharacterAdded:Wait()
          Cheat.Globals.ClientCharacter = character
          
          local hum = character:FindFirstChildOfClass('Humanoid') or character:WaitForChild('Humanoid')
          local InventoryController = character:WaitForChild('InventoryController')
          local EquipArmor = InventoryController:WaitForChild('EquipArmor')
          
          for _, conn in getconnections(EquipArmor.Event) do
              local f = conn.Function
              if not f then continue end
              for _, v in debug.getupvalues(f) do
                  if type(v) ~= 'function' then continue end
                  local Constants = debug.getconstants(v)
                  if Constants[1] == "ArmorEquip" and Constants[5] == "GetAttribute" then
                      if flags.InstantLoot then
                          debug.setconstant(v, 19, 0)
                          debug.setconstant(v, 20, 0)
                          debug.setconstant(v, 21, 0)
                      end;
                      table.insert(Cheat.Globals.QuickStackFunctions, v)
                  end
              end
          end
  
          for _, c in getconnections(hum.StateChanged) do
              local fn = c.Function
              if type(fn) == 'function' then
                  local i = debug.getinfo(fn)
                  if i and i.short_src and i.short_src:find('ViewmodelController') then
                      local Old; Old = hookfunction(fn, function(oldState, newState, ...)
                          if flags.NoGrounded then
                              oldState = Enum.HumanoidStateType.Running
                              newState = Enum.HumanoidStateType.Running
                          end
                          local s, r = pcall(Old, oldState, newState, ...)
                          if s then
                              return r
                          end
                          return nil
                      end)
                  end
              else
                  c:Disconnect()
              end
          end
      end);
  
      UpdateChar();
      Client.CharacterAdded:Connect(UpdateChar);
  end
end

--// Menu Keybind Handler (since using remote library)
task.spawn(function()
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        
        -- Check for menu keybind (RightShift by default, or from MenuBind flag)
        local menuKey = flags["MenuBind"] and flags["MenuBind"].Key or "RightShift"
        
        if tostring(Input.KeyCode) == menuKey or tostring(Input.UserInputType) == menuKey then
            if Window and Window.SetOpen then
                Window:SetOpen(not Window.IsOpen)
            end
        end
    end)
end)
print("Vision Full v2 Commented loaded successfully!")
