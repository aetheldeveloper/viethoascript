-- Đây là bản beta dành cho tựa game Steal An Egg (nếu có lỗi hãy báo cáo lại bên https://discord.gg/6sVJ8bpEs3)
if not game:IsLoaded() then game.Loaded:Wait() end

local S = {}
for _, name in ipairs({"Players", "TeleportService", "HttpService", "TweenService", "UserInputService", "RunService", "Stats", "GuiService", "CoreGui", "ContentProvider"}) do
    S[name] = game:GetService(name)
end
local player = S.Players.LocalPlayer or S.Players.PlayerAdded:Wait()
local placeId, jobId = game.PlaceId, tostring(game.JobId)
local env = (getgenv and getgenv()) or _G
if type(env.AethelHopV8) == "table" and type(env.AethelHopV8.destroy) == "function" then
    pcall(env.AethelHopV8.destroy)
end
local App = {alive = true, connections = {}, tasks = {}, buttons = {}, bindings = {}, history = {}, candidates = {}, visited = {}, state = "idle", status = "ready", args = {}, scanned = 0, pages = 0, valid = 0, serial = 0, nextAuto = os.clock() + 15, binding = nil}
env.AethelHopV8 = App
local CFG, OLD_CFG, SOURCE, VISITS = "AethelServerHop_Config_v8.json", "AethelServerHop_Config_v7.json", "aethelhop.lua", "AethelServerHop_Visited_v8.json"
local cap = {
    read = type(readfile) == "function" and type(isfile) == "function",
    write = type(writefile) == "function",
    clipboard = setclipboard or toclipboard,
    queue = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport),
    request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
}
local Config = {lang = "VI", maxPlayers = 2, autoHop = false, autoExecute = true, toggleMenuKey = "RightShift", quickHopKey = "H", priority = "balanced", allowFallback = false, antiIdle = false}
local function capacity()
    return math.max(1, tonumber(S.Players.MaxPlayers) or 1)
end
local function integer(value, default, lo, hi)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then n = default end
    return math.clamp(math.floor(n), lo, hi)
end
local forbidden = {Unknown = true, Escape = true, Return = true, KeypadEnter = true, Tab = true, Slash = true, Backspace = true, Delete = true}
local function validKey(key)
    if type(key) ~= "string" or forbidden[key] then return false end
    local ok, value = pcall(function() return Enum.KeyCode[key] end)
    return ok and value ~= nil
end
if cap.read then
    pcall(function()
        local path = isfile(CFG) and CFG or OLD_CFG
        if not isfile(path) then return end
        local data = S.HttpService:JSONDecode(readfile(path))
        if type(data) ~= "table" then return end
        for k, v in pairs(Config) do
            if type(data[k]) == type(v) then Config[k] = data[k] end
        end
    end)
end
Config.maxPlayers = integer(Config.maxPlayers, 2, 1, capacity())
if Config.lang ~= "VI" and Config.lang ~= "EN" then Config.lang = "VI" end
if not validKey(Config.toggleMenuKey) then Config.toggleMenuKey = "RightShift" end
if not validKey(Config.quickHopKey) or Config.quickHopKey == Config.toggleMenuKey then Config.quickHopKey = Config.toggleMenuKey == "H" and "J" or "H" end
if Config.priority ~= "balanced" and Config.priority ~= "players" and Config.priority ~= "ping" then Config.priority = "balanced" end
local function sourceReady()
    if not cap.read then return false end
    local ok, result = pcall(function()
        if not isfile(SOURCE) then return false end
        local body = readfile(SOURCE)
        return type(body) == "string" and body:sub(1, 80):find("Aethel Server Hop v8.0", 1, true) ~= nil
    end)
    return ok and result == true
end
cap.source = sourceReady()
cap.autorun = type(cap.queue) == "function" and cap.source
local function saveConfig()
    if not cap.write then return false end
    local ok = pcall(writefile, CFG, S.HttpService:JSONEncode(Config))
    App.saveFailed = not ok
    return ok
end
local function persistVisited()
    local now = os.time()
    for id, expiry in pairs(App.visited) do
        if type(expiry) ~= "number" or expiry <= now then App.visited[id] = nil end
    end
    if cap.write then pcall(writefile, VISITS, S.HttpService:JSONEncode({place = placeId, entries = App.visited})) end
end
if cap.read then
    pcall(function()
        if not isfile(VISITS) then return end
        local data = S.HttpService:JSONDecode(readfile(VISITS))
        if type(data) == "table" and data.place == placeId and type(data.entries) == "table" then
            for id, expiry in pairs(data.entries) do
                if type(id) == "string" and type(expiry) == "number" and expiry > os.time() and expiry <= os.time() + 600 then App.visited[id] = expiry end
            end
        end
    end)
end
local function connect(signal, fn)
    local conn = signal:Connect(function(...)
        if App.alive then fn(...) end
    end)
    table.insert(App.connections, conn)
    return conn
end
