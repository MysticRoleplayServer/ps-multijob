local QBCore = exports['qb-core']:GetCoreObject()


-- Command Code
RegisterCommand("jobmenu", OpenUI)

RegisterKeyMapping('jobmenu', "Show Job Management", "keyboard", "J")

TriggerEvent('chat:removeSuggestion', '/jobmenu')

local function GetJobs()
    local p = promise.new()
    QBCore.Functions.TriggerCallback('ps-multijob:getJobs', function(result)
        p:resolve(result)
    end)
    return Citizen.Await(p)
end

local function OpenUI()
    local job = QBCore.Functions.GetPlayerData().job
    SetNuiFocus(true,true)
    SendNUIMessage({
        action = 'sendjobs',
        activeJob = job["name"],
        onDuty = job["onduty"],
        jobs = GetJobs(),
    })
end

RegisterNUICallback('selectjob', function(data, cb)
    TriggerServerEvent("ps-multijob:changeJob", data["name"], data["grade"])
    -- TODO: Need to send back if we are on duty for this new job we are selecting
    local onDuty = false
    if data["name"] ~= "police" then onDuty = QBCore.Shared.Jobs[data["name"]].defaultDuty end
    cb({onDuty = onDuty})
end)

RegisterNUICallback('closemenu', function(data, cb)
    cb({})
    SetNuiFocus(false,false)
end)

RegisterNUICallback('removejob', function(data, cb)
    cb({})
    TriggerServerEvent("ps-multijob:removeJob", data["name"], data["grade"])
end)

RegisterNUICallback('toggleduty', function(data, cb)
    cb({})
    -- to do, add toggle sync

    local job = QBCore.Functions.GetPlayerData().job.name

    local policeJobs = {
        ["police"] = true
    }
    if policeJobs[job] then
        TriggerEvent('qb-policejob:ToggleDuty')
        return
    end
    
    TriggerServerEvent("QBCore:ToggleDuty")
end)
