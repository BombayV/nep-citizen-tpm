consoleRem = true -- enabled by default.
chatRem = false -- disabled by default.

TriggerEvent('chat:addSuggestion', '/tpm', "Teleport to your marked waypoint.")

RegisterCommand("tpm", function(source)
    TeleportToWaypoint()
end)

TeleportToWaypoint = function()
    local WaypointHandle = GetFirstBlipInfoId(8)
    if DoesBlipExist(WaypointHandle) then
        local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
        for height = 1, 1000 do
            SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
            local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
            if foundGround then
                SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
                break
            end
            Wait(5)
        end
    else
        if chatRem then
            TriggerEvent('chat:addMessage', {
                color = {255,85,85},
                args = {"citizen-tpm", "client needs to set a waypoint first."}
            })
        else
            if consoleRem then
                print("client needs to set a waypoint first")
            end
        end
    end
end