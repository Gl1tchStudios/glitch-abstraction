-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading Glitch notifications module^7")
    return false
end

GlitchAbst.Notifications = GlitchAbst.Notifications or {}
GlitchAbst.Notifications.Glitch = GlitchAbst.Notifications.Glitch or {}

-- Checked on every call: glitch-notifications can start (or restart) after this library
local function Available()
    return GetResourceState('glitch-notifications') == 'started'
end

if not Available() then
    GlitchAbst.Utils.DebugLog('glitch-notifications resource is not available')
else
    GlitchAbst.Utils.DebugLog('Glitch notifications module loaded')
end

-- Store notification IDs for reference
local activeNotifications = {}
local nextNotificationId = 1

local typeToColor = {
    success = '#00a65a',  -- Green
    error = '#dd4b39',    -- Red
    warning = '#f39c12',  -- Orange/Yellow
    info = '#00c0ef',     -- Blue
    inform = '#00c0ef',   -- Blue (ox_lib name)
    primary = '#3c8dbc'   -- Light Blue
}

-- Types other systems use -> ox_lib types
local OX_TYPES = { info = 'inform', inform = 'inform', primary = 'inform', success = 'success', error = 'error', warning = 'warning', warn = 'warning' }

local function Params(params)
    if type(params) ~= 'table' then return { description = tostring(params or '') } end
    return params
end

local function OxNotify(params)
    exports['ox_lib']:notify({
        title = params.title,
        description = params.description or params.message,
        type = OX_TYPES[params.type or 'inform'] or 'inform',
        duration = params.duration or 5000,
        position = params.position or 'top-right',
        icon = params.icon
    })
end

local function NativeNotify(params)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(tostring(params.description or params.message or params.title or ''))
    EndTextCommandThefeedPostTicker(false, true)
end

GlitchAbst.Notifications.Glitch.Show = function(params)
    params = Params(params)
    if not Available() then
        return GlitchAbst.Notifications.Fallback('Show', params)
    end

    local title = params.title or ''
    local message = params.description or params.message or ''
    local duration = params.duration or 5000
    local color = params.color or typeToColor[params.type or 'info'] or '#00c0ef'
    local noAnimation = params.noAnimation or false

    -- Use the correct export
    local notificationId = exports['glitch-notifications']:ShowNotification(
        title,
        message,
        duration,
        color,
        noAnimation
    )

    -- Store the notification id for potential future use
    activeNotifications[nextNotificationId] = notificationId
    nextNotificationId = nextNotificationId + 1

    return notificationId
end

local function GlitchTyped(kind)
    return function(title, message, duration)
        return GlitchAbst.Notifications.Glitch.Show({
            title = title,
            description = message,
            type = kind,
            duration = duration
        })
    end
end

GlitchAbst.Notifications.Glitch.Success = GlitchTyped('success')
GlitchAbst.Notifications.Glitch.Error = GlitchTyped('error')
GlitchAbst.Notifications.Glitch.Info = GlitchTyped('info')
GlitchAbst.Notifications.Glitch.Warning = GlitchTyped('warning')

-- Add box to an existing notification
GlitchAbst.Notifications.Glitch.AddBox = function(notificationId, title, message, color)
    if not Available() or not notificationId then return nil end

    return exports['glitch-notifications']:AddBoxToNotification(
        notificationId,
        title,
        message,
        color or '#FFFFFF',
        false
    )
end

-- Remove a specific box from a notification
GlitchAbst.Notifications.Glitch.RemoveBox = function(notificationId, boxId)
    if not Available() or not notificationId or not boxId then return false end

    exports['glitch-notifications']:RemoveBoxFromNotification(notificationId, boxId)
    return true
end

-- Remove an entire notification
GlitchAbst.Notifications.Glitch.Remove = function(notificationId)
    if not Available() or not notificationId then return false end

    exports['glitch-notifications']:RemoveNotification(notificationId)
    return true
end

-- Update content of a notification box
GlitchAbst.Notifications.Glitch.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if not Available() or not notificationId or not boxId then return false end

    exports['glitch-notifications']:UpdateBoxContent(
        notificationId,
        boxId,
        newMessage,
        newTitle,
        newColor
    )
    return true
end

-- Toggle a notification on or off
GlitchAbst.Notifications.Glitch.Toggle = function(id, title, message, color)
    if not Available() then return false end

    exports['glitch-notifications']:ToggleNotification(
        id,
        title,
        message,
        color or '#FFFFFF'
    )
    return true
end

-- Route to the other notification systems when glitch-notifications is not used
GlitchAbst.Notifications.Fallback = function(method, params)
    params = Params(params)
    if method ~= 'Show' then return nil end

    -- First try ox_lib if available
    if GetResourceState('ox_lib') == 'started' then
        OxNotify(params)
        return 1 -- Return dummy ID
    end

    -- Try ESX notifications if available
    if GlitchAbst.FrameworkName == 'ESX' then
        TriggerEvent('esx:showNotification', (params.title and (params.title .. ': ') or '') ..
            (params.description or params.message or ''), params.type or 'info', params.duration)
        return 1
    end

    -- Try QBCore notifications if available
    if GlitchAbst.FrameworkName == 'QBCore' then
        TriggerEvent('QBCore:Notify', params.description or params.message or params.title, params.type or 'primary', params.duration or 5000)
        return 1
    end

    -- Last resort - basic game notification
    NativeNotify(params)
    return 1
end

-- Create top-level functions that route to appropriate notification system
GlitchAbst.Notifications.Show = function(params)
    params = Params(params)

    -- If explicitly configured to use Glitch, then use it when available
    if Config.NotificationSystem == 'glitch' and Available() then
        return GlitchAbst.Notifications.Glitch.Show(params)
    end

    -- For auto mode, implement a proper priority order
    if Config.NotificationSystem == 'auto' then
        -- Define the priority order for auto detection
        local priorityOrder = Config.NotificationsPriority or {
            'ox', -- Default to ox first
            'qb',
            'esx',
            'glitch', -- Glitch comes last in priority for auto mode
            'native'
        }

        -- Try each system in priority order
        for _, system in ipairs(priorityOrder) do
            if system == 'ox' and GetResourceState('ox_lib') == 'started' then
                OxNotify(params)
                return 1 -- Return dummy ID
            end

            if system == 'qb' and GlitchAbst.FrameworkName == 'QBCore' then
                TriggerEvent('QBCore:Notify', params.description or params.message or params.title,
                    params.type or 'primary', params.duration or 5000)
                return 2 -- Return dummy ID
            end

            if system == 'esx' and GlitchAbst.FrameworkName == 'ESX' then
                TriggerEvent('esx:showNotification',
                    (params.title and (params.title .. ': ') or '') ..
                    (params.description or params.message or ''),
                    params.type or 'info', params.duration)
                return 3 -- Return dummy ID
            end

            if system == 'glitch' and Available() then
                return GlitchAbst.Notifications.Glitch.Show(params)
            end

            if system == 'native' then
                NativeNotify(params)
                return 4
            end
        end

        -- Native as absolute fallback
        NativeNotify(params)
        return 4 -- Return dummy ID
    end

    -- For specific configured systems
    return GlitchAbst.Notifications.Fallback('Show', params)
end

local function Typed(kind)
    return function(title, message, duration)
        return GlitchAbst.Notifications.Show({
            title = title,
            description = message,
            type = kind,
            duration = duration
        })
    end
end

GlitchAbst.Notifications.Success = Typed('success')
GlitchAbst.Notifications.Error = Typed('error')
GlitchAbst.Notifications.Info = Typed('info')
GlitchAbst.Notifications.Warning = Typed('warning')

local function UseGlitchBoxes()
    return (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and Available()
end

-- Basic fallback functions for extended functionality
GlitchAbst.Notifications.AddBox = function(notificationId, title, message, color)
    if UseGlitchBoxes() then
        return GlitchAbst.Notifications.Glitch.AddBox(notificationId, title, message, color)
    end
    -- Most systems don't have AddBox functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = title, description = message})
end

GlitchAbst.Notifications.RemoveBox = function(notificationId, boxId)
    if UseGlitchBoxes() then
        return GlitchAbst.Notifications.Glitch.RemoveBox(notificationId, boxId)
    end
    return false
end

GlitchAbst.Notifications.Remove = function(notificationId)
    if UseGlitchBoxes() then
        return GlitchAbst.Notifications.Glitch.Remove(notificationId)
    end
    return false
end

GlitchAbst.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if UseGlitchBoxes() then
        return GlitchAbst.Notifications.Glitch.Update(notificationId, boxId, newMessage, newTitle, newColor)
    end
    -- Most systems don't have Update functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = newTitle, description = newMessage})
end

GlitchAbst.Notifications.Toggle = function(id, title, message, color)
    if UseGlitchBoxes() then
        return GlitchAbst.Notifications.Glitch.Toggle(id, title, message, color)
    end
    -- Most systems don't have Toggle functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = title, description = message})
end

-- Mirror function to UI namespace for backward compatibility
GlitchAbst.UI.Notify = function(params)
    return GlitchAbst.Notifications.Show(params)
end

-- Loaded only when glitch-notifications is running
return Available()
