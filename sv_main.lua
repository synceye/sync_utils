ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterCommand('snow', 'admin', function(xPlayer, showError)
    snijegon()
    xPlayer.showNotification('Snow is falling!')
end)

ESX.RegisterCommand('snowoff', 'admin', function(xPlayer, showError)
    snijegoff()
    xPlayer.showNotification('Snow stopped falling!')
end)

local stoppaneresources, jeldopusteno = {}, false --> ESX github old updates

for imeSkripte, razlog in pairs(Config.SkripteKojeTrebajuBitiStoppane) do
    local status = GetResourceState(imeSkripte)

    if status == 'started' or status == 'starting' then
        while GetResourceState(imeSkripte) == 'starting' do
            Citizen.Wait(120)
        end
        
        if not jeldopusteno then
            ExecuteCommand('add_ace resource.es_extended command.stop allow')
            jeldopusteno = true
        end

        ExecuteCommand(('stop %s'):format(imeSkripte))
        stoppaneresources[imeSkripte] = razlog
    end
end

if ESX.Table.SizeOf(stoppaneresources) > 0 then
    local sveStoppaneSkripte = ''

    for imeSkripte, razlog in pairs(stoppaneresources) do
        sveStoppaneSkripte = ('%s\n- ^3%s^7, %s'):format(sveStoppaneSkripte, imeSkripte, razlog)
    end

    print(('[sync_utils] [^3WARNING/UPOZORENJE^7] Stopped %s resources  / Stopirano %s skripti'):format(ESX.Table.SizeOf(stoppaneresources), sveStoppaneSkripte))
end