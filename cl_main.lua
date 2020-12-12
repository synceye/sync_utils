ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function snijegon() -- Tinky: esx_balkan: https://discord.gg/KbEgsV4tjw
    SetForceVehicleTrails(true)
    SetForcePedFootstepsTracks(true)
    ForceSnowPass(true)
    RequestScriptAudioBank("ICE_FOOTSTEPS", false)
    RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
    RequestNamedPtfxAsset("core_snow")
    while not HasNamedPtfxAssetLoaded("core_snow") do Wait(0) end
    UseParticleFxAssetNextCall("core_snow")
end

function snijegoff() -- Tinky: esx_balkan: https://discord.gg/KbEgsV4tjw
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    ForceSnowPass(false)
end