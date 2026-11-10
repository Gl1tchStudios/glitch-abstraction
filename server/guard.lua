-- Local event guard. This copy keeps the bridge independent from glitch-poolcleaning.
-- It records event traffic when glitch-poolcleaning is present, but never blocks handlers.
if IsDuplicityVersion and not IsDuplicityVersion() then return end
-- Only for servers that run glitch-poolcleaning (its telemetry reads these counts). Elsewhere this file does nothing.
if GetResourceState('glitch-poolcleaning') == 'missing' then return end
if Config and Config.EventGuard == false then return end
local guardState = rawget(_G, '__glitchGuard')
if guardState then return end
__glitchGuard = true

local resourceName = GetCurrentResourceName()
local reportEvent = 'glitch-poolcleaning:netcount'
local originalRegisterNetEvent = RegisterNetEvent
local originalRegisterServerEvent = RegisterServerEvent
local originalAddEventHandler = AddEventHandler
local netEvents = {}
local counts, invalidArguments = {}, {}
local pending = false
local maxStringLength = 32768
local registering = 0

local function checkArguments(...)
    local count = select('#', ...)
    for index = 1, math.min(count, 16) do
        local value = select(index, ...)
        local valueType = type(value)
        if valueType == 'number' then
            if value ~= value then return ('argument %d is NaN'):format(index) end
            if value == math.huge or value == -math.huge then
                return ('argument %d is infinite'):format(index)
            end
        elseif valueType == 'string' and #value > maxStringLength then
            return ('argument %d is a %d character string'):format(index, #value)
        end
    end
end

local function countEvent(name, ...)
    local sourceId = tonumber(source)
    if not sourceId or sourceId <= 0 then return end

    local resourceCounts = counts[sourceId]
    if not resourceCounts then
        resourceCounts = {}
        counts[sourceId] = resourceCounts
    end
    resourceCounts[name] = (resourceCounts[name] or 0) + 1

    local reason = checkArguments(...)
    if reason and #invalidArguments < 50 then
        invalidArguments[#invalidArguments + 1] = { sourceId, name, reason }
    end
    pending = true
end

local function wrapHandler(name, callback)
    if type(callback) ~= 'function'
        and not (type(callback) == 'table' and getmetatable(callback) and getmetatable(callback).__call) then
        return callback
    end
    return function(...)
        countEvent(name, ...)
        return callback(...)
    end
end

function RegisterNetEvent(name, callback)
    if type(name) == 'string' then netEvents[name] = true end
    if callback == nil then return originalRegisterNetEvent(name) end

    registering = registering + 1
    local ok, result = pcall(originalRegisterNetEvent, name, wrapHandler(name, callback))
    registering = registering - 1
    if not ok then error(result, 2) end
    return result
end

function RegisterServerEvent(name, callback)
    if type(name) == 'string' then netEvents[name] = true end
    if callback == nil then return originalRegisterServerEvent(name) end

    registering = registering + 1
    local ok, result = pcall(originalRegisterServerEvent, name, wrapHandler(name, callback))
    registering = registering - 1
    if not ok then error(result, 2) end
    return result
end

function AddEventHandler(name, callback)
    if registering == 0 and type(name) == 'string' and netEvents[name] then
        callback = wrapHandler(name, callback)
    end
    return originalAddEventHandler(name, callback)
end

CreateThread(function()
    while true do
        Wait(1000)
        if pending then
            local currentCounts, currentInvalid = counts, invalidArguments
            counts, invalidArguments, pending = {}, {}, false
            TriggerEvent(reportEvent, resourceName, currentCounts, currentInvalid)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        if GetResourceState('glitch-poolcleaning') == 'started' then
            local ok, settings = pcall(function()
                return exports['glitch-poolcleaning']:NetGuardSettings()
            end)
            if ok and type(settings) == 'table' and tonumber(settings.maxStringLength) then
                maxStringLength = tonumber(settings.maxStringLength)
            end
        end
        Wait(55000)
    end
end)
