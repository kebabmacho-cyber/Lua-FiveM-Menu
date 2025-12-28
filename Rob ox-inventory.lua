local robbing = false
local attachedTo = nil

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local dist = #(p - vec3(x, y, z))
    local scale = 200 / (GetGameplayCamFov() * dist)

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function GetClosestPlayer()
    local closestPlayer = -1
    local closestDistance = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function ForceHandsUpOnPlayer(ped)
    local dict = "missminuteman_1ig_2"
    local anim = "handsup_base"

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
end

local function StopRobbing()
    local playerPed = PlayerPedId()

    DetachEntity(playerPed, true, false)
    SetEntityVisible(playerPed, true, false)

    if attachedTo and DoesEntityExist(attachedTo) then
        ClearPedTasks(attachedTo)
    end

    robbing = false
    attachedTo = nil
end

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()

        if not robbing then
            local closestPlayer, distance = GetClosestPlayer()
            if closestPlayer ~= -1 and distance <= 2.0 then
                local targetPed = GetPlayerPed(closestPlayer)
                local targetCoords = GetEntityCoords(targetPed)

                DrawText3D(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, "~g~[E]~s~ Rob Player")

                if IsControlJustReleased(0, 38) then
                    robbing = true
                    attachedTo = targetPed

                    ForceHandsUpOnPlayer(targetPed)
                end
            end
        else
            if IsControlJustReleased(0, 38) then
                StopRobbing()
            end
        end
    end
end)