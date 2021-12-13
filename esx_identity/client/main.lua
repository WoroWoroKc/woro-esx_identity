local guiEnabled = false
local myIdentity = {}
local myIdentifiers = {}
local hasIdentity = false
local isDead = false

ESX = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:AkiragetSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)

function EnableGui(state)
    SetNuiFocus(state, state)
    guiEnabled = state

    SendNUIMessage({
        type = "enableui",
        enable = state
    })
end

RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function()
    if not isDead then
        EnableGui(true)
    end
end)

RegisterNetEvent('esx_identity:identityCheck')
AddEventHandler('esx_identity:identityCheck', function(identityCheck)
    hasIdentity = identityCheck
end)

RegisterNetEvent('esx_identity:saveID')
AddEventHandler('esx_identity:saveID', function(data)
    myIdentifiers = data
end)

RegisterNUICallback('escape', function(data, cb)
    if hasIdentity then
        EnableGui(false)
    else
        TriggerEvent('chatMessagess','[IDENTITY] ', 1, 'You must create your first character in order to play!')
    end
end)

RegisterNUICallback('JEBACTUSKAKURWEFAJNYJESTEMREJESTRACJAPOSTACIHEREJSDJHASHDADASZUBIENICAPESTYCYDYBRONHEREXDDDDDDDDDKARTKYKOCHAMCIE', function(data, cb)
    local reason = ""
    myIdentity = data
    for theData, value in pairs(myIdentity) do
        if theData == "firstname" or theData == "lastname" then
            reason = verifyName(value)

            if reason ~= "" then
                break
            end
        elseif theData == "dateofbirth" then
            if value == "invalid" then
                reason = "Invalid date of birth!"
                break
            end
        elseif theData == "height" then
            local height = tonumber(value)
            if height then
                if height > 200 or height < 140 then
                    reason = "Unacceptable player height!"
                    break
                end
            else
                reason = "Unacceptable player height!"
                break
            end
        end
    end

    if reason == "" then
        EnableGui(false)
        DoScreenFadeOut(1000)
        DoScreenFadeIn(3000)
        SetCamActive(cam,  false)
        RenderScriptCams(false,  false,  0,  true,  true)
        SetEntityCollision(GetPlayerPed(-1),  true,  true)
        SetEntityVisible(GetPlayerPed(-1),  true)
        FreezeEntityPosition(GetPlayerPed(-1), false)
        DoScreenFadeIn(1000)
        TriggerServerEvent('esx_identity:setIdentity', data, myIdentifiers)
        EnableGui(false)
        ESX.Scaleform.ShowFreemodeMessage('~g~AkiraRP', 'Ustaw się w dogodnym miejscu, za 10 sekund uruchomi się menu tworzenia postaci.', 3)
        Wait(150)
        ESX.ShowAdvancedNotification('~g~AkiraRP', nil, 'Menu tworzenia postaci zostało otworzone.', 'CustomLogo')
        TriggerEvent('esx_skin:openSaveableMenu', myIdentifiers.id)
    else
        TriggerEvent('DoLongHudText' ..reason, 1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if guiEnabled then
            DisableControlAction(0, 1,   true) -- LookLeftRight
            DisableControlAction(0, 2,   true) -- LookUpDown
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 30,  true) -- MoveLeftRight
            DisableControlAction(0, 31,  true) -- MoveUpDown
            DisableControlAction(0, 21,  true) -- disable sprint
            DisableControlAction(0, 24,  true) -- disable attack
            DisableControlAction(0, 25,  true) -- disable aim
            DisableControlAction(0, 47,  true) -- disable weapon
            DisableControlAction(0, 58,  true) -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee
            DisableControlAction(0, 75,  true) -- disable exit vehicle
            DisableControlAction(27, 75, true) -- disable exit vehicle
        end
        Citizen.Wait(10)
    end
end)

function verifyName(name)
    local nameLength = string.len(name)
    if nameLength > 35 or nameLength < 1 then
        return 'Your player name is either too short or too long.'
    end
    local count = 0
    for i in name:gmatch('[abcdefghijklmnopqrstuvwxyzåäöABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ0123456789 -]') do
        count = count + 1
    end
    if count ~= nameLength then
        return 'Your player name contains special characters that are not allowed on this server.'
    end

    local spacesInName    = 0
    local spacesWithUpper = 0
    for word in string.gmatch(name, '%S+') do

        if string.match(word, '%u') then
            spacesWithUpper = spacesWithUpper + 1
        end

        spacesInName = spacesInName + 1
    end

    if spacesInName > 2 then
        return 'Your name contains more than two spaces'
    end

    if spacesWithUpper ~= spacesInName then
        return 'your name must start with a capital letter.'
    end

    return ''
end
