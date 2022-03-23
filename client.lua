local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

local consoleRem <const> = true -- console reminder; enabled by default.
local customRem <const> = false -- custom reminder (line 23).
local chatRem <const> = false -- disabled by default.
local commandName <const> = 'tpm'

TriggerEvent('chat:addSuggestion', '/' .. commandName, 'Teleport to your marked waypoint.')

local function notify(message)
    if consoleRem then
        print(message)
    end
    if chatRem then
        TriggerEvent('chat:addMessage', {
            color = {255,85,85},
            args = {"citizen-tpm", message}
        })
    end
    if customRem then
        -- Add your custom notification here.
    end
end

local function teleportToWaypoint()
    local blipMarker <const> = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        notify('client needs to set a waypoint first.')
        return 'marker'
    end

    -- Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = PlayerPedId(), GetBlipInfoIdCoord(blipMarker)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end

        NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        NewLoadSceneStop()
        SetPedCoordsKeepVehicle(ped, x, y, z)

        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end

        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);
        if found then
            Wait(0)
            SetPedCoordsKeepVehicle(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        return false
    end

    -- If Z coord was found, set coords in found coords.
    SetPedCoordsKeepVehicle(ped, x, y, groundZ)
    return true
end

RegisterCommand(commandName, function()
    local hasTeleported <const> = teleportToWaypoint()
    if not hasTeleported then
        notify('Could not teleport to desired location.')
        return
    elseif hasTeleported ~= 'marker' then
        notify('teleported successfully')
    end
end)

exports('TeleportToWaypoint', teleportToWaypoint)
