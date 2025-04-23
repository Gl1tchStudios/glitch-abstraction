Config = {}

-- Frameworks our library supports
Config.Framework = {
    {name = 'ESX', resourceName = 'es_extended', getObject = function() return exports['es_extended']:getSharedObject() end},
    {name = 'QBCore', resourceName = 'qb-core', getObject = function() return exports['qb-core']:GetCoreObject() end},
}

-- Inventory systems
Config.Inventory = {
    {name = 'ox', resourceName = 'ox_inventory'},
    {name = 'qb', resourceName = 'qb-inventory'},
    {name = 'esx', resourceName = 'es_extended'},
}

-- Target systems
Config.Target = {
    {name = 'ox', resourceName = 'ox_target'},
    {name = 'qb', resourceName = 'qb-target'},
    {name = 'esx', resourceName = 'bt-target'},
}

-- Door Lock systems
Config.DoorLock = {
    {name = 'ox', resourceName = 'ox_doorlock'},
    {name = 'qb', resourceName = 'qb-doorlock'},
    {name = 'esx', resourceName = 'esx_doorlock'},
}

Config.FrameworkMapping = {
    ["QBox"] = "QBCore" -- QBox is the same as QBCore as it's a fork of it
}

-- UI system to use
Config.UISystem = 'oxlib' -- 'oxlib', 'qb', 'esx'
Config.ProgressCircle = true -- Use circle progress bar for oxlib

-- XP system
Config.xpSystem = 'pickle_xp'

-- Debug mode
Config.Debug = false