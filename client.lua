local function isVehicleWithEmergencyLights(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    return IsVehicleSirenOn(vehicle) and IsVehicleSirenSoundOn(vehicle)
end

local function isAtIntersection(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local vehiclePos = GetEntityCoords(vehicle)
    return IsPointOnRoad(vehiclePos.x, vehiclePos.y, vehiclePos.z, vehicle)
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in ipairs(vehicles) do
            if vehicle ~= playerVeh and isVehicleWithEmergencyLights(vehicle) then
                local emergencyPos = GetEntityCoords(vehicle)
                for _, aiVehicle in ipairs(vehicles) do
                    if aiVehicle ~= vehicle then
                        local aiDriver = GetPedInVehicleSeat(aiVehicle, -1)

                        if aiDriver ~= 0 and not IsPedAPlayer(aiDriver) then
                            local distance = #(GetEntityCoords(aiVehicle) - emergencyPos)

                            if distance < 100.0 then
                                if isAtIntersection(aiVehicle) then
                                    TaskVehicleTempAction(aiDriver, aiVehicle, 27, 1000)
                                    TaskVehicleTempAction(aiDriver, aiVehicle, 6, 3000)
                                else
                                    TaskVehicleTempAction(aiDriver, aiVehicle, 1, 5000)
                                    Citizen.Wait(100)
                                    SetVehicleBrake(aiVehicle, true)
                                end
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(500)
    end
end)
