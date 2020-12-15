ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

SkripteKojeTrebajuBitiStoppane = {
    ['essentialmode'] = 'ES for short, the performance heavy RP framework no one uses - and source for the random unwanted ZAP ads you\'re seeing',
	['es_admin2'] = 'Adminstration tool for the ancient ES framework that wont work with ESX',
	['esplugin_mysql'] = 'MySQL "plugin" for the ancient ES framework that has a SQL injection vulnerability',
	['es_ui'] = 'Money HUD for ES'
}

ESX.RegisterCommand('snow', 'admin', function(xPlayer, showError)
    snijegon()
    xPlayer.showNotification('Snow is falling!')
end)

ESX.RegisterCommand('snowoff', 'admin', function(xPlayer, showError)
    snijegoff()
    xPlayer.showNotification('Snow stopped falling!')
end)

ESX.RegisterServerCallback("sync_ids:pregledajrankove", function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    if player ~= nil then
        local playerGroup = player.getGroup()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb("user")
        end
    else
        cb("user")
    end
end)

local stoppaneresources, jeldopusteno = {}, false --> ESX github old updates

for imeSkripte, razlog in pairs(SkripteKojeTrebajuBitiStoppane) do
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
