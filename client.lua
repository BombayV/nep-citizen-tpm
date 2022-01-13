local consoleRem <const> = true -- enabled by default.
local chatRem <const> = false -- disabled by default.
local commandName <const> = 'tpm'

local function teleportToWaypoint()
    local blipMarker <const> = GetFirstBlipInfoId(8)
    local ped = PlayerPedId()
    if DoesBlipExist(blipMarker) then
        local waypointCoords = GetBlipInfoIdCoord(blipMarker)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(ped, waypointCoords["x"], waypointCoords["y"], height + 0.0)
            local foundGround, _ = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
            if foundGround then
                SetPedCoordsKeepVehicle(ped, waypointCoords["x"], waypointCoords["y"], height + 0.0)
                return true
            end
            Wait(5)
        end
    else
        if chatRem then
            TriggerEvent('chat:addMessage', {
                color = {255,85,85},
                args = {"citizen-tpm", "client needs to set a waypoint first."}
            })
        end
        if consoleRem then
            print("client needs to set a waypoint first")
        end
        return false
    end
end

RegisterCommand(commandName, function()
    teleportToWaypoint()
end)

TriggerEvent('chat:addSuggestion', '/' .. commandName, "Teleport to your marked waypoint.")