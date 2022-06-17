-----------------------------------------------------------------------------------------------------------------------------------------

-- VRP

-----------------------------------------------------------------------------------------------------------------------------------------

local Tunnel = module("vrp","lib/Tunnel")

local Proxy = module("vrp","lib/Proxy")

local Config = module(GetCurrentResourceName(),"config")

vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------

-- CONEXÃO

-----------------------------------------------------------------------------------------------------------------------------------------

psRP = {}

Tunnel.bindInterface(GetCurrentResourceName(),psRP)

vSERVER = Tunnel.getInterface(GetCurrentResourceName())

-----------------------------------------------------------------------------------------------------------------------------------------

-- VARIABLES

-----------------------------------------------------------------------------------------------------------------------------------------

local PlayerJob    = {}

local isLoggedIn   = false

local patt         = "[?!@#]"

local takePhoto    = false

local focus        = true

local loaded       = false

local NuiFocus     = true

local IsTyping     = false

local DisableKey   = false

local checklicense = false

local painelopen   = false

PhoneData = {

    background        = nil,

    picture           = nil,

    UserData          = {},

    isOpen            = false,

    PlayerData        = nil,

    Contacts          = {},

    Invoices          = {},

    CallData          = {},

    RecentCalls       = {},

    InstagramAccount  = nil,

    StoriesInstagram  = {},

    MyStorieInstagram = {},

    StoriesPosts      = {},

    WhatsAppAccount   = nil,

    StoriesWhatsApp   = {},

    MyStorieWhatsApp  = {},

    TwitterAccount    = nil,

    GarageVehicles    = {},

    AnimationData     = {

        lib  = nil,

        anim = nil,

    },

    SuggestedContacts  = {},

    CryptoTransactions = {},

    Zoom               = nil,

    AnonymousCall      = nil

}

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddRecentCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':GetActivePlayers')

AddEventHandler(GetCurrentResourceName()..':GetActivePlayers', function(name, username, TweetMessage)

    local players = GetActivePlayers()

    TriggerServerEvent(GetCurrentResourceName()..':MentionedPlayerReturn', name, username, TweetMessage)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddRecentCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':AddRecentCall')

AddEventHandler(GetCurrentResourceName()..':AddRecentCall', function(data, time, type)

    table.insert(PhoneData.RecentCalls, {

        name = IsNumberInContacts(data.number),

        time = time,

        type = type,

        number = data.number,

        anonymous = data.anonymous

    })

    TriggerServerEvent(GetCurrentResourceName()..':SetPhoneAlerts', "phone")

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ClearRecentAlerts

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('ClearRecentAlerts', function(data, cb)

    TriggerServerEvent(GetCurrentResourceName()..':SetPhoneAlerts', "phone", 0)

    SendNUIMessage({ action = "RefreshAppAlerts" })

    cb(true)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SetBackground

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SetBackground', function(data, cb)

    local save = {}

    save.option = "background"

    save.value = data.background



    TriggerServerEvent(GetCurrentResourceName()..':SaveSettings', save)



    cb(true)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SaveSettings

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SaveSettings', function(data, cb)

    local save = {}

    save.option = data.option

    save.value = data.value



    TriggerServerEvent(GetCurrentResourceName()..':SaveSettings', save)



    cb(true)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMissedCalls

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMissedCalls', function(data, cb)

    local calls = vSERVER.GetMissedCalls()

    if calls then

        cb(json.encode(calls))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- IsNumberInContacts

-----------------------------------------------------------------------------------------------------------------------------------------

function IsNumberInContacts(num)

    local retval = num

    for _, v in pairs(PhoneData.Contacts) do

        if num == v.number then

            retval = v.name

        end

    end

    return retval

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- PRESSED OPEN PHONE

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand("psopenphone",function(source,args)

    OpenPhone()

end)

RegisterKeyMapping("psopenphone","Abrir Celular","keyboard", Config.OpenPhone)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ChangeNuiFocus

-----------------------------------------------------------------------------------------------------------------------------------------

function ChangeNuiFocus(value)

    NuiFocus = value

    SetNuiFocus(NuiFocus, NuiFocus)

    if IsTyping == false then

        SetNuiFocusKeepInput(NuiFocus)

    end

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- LoadPhone

-----------------------------------------------------------------------------------------------------------------------------------------

function LoadPhone()

    Citizen.Wait(100)

    isLoggedIn = true

    local pData = vSERVER.GetPhoneData()



    checklicense = true



    if pData ~= nil and checklicense then

        loaded = true

        

        local background = vSERVER.GetPhoneSettings('background')

        PhoneData.background = background



        local zoom = vSERVER.GetPhoneSettings('zoom')

        PhoneData.Zoom = zoom



        local anonymouscall = vSERVER.GetPhoneSettings('anonymouscall')

        PhoneData.AnonymousCall = anonymouscall



        local UserData = vSERVER.GetUserData()

        PhoneData.UserData = UserData



        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 

            PhoneData.Contacts = pData.PlayerContacts

        end



        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then

            PhoneData.Invoices = pData.Invoices

        end



        Citizen.Wait(300)



        SendNUIMessage({ 

            action = "LoadPhoneData", 

            PhoneData = PhoneData, 

            UserData = PhoneData.UserData

        })



        Citizen.Wait(2000)

    end



end

-----------------------------------------------------------------------------------------------------------------------------------------

-- OnPlayerUnload

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':OnPlayerUnload')

AddEventHandler(GetCurrentResourceName()..':OnPlayerUnload', function()

    PhoneData = {

        MetaData = {

            background = nil,

            picture = nil

        },

        isOpen = false,

        PlayerData = nil,

        Contacts = {},

        Invoices = {},

        CallData = {},

        RecentCalls = {},

        StoriesInstagram = {},

        MyStorieInstagram = {},

        StoriesPosts = {},

        GarageVehicles = {},

        AnimationData = {

            lib = nil,

            anim = nil,

        },

        SuggestedContacts = {},

        CryptoTransactions = {},

    }



    isLoggedIn = false

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- OnPlayerLoaded

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':OnPlayerLoaded')

AddEventHandler(GetCurrentResourceName()..':OnPlayerLoaded', function()

    LoadPhone()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- RefreshUserData

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('RefreshUserData', function(data, cb)

    LoadPhone()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- HasPhone

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('HasPhone', function(data, cb)

    local HasPhone = vSERVER.HasPhone()

    cb(HasPhone)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DISABLED ACTIONS

-----------------------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()

    while true do

        local time = 1000

        if PhoneData.isOpen then

            time = 1

            for k, v in pairs(Config.ButtonDisable) do

                DisableControlAction(0, Config.ButtonDisable[k], true)

                DisableControlAction(1, Config.ButtonDisable[k], true)

                DisableControlAction(2, Config.ButtonDisable[k], true)

            end

            if IsTyping then

                DisableAllControlActions(0)

            end

        end



        if not loaded then

            LoadPhone()

        end



        Citizen.Wait(time)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- OpenPhone

-----------------------------------------------------------------------------------------------------------------------------------------

function OpenPhone()



    if not loaded then

        LoadPhone()

    end



    local life = GetEntityHealth(PlayerPedId())



    local handcuffed = vSERVER.CheckHandcuffed()



    if PhoneData.isOpen or life <= Config.CheckLife or handcuffed then

        return false

    end



	local HasPhone = vSERVER.HasPhone()

    checklicense   = true



    if HasPhone and checklicense then

        local UserData = vSERVER.GetUserData();

        PhoneData.PlayerData = UserData

        

        -- set focus

        SetNuiFocus(true, true)

        if Config.UseMoving then

            SetNuiFocusKeepInput(true)

        end



        SendNUIMessage({

            action       = "open",

            CallData     = PhoneData.CallData,

            UserData     = PhoneData.UserData,

            checklicense = checklicense

        })



        SendNUIMessage({

            action    = "UpdateIPAddress",

            ipaddress = Config.IPAddress,

        })



        SendNUIMessage({

            action     = "UpdateConfig",

            configfile = json.encode(Config.Client),

        })



        local languages = json.encode(Locales[Config.Locale])



        SendNUIMessage({

            action    = "UpdateLanguages",

            languages = languages,

        })



        PhoneData.isOpen = true



        if PhoneData.CallData.InCall then

            PhonePlayText()

            TriggerEvent("cancelando",true)

            TriggerEvent("status:celular",true)

            TriggerEvent("player:blockCommands",true)

        else

            PhonePlayText()

        end



        TriggerEvent("cancelando",true)

		TriggerEvent("status:celular",true)

		TriggerEvent("player:blockCommands",true)

        



        SetTimeout(250, function()

            newPhoneProp()

        end)

    end

end

exports("OpenPhone", OpenPhone)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Close

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('Close', function(data, cb)

    if PhoneData.CallData.InCall and checklicense then

        PhonePlayText()

    else

        PhonePlayOut()

    end

    SetNuiFocus(false, false)

    SetNuiFocusKeepInput(false)

    SetTimeout(1000, function()

        PhoneData.isOpen = false

    end)



    TriggerEvent("cancelando",false)

    TriggerEvent("status:celular",false)

    TriggerEvent("player:blockCommands",false)

    cb(true)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddNewContact

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddNewContact', function(data, cb)

    if not checklicense then

        return false

    end

    TriggerServerEvent(GetCurrentResourceName()..':AddNewContact', data.ContactName, data.ContactNumber, data.ContactIban)

    Citizen.Wait(1000)



    local pData = vSERVER.GetPhoneData()  

    if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 

        PhoneData.Contacts = pData.PlayerContacts

    end



    SendNUIMessage({

        action = "RefreshContacts",

        Contacts = PhoneData.Contacts

    })

    cb({ PhoneContacts = PhoneData.Contacts })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetWhatsappChat

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetWhatsappChat', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetWhatsappChat(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SetChatReadWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SetChatReadWhatsapp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.SetChatReadWhatsapp(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeleteWhatsappChat

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeleteWhatsappChat', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeleteWhatsappChat(data)

    if check then

        local messages = vSERVER.GetWhatsappChat(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfilePicture

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfilePicture', function(data, cb)

    if not checklicense then

        return false

    end

    local number = data.number



    local avatar = vSERVER.GetProfilePicture(number)

    if avatar then

        cb(json.encode(avatar))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendMessage

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendMessage', function(data, cb)



    if not checklicense then

        return false

    end



    local phone = data.phone

    local message = data.message

    local number = data.number

    local type = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        phone = phone,

        message = message,

        number = number,

        type = type

    }



    local check = vSERVER.SendMessage(send)

    if check then

        local messages = vSERVER.GetWhatsappChat(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SharedLocation

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SharedLocation', function(data)

    if not checklicense then

        return false

    end



    local x = data.coords.x

    local y = data.coords.y



    SetNewWaypoint(x, y)

    SendNUIMessage({

        action = "PhoneNotification",

        PhoneNotify = {

            title = "Whatsapp",

            text = _("location_is_set"),

            icon = "fab fa-whatsapp",

            color = "#25D366",

            timeout = 1500,

        },

    })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SharedLocation

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SharedLocationMessage', function(data)

    if not checklicense then

        return false

    end



    local x = data.coords.x

    local y = data.coords.y



    SetNewWaypoint(x, y)

    SendNUIMessage({

        action = "PhoneNotification",

        PhoneNotify = {

            title = "iMessage",

            text = _("location_is_set"),

            icon = "fas fa-comment",

            color = "#36a9fc",

            timeout = 1500,

        },

    })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SharedLocationInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SharedLocationInsta', function(data)

    if not checklicense then

        return false

    end



    local x = data.coords.x

    local y = data.coords.y



    SetNewWaypoint(x, y)

    SendNUIMessage({

        action = "PhoneNotification",

        PhoneNotify = {

            title = "Instagram",

            text = _("location_is_set"),

            icon = "fab fa-instagram",

            color = "#36a9fc",

            timeout = 1500,

        },

    })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetLocation

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetLocation', function(data, cb)

    if not checklicense then

        return false

    end



    local ped = PlayerPedId()

    local x,y,z = table.unpack(GetEntityCoords(ped))



    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))



    cb(street)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- PayInvoice

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('PayInvoice', function(data, cb)

    if not checklicense then

        return false

    end

    local sender    = data.sender

    local amount    = data.amount

    local invoiceId = data.invoiceId



    TriggerServerEvent(GetCurrentResourceName()..':PayInvoice', function(CanPay, Invoices)

        if CanPay then PhoneData.Invoices = Invoices end

        cb(CanPay)

    end, sender, amount, invoiceId)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditContact

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditContact', function(data, cb)

    if not checklicense then

        return false

    end

    local name      = data.name

    local number    = data.number

    local bank      = data.bank

    local oldname   = data.oldname

    local oldnumber = data.oldnumber

    local oldbank   = data.oldbank



    TriggerServerEvent(GetCurrentResourceName()..':EditContact', name, number, bank, oldname, oldnumber, oldbank)



    Citizen.Wait(100)



    local pData = vSERVER.GetPhoneData()  

    if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 

        PhoneData.Contacts = pData.PlayerContacts

    end



    SendNUIMessage({

        action = "RefreshContacts",

        Contacts = PhoneData.Contacts

    })

    cb({ PhoneContacts = PhoneData.Contacts })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeleteTweet

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeleteTweet', function(data, cb)

    if not checklicense then

        return false

    end

    TriggerServerEvent(GetCurrentResourceName()..":deleteTweet", data.id)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetTweets

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetTweets', function(data, cb)

    if not checklicense then

        return false

    end

    local tweets = vSERVER.GetTweets()

    if tweets then

        cb(json.encode(tweets))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetSelfTweets

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetSelfTweets', function(data, cb)

    if not checklicense then

        return false

    end

    local tweets = vSERVER.GetSelfTweets(data)

    if tweets then

        cb(json.encode(tweets))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- PostNewTweet

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('PostNewTweet', function(data, cb)

    if not checklicense then

        return false

    end



    local check = vSERVER.PostNewTweet(data)



    if check then

        local TweetMessage = {

            name     = TwitterAccount.name,

            username = TwitterAccount.username,

            message  = data.message,

            image    = data.image

        }



        if (TwitterAccount.name ~= nil and TwitterAccount.name ~= "") and (TwitterAccount.username ~= nil and TwitterAccount.username ~= "") then

            TriggerServerEvent(GetCurrentResourceName()..':MentionedPlayer', TwitterAccount.name, TwitterAccount.username, TweetMessage)

        end



        TriggerServerEvent(GetCurrentResourceName()..':UpdateTweets', TweetMessage)



    end

    

    Citizen.Wait(1000)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- comand tt

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand("tt", function()

	CreateMobilePhone(1)

    CellCamActivate(true, true)

end,false)

-----------------------------------------------------------------------------------------------------------------------------------------

-- UpdateTweets

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':UpdateTweets')

AddEventHandler(GetCurrentResourceName()..':UpdateTweets', function(src, NewTweetData)

    if not checklicense then

        return false

    end

    local MyPlayerId = PhoneData.UserData.source



    if src ~= MyPlayerId then

        if not PhoneData.isOpen then

            if NewTweetData ~= nil then

                SendNUIMessage({

                    action = "Notification",

                    NotifyData = {

                        title = _("new_tweet").. " (@"..NewTweetData.username..")", 

                        content = NewTweetData.message, 

                        icon = "twitter", 

                        timeout = 3500, 

                        color = nil,

                    },

                })

            else

                SendNUIMessage({

                    action = "Notification",

                    NotifyData = {

                        title = _("new_tweet"), 

                        content = _("tweet_posted"), 

                        icon = "twitter", 

                        timeout = 3500, 

                        color = nil,

                    },

                })

            end

        else

            if NewTweetData ~= nil then

                SendNUIMessage({

                    action = "PhoneNotification",

                    PhoneNotify = {

                        title = _("new_tweet") .. " (@"..NewTweetData.username..")", 

                        text = NewTweetData.message, 

                        icon = "fab fa-twitter",

                        color = "#1DA1F2",

                    },

                })

            else

                SendNUIMessage({

                    action = "PhoneNotification",

                    PhoneNotify = {

                        title = _("new_tweet"), 

                        text = _("tweet_posted"), 

                        icon = "fab fa-twitter",

                        color = "#1DA1F2",

                    },

                })

            end

        end

    else

        SendNUIMessage({

            action = "PhoneNotification",

            PhoneNotify = {

                title = "Twitter", 

                text = _("tweet_posted"), 

                icon = "fab fa-twitter",

                color = "#1DA1F2",

                timeout = 1000,

            },

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMentionedTweets

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMentionedTweets', function(data, cb)

    if not checklicense then

        return false

    end

    local mentions = vSERVER.GetMentionedTweets(data)

    if mentions then

        cb(json.encode(mentions))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetHashtags

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetHashtags', function(data, cb)

    if not checklicense then

        return false

    end

    local hashtags = vSERVER.GetHashtags()

    if hashtags then

        cb(json.encode(hashtags))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMentioned

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':GetMentioned')

AddEventHandler(GetCurrentResourceName()..':GetMentioned', function(TweetMessage)

    if not checklicense then

        return false

    end

    if not PhoneData.isOpen then

        SendNUIMessage({ action = "Notification", NotifyData = { title = "Twitter", content = TweetMessage.message, icon = "twitter", timeout = 3500, color = nil, }, })

    else

        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "Twitter", text = TweetMessage.message, icon = "fab fa-twitter", color = "#1DA1F2", }, })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendNotification

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':SendNotification')

AddEventHandler(GetCurrentResourceName()..':SendNotification', function(data)

    if not checklicense then

        return false

    end

    if not PhoneData.isOpen then

        SendNUIMessage({ action = "Notification", NotifyData = { title = data.title, content = data.message, icon = data.icon, timeout = data.timeout, color = data.color, }, })

    else

        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = data.title, text = data.message, icon = "fab fa-"..data.icon, color = data.color, }, })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendNUIMessage

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':SendNUIMessage')

AddEventHandler(GetCurrentResourceName()..':SendNUIMessage', function(action)

    SendNUIMessage({ action = action })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ClearMentions

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('ClearMentions', function()

    if not checklicense then

        return false

    end

    SendNUIMessage({

        action = "RefreshAppAlerts"

    })

    TriggerServerEvent(GetCurrentResourceName()..':SetPhoneAlerts', "twitter", 0)

    SendNUIMessage({ action = "RefreshAppAlerts" })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ClearMentions

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('ClearGeneralAlerts', function(data)

    if not checklicense then

        return false

    end

    SetTimeout(400, function()

        SendNUIMessage({

            action = "RefreshAppAlerts"

        })

        TriggerServerEvent(GetCurrentResourceName()..':SetPhoneAlerts', data.app, 0)

        SendNUIMessage({ action = "RefreshAppAlerts" })

    end)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- TransferMoney

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('TransferMoney', function(data, cb)

    if not checklicense then

        return false

    end

    data.amount = parseInt(data.amount)

    if parseInt(PhoneData.UserData.banco) >= data.amount then

        local amaountata = PhoneData.UserData.banco - data.amount

        local checktransfer = vSERVER.TransferMoney(data.bankaccount, data.amount)

        local cbdata = {

            CanTransfer = checktransfer,

            NewAmount = amaountata 

        }

        cb(cbdata)

        LoadPhone()

    else

        local cbdata = {

            CanTransfer = false,

            NewAmount = nil,

        }

        cb(cbdata)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- TransferMoney

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('TransferPIX', function(data, cb)

    if not checklicense then

        return false

    end

    data.amount = parseInt(data.amount)

    if parseInt(PhoneData.UserData.banco) >= data.amount then

        local amaountata = PhoneData.UserData.banco - data.amount

        local checktransfer = vSERVER.TransferPIX(data.keypix, data.amount)

        local cbdata = {

            CanTransfer = checktransfer,

            NewAmount = amaountata 

        }

        cb(cbdata)

        LoadPhone()

    else

        local cbdata = {

            CanTransfer = false,

            NewAmount = nil,

        }

        cb(cbdata)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CreatePIX

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CreatePIX', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.CreatePIX(data)

    if check then

        cb(true)

        LoadPhone()

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetBankHistory

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetBankHistory', function(data, cb)

    if not checklicense then

        return false

    end

    local bankhistory = vSERVER.GetBankHistory()

    cb(json.encode(bankhistory))

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetWhatsappChats

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetWhatsappChats', function(data, cb)

    if not checklicense then

        return false

    end

    local chats = vSERVER.GetWhatsappChats(data)

    if chats then

        cb(json.encode(chats))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Callback CallContact

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CallContact', function(data, cb)

    if not checklicense then

        return false

    end

    local CallState = vSERVER.GetCallState(data.ContactData.number)



    local status = { 

        CanCall = CallState.CanCall, 

        IsOnline = CallState.IsOnline,

        InCall = PhoneData.CallData.InCall,

    }



    cb(status)



    if CallState.CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.UserData.identity.phone) then

        CallContact(data.ContactData, data.Anonymous)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GenerateCallId

-----------------------------------------------------------------------------------------------------------------------------------------

function GenerateCallId(caller, target)

    if not checklicense then

        return false

    end

    caller = caller:gsub("%-", "")

    target = target:gsub("%-", "")

    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))

    return CallId + 1300

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- CallContact

-----------------------------------------------------------------------------------------------------------------------------------------

function CallContact(CallData, AnonymousCall)

    if not checklicense then

        return false

    end

    local RepeatCount = 0

    PhoneData.CallData.CallType = "outgoing"

    PhoneData.CallData.InCall = true

    PhoneData.CallData.TargetData = CallData

    PhoneData.CallData.AnsweredCall = false

    PhoneData.CallData.CallId = GenerateCallId(PhoneData.UserData.identity.phone, CallData.number)



    TriggerServerEvent(GetCurrentResourceName()..':CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)

    TriggerServerEvent(GetCurrentResourceName()..':SetCallState', true)

    

    for i = 1, Config.CallRepeats + 1, 1 do

        if not PhoneData.CallData.AnsweredCall then

            if RepeatCount + 1 ~= Config.CallRepeats + 1 then

                if PhoneData.CallData.InCall then

                    RepeatCount = RepeatCount + 1

                else

                    break

                end

                Citizen.Wait(Config.RepeatTimeout)

            else

                CancelCall()

                break

            end

        else

            break

        end

    end

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- CancelCall

-----------------------------------------------------------------------------------------------------------------------------------------

function CancelCall()

    if not checklicense then

        return false

    end

    TriggerServerEvent(GetCurrentResourceName()..':CancelCall', PhoneData.CallData)

    if PhoneData.CallData.CallType == "ongoing" then

        if Config.CallSystem == "tokovoip" then

            exports.tokovoip_script:removePlayerFromRadio(PhoneData.CallData.CallId)

        elseif Config.CallSystem == "mumblevoip" then

            exports["mumble-voip"]:SetCallChannel(0)

        elseif Config.CallSystem == "saltychat" then

            local checksalty = vSERVER.SaltyChatEndCall(PhoneData.CallData)

        elseif Config.CallSystem == "pmavoice" then

            exports["pma-voice"]:removePlayerFromCall(0)

        end

    end

    TriggerServerEvent(GetCurrentResourceName()..':CancelCall', PhoneData.CallData.TargetData)

    TriggerServerEvent(GetCurrentResourceName()..':SaveCall', PhoneData.CallData)



    PhoneData.CallData.CallType = nil

    PhoneData.CallData.InCall = false

    PhoneData.CallData.AnsweredCall = false

    PhoneData.CallData.TargetData = {}

    PhoneData.CallData.CallId = nil



    focus = true



    SetNuiFocusKeepInput(false)

    TriggerEvent("cancelando",true)

    TriggerEvent("status:celular",true)

    TriggerEvent("player:blockCommands",true)



    if not PhoneData.isOpen then

        PhonePlayOut()

    else

        PhonePlayText()

    end



    TriggerServerEvent(GetCurrentResourceName()..':SetCallState', false)



    if not PhoneData.isOpen then

        SendNUIMessage({ 

            action = "Notification", 

            NotifyData = { 

                title = _("phone"),

                content = _("call_ended"), 

                icon = "telefone", 

                timeout = 3500, 

                color = "#e84118",

            }, 

        })



        SendNUIMessage({

            action = "CancelCallPhoneCLose",

        })

    else

        SendNUIMessage({ 

            action = "PhoneNotification", 

            PhoneNotify = { 

                title = _("phone"), 

                text = _("call_ended"), 

                icon = "fas fa-phone", 

                color = "#e84118", 

            }, 

        })



        SendNUIMessage({

            action = "SetupHomeCall",

            CallData = PhoneData.CallData,

        })



        SendNUIMessage({

            action = "CancelOutgoingCall",

        })

    end

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- CancelCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':CancelCall')

AddEventHandler(GetCurrentResourceName()..':CancelCall', function()

    if not checklicense then

        return false

    end

    if PhoneData.CallData.CallType == "ongoing" then

        SendNUIMessage({

            action = "CancelOngoingCall"

        })

        

        if Config.CallSystem == "tokovoip" then

            exports.tokovoip_script:removePlayerFromRadio(PhoneData.CallData.CallId)

        elseif Config.CallSystem == "mumblevoip" then

            exports["mumble-voip"]:SetCallChannel(0)

        elseif Config.CallSystem == "saltychat" then

            local checksalty = vSERVER.SaltyChatEndCall(PhoneData.CallData)

        elseif Config.CallSystem == "pmavoice" then

            exports["pma-voice"]:removePlayerFromCall(0)

        end

    end



    TriggerServerEvent(GetCurrentResourceName()..':SaveCallUser', PhoneData.CallData)



    PhoneData.CallData.CallType = nil

    PhoneData.CallData.InCall = false

    PhoneData.CallData.AnsweredCall = false

    PhoneData.CallData.TargetData = {}

    

    SetNuiFocusKeepInput(false)



    if not PhoneData.isOpen then

        PhonePlayOut()

    else

        PhonePlayText()

    end



    TriggerServerEvent(GetCurrentResourceName()..':SetCallState', false)



    if not PhoneData.isOpen then

        SendNUIMessage({ 

            action = "Notification", 

            NotifyData = { 

                title = _("phone"),

                content = _("call_ended"), 

                icon = "telefone", 

                timeout = 3500, 

                color = "#e84118",

            }, 

        })            

    else

        SendNUIMessage({ 

            action = "PhoneNotification", 

            PhoneNotify = { 

                title = _("phone"), 

                text = _("call_ended"), 

                icon = "fas fa-phone", 

                color = "#e84118", 

            }, 

        })



        SendNUIMessage({

            action = "SetupHomeCall",

            CallData = PhoneData.CallData,

        })



        SendNUIMessage({

            action = "CancelOutgoingCall",

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetCalled

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':GetCalled')

AddEventHandler(GetCurrentResourceName()..':GetCalled', function(CallerData, CallId, AnonymousCall, GetContact)

    if not checklicense then

        return false

    end

    local RepeatCount = 0

    local CallData = {

        number    = CallerData.phone,

        name      = CallerData.phone,

        anonymous = AnonymousCall

    }



    if AnonymousCall then

        CallData.name   = _("anonymous")

        CallData.number = _("anonymous")

    end



    if GetContact ~= nil and not AnonymousCall then

        CallData.name = GetContact.display

    end



    PhoneData.CallData.CallType = "incoming"

    PhoneData.CallData.InCall = true

    PhoneData.CallData.AnsweredCall = false

    PhoneData.CallData.TargetData = CallData

    PhoneData.CallData.CallId = CallId



    TriggerServerEvent(GetCurrentResourceName()..':SetCallState', true)



    SendNUIMessage({

        action = "SetupHomeCall",

        CallData = PhoneData.CallData,

    })



    for i = 1, Config.CallRepeats + 1, 1 do

        if not PhoneData.CallData.AnsweredCall then

            if RepeatCount + 1 ~= Config.CallRepeats + 1 then

                if PhoneData.CallData.InCall then

                    RepeatCount = RepeatCount + 1

                    

                    if not PhoneData.isOpen then

                        SendNUIMessage({

                            action = "IncomingCallAlert",

                            CallData = PhoneData.CallData.TargetData,

                            Canceled = false,

                            AnonymousCall = AnonymousCall,

                        })

                    end

                else

                    SendNUIMessage({

                        action = "IncomingCallAlert",

                        CallData = PhoneData.CallData.TargetData,

                        Canceled = true,

                        AnonymousCall = AnonymousCall,

                    })

                    TriggerServerEvent(GetCurrentResourceName()..':AddRecentCall', "missed", CallData)

                    break

                end

                Citizen.Wait(Config.RepeatTimeout)

            else

                SendNUIMessage({

                    action = "IncomingCallAlert",

                    CallData = PhoneData.CallData.TargetData,

                    Canceled = true,

                    AnonymousCall = AnonymousCall,

                })

                TriggerServerEvent(GetCurrentResourceName()..':AddRecentCall', "missed", CallData)

                break

            end

        else

            TriggerServerEvent(GetCurrentResourceName()..':AddRecentCall', "missed", CallData)

            break

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CancelOutgoingCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CancelOutgoingCall', function()

    if not checklicense then

        return false

    end

    CancelCall()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DenyIncomingCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DenyIncomingCall', function()

    if not checklicense then

        return false

    end

    CancelCall()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CancelOngoingCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CancelOngoingCall', function()

    if not checklicense then

        return false

    end

    CancelCall()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Callback AnswerCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AnswerCall', function()

    if not checklicense then

        return false

    end

    AnswerCall()

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Function AnswerCall

-----------------------------------------------------------------------------------------------------------------------------------------

function AnswerCall()

    if not checklicense then

        return false

    end

    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then

        PhoneData.CallData.CallType = "ongoing"

        PhoneData.CallData.AnsweredCall = true

        PhoneData.CallData.CallTime = 0



        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData, AnonymousCall = AnonymousCall})

        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData, AnonymousCall = AnonymousCall})



        TriggerServerEvent(GetCurrentResourceName()..':SetCallState', true)



        if PhoneData.isOpen then

            PhonePlayCall()

        else

            PhonePlayIn()

        end



        focus = false



        SetNuiFocusKeepInput(true)

        TriggerEvent("cancelando",false)

        TriggerEvent("status:celular",false)

        TriggerEvent("player:blockCommands",false)



        Citizen.CreateThread(function()

            while true do

                if PhoneData.CallData.AnsweredCall then

                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1



                    local name = ""



                    if PhoneData.CallData.TargetData.name then

                        name = PhoneData.CallData.TargetData.name

                    end



                    if PhoneData.CallData.TargetData.display then

                        name = PhoneData.CallData.TargetData.display

                    end



                    SendNUIMessage({

                        action = "UpdateCallTime",

                        Time = PhoneData.CallData.CallTime,

                        Name = name,

                    })

                else

                    break

                end



                Citizen.Wait(1000)

            end

        end)



        TriggerServerEvent(GetCurrentResourceName()..':AnswerCall', PhoneData.CallData)



        if Config.CallSystem == "tokovoip" then

            exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Telefone')

        elseif Config.CallSystem == "mumblevoip" then

            exports["mumble-voip"]:SetCallChannel(PhoneData.CallData.CallId)

        elseif Config.CallSystem == "saltychat" then

            local checksalty = vSERVER.SaltyChatEstablishCall(PhoneData.CallData)

        elseif Config.CallSystem == "pmavoice" then

            exports["pma-voice"]:SetCallChannel(PhoneData.CallData.CallId)

        end

    else

        PhoneData.CallData.InCall = false

        PhoneData.CallData.CallType = nil

        PhoneData.CallData.AnsweredCall = false



        SendNUIMessage({ 

            action = "PhoneNotification", 

            PhoneNotify = { 

                title = _("phone"), 

                text = _("have_no_call"), 

                icon = "fas fa-phone", 

                color = "#e84118", 

            }, 

        })

    end

end

-----------------------------------------------------------------------------------------------------------------------------------------

-- Event AnswerCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':sound')

AddEventHandler(GetCurrentResourceName()..':sound', function(sound,volume)

	SendNUIMessage({ transactionType = 'playSound', transactionFile = sound, transactionVolume = volume })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- Event AnswerCall

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent(GetCurrentResourceName()..':AnswerCall')

AddEventHandler(GetCurrentResourceName()..':AnswerCall', function()

    if not checklicense then

        return false

    end

    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then

        PhoneData.CallData.CallType = "ongoing"

        PhoneData.CallData.AnsweredCall = true

        PhoneData.CallData.CallTime = 0



        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})

        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})



        TriggerServerEvent(GetCurrentResourceName()..':SetCallState', true)



        if PhoneData.isOpen then

            PhonePlayCall()

        else

            PhonePlayIn()

        end



        focus = false

        

        SetNuiFocusKeepInput(true)

        TriggerEvent("cancelando",false)

        TriggerEvent("status:celular",false)

        TriggerEvent("player:blockCommands",false)



        Citizen.CreateThread(function()

            while true do

                if PhoneData.CallData.AnsweredCall then

                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1



                    local name = ""



                    if PhoneData.CallData.TargetData.name then

                        name = PhoneData.CallData.TargetData.name

                    end



                    if PhoneData.CallData.TargetData.display then

                        name = PhoneData.CallData.TargetData.display

                    end



                    SendNUIMessage({

                        action = "UpdateCallTime",

                        Time = PhoneData.CallData.CallTime,

                        Name = name,

                    })

                else

                    break

                end



                Citizen.Wait(1000)

            end

        end)



        if Config.CallSystem == "tokovoip" then

            exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Telefone')

        elseif Config.CallSystem == "mumblevoip" then

            exports["mumble-voip"]:SetCallChannel(PhoneData.CallData.CallId)

        elseif Config.CallSystem == "saltychat" then

            local checksalty = vSERVER.SaltyChatEstablishCall(PhoneData.CallData)

        elseif Config.CallSystem == "pmavoice" then

            exports["pma-voice"]:SetCallChannel(PhoneData.CallData.CallId)

        end

    else

        PhoneData.CallData.InCall = false

        PhoneData.CallData.CallType = nil

        PhoneData.CallData.AnsweredCall = false



        SendNUIMessage({ 

            action = "PhoneNotification", 

            PhoneNotify = { 

                title = _("phone"), 

                text = _("have_no_call"), 

                icon = "fas fa-phone", 

                color = "#e84118", 

            }, 

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeleteContact

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeleteContact', function(data, cb)   

    if not checklicense then

        return false

    end 

    local name      = data.name

    local number    = data.number

    local bank      = data.bank



    TriggerServerEvent(GetCurrentResourceName()..':RemoveContact', name, number, bank)



    Citizen.Wait(100)



    local pData = vSERVER.GetPhoneData()  

    if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 

        PhoneData.Contacts = pData.PlayerContacts

    end



    SendNUIMessage({

        action = "RefreshContacts",

        Contacts = PhoneData.Contacts

    })

    

    if PhoneData.isOpen then

        SendNUIMessage({

            action = "PhoneNotification",

            PhoneNotify = {

                title = _("phone"),

                text = _("removed_a_contact"), 

                icon = "fa fa-phone-alt",

                color = "#04b543",

                timeout = 1500,

            },

        })

    else

        SendNUIMessage({

            action = "Notification",

            NotifyData = {

                title =  _("phone"), 

                content = _("removed_a_contact"), 

                icon = "telefone", 

                timeout = 3500, 

                color = "#04b543",

            },

        })

    end



    cb({ PhoneContacts = PhoneData.Contacts })

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUserProfileInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUserProfileInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local account = vSERVER.GetUserProfileInsta()

    if account ~= nil then

        InstagramAccount = account

        cb(account)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddAccountInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddAccountInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddAccountInsta(data)

    if check then

        local account = vSERVER.GetUserProfileInsta()

        if account ~= nil then

            InstagramAccount = account

            cb(account)

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetStoriesInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetStoriesInstagram', function(data, cb)

    if not checklicense then

        return false

    end

    local stories = vSERVER.GetStoriesInstagram(data)

    if stories then

        StoriesInstagram = stories

        cb(json.encode(stories))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMyStorieInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMyStorieInstagram', function(data, cb)

    if not checklicense then

        return false

    end

    local storie = vSERVER.GetMyStorieInstagram(data)

    if storie then

        MyStorieInstagram = storie

        cb(json.encode(storie))

    else

        cb(json.encode('vazio'))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostsInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostsInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local posts = vSERVER.GetPostsInstagram(data)

    if posts then

        StoriesPosts = posts

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddStorieInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddStorieInsta', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.AddStorieInsta(data)

    if check then

        local storie = vSERVER.GetMyStorieInstagram(data)

        if storie then

            MyStorieInstagram = storie

            cb(json.encode(storie))

        end



        

        local stories = vSERVER.GetStoriesInstagram(data)

        if stories then

            StoriesInstagram = stories

        end



        SendNUIMessage({

            action = "RefreshStoriesInsta",

            stories = json.encode(StoriesInstagram),

        })



        SendNUIMessage({

            action = "RefreshMyStorieInsta",

            stories = json.encode(MyStorieInstagram),

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddPostInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddPostInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddPostInsta(data)

    if check then

		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

            cb(json.encode(posts))

        end



        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfilesInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfilesInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local profiles = vSERVER.GetProfilesInstagram(data)

    if profiles then

        cb(json.encode(profiles))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfilesInstagramLike

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfilesInstagramLike', function(data, cb)

    if not checklicense then

        return false

    end

	local profiles = vSERVER.GetProfilesInstagramLike(data)

    if profiles then

        cb(json.encode(profiles))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfileInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfileInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local profile = vSERVER.GetProfileInstagram(data.id)

    if profile then

        cb(json.encode(profile))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfileInstagramUsername

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfileInstagramUsername', function(data, cb)

    if not checklicense then

        return false

    end

	local profile = vSERVER.GetProfileInstagramUsername(data.username)

    if profile then

        cb(json.encode(profile))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- FollowUserInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('FollowUserInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.FollowUserInsta(data)

    if check then

        cb(json.encode(true))



		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

        end

        

        local stories = vSERVER.GetStoriesInstagram(data)

        if stories then

            StoriesInstagram = stories

        end

        

        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })



        SendNUIMessage({

            action = "RefreshStoriesInsta",

            stories = json.encode(stories),

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- UnfollowUserInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('UnfollowUserInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.UnfollowUserInsta(data)

    if check then

        cb(json.encode(true))



		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

        end

        

        local stories = vSERVER.GetStoriesInstagram(data)

        if stories then

            StoriesInstagram = stories

        end

        

        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })



        SendNUIMessage({

            action = "RefreshStoriesInsta",

            stories = json.encode(stories),

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetTotalFollowsAndFolloweds

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetTotalFollowsAndFolloweds', function(data, cb)

    if not checklicense then

        return false

    end

	local follows = vSERVER.GetTotalFollowsAndFolloweds(data)

    if follows then

        cb(json.encode(follows))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetFollowsInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetFollowsInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local follows = vSERVER.GetFollowsInstagram(data)

    if follows then

        cb(json.encode(follows))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetFollowedsInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetFollowedsInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local followeds = vSERVER.GetFollowedsInstagram(data)

    if followeds then

        cb(json.encode(followeds))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditProfileInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditProfileInsta', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditProfileInsta(data)

    if check then

        cb(json.encode(true))



		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

        end

        

        local stories = vSERVER.GetStoriesInstagram(data)

        if stories then

            StoriesInstagram = stories

        end



        local storie = vSERVER.GetMyStorieInstagram(data)

        if storie then

            MyStorieInstagram = storie

        end

        

        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })



        SendNUIMessage({

            action = "RefreshStoriesInsta",

            stories = json.encode(stories),

        })



        SendNUIMessage({

            action = "RefreshMyStorieInsta",

            stories = json.encode(storie),

        })

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddLikePostInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddLikePostInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddLikePostInstagram(data)

    if check then

        cb(json.encode(true))



		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

        end

        

        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })

    else

        cb(json.encode(false))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostIdInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostIdInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.GetPostIdInstagram(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddCommentPostInstagram

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddCommentPostInstagram', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddCommentPostInstagram(data)

    if check then

        cb(json.encode(true))



		local posts = vSERVER.GetPostsInstagram(data)

        if posts then

            StoriesPosts = posts

        end

        

        SendNUIMessage({

            action = "RefreshPostsInsta",

            posts = json.encode(posts),

        })

    else

        cb(json.encode(false))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetInstaChats

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetInstaChats', function(data, cb)

    if not checklicense then

        return false

    end

    local chats = vSERVER.GetInstaChats(data)

    if chats then

        cb(json.encode(chats))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetInstaChat

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetInstaChat', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetInstaChat(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfilePictureInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfilePictureInsta', function(data, cb)

    if not checklicense then

        return false

    end

    local username = data.username



    local avatar = vSERVER.GetProfilePictureInsta(username)

    if avatar then

        cb(json.encode(avatar))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendMessageInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendMessageInsta', function(data, cb)

    if not checklicense then

        return false

    end

    local myusername = data.myusername

    local username   = data.username

    local message    = data.message

    local type       = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        myusername = myusername,

        username   = username,

        message    = message,

        type       = type

    }



    local check = vSERVER.SendMessageInsta(send)

    if check then

        local messages = vSERVER.GetInstaChat(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeletePostInsta

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeletePostInsta', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeletePostInsta(data)

    if check then

        cb(json.encode(true))

    else

        cb(json.encode(false))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUserProfileWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUserProfileWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

	local account = vSERVER.GetUserProfileWhatsApp()

    if account ~= nil then

        WhatsAppAccount = account

        cb(account)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddAccountWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddAccountWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddAccountWhatsApp(data)

    if check then

        local account = vSERVER.GetUserProfileWhatsApp()

        if account ~= nil then

            WhatsAppAccount = account

            cb(account)

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetStoriesWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetStoriesWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

    local stories = vSERVER.GetStoriesWhatsApp(data)

    if stories then

        StoriesWhatsApp = stories

        cb(json.encode(stories))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMyStorieWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMyStorieWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

    local storie = vSERVER.GetMyStorieWhatsApp(data)

    if storie then

        MyStorieWhatsApp = storie

        cb(json.encode(storie))

    else

        cb(json.encode('vazio'))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddStorieWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddStorieWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.AddStorieWhatsApp(data)

    if check then

        local storie = vSERVER.GetMyStorieWhatsApp(data)

        if storie then

            MyStorieWhatsApp = storie

        end



        

        local stories = vSERVER.GetStoriesWhatsApp(data)

        if stories then

            StoriesWhatsApp = stories

        end



        SendNUIMessage({

            action = "RefreshStoriesWhatsApp",

            stories = json.encode(StoriesWhatsApp),

        })



        SendNUIMessage({

            action = "ReceiveMyStorieWhatsApp",

            storie = json.encode(MyStorieWhatsApp),

        })

        cb(true)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditProfileWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditProfileWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditProfileWhatsApp(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CreateGroupWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CreateGroupWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.CreateGroupWhatsApp(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditGroupWhatsApp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditGroupWhatsApp', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditGroupWhatsApp(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetWhatsappGroups

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetWhatsappGroups', function(data, cb)

    if not checklicense then

        return false

    end

    local groups = vSERVER.GetWhatsappGroups(data)

    if groups then

        cb(json.encode(groups))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetGroupImage

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetGroupImage', function(data, cb)

    if not checklicense then

        return false

    end

    local number = data.number



    local image = vSERVER.GetGroupImage(number)

    if image then

        cb(json.encode(image))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetWhatsappGroupMessages

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetWhatsappGroupMessages', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetWhatsappGroupMessages(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetWhatsappGroup

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetWhatsappGroup', function(data, cb)

    if not checklicense then

        return false

    end

    local group = vSERVER.GetWhatsappGroup(data)

    if group then

        cb(json.encode(group))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddMemberGroupWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddMemberGroupWhatsapp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.AddMemberGroupWhatsapp(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- RemoveMemberGroupWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('RemoveMemberGroupWhatsapp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.RemoveMemberGroupWhatsapp(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- LeaveGroupWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('LeaveGroupWhatsapp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.LeaveGroupWhatsapp(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeleteGroupWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeleteGroupWhatsapp', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeleteGroupWhatsapp(data)

    if check then

        cb(json.encode(check))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendMessageGroup

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendMessageGroup', function(data, cb)

    if not checklicense then

        return false

    end

    local phone = data.phone

    local message = data.message

    local number = data.number

    local type = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        phone = phone,

        message = message,

        number = number,

        type = type

    }



    local check = vSERVER.SendMessageGroup(send)

    if check then

        local messages = vSERVER.GetWhatsappGroupMessages(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetContacts

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetContacts', function(data, cb)

    if not checklicense then

        return false

    end

    if isLoggedIn then

        local pData = vSERVER.GetPhoneData()  

        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 

            PhoneData.Contacts = pData.PlayerContacts

        end



        SendNUIMessage({

            action = "RefreshContacts",

            Contacts = PhoneData.Contacts

        })

        cb(true)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUserProfileTwitter

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUserProfileTwitter', function(data, cb)

    if not checklicense then

        return false

    end

	local account = vSERVER.GetUserProfileTwitter()

    if account ~= nil then

        TwitterAccount = account

        cb(account)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddAccountTwitter

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddAccountTwitter', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddAccountTwitter(data)

    if check then

        local account = vSERVER.GetUserProfileTwitter()

        if account ~= nil then

            TwitterAccount = account

            cb(account)

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditProfileTwitter

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditProfileTwitter', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditProfileTwitter(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMessages

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMessages', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetMessages(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetMessagesChat

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetMessagesChat', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetMessagesChat(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendNewMessage

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendNewMessage', function(data, cb)

    if not checklicense then

        return false

    end

    local message = data.message

    local phone = data.phone

    local number = data.number

    local type = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        message = message,

        phone   = phone,

        number  = number,

        type    = type

    }



    local check = vSERVER.SendNewMessage(send)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetHelpList

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetHelpList', function(data, cb)

    if not checklicense then

        return false

    end

    local helplist = Config.HelpList

    if helplist ~= nil then

        cb(json.encode(helplist))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendHelp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendHelp', function(data, cb)

    if not checklicense then

        return false

    end

    local message = data.message

    local check = vSERVER.SendHelp(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUserProfileDarkweb

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUserProfileDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

	local account = vSERVER.GetUserProfileDarkweb()

    if account ~= nil then

        WhatsAppAccount = account

        cb(account)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddAccountDarkweb

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddAccountDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddAccountDarkweb(data)

    if check then

        local account = vSERVER.GetUserProfileDarkweb()

        if account ~= nil then

            WhatsAppAccount = account

            cb(account)

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditAccountDarkweb

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditAccountDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditAccountDarkweb(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CreateLayerDarkweb

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('CreateLayerDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.CreateLayerDarkweb(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetDarkwebLayers

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetDarkwebLayers', function(data, cb)

    if not checklicense then

        return false

    end

    local groups = vSERVER.GetDarkwebLayers(data)

    if groups then

        cb(json.encode(groups))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetLayerImage

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetLayerImage', function(data, cb)

    if not checklicense then

        return false

    end

    local number = data.number



    local image = vSERVER.GetLayerImage(number)

    if image then

        cb(json.encode(image))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetDarkwebLayerMessages

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetDarkwebLayerMessages', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetDarkwebLayerMessages(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetDarkwebLayersPublic

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetDarkwebLayersPublic', function(data, cb)

    if not checklicense then

        return false

    end

    local groups = vSERVER.GetDarkwebLayersPublic(data)

    if groups then

        cb(json.encode(groups))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AcessLayerDarkweb

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AcessLayerDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AcessLayerDarkweb(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeleteGroupWhatsapp

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeleteLayerDarkweb', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeleteLayerDarkweb(data)

    if check then

        cb(json.encode(check))

    else

        cb(json.encode(false))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendMessageLayer

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendMessageLayer', function(data, cb)

    if not checklicense then

        return false

    end

    local username = data.username

    local message = data.message

    local number = data.number

    local type = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        username = username,

        message = message,

        number = number,

        type = type

    }



    local check = vSERVER.SendMessageLayer(send)

    if check then

        local messages = vSERVER.GetDarkwebLayerMessages(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUserProfileTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUserProfileTinder', function(data, cb)

    if not checklicense then

        return false

    end

	local account = vSERVER.GetUserProfileTinder()

    if account ~= nil then

        InstagramAccount = account

        cb(account)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddAccountTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddAccountTinder', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddAccountTinder(data)

    if check then

        local account = vSERVER.GetUserProfileTinder()

        if account ~= nil then

            InstagramAccount = account

            cb(account)

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUsersTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetUsersTinder', function(data, cb)

    if not checklicense then

        return false

    end

    local users = vSERVER.GetUsersTinder(data)

    if users then

        cb(json.encode(users))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetUsersTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('LikeUserTinder', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.LikeUserTinder(data)

    if check then

        cb(json.encode(true))

    else

        cb(json.encode(false))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetTinderChats

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetTinderChats', function(data, cb)

    if not checklicense then

        return false

    end

    local chats = vSERVER.GetTinderChats(data)

    if chats then

        cb(json.encode(chats))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetTinderChat

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetTinderChat', function(data, cb)

    if not checklicense then

        return false

    end

    local messages = vSERVER.GetTinderChat(data)

    if messages then

        cb(json.encode(messages))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SendMessageTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SendMessageTinder', function(data, cb)

    if not checklicense then

        return false

    end

    local id = data.id

    local message = data.message

    local type = data.type



    local Ped = GetPlayerPed(-1)

    local Pos = GetEntityCoords(Ped)



    if type == "location" then

        message = json.encode({

            x = Pos.x,

            y = Pos.y

        })

    end



    local send = {

        id = id,

        message = message,

        type = type

    }



    local check = vSERVER.SendMessageTinder(send)

    if check then

        local messages = vSERVER.GetTinderChat(data)

        if messages then

            cb(json.encode(messages))

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetProfileTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetProfileTinder', function(data, cb)

    if not checklicense then

        return false

    end

	local profile = vSERVER.GetProfileTinder(data.id)

    if profile then

        cb(json.encode(profile))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditAvatarTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditAvatarTinder', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditAvatarTinder(data)

    if check then

        cb(json.encode(true))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditProfileTinder

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditProfileTinder', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.EditProfileTinder(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostsOlx

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostsOlx', function(data, cb)

    if not checklicense then

        return false

    end

	local posts = vSERVER.GetPostsOlx(data)

    if posts then

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddPostOlx

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddPostOlx', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddPostOlx(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostOlx

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostOlx', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.GetPostOlx(data)

    if check.post ~= nil then

        cb(json.encode(check))

    else

        local empty = {}

        cb(json.encode(empty))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- SearchPostsOlx

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('SearchPostsOlx', function(data, cb)

    if not checklicense then

        return false

    end

	local posts = vSERVER.SearchPostsOlx(data)

    if posts then

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeletePostOlx

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeletePostOlx', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeletePostOlx(data)

    if check then

        local posts = vSERVER.GetPostsOlx(data)

        if posts then

            SendNUIMessage({

                action = "RefreshPostsOlx",

                posts = json.encode(posts),

            })

        end

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostsGallery

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostsGallery', function(data, cb)

    if not checklicense then

        return false

    end

    local posts = vSERVER.GetPostsGallery(data)

    if posts then

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeletePostGallery

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeletePostGallery', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeletePostGallery(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetAdvertNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetAdvertNews', function(data, cb)

    if not checklicense then

        return false

    end

	local advert = Config.NewsAdvert

    if advert then

        cb(json.encode(advert))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostsNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostsNews', function(data, cb)

    if not checklicense then

        return false

    end

	local posts = vSERVER.GetPostsNews(data)

    if posts then

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostsNewsFull

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostsNewsFull', function(data, cb)

    if not checklicense then

        return false

    end

	local posts = vSERVER.GetPostsNewsFull(data)

    if posts then

        cb(json.encode(posts))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- AddPostNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('AddPostNews', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.AddPostNews(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetPostNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetPostNews', function(data, cb)

    if not checklicense then

        return false

    end

	local check = vSERVER.GetPostNews(data)

    if check.post ~= nil then

        cb(json.encode(check))

    else

        local empty = {}

        cb(json.encode(empty))

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- EditPostNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('EditPostNews', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.EditPostNews(data)

    if check then

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- DeletePostNews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('DeletePostNews', function(data, cb)

    if not checklicense then

        return false

    end

    local check = vSERVER.DeletePostNews(data)

    if check then

        local posts = vSERVER.GetPostsNewsFull(data)

        if posts then

            SendNUIMessage({

                action = "RefreshPostsNewsPainel",

                posts = json.encode(posts),

            })

        end

        cb(true)

    else

        cb(false)

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- GetClientID

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('GetClientID', function(data, cb)

    if not checklicense then

        return false

    end

    cb("516b790a82b7c6d89856376fa4ced361")

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ChangeIsTyping

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('ChangeIsTyping', function(data, cb)

    if not checklicense then

        return false

    end

    IsTyping = data.status

    cb(true)

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- CheckPhoneIsOpen

-----------------------------------------------------------------------------------------------------------------------------------------

function CheckPhoneIsOpen()

    if not checklicense then

        return false

    end

    return PhoneData.isOpen

end

exports("CheckPhoneIsOpen", CheckPhoneIsOpen)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ClosePhone

-----------------------------------------------------------------------------------------------------------------------------------------

function ClosePhone()

    if not checklicense then

        return false

    end

    if PhoneData.CallData.InCall then

        PhonePlayText()

    else

        PhonePlayOut()

    end



    SendNUIMessage({

        action = "close",

    })



    SetNuiFocus(false, false)

    SetNuiFocusKeepInput(false)

    SetTimeout(1000, function()

        PhoneData.isOpen = false

    end)

end

exports("ClosePhone", ClosePhone)

-----------------------------------------------------------------------------------------------------------------------------------------

-- phonenews

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand("phonenews",function(source,args)

    if vSERVER.checkPermissionNews() then

        checklicense = true

        SetNuiFocus(true, true)

		TransitionToBlurred(1000)



        TriggerEvent("cancelando",true)

        TriggerEvent("status:celular",true)

        TriggerEvent("player:blockCommands",true)

        

        SendNUIMessage({

            action       = "openpainel",

            checklicense = checklicense

        })



        painelopen = true



        local posts = vSERVER.GetPostsNewsFull()

        if posts then

            SendNUIMessage({

                action = "RefreshPostsNewsPainel",

                posts = json.encode(posts),

            })

        end

    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------

-- ClosePainel

-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('ClosePainel', function(data, cb)

    if painelopen then

        SetNuiFocus(false)

        TransitionFromBlurred(1000)



        TriggerEvent("cancelando",false)

        TriggerEvent("status:celular",false)

        TriggerEvent("player:blockCommands",false)

        cb(true)

        painelopen = false

    end

end)