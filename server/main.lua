local framework = Config.Framework
local ESX = nil
local timeUnit = Config.TimeUnit

if framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif framework == 'frw' then
    ESX = exports['Framework']:getSharedObject()
else
    print("Votre Framework est spécial ou trop ancian, get le code pour changer l'export")
end

local playersInJail = {}
local function convertTime(time)
    if timeUnit == "M" then
        return time * 60
    elseif timeUnit == "H" then
        return time * 3600 
    else
        return time 
    end
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] and result[1].jail_time > 0 then
            TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
        end
    end)
end)

AddEventHandler('esx:playerDropped', function(playerId)
    playersInJail[playerId] = nil
end)

MySQL.ready(function()
    Wait(2000)
    local xPlayers = ESX.GetPlayers()

    for _, playerId in ipairs(xPlayers) do
        Wait(100)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            MySQL.Async.fetchAll('SELECT jail_time FROM users WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(result)
                if result[1] and result[1].jail_time > 0 then
                    TriggerEvent('esx_jail:sendToJail', xPlayer.source, result[1].jail_time, true)
                end
            end)
        end
    end
end)

ESX.RegisterCommand('jail', {'mod', 'admin', 'superadmin', 'owner', '_dev'}, function(xPlayer, args, showError)
    local targetId = args.playerId
    local jailTime = convertTime(args.time)
    local message = args.message

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if targetPlayer and jailTime and jailTime > 0 then
        TriggerEvent('esx_jail:sendToJail', targetId, jailTime, message, xPlayer.source, false)
    else
        showError("Erreur.")
    end
end, true, {help = 'Jail a player', validate = true, arguments = {
    {name = 'playerId', type = 'playerId'},
    {name = 'time', type = 'number'},
    {name = 'message', type = 'any'}
}})

ESX.RegisterCommand('unjail', {'mod', 'admin', 'superadmin', 'owner', '_dev'}, function(xPlayer, args, showError)
    local targetId = args.playerId
    if targetId then
        unjailPlayer(targetId)
    else
        showError("Erreur.")
    end
end, true, {help = 'Unjail joueur', validate = true, arguments = {
    {name = 'playerId', type = 'playerId'}
}})

RegisterNetEvent('esx_jail:unjail')
AddEventHandler('esx_jail:unjail', function(playerId)
    unjailPlayer(playerId)
end)

RegisterNetEvent('esx_jail:sendToJail')
AddEventHandler('esx_jail:sendToJail', function(playerId, jailTime, message, src, quiet)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and not playersInJail[playerId] then
        MySQL.Async.execute('UPDATE users SET jail_time = @jail_time WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier,
            ['@jail_time'] = jailTime
        }, function()
            xPlayer.triggerEvent('esx_jail:jailPlayer', jailTime, message, src)
            playersInJail[playerId] = {timeRemaining = jailTime, identifier = xPlayer.identifier}
            if not quiet then
                TriggerClientEvent('esx:showNotification', playerId, "Vous avez été Jail.")
            end
        end)
    end
end)

function unjailPlayer(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and playersInJail[playerId] then
        MySQL.Async.execute('UPDATE users SET jail_time = 0 WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function()
            TriggerClientEvent('esx:showNotification', playerId, "Vous avez été UnJail.")
            playersInJail[playerId] = nil
            xPlayer.triggerEvent('esx_jail:unjailPlayer')
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        for playerId, data in pairs(playersInJail) do
            data.timeRemaining = data.timeRemaining - 1
            if data.timeRemaining <= 0 then
                unjailPlayer(playerId)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        for playerId, data in pairs(playersInJail) do
            MySQL.Async.execute('UPDATE users SET jail_time = @time_remaining WHERE identifier = @identifier', {
                ['@identifier'] = data.identifier,
                ['@time_remaining'] = data.timeRemaining
            })
        end
    end
end)
