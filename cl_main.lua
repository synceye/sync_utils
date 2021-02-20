ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
local idovi = false
local disPlayerNames = 30

RegisterCommand('id', function()
    ESX.TriggerServerCallback("sync_ids:pregledajrankove", function(playerRank)
        if playerRank == "admin" or playerRank == "superadmin" then
          if not idovi then
            ESX.ShowNotification('~g~ID on!')
            idovi = true
          else
            idovi = false
           ESX.ShowNotification('~r~ID off!')
          end
        else
           ESX.ShowNotification('~r~You are not an admin!')
        end
    end)
end)
  
  playerDistances = {}
  Citizen.CreateThread(function()
      Wait(100)
      while true do
      Citizen.Wait(0)
        if not idovi then
          Citizen.Wait(2000)
        else
          for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if GetPlayerPed(player) ~= GetPlayerPed(-1) then
              if playerDistances[player] ~= nil and playerDistances[player] < disPlayerNames then
                x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(player), true))
                if not NetworkIsPlayerTalking(player) then
                  DrawText3D(x2, y2, z2+1, '~r~' .. GetPlayerServerId(player) .. ' ~c~| ~w~' .. GetPlayerName(player))
                else
                  DrawText3D(x2, y2, z2+1, '~g~' .. GetPlayerServerId(player) .. ' ~c~| ~w~' .. GetPlayerName(player))
                end
              end
            end
          end
        end
      end
  end)
  
  
  Citizen.CreateThread(function()
      while true do
          for _, player in ipairs(GetActivePlayers()) do
              if GetPlayerPed(player) ~= GetPlayerPed(-1) then
                  x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                  x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(player), true))
                  distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
                  playerDistances[player] = distance
              end
          end
          Citizen.Wait(1000)
      end
  end)
  
    function DrawText3D(x,y,z, text) 
        local onScreen,_x,_y=World3dToScreen2d(x,y,z)
        local px,py,pz=table.unpack(GetGameplayCamCoords())
        local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    
        local scale = (1/dist)*5
        local fov = (1/GetGameplayCamFov())*100
        local scale = scale*fov
        
        if onScreen then
            SetTextScale(0.0*scale, 0.30*scale)
            SetTextFont(0)
            SetTextProportional(1)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(2, 0, 0, 0, 150)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x,_y)
        end
    end

local mp_pointing = false --> ALL: https://github.com/redoper1/FiveM-Point-finger/
local keyPressed = false

local function startPointing()
    local ped = GetPlayerPed(-1)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing()
    local ped = GetPlayerPed(-1)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

local once = true
local oldval = false
local oldvalped = false

Citizen.CreateThread(function()
    while true do
        Wait(0)

        if once then
            once = false
        end

        if not keyPressed then
            if IsControlPressed(0, 29) and not mp_pointing and IsPedOnFoot(PlayerPedId()) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    keyPressed = true
                    startPointing()
                    mp_pointing = true
                else
                    keyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and mp_pointing) or (not IsPedOnFoot(PlayerPedId()) and mp_pointing) then
                keyPressed = true
                mp_pointing = false
                stopPointing()
            end
        end

        if keyPressed then
            if not IsControlPressed(0, 29) then
                keyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) and not mp_pointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
            if not IsPedOnFoot(PlayerPedId()) then
                stopPointing()
            else
                local ped = GetPlayerPed(-1)
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = 0
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
                nn,blocked,coords,coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)

            end
        end
    end
end)

function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
  AddTextEntry('FE_THDR_GTAO', '~r~Sync World~r~ | ~g~ID: ~b~' .. GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))) .. ' ~p~| ' .. '~p~Discord: ~y~https://discord.gg/pSEEteRgzJ')
  AddTextEntry('PM_PANE_LEAVE', '~b~FiveM Server Finder~b~')
  AddTextEntry('PM_PANE_QUIT', '~r~Leave~r~')
  AddTextEntry('PM_SCR_MAP', '~b~Map🗺️~b~')
  AddTextEntry('PM_SCR_GAM', '~r~Exit🎮~r~')
  AddTextEntry('PM_SCR_INF', '~y~Info~y~📝')
  AddTextEntry('PM_SCR_SET', '~b~Settings💻~b~')
  AddTextEntry('PM_SCR_STA', 'Stats')
  AddTextEntry('PM_SCR_GAL', 'Gallery📷')
  AddTextEntry('PM_SCR_RPL', 'Rockstart Editor')
end)
