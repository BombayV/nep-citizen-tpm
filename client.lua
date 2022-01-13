local consoleRem <const> = true -- enabled by default.
local chatRem <const> = false -- disabled by default.
local commandName <const> = 'tpm'

local function teleportToWaypoint()
    local blipMarker <const> = GetFirstBlipInfoId(8)
    if DoesBlipExist(blipMarker) then
        local coords, found, zState = GetBlipInfoIdCoord(blipMarker), true, -1.0
        local x, z, y = coords['x'], coords['y'], 1500.0

        SetTimeout(function() if found then found = false end end, 5000)
        while found do
            local groundFound, groundZ = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, z + zState)
            if z < 0 then
                zState = 1.0
            elseif z > 1500 then
                zState = -1.0
            end
            if groundFound then
                z = groundZ + 0.0
                SetPedCoordsKeepVehicle(PlayerPedId(), x, y, z)
                return true
            end
            Wait(0)
        end
    end
    return false
end

RegisterCommand(commandName, function()
    local hasTeleported <const> = teleportToWaypoint()
    if not hasTeleported then
        if chatRem then
            TriggerEvent('chat:addMessage', {
                color = {255,85,85},
                args = {"citizen-tpm", "could not find ground."}
            })
        end
        if consoleRem then
            print("could not find ground")
        end
        return
    end

    if chatRem then
        TriggerEvent('chat:addMessage', {
            color = {255,85,85},
            args = {"citizen-tpm", "client needs to set a waypoint first."}
        })
    end
    if consoleRem then
        print("client needs to set a waypoint first")
    end
end)

TriggerEvent('chat:addSuggestion', '/' .. commandName, "Teleport to your marked waypoint.")