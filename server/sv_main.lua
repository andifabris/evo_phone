-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy  = module("vrp","lib/Proxy")
local Tools  = module("vrp","lib/Tools")
local Config = module(GetCurrentResourceName(),"config")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
psRP = {}
Tunnel.bindInterface(GetCurrentResourceName(),psRP)
vCLIENT = Tunnel.getInterface(GetCurrentResourceName())
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PSPhone   = {}
local AppAlerts = {}
local Calls     = {}
local cache     = {}
local count     = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERYES
-----------------------------------------------------------------------------------------------------------------------------------------
DB.prepare(GetCurrentResourceName().."/insta_account","SELECT * FROM evo_phone_accounts WHERE id = @user_id AND app = 'instagram'")
DB.prepare(GetCurrentResourceName().."/insta_account_username","SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'instagram'")
DB.prepare(GetCurrentResourceName().."/whatsapp_account","SELECT * FROM evo_phone_accounts WHERE phone = @phone AND app = 'whatsapp'")
DB.prepare(GetCurrentResourceName().."/twitter_account","SELECT * FROM evo_phone_accounts WHERE id = @user_id AND app = 'twitter'")
DB.prepare(GetCurrentResourceName().."/twitter_account_username","SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'twitter'")
DB.prepare(GetCurrentResourceName().."/darkweb_account","SELECT * FROM evo_phone_accounts WHERE id = @user_id AND app = 'darkweb'")
DB.prepare(GetCurrentResourceName().."/darkweb_account_username","SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'darkweb'")
DB.prepare(GetCurrentResourceName().."/tinder_account","SELECT * FROM evo_phone_accounts WHERE id = @user_id AND app = 'tinder'")
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOKS
-----------------------------------------------------------------------------------------------------------------------------------------
function SendWebhookEmbed(webhook,data)
 if webhook ~= nil and webhook ~= "" then

         PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
                 embeds = data
         }), { ['Content-Type'] = 'application/json' })
 end
end

function SendWebhookContant(webhook,data)
 if webhook ~= nil and webhook ~= "" then

         PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
                 content = data
         }), { ['Content-Type'] = 'application/json' })
 end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- playerSpawn
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source)
    local source = source
    if source ~= nil then
     TriggerClientEvent(GetCurrentResourceName()..":OnPlayerLoaded",source)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- playerLeave
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerLeave", function(user_id, group, gtype)
 if cache[user_id] then
        cache[user_id] = nil
 end
 if count[user_id] then
        count[user_id] = 0
 end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetOnlineStatus
-----------------------------------------------------------------------------------------------------------------------------------------
function GetOnlineStatus(number)
    local Target = getUserByPhone(number)
    local retval = false
    if Target ~= nil then
        retval = true
    end
    return retval
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPhoneData
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetPhoneData()
    local source  = source
    local user_id = getUserId(source)
    if user_id then
        local PhoneData = {
            PlayerContacts = {},
            Invoices       = {}
        }

        --list of contacts
        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_contacts WHERE evo_phone_contacts.user_id = @user_id ORDER BY display ASC",
        { ['@user_id'] = tonumber(user_id) })
        local Contacts = result
        if result[1] ~= nil then
            for k, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end

            PhoneData.PlayerContacts = result
        end

        --list alerts
        if AppAlerts[user_id] ~= nil then
            PhoneData.Applications = AppAlerts[user_id]
        end

        return PhoneData
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPhoneData
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetCallState(phone_number)
    if phone_number then
        local player = getUserByPhone(phone_number)

        if player ~= nil then
            if Calls[tonumber(player)] ~= nil then
                if Calls[tonumber(player)].inCall then
                    local data = {}
                    data.CanCall = false
                    data.IsOnline = true
                    data.InCall = false
                    return data
                else
                    local data = {}
                    data.CanCall = true
                    data.IsOnline = true
                    data.InCall = false
                    return data
                end
            else
                local data = {}
                data.CanCall = true
                data.IsOnline = true
                data.InCall = false
                return data
            end
        else
            local data = {}
            data.CanCall = false
            data.IsOnline = false
            data.InCall = false
            return data
        end
    else
        local data = {}
        data.CanCall = false
        data.IsOnline = false
        data.InCall = false
        return data
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetCallState
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':SetCallState')
AddEventHandler(GetCurrentResourceName()..':SetCallState', function(bool)
    local source  = source
    local user_id = getUserId(source)

    if Calls[user_id] ~= nil then
        Calls[user_id].inCall = bool
    else
        Calls[user_id] = {}
        Calls[user_id].inCall = bool
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddRecentCall
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':AddRecentCall')
AddEventHandler(GetCurrentResourceName()..':AddRecentCall', function(type, data)
    local source  = source
    local user_id = getUserId(source)

    local Hour   = os.date("%H")
    local Minute = os.date("%M")
    local label  = Hour..":"..Minute

    TriggerClientEvent(GetCurrentResourceName()..':AddRecentCall', source, data, label, type)

    if user_id ~= nil then
         local identity = getUserIdentity(user_id)
        TriggerClientEvent(GetCurrentResourceName()..':AddRecentCall', source, {
            number = identity.phone,
            anonymous = anonymous
        }, label, "outgoing")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CallContact
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':CallContact')
AddEventHandler(GetCurrentResourceName()..':CallContact', function(ContactData, CallId, AnonymousCall)
    local source   = source
    local user_id  = getUserId(source)
    local identity = getUserIdentity(user_id)
    local contact  = getUserByPhone(ContactData.number)

    if contact ~= nil then
        local nplayer = getUserSource(contact)
        local rcontact = nil
        local getcontact = exports.oxmysql:executeSync("SELECT * FROM evo_phone_contacts WHERE user_id = @user_id AND `number` = @number",{
            ['@user_id'] = contact,
            ['@number'] = identity.phone
        })

        if #getcontact > 0 then
            rcontact = getcontact[1]
        end

         if nplayer ~= nil then
            TriggerClientEvent(GetCurrentResourceName()..":sound",nplayer,'ring',0.7)
            TriggerClientEvent(GetCurrentResourceName()..':GetCalled', nplayer, identity, CallId, AnonymousCall, rcontact)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CancelCall
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':CancelCall')
AddEventHandler(GetCurrentResourceName()..':CancelCall', function(ContactData)
    local player = getUserByPhone(ContactData.number)

    if player ~= nil then
        local nplayer = getUserSource(player)
         if nplayer ~= nil then
            TriggerClientEvent(GetCurrentResourceName()..':CancelCall', nplayer)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AnswerCall
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':AnswerCall')
AddEventHandler(GetCurrentResourceName()..':AnswerCall', function(CallData)
    local player = getUserByPhone(CallData.TargetData.number)

    if player ~= nil then
        local nplayer = getUserSource(player)
         if nplayer ~= nil then
            TriggerClientEvent(GetCurrentResourceName()..':AnswerCall', nplayer)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MentionedPlayer
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':MentionedPlayer')
AddEventHandler(GetCurrentResourceName()..':MentionedPlayer', function(name, username, TweetMessage)
    TriggerClientEvent(GetCurrentResourceName()..':GetMentioned', source, name, username, TweetMessage)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- MentionedPlayerReturn
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':MentionedPlayerReturn')
AddEventHandler(GetCurrentResourceName()..':MentionedPlayerReturn', function(players, name, username, TweetMessage)
    for k, v in pairs(players) do
        local user_id = getUserId(v)
        if user_id ~= nil then
            local account = DB.query(GetCurrentResourceName().."/twitter_account", { user_id = tonumber(user_id) })
            if account[1] ~= nil then
                if (account.name == name and account.username == username) then
                    TriggerClientEvent(GetCurrentResourceName()..':GetMentioned', source, TweetMessage)
                end
            end
        end
 end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- deleteTweet
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':deleteTweet')
AddEventHandler(GetCurrentResourceName()..':deleteTweet', function(id)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        local account = DB.query(GetCurrentResourceName().."/twitter_account", { user_id = user_id })
        if account[1] ~= nil then
            exports.oxmysql:execute("DELETE FROM evo_phone_posts WHERE author = @username AND id = @id AND app = 'twitter'",{
                ['@username'] = account[1].username,
                ['@id']       = id
            })
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateTweets
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':UpdateTweets')
AddEventHandler(GetCurrentResourceName()..':UpdateTweets', function(TweetData)
    local TwtData = TweetData
    if Config.NotifyAll then
        TriggerClientEvent(GetCurrentResourceName()..':UpdateTweets', -1, TweetData)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetPhoneAlerts
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':SetPhoneAlerts')
AddEventHandler(GetCurrentResourceName()..':SetPhoneAlerts', function(app, alerts)
    local source  = source
    local user_id = getUserId(source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TransferMoney
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.TransferMoney(sender, amount)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if sender ~= nil then
            if user_id ~= tonumber(sender) then

                local nsender = tonumber(sender)

                local nplayer = getUserSource(nsender)

                if nplayer ~= nil then
                    if tonumber(amount) > 0 then

                        local bank = getBankMoney(user_id)
                        local bank_sender = getBankMoney(nsender)

                        if bank >= tonumber(amount) then

                            --remove bank
                            remBankMoney(user_id, amount)

                            --add bank
                            addBankMoney(nsender, amount)

                            local datanotify = {
                                title   = _("transfer_money_title"),
                                message = _("send_money", formatnumber(tonumber(amount)), tonumber(nsender)),
                                icon    = "banco",
                                timeout = 5000,
                                color   = "green",
                            }

                            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)

                            local datanotify = {
                                title   = _("transfer_money_title"),
                                message = _("receive_money", formatnumber(tonumber(amount))),
                                icon    = "banco",
                                timeout = 5000,
                                color   = "green",
                            }

                            if nplayer ~= nil then
                                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nplayer, datanotify)
                            end

                            local time = os.date("%d/%m/%Y %H:%M:%S")

                            local data = {
                                {
                                    fields = {
                                        { name = _U("transfer_money_title"), value = time },
                                        { name = _("send_user_money"), value = user_id, inline = true },
                                        { name = _("receive_user_money"), value = nsender, inline = true },
                                        { name = _("amount_money"), value = amount }
                                    },
                                    color = "3066993"
                                }
                            }

                            SendWebhookEmbed(Config.WebhookBank, data)

                            local history      = {}
                            local history2     = {}
                            local bankhistory  = json.decode(getUserData(user_id, "ps_bank_history"))
                            local bankhistory2 = json.decode(getUserData(nsender, "ps_bank_history"))

                            if bankhistory ~= nil then
                                for k, v in pairs(bankhistory) do
                                    table.insert(history, v)
                                end
                            end

                            if bankhistory2 ~= nil then
                                for k, v in pairs(bankhistory2) do
                                    table.insert(history2, v)
                                end
                            end

                            local data = {
                                type  = "down",
                                name  = _("transfer_title").." #"..nsender,
                                value = amount
                            }

                            table.insert(history, data)

                            local data2 = {
                                type  = "up",
                                name  = _("transfer_title").." #"..user_id,
                                value = amount
                            }

                            table.insert(history2, data2)

                            setUserData(user_id, "ps_bank_history", json.encode(history))
                            setUserData(nsender, "ps_bank_history", json.encode(history2))

                            return true
                        else
                            local datanotify = {
                                title   = _("error_transfer"),
                                message = _("no_money"),
                                icon    = "banco",
                                timeout = 5000,
                                color   = "red",
                            }

                            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                            return false
                        end
                    else
                        local datanotify = {
                            title   = _("error_transfer"),
                            message = _("no_transfer_amout_0"),
                            icon    = "banco",
                            timeout = 5000,
                            color   = "red",
                        }

                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                        return false
                    end
                else
                    local datanotify = {
                        title   = _("error_transfer"),
                        message = _("player_not_online"),
                        icon    = "banco",
                        timeout = 5000,
                        color   = "red",
                    }

                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                    return false
                end
            else
                local datanotify = {
                    title   = _("error_transfer"),
                    message = _("no_transfer_your"),
                    icon    = "banco",
                    timeout = 5000,
                    color   = "red",
                }

                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                return false
            end
        else
            local datanotify = {
                title   = _("error_transfer"),
                message = _("player_not_exist"),
                icon    = "banco",
                timeout = 5000,
                color   = "red",
            }

            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TransferPIX
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.TransferPIX(sender, amount)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if sender ~= nil then
            local result = exports.oxmysql:executeSync("SELECT * FROM "..Config.TablePlayerDB.." WHERE dvalue = @dvalue",{
                ['@dvalue'] = sender,
            })

            if result[1] ~= nil then
                if user_id ~= tonumber(result[1].user_id) then

                    local nsender = tonumber(result[1].user_id)

                    local nplayer = getUserSource(nsender)

                    if nplayer ~= nil then

                        local key_pix = getUserData(user_id, "ps_key_pix")
                            if key_pix ~= nil then

                            if tonumber(amount) > 0 then

                                local bank = getBankMoney(user_id)
                                local bank_sender = getBankMoney(nsender)

                                if bank >= tonumber(amount) then

                                    --remove bank
                                    remBankMoney(user_id, amount)

                                    --add bank
                                    addBankMoney(nsender, amount)

                                    local datanotify = {
                                        title   = _("transfer_pix_title"),
                                        message = _("send_pix", formatnumber(tonumber(amount)), sender),
                                        icon    = "banco",
                                        timeout = 5000,
                                        color   = "green",
                                    }

                                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)

                                    local datanotify = {
                                        title   = _("transfer_pix_title"),
                                        message = _("receive_money", formatnumber(tonumber(amount))),
                                        icon    = "banco",
                                        timeout = 5000,
                                        color   = "green",
                                    }

                                    if nplayer ~= nil then
                                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nplayer, datanotify)
                                    end

                                    local time = os.date("%d/%m/%Y %H:%M:%S")

                                    local data = {
                                        {
                                            fields = {
                                                { name = _U("transfer_pix_title"), value = time },
                                                { name = _("send_user_money"), value = user_id, inline = true },
                                                { name = _("receive_user_money"), value = nsender, inline = true },
                                                { name = _("amount_money"), value = amount }
                                            },
                                            color = "3066993"
                                        }
                                    }

                                    SendWebhookEmbed(Config.WebhookBank, data)

                                    local history      = {}
                                    local history2     = {}
                                    local bankhistory  = json.decode(getUserData(user_id, "ps_bank_history"))
                                    local bankhistory2 = json.decode(getUserData(nsender, "ps_bank_history"))

                                    if bankhistory ~= nil then
                                        for k, v in pairs(bankhistory) do
                                            table.insert(history, v)
                                        end
                                    end

                                    if bankhistory2 ~= nil then
                                        for k, v in pairs(bankhistory2) do
                                            table.insert(history2, v)
                                        end
                                    end

                                    local data = {
                                        type  = "down",
                                        name  = _("transfer_pix_title").." #"..sender,
                                        value = amount
                                    }

                                    table.insert(history, data)

                                    local data2 = {
                                        type  = "up",
                                        name  = _("transfer_pix_title").." #"..key_pix,
                                        value = amount
                                    }

                                    table.insert(history2, data2)

                                    setUserData(user_id, "ps_bank_history", json.encode(history))
                                    setUserData(nsender, "ps_bank_history", json.encode(history2))

                                    return true
                                else
                                    local datanotify = {
                                        title   = _("error_transfer"),
                                        message = _("no_money"),
                                        icon    = "banco",
                                        timeout = 5000,
                                        color   = "red",
                                    }

                                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                                    return false
                                end
                            else
                                local datanotify = {
                                    title   = _("error_transfer"),
                                    message = _("no_transfer_amout_0"),
                                    icon    = "banco",
                                    timeout = 5000,
                                    color   = "red",
                                }

                                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                                return false
                            end
                        else
                            local datanotify = {
                                title   = _("error_transfer"),
                                message = _("key_pix_not_exist"),
                                icon    = "banco",
                                timeout = 5000,
                                color   = "red",
                            }

                            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                            return false
                        end
                    else
                        local datanotify = {
                            title   = _("error_transfer"),
                            message = _("player_not_online"),
                            icon    = "banco",
                            timeout = 5000,
                            color   = "red",
                        }

                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                        return false
                    end
                else
                    local datanotify = {
                        title   = _("error_transfer"),
                        message = _("no_transfer_your"),
                        icon    = "banco",
                        timeout = 5000,
                        color   = "red",
                    }

                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                    return false
                end
            else
                local datanotify = {
                    title   = _("error_transfer"),
                    message = _("pix_not_exist"),
                    icon    = "banco",
                    timeout = 5000,
                    color   = "red",
                }

                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                return false
            end
        else
            local datanotify = {
                title   = _("error_transfer"),
                message = _("player_not_exist"),
                icon    = "banco",
                timeout = 5000,
                color   = "red",
            }

            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreatePIX
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.CreatePIX(data)
 local source = source
    local user_id = getUserId(source)

 if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM "..Config.TablePlayerDB.." WHERE dvalue = @dvalue",{
            ['@dvalue'] = data.keypix,
        })

        if result[1] == nil then
            setUserData(user_id, "ps_key_pix", data.keypix)
            return true
        end

        return nil
 end

 return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetBankHistory
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetBankHistory()
 local source = source
    local user_id = getUserId(source)

 if user_id ~= nil then
        local bankhistory = json.decode(getUserData(user_id, "ps_bank_history"))
        if bankhistory ~= nil then
            return bankhistory
        else
            return nil
        end
 end

 return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditContact
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':EditContact')
AddEventHandler(GetCurrentResourceName()..':EditContact', function(name, number, bank, oldname, oldnumber, oldbank)
    local source  = source
    local user_id = getUserId(source)

    exports.oxmysql:execute("UPDATE evo_phone_contacts SET number = @number, bank = @bank, display = @display WHERE user_id = @user_id AND number = @oldnumber",{
        ['@number']    = number,
        ['@bank']      = bank,
        ['@display']   = name,
        ['@user_id']   = user_id,
        ['@oldnumber'] = oldnumber
 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RemoveContact
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':RemoveContact')
AddEventHandler(GetCurrentResourceName()..':RemoveContact', function(name, number, bank)
    local source  = source
    local user_id = getUserId(source)

    exports.oxmysql:execute("DELETE FROM evo_phone_contacts WHERE user_id = @user_id AND number = @number",{
         ['@user_id'] = user_id,
         ['@number']  = number
 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddNewContact
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':AddNewContact')
AddEventHandler(GetCurrentResourceName()..':AddNewContact', function(name, number, bank)
    local src     = source
 local user_id = getUserId(source)

    exports.oxmysql:insert("INSERT INTO evo_phone_contacts (`user_id`, `number`, `bank`, `display`) VALUES (@user_id, @number, @bank, @display)",{
         ['@user_id'] = user_id,
         ['@number']  = number,
         ['@bank']    = bank,
         ['@display'] = name
 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaveSettings
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':SaveSettings')
AddEventHandler(GetCurrentResourceName()..':SaveSettings', function(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_settings WHERE `option` = @option AND user_id = @user_id",{
            ['@option']  = data.option,
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("UPDATE evo_phone_settings SET value = @value WHERE user_id = @user_id AND `option` = @option",{
                ['@option']  = data.option,
                ['@value']   = data.value,
                ['@user_id'] = user_id
            })
            return true
        else

            exports.oxmysql:insert("INSERT INTO evo_phone_settings (`user_id`, `option`, `value`) VALUES(@user_id, @option, @value);",{
                ['@user_id'] = user_id,
                ['@option']  = data.option,
                ['@value']   = data.value
            })
            return true
        end
    end

end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- escape_sqli
-----------------------------------------------------------------------------------------------------------------------------------------

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HasPhone
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.HasPhone()
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        if Config.VerifyItem then
            local check = Config.checkItemPhone(source, user_id,Config.ItemPhone)

            return check
         else
                 return true
         end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPhoneSettings
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPhoneSettings(option)
 local source = source
    local user_id = getUserId(source)

 if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_settings WHERE `option` = @option AND user_id = @user_id",{
            ['@option'] = option,
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            return result[1].value
        end

        return nil
 end

 return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserData
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserData()
 local source = source
    local user_id = getUserId(source)

 if user_id ~= nil then
        local UserData = {
                 cash     = 0,
                 banco    = 0,
                 name     = nil,
                 identity = {},
                 result   = {},
                 pix      = nil
         }

        local cash     = getBankMoney(user_id)
        local identity = getUserIdentity(user_id)
        local banco    = getBankMoney(user_id)
        local result   = getUserIdentity(user_id)
        local name     = getUserFullName(user_id)
        local key_pix  = getUserData(user_id, "ps_key_pix")

        UserData.cash     = cash
        UserData.banco    = banco
        UserData.name     = name
        UserData.identity = identity
        UserData.result   = result
        UserData.pix      = key_pix

        return UserData
 end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserProfileInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserProfileInsta()
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then
         local account = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(user_id) })
        return account[1]
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAccountInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddAccountInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.name ~= nil and data.username ~= nil and data.password ~= nil then

        local check = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(user_id) })

        if check[1] == nil then

            local check2 = DB.query(GetCurrentResourceName().."/insta_account_username",{ username = data.username })
            if check2[1] == nil then
                exports.oxmysql:insert("INSERT INTO evo_phone_accounts (`id`, `name`, `username`, `password`, `avatar`, `app`) VALUES(@user_id, @name, @username, @password, @avatar, 'instagram');",{
                    ['@user_id']  = user_id,
                    ['@name']     = data.name,
                    ['@username'] = data.username,
                    ['@password'] = data.password,
                    ['@avatar']   = "default.png"
                })
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetStoriesInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetStoriesInstagram(data)
    local source   = source
    local user_id  = getUserId(source)
    local stories  = {}

    if user_id ~= nil then

        local start   = os.date("%Y-%m-%d 00:00:00")
        local finish  = os.date("%Y-%m-%d 23:59:59")
        local result  = exports.oxmysql:executeSync("SELECT S.author as username, S.image, S.description, S.location, S.filter, S.created FROM evo_phone_stories AS S LEFT JOIN evo_phone_followers AS F ON F.followed = S.author AND F.app = 'instagram' WHERE S.created BETWEEN @start AND @finish AND F.username = @username AND S.app = 'instagram' ORDER BY S.created DESC",{
            ['@start']    = start,
            ['@finish']   = finish,
            ['@username'] = data.username
        })

        if result ~= nil then
            stories = result
            return stories
        else
            return stories
        end
    else
        return stories
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMyStorieInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetMyStorieInstagram(data)
    local source  = source
    local user_id = getUserId(source)
    local storie  = nil

    if user_id ~= nil then

        local start   = os.date("%Y-%m-%d 00:00:00")
        local finish  = os.date("%Y-%m-%d 23:59:59")
        local result  = exports.oxmysql:executeSync("SELECT *, author AS username FROM evo_phone_stories WHERE created BETWEEN @start AND @finish AND author = @username AND app = 'instagram' ORDER BY created DESC LIMIT 1",{
            ['@start']    = start,
            ['@finish']   = finish,
            ['@username'] = data.username
        })

        if result ~= nil then
            storie = result[1]
            return storie
        else
            return storie
        end
    else
        return storie
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostsInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostsInstagram(data)
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        local result = nil

        if Config.AllPostsInsta then
            result = exports.oxmysql:executeSync("SELECT S.id, S.author AS username, S.image, S.description, S.location, S.filter, S.created, A.avatar, A.verify, (SELECT COUNT(*) FROM evo_phone_likes WHERE post_id = S.id) AS total_likes, (SELECT COUNT(*) FROM evo_phone_likes  WHERE post_id = S.id AND username = @username) AS liked FROM evo_phone_posts AS S LEFT JOIN evo_phone_accounts AS A ON A.username = S.author AND A.app = 'instagram' WHERE S.app = 'instagram' GROUP BY S.id ORDER BY S.id DESC LIMIT 100",{
                ['@username'] = data.username
            })
        else
            result = exports.oxmysql:executeSync("SELECT S.id, S.author AS username, S.image, S.description, S.location, S.filter, S.created, A.avatar, A.verify, (SELECT COUNT(*) FROM evo_phone_likes WHERE post_id = S.id) AS total_likes, (SELECT COUNT(*) FROM evo_phone_likes WHERE post_id = S.id AND username = @username) AS liked FROM evo_phone_posts AS S LEFT JOIN evo_phone_followers AS F ON F.followed = S.author LEFT JOIN evo_phone_accounts AS A ON A.username = S.author AND A.app = 'instagram' WHERE F.username = @username OR S.author = @username AND S.app = 'instagram' GROUP BY S.id ORDER BY S.id DESC LIMIT 100",{
                ['@username'] = data.username
            })
        end

        if result ~= nil then
            posts = result
            return posts
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddStorieInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddStorieInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local created = os.date("%Y-%m-%d %H:%I:%S")

        exports.oxmysql:insert("INSERT INTO evo_phone_stories (`app`, `author`, `image`, `created`) VALUES('instagram', @username, @image, @created);",{
            ['@username'] = data.username,
            ['@image']    = data.image,
            ['@created']  = created
        })

        local follows = exports.oxmysql:executeSync("SELECT AC.id, AC.username FROM evo_phone_followers AS F INNER JOIN evo_phone_accounts AS AC ON AC.username = F.username AND AC.app = 'instagram' WHERE followed = @followed AND F.app = 'instagram'",{
            ['@followed'] = data.username
        })

        if follows ~= nil then
            for k, v in pairs(follows) do

                local nsource = getUserSource(v.id)

                local datanotify = {
                    title   = data.username,
                    message = "Postou um novo storie",
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshStoriesInstagram")
                end

                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshStoriesInstagram")
            end
        end

        return true
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddPostInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddPostInsta(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local created = os.date("%Y-%m-%d %H:%I:%S")

        local location = nil

        if data.location ~= 'Desativado' then
            location = data.location
        end
        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.image

        exports.oxmysql:insert("INSERT INTO evo_phone_posts (`app`, `author`, `image`, `description`, `location`, `filter`, `created`) VALUES('instagram', @username, @image, @description, @location, @filter, @created);",{
            ['@username']    = data.username,
            ['@image']       = data.image,
            ['@description'] = data.description,
            ['@location']    = data.location,
            ['@filter']      = data.filter,
            ['@created']     = created
        })

        local follows = exports.oxmysql:executeSync("SELECT AC.id, AC.username FROM evo_phone_followers AS F INNER JOIN evo_phone_accounts AS AC ON AC.username = F.username AND AC.app = 'instagram' WHERE followed = @followed AND F.app = 'instagram'",{
            ['@followed'] = data.username
        })

        if follows ~= nil then
            for k, v in pairs(follows) do

                local nsource = getUserSource(v.id)

                local datanotify = {
                    title   = data.username,
                    message = "Postou uma nova foto",
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshPostsInstagram")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshPostsInstagram")
            end
        end

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfilesInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfilesInstagram(data)
    local source   = source
    local user_id  = getUserId(source)
    local profiles = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts WHERE NOT EXISTS (SELECT * FROM evo_phone_followers WHERE evo_phone_followers.followed = evo_phone_accounts.username OR evo_phone_accounts.username = @username AND evo_phone_followers.app = 'instagram') AND app = 'instagram' ORDER BY id DESC LIMIT 30",{
            ['@username'] = data.username
        })

        if result ~= nil then
            profiles = result
            return profiles
        else
            return profiles
        end
    else
        return profiles
    end

end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfilesInstagramLike
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfilesInstagramLike(data)
    local source   = source
    local user_id  = getUserId(source)
    local profiles = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts WHERE NOT EXISTS (SELECT * FROM evo_phone_followers WHERE evo_phone_followers.followed = evo_phone_accounts.username OR evo_phone_accounts.username = @username AND evo_phone_followers.app = 'instagram') AND name LIKE @name OR username LIKE @username2 AND app = 'instagram' ORDER BY id DESC LIMIT 30",{
            ['@username'] = data.username,
            ['@name'] = string.lower('%'..data.search..'%'),
            ['@username2'] = string.lower('%'..data.search..'%')
        })

        if result ~= nil then
            profiles = result
            return profiles
        else
            return profiles
        end
    else
        return profiles
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfileInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfileInstagram(nuser_id)
    local source  = source
    local user_id = getUserId(source)
    local profile = {
        total_follows   = 0,
        total_followeds = 0,
        total_posts     = 0,
        posts           = {},
        account         = {},
        followed        = false
    }

    if nuser_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(nuser_id) })

        local myaccount = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(user_id) })

        if account[1] ~= nil then
            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_follows FROM evo_phone_followers WHERE followed = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_follows = result[1].total_follows
            end

            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_followeds FROM evo_phone_followers WHERE username = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_followeds = result[1].total_followeds
            end

            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_posts FROM evo_phone_posts WHERE author = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_posts = result[1].total_posts
            end

            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts WHERE author = @username AND app = 'instagram' ORDER BY created DESC LIMIT 30",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.posts = result
            end

            if user_id ~= nuser_id then
                local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_followers WHERE username = @username AND followed = @followed AND app = 'instagram'",{
                    ['@username'] = myaccount[1].username,
                    ['@followed'] = account[1].username
                })

                if result[1] ~= nil then
                    profile.followed = true
                end
            end

            profile.account = account[1]

            return profile

        else
            return profile
        end
    else
        return profile
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfileInstagramUsername
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfileInstagramUsername(username)
    local source  = source
    local user_id = getUserId(source)
    local profile = {
        total_follows   = 0,
        total_followeds = 0,
        total_posts     = 0,
        posts           = {},
        account         = {},
        followed        = false
    }

    if username ~= nil and user_id ~= nil then


        local account = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'instagram'",{
            ['@username'] = username
        })

        local myaccount = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(user_id) })

        if account[1] ~= nil then
            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_follows FROM evo_phone_followers WHERE followed = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_follows = result[1].total_follows
            end

            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_followeds FROM evo_phone_followers WHERE username = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_followeds = result[1].total_followeds
            end

            local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_posts FROM evo_phone_posts WHERE author = @username AND app = 'instagram'",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.total_posts = result[1].total_posts
            end

            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts WHERE author = @username AND app = 'instagram' ORDER BY created DESC LIMIT 30",{
                ['@username'] = account[1].username
            })

            if result ~= nil then
                profile.posts = result
            end

            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_followers WHERE username = @username AND followed = @followed AND app = 'instagram'",{
                ['@username'] = myaccount[1].username,
                ['@followed'] = account[1].username
            })

            if result[1] ~= nil then
                profile.followed = true
            end

            profile.account = account[1]

            return profile

        else
            return profile
        end
    else
        return profile
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FollowUserInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.FollowUserInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id, _("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.followed

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_followers WHERE username = @username AND followed = @followed AND app = 'instagram'",{
            ['@username'] = data.username,
            ['@followed'] = data.followed
        })

        if result[1] ~= nil then
            return false
        end

        local accountfollow = DB.query(GetCurrentResourceName().."/insta_account_username",{ username = data.followed })

        if accountfollow[1] ~= nil then

            exports.oxmysql:insert("INSERT INTO evo_phone_followers (`app`, `username`, `followed`) VALUES('instagram', @username, @followed);",{
                ['@username'] = data.username,
                ['@followed'] = data.followed
            })

            local nsource = getUserSource(accountfollow[1].id)

            local datanotify = {
                title   = data.username,
                message = _("follow_your"),
                icon    = "instagram",
                timeout = 5000,
                color   = "green",
            }

            if nsource ~= nil then
                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshPostsInstagram")
            end

            Wait(100)
            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshPostsInstagram")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UnfollowUserInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.UnfollowUserInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.followed

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_followers WHERE username = @username AND followed = @followed AND app = 'instagram'",{
            ['@username'] = data.username,
            ['@followed'] = data.followed
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("DELETE FROM evo_phone_followers WHERE username = @username AND followed = @followed AND app = 'instagram'",{
                ['@username'] = data.username,
                ['@followed'] = data.followed
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else

            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetTotalFollowsAndFolloweds
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetTotalFollowsAndFolloweds(data)
    local source   = source
    local user_id  = getUserId(source)
    local dataret  = {
        total_follows   = 0,
        total_followeds = 0
    }

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return dataret
        end

        cache[user_id] = data.username..user_id

        local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_follows FROM evo_phone_followers WHERE followed = @username AND app = 'instagram'",{
            ['@username'] = data.username
        })

        if result ~= nil then
            dataret.total_follows = result[1].total_follows
        end

        local result = exports.oxmysql:executeSync("SELECT COUNT(*) AS total_followeds FROM evo_phone_followers WHERE username = @username AND app = 'instagram'",{
            ['@username'] = data.username
        })

        if result ~= nil then
            dataret.total_followeds = result[1].total_followeds
        end

        cache[user_id] = nil
        count[user_id] = 0

        return dataret
    else
        return dataret
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetFollowsInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetFollowsInstagram(data)
    local source  = source
    local user_id = getUserId(source)
    local follows = {}

    if user_id then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return follows
        end

        cache[user_id] = data.username..user_id

        local result = exports.oxmysql:executeSync("SELECT A.id, A.name, A.username, A.avatar FROM evo_phone_followers AS F LEFT JOIN evo_phone_accounts AS A ON A.username = F.username AND A.app = 'instagram' WHERE F.app = 'instagram' AND F.followed = @username ORDER BY F.id DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            follows = result
        end

        cache[user_id] = nil
        count[user_id] = 0

        return follows
    else
        return follows
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetFollowedsInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetFollowedsInstagram(data)
    local source  = source
    local user_id = getUserId(source)
    local follows = {}

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return follows
        end

        cache[user_id] = data.username..user_id

        local result = exports.oxmysql:executeSync("SELECT A.id, A.name, A.username, A.avatar FROM evo_phone_followers AS F LEFT JOIN evo_phone_accounts AS A ON A.username = F.followed AND A.app = 'instagram' WHERE F.app = 'instagram' AND F.username = @username ORDER BY F.id DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            follows = result
        end

        cache[user_id] = nil
        count[user_id] = 0

        return follows
    else
        return follows
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditProfileInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditProfileInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(user_id) })
        if account[1] ~= nil then

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = account[1].username..data.username..user_id

            if account[1].username ~= data.username then
                local check = DB.query(GetCurrentResourceName().."/insta_account_username",{ username = data.username })
                if check[1] == nil then
                    exports.oxmysql:execute("UPDATE evo_phone_accounts SET name = @name, username = @username, avatar = @avatar, description = @description WHERE id = @id AND app = 'instagram'",{
                        ['@name']        = data.name,
                        ['@username']    = data.username,
                        ['@avatar']      = data.avatar,
                        ['@description'] = data.description,
                        ['@id']          = user_id
                    })

                    exports.oxmysql:execute("UPDATE evo_phone_followers SET username = @username WHERE username = @usernameold AND app = 'instagram'",{
                        ['@username']    = data.username,
                        ['@usernameold'] = account[1].username
                    })

                    exports.oxmysql:execute("UPDATE evo_phone_followers SET followed = @followed WHERE followed = @followedold AND app = 'instagram'",{
                        ['@followed']    = data.username,
                        ['@usernameold'] = account[1].username
                    })
                else
                    return false
                end
            else
                exports.oxmysql:execute("UPDATE evo_phone_accounts SET name = @name, avatar = @avatar, description = @description WHERE id = @id AND app = 'instagram'",{
                    ['@name']        = data.name,
                    ['@avatar']      = data.avatar,
                    ['@description'] = data.description,
                    ['@id']          = user_id
                })
            end

            cache[user_id] = nil
            count[user_id] = 0

            return true

        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddLikePostInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddLikePostInstagram(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.id..user_id

        local check = exports.oxmysql:executeSync("SELECT * FROM evo_phone_likes WHERE post_id = @post_id AND username = @username",{
            ['@post_id']  = data.id,
            ['@username'] = data.username
        })

        if check[1] == nil then

            exports.oxmysql:insert("INSERT INTO evo_phone_likes (`post_id`, `username`) VALUES (@post_id, @username);",{
                ['@post_id']  = data.id,
                ['@username'] = data.username
            })

            local post = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts WHERE id = @id AND app = 'instagram'",{
                ['@id'] = data.id
            })

            if post[1] ~= nil then
                if post[1].username ~= data.username then
                    local useraccount = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'instagram'",{
                        ['@username'] = post[1].username
                    })

                    if useraccount[1] ~= nil then
                        local nuser_id = tonumber(useraccount[1].id)
                        local nsource = getUserSource(nuser_id)

                        local datanotify = {
                            title   = data.username,
                            message = _("like_your_photo"),
                            icon    = "instagram",
                            timeout = 5000,
                            color   = "green",
                        }

                        if nsource ~= nil then
                            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                        end
                    end
                end
            end

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            exports.oxmysql:execute("DELETE FROM evo_phone_likes WHERE post_id = @post_id AND username = @username",{
                ['@post_id']  = data.id,
                ['@username'] = data.username
            })

            cache[user_id] = nil
            count[user_id] = 0
            return true
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostIdInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostIdInstagram(data)
    local source   = source
    local user_id  = getUserId(source)
    local post     = {
        data     = {},
        comments = {},
    }

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT S.id, S.author AS username, S.image, S.description, S.location, S.filter, S.created, A.avatar, A.verify, (SELECT COUNT(*) FROM evo_phone_likes WHERE post_id = S.id) AS total_likes, (SELECT COUNT(*) FROM evo_phone_likes WHERE post_id = S.id AND username = @username) AS liked FROM evo_phone_posts AS S LEFT JOIN evo_phone_accounts AS A ON A.username = S.author AND A.app = 'instagram' WHERE S.id = @id AND S.app = 'instagram' GROUP BY S.id ORDER BY S.id DESC LIMIT 100",{
            ['@id']       = data.id,
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            post.data = result[1]
        end

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_comments WHERE post_id = @post_id and app = 'instagram'",{
            ['@post_id'] = data.id
        })

        if result ~= nil then
            post.comments = result
        end

        return post
    else
        return post
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddCommentPostInstagram
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddCommentPostInstagram(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local created = os.date("%Y-%m-%d %H:%I:%S")

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.id..user_id

        exports.oxmysql:insert("INSERT INTO evo_phone_comments (`app`, `post_id`, `author`, `description`, `created`) VALUES ('instagram', @post_id, @username, @description, @created);",{
            ['@post_id']     = data.id,
            ['@username']    = data.username,
            ['@description'] = data.description,
            ['@created']     = created
        })

        local post = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts WHERE id = @id AND app = 'instagram'",{
            ['@id'] = data.id
        })

        if post[1] ~= nil then
            if post[1].username ~= data.username then
                local useraccount = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts WHERE username = @username AND app = 'instagram'",{
                    ['@username'] = post[1].username
                })

                if useraccount[1] ~= nil then
                    local nuser_id = tonumber(useraccount[1].id)
                    local nsource = getUserSource(nuser_id)

                    local datanotify = {
                        title   = data.username,
                        message = _("comment_your_photo"),
                        icon    = "instagram",
                        timeout = 5000,
                        color   = "green",
                    }

                    if nsource ~= nil then
                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    end
                end
            end
        end

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetInstaChats
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetInstaChats(data)
    local source   = source
    local user_id  = getUserId(source)
    local chats  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT C.number AS username, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.username = C.number AND A.app = 'instagram' WHERE C.author = @username AND C.app = 'instagram' AND C.`type` = 'chat' GROUP BY C.id ORDER BY id_message DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        local result  = exports.oxmysql:executeSync("SELECT C.author AS username, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.username = C.author AND A.app = 'instagram' WHERE C.number = @username AND C.app = 'instagram' AND C.`type` = 'chat' GROUP BY C.id ORDER BY id_message DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        return chats
    else
        return chats
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetInstaChat
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetInstaChat(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @username AND number = @username_from AND app = 'instagram' AND `type` = 'chat'",{
            ['@username'] = data.myusername,
            ['@username_from'] = data.username
        })

        if result[1] ~= nil then

            local getmessages  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages WHERE id_chat = @id_chat ORDER BY id ASC",{
                ['@id_chat'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @username AND number = @username_from AND app = 'instagram' AND `type` = 'chat'",{
            ['@username'] = data.username,
            ['@username_from'] = data.myusername
        })

        if result[1] ~= nil then
            local getmessages  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages WHERE id_chat = @id_chat ORDER BY id ASC",{
                ['@id_chat'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        return messages
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfilePictureInsta
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfilePictureInsta(username)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        if username ~= nil then
            local account = DB.query(GetCurrentResourceName().."/insta_account_username", { username = username })
            if account[1] ~= nil then
                return account[1].avatar
            else
                return "default.png"
            end
        else
            return nil
        end
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendMessageInsta
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SendMessageInsta(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/insta_account_username", { username = data.myusername })
        local accountsender = DB.query(GetCurrentResourceName().."/insta_account_username", { username = data.username })
        if account ~= nil and accountsender[1] ~= nil then

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = data.username..data.type..user_id

            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @username AND number = @username_from AND app = 'instagram' AND `type` = 'chat'",{
                ['@username']  = data.myusername,
                ['@username_from'] = data.username
            })

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id,
                    ['@owner']   = data.myusername,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = tonumber(accountsender[1].id)
                local nsource  = getUserSource(nuser_id)
                local message  = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                else
                    message = data.message
                end

                local datanotify = {
                    title   = data.myusername,
                    message = message,
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatInstagram")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatInstagram")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @username AND number = @username_from AND app = 'instagram' AND `type` = 'chat'",{
                ['@username']  = data.username,
                ['@username_from'] = data.myusername
            })

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id,
                    ['@owner']   = data.myusername,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = tonumber(accountsender[1].id)
                local nsource  = getUserSource(nuser_id)
                local message  = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                else
                    message = data.message
                end

                local datanotify = {
                    title   = data.myusername,
                    message = message,
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatInstagram")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatInstagram")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            local created = os.date("%Y-%m-%d %H:%I:%S")



            exports.oxmysql:insert("INSERT INTO evo_phone_chats (`app`, `author`, `type`, `number`, `created`) VALUES('instagram', @username, 'chat', @username_from, @created);",{
                ['@username']      = data.myusername,
                ['@username_from'] = data.username,
                ['@created']       = created
            })

            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats ORDER BY id DESC LIMIT 1",{})

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id + 1,
                    ['@owner']   = data.myusername,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = tonumber(accountsender[1].id)
                local nsource  = getUserSource(nuser_id)
                local message  = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                else
                    message = data.message
                end

                local datanotify = {
                    title   = data.myusername,
                    message = message,
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatInstagram")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatInstagram")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = 1,
                    ['@owner']   = data.myusername,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = tonumber(accountsender[1].id)
                local nsource  = getUserSource(nuser_id)
                local message  = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                else
                    message = data.message
                end

                local datanotify = {
                    title   = data.myusername,
                    message = message,
                    icon    = "instagram",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatInstagram")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatInstagram")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            return false

        else

            local datanotify = {
                title   = "Error",
                message = _("no_search_account"),
                icon    = "instagram",
                timeout = 5000,
                color   = "red",
            }

            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeletePostInsta
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeletePostInsta(data)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        exports.oxmysql:execute("DELETE FROM evo_phone_posts WHERE author = @username AND id = @id AND app = 'instagram'",{
            ['@username'] = data.username,
            ['@id']       = data.id
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserProfileWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserProfileWhatsApp()
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        local identity = getUserIdentity(user_id)
        if identity ~= nil then
            local account = DB.query(GetCurrentResourceName().."/whatsapp_account", { phone = identity.phone })
            return account[1]
        else
            return nil
        end
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAccountWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddAccountWhatsApp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil and data.name ~= nil and data.phone ~= nil and data.password ~= nil then

        local identity = getUserIdentity(user_id)

        if identity == nil then
            return nil
        end

        if identity.phone == data.phone then
            local check = DB.query(GetCurrentResourceName().."/whatsapp_account", { phone = identity.phone })

            if check[1] == nil then

                if cache[user_id] ~= nil then
                    if count[user_id] ~= nil then
                        count[user_id] = count[user_id] + 1
                    else
                        count[user_id] = 1
                    end

                    if count[user_id] >= 10 then
                        expulseUser(user_id,_("kick_flood"))
                    end
                    return false
                end

                cache[user_id] = data.phone..user_id

                exports.oxmysql:insert("INSERT INTO evo_phone_accounts (`id`, `name`, `phone`, `password`, `avatar`, `app`) VALUES(@user_id, @name, @phone, @password, @avatar, 'whatsapp');",{
                    ['@user_id']  = user_id,
                    ['@name']     = data.name,
                    ['@phone']    = data.phone,
                    ['@password'] = data.password,
                    ['@avatar']   = "default.png"
                })

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetStoriesWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetStoriesWhatsApp(data)
    local source   = source
    local user_id  = getUserId(source)
    local stories  = {}

    if user_id ~= nil then

        local start   = os.date("%Y-%m-%d 00:00:00")
        local finish  = os.date("%Y-%m-%d 23:59:59")
        local result  = exports.oxmysql:executeSync("SELECT S.author AS phone, S.image, S.description, S.location, S.filter, S.created, C.display AS contact_name FROM evo_phone_stories AS S LEFT JOIN evo_phone_contacts AS C ON C.number = S.author WHERE S.created BETWEEN @start AND @finish AND C.user_id = @user_id AND S.author != @phone AND S.app = 'whatsapp' ORDER BY S.created DESC",{
            ['@start']   = start,
            ['@finish']  = finish,
            ['@user_id'] = user_id,
            ['@phone']   = data.phone
        })

        if result ~= nil then
            stories = result
            return stories
        else
            return stories
        end
    else
        return stories
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMyStorieWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetMyStorieWhatsApp(data)
    local source  = source
    local user_id = getUserId(source)
    local storie  = nil

    if user_id ~= nil then

        local start   = os.date("%Y-%m-%d 00:00:00")
        local finish  = os.date("%Y-%m-%d 23:59:59")
        local result  = exports.oxmysql:executeSync("SELECT *, author AS phone FROM evo_phone_stories WHERE created BETWEEN @start AND @finish AND author = @phone AND app = 'whatsapp' ORDER BY created DESC LIMIT 1",{
            ['@start']  = start,
            ['@finish'] = finish,
            ['@phone']  = data.phone
        })

        if result ~= nil then
            storie = result[1]
            return storie
        else
            return storie
        end
    else
        return storie
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddStorieWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddStorieWhatsApp(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local created = os.date("%Y-%m-%d %H:%I:%S")

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.phone..user_id

        exports.oxmysql:insert("INSERT INTO evo_phone_stories (`app`, `author`, `image`, `created`) VALUES('whatsapp', @phone, @image, @created);",{
            ['@phone']   = data.phone,
            ['@image']   = data.image,
            ['@created'] = created
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditProfileWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditProfileWhatsApp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.phone..user_id

        exports.oxmysql:execute("UPDATE evo_phone_accounts SET name = @name, avatar = @avatar WHERE phone = @phone AND app = 'whatsapp'",{
            ['@name']   = data.name,
            ['@avatar'] = data.avatar,
            ['@phone']  = data.phone
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateGroupWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.CreateGroupWhatsApp(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local created = os.date("%Y-%m-%d %H:%I:%S")

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.phone..user_id

        local charset = {}  do -- [0-9a-zA-Z]
            for c = 48, 57  do table.insert(charset, string.char(c)) end
            for c = 65, 90  do table.insert(charset, string.char(c)) end
            for c = 97, 122 do table.insert(charset, string.char(c)) end
        end

        local function randomString(length)
            if not length or length <= 0 then return '' end
            math.randomseed(os.clock())
            local random = tonumber(os.clock())
            return randomString(length - 1) .. charset[math.random(1, #charset)]
        end

        local number = os.date("%m%Y%m%d%H%I%S")..""..randomString(30)

        exports.oxmysql:insert("INSERT INTO evo_phone_chats (`app`, `author`, `number`, `type`, `name`, `image`, `created`) VALUES('whatsapp', @phone, @number, @type, @name, @image, @created);",{
            ['@phone']   = data.phone,
            ['@number']  = number,
            ['@type']    = 'group',
            ['@name']    = data.name,
            ['@image']   = data.image,
            ['@created'] = created
        })

        exports.oxmysql:insert("INSERT INTO evo_phone_chats_users (`app`, `number`, `admin`, `author`) VALUES('whatsapp', @number_group, @admin, @phone);",{
            ['@number_group'] = number,
            ['@admin']        = 1,
            ['@phone']        = data.phone
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditGroupWhatsApp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditGroupWhatsApp(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..user_id

        exports.oxmysql:insert("UPDATE evo_phone_chats SET name = @name, image = @image WHERE number = @number AND type = 'group' AND app = 'whatsapp'",{
            ['@name']    = data.name,
            ['@image']   = data.image,
            ['@number']  = data.number
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetWhatsappChats
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetWhatsappChats(data)
    local source   = source
    local user_id  = getUserId(source)
    local chats  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT C.number AS phone, (SELECT display FROM evo_phone_contacts WHERE number = C.number AND user_id = @user_id LIMIT 1) AS contact_name, (SELECT number FROM evo_phone_contacts WHERE number = C.number AND user_id = @user_id LIMIT 1) AS contact_phone, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message, (SELECT owner FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS owner, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.phone = C.number WHERE C.author = @phone AND C.app = 'whatsapp' AND C.`type` = 'chat' AND A.app = 'whatsapp' GROUP BY C.id ORDER BY id_message DESC",{
            ['@phone'] = data.phone,
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        local result  = exports.oxmysql:executeSync("SELECT C.author AS phone, (SELECT display FROM evo_phone_contacts WHERE number = C.author AND user_id = @user_id LIMIT 1) AS contact_name, (SELECT number FROM evo_phone_contacts WHERE number = C.author AND user_id = @user_id LIMIT 1) AS contact_phone, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message,  (SELECT owner FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS owner, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.phone = C.author WHERE C.number = @phone AND C.app = 'whatsapp' AND C.`type` = 'chat' AND A.app = 'whatsapp' GROUP BY C.id ORDER BY id_message DESC",{
            ['@phone'] = data.phone,
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        return chats
    else
        return chats
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfilePicture
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfilePicture(number)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        if number ~= nil then
            local account = DB.query(GetCurrentResourceName().."/whatsapp_account", { phone = number })
            if account[1] ~= nil then
                return account[1].avatar
            else
                return "default.png"
            end
        else
            return nil
        end
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetWhatsappChat
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetWhatsappChat(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @phone AND number = @number AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            local getmessages  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages WHERE id_chat = @id_chat ORDER BY id ASC",{
                ['@id_chat'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @number AND number = @phone AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            local getmessages  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages WHERE id_chat = @id_chat ORDER BY id ASC",{
                ['@id_chat'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        return messages
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetChatReadWhatsapp
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SetChatReadWhatsapp(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @phone AND number = @number AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("UPDATE evo_phone_messages SET `read` = 1 WHERE id_chat = @id_chat AND `owner` != @owner",{
                ['@id_chat'] = result[1].id,
                ['@owner']   = data.phone
            })
        end

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @number AND number = @phone AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("UPDATE evo_phone_messages SET `read` = 1 WHERE id_chat = @id_chat AND `owner` != @owner",{
                ['@id_chat'] = result[1].id,
                ['@owner']   = data.phone
            })
        end

        return true
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteWhatsappChat
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeleteWhatsappChat(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @phone AND number = @number AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("UPDATE evo_phone_messages SET deleted = 'all' WHERE id_chat = @id_chat AND deleted IS NOT NULL",{
                ['@id_chat'] = result[1].id
            })
            Wait(1000)
            exports.oxmysql:execute("UPDATE evo_phone_messages SET deleted = @deleted WHERE id_chat = @id_chat AND deleted IS NULL",{
                ['@id_chat'] = result[1].id,
                ['@deleted'] = data.phone
            })
        end

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @number AND number = @phone AND app = 'whatsapp' AND type = 'chat'",{
            ['@phone']  = data.phone,
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            exports.oxmysql:execute("UPDATE evo_phone_messages SET deleted = 'all' WHERE id_chat = @id_chat AND deleted IS NOT NULL",{
                ['@id_chat'] = result[1].id
            })
            Wait(1000)
            exports.oxmysql:execute("UPDATE evo_phone_messages SET deleted = @deleted WHERE id_chat = @id_chat AND deleted IS NULL",{
                ['@id_chat'] = result[1].id,
                ['@deleted'] = data.phone
            })
        end

        return true
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendMessage
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SendMessage(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/whatsapp_account", { phone = data.phone })
        local accountsender = DB.query(GetCurrentResourceName().."/whatsapp_account", { phone = data.number })
        if account ~= nil and accountsender[1] ~= nil then

            if data.type == 'pix' then
                local amount = data.message

                if tonumber(amount) > 0 then
                    local nsender = getUserByPhone(data.number)

                    local bank = getBankMoney(user_id)
                    local bank_sender = getBankMoney(nsender)

                    if bank >= tonumber(amount) then

                        --remove bank
                        remBankMoney(user_id, amount)

                        --add bank
                        addBankMoney(nsender, amount)

                        local time = os.date("%d/%m/%Y %H:%M:%S")

                        local data = {
                            {
                                fields = {
                                    { name = _U("transfer_wpp_title"), value = time },
                                    { name = _("send_user_money"), value = user_id, inline = true },
                                    { name = _("receive_user_money"), value = nsender, inline = true },
                                    { name = _("amount_money"), value = amount }
                                },
                                color = "3066993"
                            }
                        }

                        SendWebhookEmbed(Config.WebhookBank, data)

                        local history      = {}
                        local history2     = {}
                        local bankhistory  = json.decode(getUserData(user_id, "ps_bank_history"))
                        local bankhistory2 = json.decode(getUserData(nsender, "ps_bank_history"))

                        if bankhistory ~= nil then
                            for k, v in pairs(bankhistory) do
                                table.insert(history, v)
                            end
                        end

                        if bankhistory2 ~= nil then
                            for k, v in pairs(bankhistory2) do
                                table.insert(history2, v)
                            end
                        end

                        local data = {
                            type  = "down",
                            name  = _("transfer_wpp_title").." #"..nsender,
                            value = amount
                        }

                        table.insert(history, data)

                        local data2 = {
                            type  = "up",
                            name  = _("transfer_wpp_title").." #"..user_id,
                            value = amount
                        }

                        table.insert(history2, data2)

                        setUserData(user_id, "ps_bank_history", json.encode(history))
                        setUserData(nsender, "ps_bank_history", json.encode(history2))
                    else
                        local datanotify = {
                            title   = _("error_transfer"),
                            message = _("no_money"),
                            icon    = "whatsapp",
                            timeout = 5000,
                            color   = "red",
                        }

                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                        return false
                    end
                else
                    local datanotify = {
                        title   = _("error_transfer"),
                        message = _("no_transfer_amout_0"),
                        icon    = "whatsapp",
                        timeout = 5000,
                        color   = "red",
                    }

                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                    return false
                end
            end

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = data.number..data.type..user_id

            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE author = @phone AND number = @number AND app = 'whatsapp' AND type = 'chat'",{
                ['@phone']  = account[1].phone,
                ['@number'] = data.number
            })

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id,
                    ['@owner']   = account[1].phone,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = getUserByPhone(data.number)
                local nsource = getUserSource(nuser_id)
                local message = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                elseif data.type == 'pix' then
                    message = _("your_receive_money", data.message)
                else
                    message = data.message
                end

                local datanotify = {
                    title   = account[1].name,
                    message = message,
                    icon    = "whatsapp",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatWhatsApp")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatWhatsApp")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @phone AND author = @number AND app = 'whatsapp' AND type = 'chat'",{
                ['@phone']  = account[1].phone,
                ['@number'] = data.number
            })

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id,
                    ['@owner']   = account[1].phone,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = getUserByPhone(data.number)
                local nsource = getUserSource(nuser_id)
                local message = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                elseif data.type == 'pix' then
                    message = _("your_receive_money", data.message)
                else
                    message = data.message
                end

                local datanotify = {
                    title   = account[1].name,
                    message = message,
                    icon    = "whatsapp",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatWhatsApp")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatWhatsApp")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            local created = os.date("%Y-%m-%d %H:%I:%S")



            exports.oxmysql:insert("INSERT INTO evo_phone_chats (`app`, `type`, `author`, `number`, `created`) VALUES('whatsapp', 'chat', @phone, @number, @created);",{
                ['@phone']   = account[1].phone,
                ['@number']  = data.number,
                ['@created'] = created
            })

            Wait(100)
            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE app = 'whatsapp' and type= 'chat' ORDER BY id DESC LIMIT 1",{})

            if result[1] ~= nil then

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = result[1].id,
                    ['@owner']   = account[1].phone,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = getUserByPhone(data.number)
                local nsource = getUserSource(nuser_id)
                local message = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                elseif data.type == 'pix' then
                    message = _("your_receive_money", data.message)
                else
                    message = data.message
                end

                local datanotify = {
                    title   = account[1].name,
                    message = message,
                    icon    = "whatsapp",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatWhatsApp")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatWhatsApp")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else

                local created = os.date("%Y-%m-%d %H:%I:%S")

                exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                    ['@id_chat'] = 1,
                    ['@owner']   = account[1].phone,
                    ['@type']    = data.type,
                    ['@message'] = data.message,
                    ['@created'] = created,
                    ['@read']    = 0,
                })

                local nuser_id = getUserByPhone(data.number)
                local nsource = getUserSource(nuser_id)
                local message = nil

                if data.type == 'audio' then
                    message = _("audio_message")
                elseif data.type == 'location' then
                    message = _("location")
                elseif data.type == 'pix' then
                    message = _("your_receive_money", data.message)
                else
                    message = data.message
                end

                local datanotify = {
                    title   = account[1].name,
                    message = message,
                    icon    = "whatsapp",
                    timeout = 5000,
                    color   = "green",
                }

                if nsource ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                    Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatWhatsApp")
                end

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatWhatsApp")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            end

            return false

        else

            local datanotify = {
                title   = "Error",
                message = _("no_search_phone"),
                icon    = "whatsapp",
                timeout = 5000,
                color   = "red",
            }

            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetWhatsappGroups
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetWhatsappGroups(data)
    local source   = source
    local user_id  = getUserId(source)
    local groups  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT G.number, G.name, G.image, (SELECT message FROM evo_phone_messages WHERE id_chat = G.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = G.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = G.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = G.id ORDER BY id DESC LIMIT 1) AS id_message, U.admin FROM evo_phone_chats AS G LEFT JOIN evo_phone_chats_users AS U ON U.number = G.number WHERE U.author = @phone AND G.`type` = 'group' AND G.app = 'whatsapp' AND U.app = 'whatsapp' GROUP BY G.id ORDER BY id_message DESC",{
            ['@phone'] = data.phone
        })

        if result[1] ~= nil then
            groups = result
        end

        return groups
    else
        return groups
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetGroupImage
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetGroupImage(number)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        if number ~= nil then
            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @number AND type = 'group' AND app = 'whatsapp'",{
                ['@number'] = number
            })

            if result[1] ~= nil then
                return result[1].image
            else
                return nil
            end

        else
            return nil
        end
    else
        return nil
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GetWhatsappGroupMessages
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetWhatsappGroupMessages(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            local getmessages  = exports.oxmysql:executeSync("SELECT M.*, A.name FROM evo_phone_messages AS M LEFT JOIN evo_phone_accounts AS A ON A.phone = M.owner WHERE M.id_chat = @id_group AND A.app = 'whatsapp' ORDER BY id ASC",{
                ['@id_group'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        return messages
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetWhatsappGroup
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetWhatsappGroup(data)
    local source  = source
    local user_id = getUserId(source)
    local group   = {
        data = nil,
        users = {}
    }

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            group.data = result[1]

            local users  = exports.oxmysql:executeSync("SELECT A.name, A.avatar, A.phone FROM evo_phone_chats_users AS U LEFT JOIN evo_phone_accounts AS A ON A.phone = U.author WHERE U.number = @number AND U.app = 'whatsapp' AND A.app = 'whatsapp' ORDER BY A.name ASC",{
                ['@number'] = data.number
            })

            if users[1] ~= nil then
                group.users = users
            end
        end

        return group
    else
        return group
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddMemberGroupWhatsapp
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.AddMemberGroupWhatsapp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..data.phone..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            local check = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats_users WHERE number = @number AND author = @phone AND app = 'whatsapp'",{
                ['@number'] = data.number,
                ['@phone']  = data.phone
            })

            if check[1] == nil then
                exports.oxmysql:insert("INSERT INTO evo_phone_chats_users (`app`, `number`, `admin`, `author`) VALUES('whatsapp', @number, @admin, @phone);",{
                    ['@number'] = data.number,
                    ['@admin']  = 0,
                    ['@phone']  = data.phone,
                })

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else
                return false
            end
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RemoveMemberGroupWhatsapp
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.RemoveMemberGroupWhatsapp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..data.phone..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            local check = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats_users WHERE number = @number AND author = @phone AND app = 'whatsapp'",{
                ['@number'] = data.number,
                ['@phone']  = data.phone
            })

            if check[1] ~= nil then
                exports.oxmysql:execute("DELETE FROM evo_phone_chats_users WHERE number = @number AND author = @phone AND app = 'whatsapp'",{
                    ['@number'] = data.number,
                    ['@phone']  = data.phone,
                })

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else
                return false
            end
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LeaveGroupWhatsapp
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.LeaveGroupWhatsapp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..data.phone..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then
            local check = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats_users WHERE number = @number AND author = @phone AND app = 'whatsapp'",{
                ['@number'] = data.number,
                ['@phone']  = data.phone
            })

            if check[1] ~= nil then
                exports.oxmysql:execute("DELETE FROM evo_phone_chats_users WHERE number = @number AND author = @phone AND app = 'whatsapp'",{
                    ['@number'] = data.number,
                    ['@phone']  = data.phone,
                })

                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshGroupWhatsApp")

                cache[user_id] = nil
                count[user_id] = 0

                return true
            else
                return false
            end
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteGroupWhatsapp
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeleteGroupWhatsapp(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            exports.oxmysql:execute("DELETE FROM evo_phone_messages WHERE id_chat = @id_group",{
                ['@id_group'] = result[1].id
            })

            exports.oxmysql:execute("DELETE FROM evo_phone_chats WHERE number = @number AND `type` = 'group' AND app = 'whatsapp'",{
                ['@number'] = data.number
            })

            exports.oxmysql:execute("DELETE FROM evo_phone_chats_users WHERE number = @number AND app = 'whatsapp'",{
                ['@number'] = data.number
            })

            Wait(100)
            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshGroupWhatsApp")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendMessageGroup
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SendMessageGroup(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.phone..data.type..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND `type` = 'group' AND app = 'whatsapp'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            local created = os.date("%Y-%m-%d %H:%I:%S")

            exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_group, @owner, @type, @message, @created, @read);",{
                ['@id_group'] = result[1].id,
                ['@owner']    = data.phone,
                ['@type']     = data.type,
                ['@message']  = data.message,
                ['@created']  = created,
                ['@read']     = 0,
            })

            local members = exports.oxmysql:executeSync("SELECT A.id, A.name FROM evo_phone_chats_users AS G INNER JOIN evo_phone_accounts AS A ON A.phone = G.author WHERE G.number = @number_group AND G.app = 'whatsapp' AND A.app = 'whatsapp'",{
                ['@number_group'] = data.number
            })

            if members[1] ~= nil then
                for k, v in pairs(members) do
                    local nuser_id = tonumber(v.id)
                    local nsource = getUserSource(nuser_id)
                    local message = nil

                    if data.type == 'audio' then
                        message = _("audio_message")
                    elseif data.type == 'location' then
                        message = _("location")
                    else
                        message = data.message
                    end

                    local title = _("group")..": "..result[1].name

                    local datanotify = {
                        title   = title,
                        message = message,
                        icon    = "whatsapp",
                        timeout = 5000,
                        color   = "green",
                    }

                    if nsource ~= nil then
                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                        Citizen.Wait(100)
                        TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshGroupWhatsApp")
                    end
                end
            end

            Citizen.Wait(100)
            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshGroupWhatsApp")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaveCall
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':SaveCall')
AddEventHandler(GetCurrentResourceName()..':SaveCall', function(CallData)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then

            local number = CallData.TargetData.number
            local type = CallData.CallType
            local status = CallData.CallId

            local created = os.date("%Y-%m-%d %H:%I:%S")

            if number and type and status then
                exports.oxmysql:insert("INSERT INTO evo_phone_calls (`phone`, `number`, `type`, `status`, `created`) VALUES(@phone, @number, @type, @status, @created);",{
                    ['@phone']   = identity.phone,
                    ['@number']  = number,
                    ['@type']    = type,
                    ['@status']  = status,
                    ['@created'] = created
                })
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaveCallUser
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent(GetCurrentResourceName()..':SaveCallUser')
AddEventHandler(GetCurrentResourceName()..':SaveCallUser', function(CallData)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then

            local number = CallData.TargetData.number
            local type = CallData.CallType
            local status = CallData.CallId

            local created = os.date("%Y-%m-%d %H:%I:%S")

            if number and type and status then
                exports.oxmysql:insert("INSERT INTO evo_phone_calls (`phone`, `number`, `type`, `status`, `created`) VALUES(@phone, @number, @type, @status, @created);",{
                    ['@phone']   = number,
                    ['@number']  = identity.phone,
                    ['@type']    = type,
                    ['@status']  = status,
                    ['@created'] = created
                })
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaltyChatEstablishCall
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SaltyChatEstablishCall(CallData)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        local sender = getUserByPhone(CallData.TargetData.number)

        if sender ~= nil then

            local nsender = tonumber(sender)
            local nsource = getUserSource(nsender)

            if nsource ~= nil then
                exports['saltychat']:EstablishCall(source, nsource)
                exports['saltychat']:EstablishCall(nsource, source)
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaltyChatEndCall
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SaltyChatEndCall(CallData)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local sender = getUserByPhone(CallData.TargetData.number)

        if sender ~= nil then

            local nsender = tonumber(sender)
            local nsource = getUserSource(nsender)

            if nsource ~= nil then
                exports['saltychat']:EndCall(source, nsource)
                exports['saltychat']:EndCall(nsource, source)
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMissedCalls
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetMissedCalls()
    local source  = source
    local user_id = getUserId(source)
    local calls = {}

    if user_id ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then
            local result  = exports.oxmysql:executeSync("SELECT CA.*, CT.display FROM evo_phone_calls AS CA LEFT JOIN evo_phone_contacts AS CT ON CT.number = CA.number WHERE CA.phone = @phone AND CT.user_id = @user_id",{
                ['@phone']   = identity.phone,
                ['@user_id'] = user_id
            })

            if result[1] ~= nil then
                calls = result
            end

            return calls

        else
            return calls
        end
    else
        return calls
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserProfileTwitter
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserProfileTwitter()
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then
         local account = DB.query(GetCurrentResourceName().."/twitter_account",{ user_id = tonumber(user_id) })
        return account[1]
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAccountTwitter
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddAccountTwitter(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.name ~= nil and data.username ~= nil and data.password ~= nil then

        local check = DB.query(GetCurrentResourceName().."/twitter_account",{ user_id = tonumber(user_id) })

        if check[1] == nil then
            exports.oxmysql:insert("INSERT INTO evo_phone_accounts (`app`, `id`, `name`, `username`, `password`, `avatar`) VALUES('twitter', @user_id, @name, @username, @password, @avatar);",{
                ['@user_id']  = user_id,
                ['@name']     = data.name,
                ['@username'] = data.username,
                ['@password'] = data.password,
                ['@avatar']   = "default.png"
            })
            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditProfileTwitter
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditProfileTwitter(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.name..user_id

        exports.oxmysql:execute("UPDATE evo_phone_accounts SET name = @name, avatar = @avatar,description = @description, cover = @cover WHERE username = @username AND app = 'twitter'",{
            ['@name']        = data.name,
            ['@avatar']      = data.avatar,
            ['@description'] = data.description,
            ['@cover']       = data.cover,
            ['@username']    = data.username
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PostNewTweet
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.PostNewTweet(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.image..user_id

        local created = os.date("%Y-%m-%d %H:%I:%S")

        exports.oxmysql:insert("INSERT INTO evo_phone_posts (`app`, `author`, `description`, `hashtags`, `mentions`, `image`, `created`) VALUES('twitter', @username, @message, @hashtags, @mentions, @image, @created);",{
            ['@username'] = data.username,
            ['@message']  = data.message,
            ['@hashtags'] = data.hashtags,
            ['@mentions'] = data.mentions,
            ['@image']    = data.image,
            ['@created']  = created
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetTweets
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetTweets()
    local source  = source
    local user_id = getUserId(source)
    local tweets  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT T.*, A.name, A.avatar FROM evo_phone_posts AS T LEFT JOIN evo_phone_accounts AS A ON A.username = T.author AND A.app = 'twitter' WHERE T.app = 'twitter' ORDER BY T.id DESC",{})

        if result[1] ~= nil then
            tweets = result
        end

        return tweets
    else
        return tweets
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetSelfTweets
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetSelfTweets(data)
    local source  = source
    local user_id = getUserId(source)
    local tweets  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT T.*, A.name, A.avatar FROM evo_phone_posts AS T LEFT JOIN evo_phone_accounts AS A ON A.username = T.author AND A.app = 'twitter' WHERE T.author = @username AND T.app = 'twitter' ORDER BY id DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            tweets = result
        end

        return tweets
    else
        return tweets
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetHashtags
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetHashtags()
    local source   = source
    local user_id  = getUserId(source)
    local hashtags = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT hashtags FROM evo_phone_posts WHERE app = 'twitter' ORDER BY id DESC",{})

        if result[1] ~= nil then
            for k, v in pairs(result) do
                local hashtagsr = v.hashtags:split("#")
                for i = 1 , #hashtagsr do

                    local hashtag = hashtagsr[i]:gsub("%,", "")

                    table.insert(hashtags, hashtag)
                end
            end
        end

        return hashtags
    else
        return hashtags
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMentionedTweets
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetMentionedTweets(data)
    local source   = source
    local user_id  = getUserId(source)
    local mentions = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT T.*, A.name, A.avatar FROM evo_phone_posts AS T LEFT JOIN evo_phone_accounts AS A ON A.username = T.author WHERE T.mentions LIKE @mentioned ORDER BY T.id DESC",{
            ['@mentioned'] = string.lower('%'..data.username..'%')
        })

        if result[1] ~= nil then
            mentions = result
        end

        return mentions
    else
        return mentions
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMessages
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetMessages(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then

            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages_app AS M WHERE M.phone = @phone OR M.number = @phone GROUP BY phone ORDER BY created DESC",{ ['@phone'] = identity.phone })
            if result[1] ~= nil then

                for k, v in pairs(result) do
                    local datan = {
                        phone = v.phone,
                        number = v.number,
                        owner = v.owner,
                        message = v.message,
                        type = v.type,
                        read = v.read,
                        created = v.created,
                        contact = _("unknown")
                    }

                    if v.phone == identity.phone then
                        local contact = exports.oxmysql:executeSync("SELECT * FROM evo_phone_contacts WHERE number = @number AND user_id = @user_id",{
                            ['@number'] = v.number,
                            ['@user_id'] = user_id
                        })

                        if contact[1] ~= nil then
                            datan.contact = contact[1].display
                        else
                            datan.contact = v.number
                        end
                    else
                        local contact = exports.oxmysql:executeSync("SELECT * FROM evo_phone_contacts WHERE number = @number AND user_id = @user_id",{
                            ['@number'] = v.phone,
                            ['@user_id'] = user_id
                        })

                        if contact[1] ~= nil then
                            datan.contact = contact[1].display
                        else
                            datan.contact = v.phone
                        end
                    end

                    table.insert(messages, datan)
                end
            end

            return messages

        else
            return messages
        end
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMessagesChat
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetMessagesChat(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then

            if data.type == 'phone' then
                local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages_app WHERE phone = @phone AND number = @number ORDER BY id ASC",{
                    ['@phone'] = identity.phone,
                    ['@number'] = data.phone,
                })
                if result[1] ~= nil then
                    messages = result
                end
            elseif data.type == 'number' then
                local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages_app WHERE phone = @phone AND number = @number ORDER BY id ASC",{
                    ['@phone'] = data.phone,
                    ['@number'] = identity.phone,
                })
                if result[1] ~= nil then
                    messages = result
                end
            end

            return messages

        else
            return messages
        end
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendNewMessage
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.SendNewMessage(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.phone ~= nil and data.number ~= nil and data.message ~= nil and data.type ~= nil then

        local identity = getUserIdentity(user_id)

        if identity ~= nil then
            local created = os.date("%Y-%m-%d %H:%I:%S")

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = identity.phone..data.phone..user_id

            exports.oxmysql:insert("INSERT INTO evo_phone_messages_app (`phone`, `number`, `owner`, `message`, `type`, `read`, `created`) VALUES(@phone, @number, @owner, @message, @type, @read, @created);",{
                ['@phone']   = data.phone,
                ['@number']  = data.number,
                ['@owner']   = identity.phone,
                ['@message'] = data.message,
                ['@type']    = data.type,
                ['@read']    = 0,
                ['@created'] = created
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESSED OPEN PHONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("verificarinsta",function(source, args, rawCommand)
    local source  = source
    local user_id = getUserId(source)
 if user_id then
         if getHasPermission(user_id,Config.Permission) then
                 if args[1] and args[2] then
                local account = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(args[1]) })

                if account[1] ~= nil then
                    exports.oxmysql:execute("UPDATE evo_phone_accounts SET verify = @verify WHERE id = @user_id AND app = 'instagram'",{
                        ['@verify']  = args[2],
                        ['@user_id'] = args[1]
                    })

                    TriggerClientEvent("Notify",source, "sucesso",_("acc_success_changed"),8000)
                else
                    TriggerClientEvent("Notify",source, "negado",_("no_search_account"),8000)
                end
                 end
         end
 end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendHelp
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.SendHelp(data)
    local source   = source
    local answered = false
    local user_id  = getUserId(source)

 if user_id then

         local x, y, z = nil
         local players = {}
         local blips   = {}
         local idgens  = Tools.newIDGenerator()

        if data.message == nil and data.app == nil then
            TriggerClientEvent("Notify",source,"negado",_("enter_a_message"), 5000)
        end

        local app    = Config.HelpList[data.app]
        local groups = app.groups
        local staff  = app.staff
        local adm    = ""

         if staff then
                 adm = "[STAFF] "
         end

         playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")

         local identitys = getUserIdentity(user_id)
         TriggerClientEvent("Notify",source,"sucesso",_("call_sent_success"), 5000)

        for k, v in pairs(groups) do
            x,y,z   = getUserPosition(source)
            players = getUsersByPermission(groups[k])
            for l,w in pairs(players) do
                local player,nuser_id = treatUsersByPermission(w)
                if player and player ~= source then

                    if cache[user_id] ~= nil then
                        if count[user_id] ~= nil then
                            count[user_id] = count[user_id] + 1
                        else
                            count[user_id] = 1
                        end

                        if count[user_id] >= 10 then
                            expulseUser(user_id,_("kick_flood"))
                        end
                        return false
                    end

                    cache[user_id] = data.app..user_id

                    async(function()
                        playSound(player,"Out_Of_Area","DLC_Lowrider_Relay_Race_Sounds")
                        local ok = false
                        local nameuser = getUserFullName(player)
                        TriggerClientEvent('chatMessage',player,_U("call"),{19,197,43},_("send_call_from", adm, nameuser, user_id, data.message))
                        ok = requestAcceptorNot(player,_("call_accept", nameuser),30)
                        if ok then
                            if not answered then
                                answered = true
                                local identity = getUserIdentity(nuser_id)

                                sendnotify(source,"importante",_("call_answered", nameuser), 8000)

                                playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
                                vRPclient._setGPS(player,x,y)
                                sendnotifypush(player,_("call"),data.message,x,y,z,nameuser,identitys.phone)
                            else
                                sendnotify(player,"importante",_("call_already_answered"), 8000)
                                playSound(player,"CHECKPOINT_MISSED","HUD_MINI_GAME_SOUNDSET")
                            end
                        end
                        createBlipTimeout(player,idgens,x,y,z,_("call"),300000)
                    end)

                    SetTimeout(20000, function()
                        cache[user_id] = nil
                        count[user_id] = 0
                    end)
                end
            end
        end
 end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserProfileDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserProfileDarkweb()
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        local account = DB.query(GetCurrentResourceName().."/darkweb_account", { user_id = user_id })
        return account[1]
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAccountDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddAccountDarkweb(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil and data.username ~= nil and data.password ~= nil then

        local check = DB.query(GetCurrentResourceName().."/darkweb_account", { user_id = user_id })

        local avatar = "default.png"

        if data.avatar ~= nil then
            avatar = data.avatar
        end

        if check[1] == nil then

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = data.username..data.password..user_id

            exports.oxmysql:insert("INSERT INTO evo_phone_accounts (`app`, `id`, `name`, `username`, `password`, `avatar`) VALUES('darkweb', @user_id, name, @username, @password, @avatar);",{
                ['@user_id']  = user_id,
                ['@name']     = data.username,
                ['@username'] = data.username,
                ['@password'] = data.password,
                ['@avatar']   = avatar
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditAccountDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditAccountDarkweb(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/darkweb_account", { user_id = user_id })
        if account[1] ~= nil then

            if cache[user_id] ~= nil then
                if count[user_id] ~= nil then
                    count[user_id] = count[user_id] + 1
                else
                    count[user_id] = 1
                end

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = data.username..data.password..user_id

            exports.oxmysql:execute("UPDATE evo_phone_accounts SET username = @username, avatar = @avatar, password = @password WHERE id = @user_id AND app = 'darkweb'",{
                ['@username'] = data.username,
                ['@avatar']   = data.avatar,
                ['@password'] = data.password,
                ['@user_id']  = user_id
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true

        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateLayerDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.CreateLayerDarkweb(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            coun[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.name..user_id

        local created = os.date("%Y-%m-%d %H:%I:%S")

        local charset = {}  do -- [0-9a-zA-Z]
            for c = 48, 57  do table.insert(charset, string.char(c)) end
            for c = 65, 90  do table.insert(charset, string.char(c)) end
            for c = 97, 122 do table.insert(charset, string.char(c)) end
        end

        local function randomString(length)
            if not length or length <= 0 then return '' end
            math.randomseed(os.clock())
            local random = tonumber(os.clock())
            return randomString(length - 1) .. charset[math.random(1, #charset)]
        end

        local image = "default.png"

        if data.image ~= "" then
            image = data.image
        end

        local number = os.date("%m%Y%m%d%H%I%S")..""..randomString(30)

        exports.oxmysql:insert("INSERT INTO evo_phone_chats (`app`, `author`, `number`, `name`, `image`, `password`, `created`) VALUES('darkweb', @username, @number, @name, @image, @password, @created);",{
            ['@username'] = data.username,
            ['@number']   = number,
            ['@name']     = data.name,
            ['@image']    = image,
            ['@password'] = data.password,
            ['@created']  = created
        })

        exports.oxmysql:insert("INSERT INTO evo_phone_chats_users (`app`, `number`, `admin`, `author`) VALUES('darkweb', @number_group, @admin, @username);",{
            ['@number_group'] = number,
            ['@admin']        = 1,
            ['@username']     = data.username
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetDarkwebLayers
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetDarkwebLayers(data)
    local source  = source
    local user_id = getUserId(source)
    local layers  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT L.number, L.name, L.image, L.author, (SELECT message FROM evo_phone_messages WHERE id_chat = L.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = L.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = L.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = L.id ORDER BY id DESC LIMIT 1) AS id_message, U.admin FROM evo_phone_chats AS L LEFT JOIN evo_phone_chats_users AS U ON U.number = L.number WHERE U.author = @username AND L.app = 'darkweb' AND U.app = 'darkweb' GROUP BY L.id ORDER BY id_message DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            layers = result
        end

        return layers
    else
        return layers
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetLayerImage
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetLayerImage(number)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then
        if number ~= nil then
            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @number AND app = 'darkweb'",{
                ['@number'] = number
            })

            if result[1] ~= nil then
                return result[1].image
            else
                return nil
            end

        else
            return nil
        end
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetDarkwebLayerMessages
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetDarkwebLayerMessages(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @number AND app = 'darkweb'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            local getmessages  = exports.oxmysql:executeSync("SELECT M.*, A.username FROM evo_phone_messages AS M LEFT JOIN evo_phone_accounts AS A ON A.username = M.owner WHERE M.id_chat = @id_layer ORDER BY M.id ASC",{
                ['@id_layer'] = result[1].id
            })

            if getmessages[1] ~= nil then
                messages = getmessages
            end
        end

        return messages
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendMessageLayer
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SendMessageLayer(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.username..data.type..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @number AND app = 'darkweb'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            local created = os.date("%Y-%m-%d %H:%I:%S")

            exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_layer, @owner, @type, @message, @created, @read);",{
                ['@id_layer'] = result[1].id,
                ['@owner']    = data.username,
                ['@type']     = data.type,
                ['@message']  = data.message,
                ['@created']  = created,
                ['@read']     = 0,
            })

            local members = exports.oxmysql:executeSync("SELECT A.id, A.username FROM evo_phone_chats_users AS L INNER JOIN evo_phone_accounts AS A ON A.username = L.author AND A.app = 'darkweb' WHERE L.number = @number_layer AND L.app = 'darkweb'",{
                ['@number_layer'] = data.number
            })

            if members[1] ~= nil then
                for k, v in pairs(members) do
                    local nuser_id = v.id
                    local nsource  = getUserSource(nuser_id)
                    local message  = nil

                    if data.type == 'audio' then
                        message = _("audio_message")
                    elseif data.type == 'location' then
                        message = _("location")
                    else
                        message = data.message
                    end

                    local title = _("layer")..": "..result[1].name

                    local datanotify = {
                        title   = title,
                        message = message,
                        icon    = "tor",
                        timeout = 5000,
                        color   = "green",
                    }

                    if nsource ~= nil then
                        TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                        Citizen.Wait(100)
                        TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshLayerDarkweb")
                    end
                end
            end

            Citizen.Wait(100)
            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshLayerDarkweb")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetDarkwebLayersPublic
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetDarkwebLayersPublic(data)
    local source  = source
    local user_id = getUserId(source)
    local layers  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT L.* FROM evo_phone_chats AS L WHERE NOT EXISTS (SELECT * FROM evo_phone_chats_users AS U WHERE U.number = L.number AND U.author = @username AND U.app = 'darkweb') AND L.app = 'darkweb' GROUP BY L.id ORDER BY L.id DESC",{
            ['@username'] = data.username
        })

        if result[1] ~= nil then
            layers = result
        end

        return layers
    else
        return layers
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AcessLayerDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AcessLayerDarkweb(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.number ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        local resultlayer = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE number = @number AND app = 'darkweb'",{
            ['@number'] = data.number
        })

        if resultlayer[1].password ~= nil then
            if data.password == nil then
                local datanotify = {
                    title   = "Error TOR",
                    message = _("enter_layer_password"),
                    icon    = "tor",
                    timeout = 5000,
                    color   = "red",
                }

                if source ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                    Citizen.Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshLayerDarkweb")
                end

                return false
            end

            if resultlayer[1].password ~= data.password then
                local datanotify = {
                    title   = "Error TOR",
                    message = _("invalid_layer_password"),
                    icon    = "tor",
                    timeout = 5000,
                    color   = "red",
                }

                if source ~= nil then
                    TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
                    Citizen.Wait(100)
                    TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshLayerDarkweb")
                end

                return false
            end
        end

        cache[user_id] = data.username..data.number..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats_users WHERE number = @number AND author = @username AND app = 'darkweb'",{
            ['@number']   = data.number,
            ['@username'] = data.username
        })

        if result[1] == nil then
            exports.oxmysql:insert("INSERT INTO evo_phone_chats_users (`app`, `number`, `admin`, `author`) VALUES('darkweb', @number_layer, @admin, @username);",{
                ['@number_layer'] = data.number,
                ['@admin']        = 0,
                ['@username']     = data.username
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteLayerDarkweb
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeleteLayerDarkweb(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.number..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE `number` = @number AND app = 'darkweb'",{
            ['@number'] = data.number
        })

        if result[1] ~= nil then

            exports.oxmysql:execute("DELETE FROM evo_phone_messages WHERE id_chat = @id_group",{
                ['@id_group'] = result[1].id
            })

            exports.oxmysql:execute("DELETE FROM evo_phone_chats WHERE number = @number AND app = 'darkweb'",{
                ['@number'] = data.number
            })

            exports.oxmysql:execute("DELETE FROM evo_phone_chats_users WHERE number = @number AND app = 'darkweb'",{
                ['@number'] = data.number
            })

            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshLayerDarkweb")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        end

        return false
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUserProfileTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUserProfileTinder()
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then
         local account = DB.query(GetCurrentResourceName().."/tinder_account",{ user_id = tonumber(user_id) })
        return account[1]
    else
        return nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAccountTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddAccountTinder(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.name ~= nil and data.password ~= nil and data.birthdate ~= nil then

        local check = DB.query(GetCurrentResourceName().."/tinder_account",{ user_id = tonumber(user_id) })

        if check[1] == nil then

            local image = "default.png"

            if data.image ~= "" then
                image = data.image
            end

            exports.oxmysql:insert("INSERT INTO evo_phone_accounts (`app`, `id`, `name`, `password`, `birthdate`, `gender`, `interested`, `avatar`) VALUES('tinder', @user_id, @name, @password, @birthdate, @gender, @interested, @avatar);",{
                ['@user_id']    = user_id,
                ['@name']       = data.name,
                ['@password']   = data.password,
                ['@birthdate']  = data.birthdate,
                ['@gender']     = data.gender,
                ['@interested'] = data.interested,
                ['@avatar']     = image
            })
            return true
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetUsersTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetUsersTinder(data)
    local source      = source
    local user_id     = getUserId(source)
    local userstinder = {}

    if user_id ~= nil and data.interested ~= nil then
        if data.interested == "MULHER" or data.interested == "HOMEM" then
            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts AS A WHERE NOT EXISTS (SELECT * FROM evo_phone_tinder_likes WHERE id_user = @id_user AND id_liked = A.id) AND A.id != @user_id AND A.gender = @interested AND A.app = 'tinder' ORDER BY RAND() LIMIT 50",{
                ['@id_user']    = user_id,
                ['@user_id']    = user_id,
                ['@interested'] = data.interested
            })

            if result[1] ~= nil then
                userstinder = result
            end
        else
            local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_accounts AS A WHERE NOT EXISTS (SELECT * FROM evo_phone_tinder_likes WHERE id_user = @id_user AND id_liked = A.id) AND A.id != @user_id AND A.app = 'tinder' ORDER BY RAND() LIMIT 50",{
                ['@id_user'] = user_id,
                ['@user_id'] = user_id,
            })

            if result[1] ~= nil then
                userstinder = result
            end
        end

        return userstinder
    else
        return userstinder
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LikeUserTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.LikeUserTinder(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.id..user_id

        local created = os.date("%Y-%m-%d %H:%I:%S")

        exports.oxmysql:insert("INSERT INTO evo_phone_tinder_likes (`id_user`, `id_liked`, `created`) VALUES(@id_user, @id_liked, @created);",{
            ['@id_user']  = user_id,
            ['@id_liked'] = data.id,
            ['@created']  = created
        })

        local check = exports.oxmysql:executeSync("SELECT * FROM evo_phone_tinder_likes AS L WHERE L.id_user = @id_user AND L.id_liked = @id_liked LIMIT 1",{
            ['@id_user']  = data.id,
            ['@id_liked'] = user_id
        })

        if check[1] ~= nil then

            local created = os.date("%Y-%m-%d %H:%I:%S")

            exports.oxmysql:insert("INSERT INTO evo_phone_chats (`app`, `author`, `number`, `created`) VALUES('tinder', @user_id, @user_from, @created);",{
                ['@user_id']   = user_id,
                ['@user_from'] = data.id,
                ['@created']   = created
            })

            local nuser_id = tonumber(data.id)
            local nsource = getUserSource(nuser_id)

            local datanotify = {
                title   = "Tinder",
                message = _("new_match", data.namefrom),
                icon    = "tinder",
                timeout = 5000,
                color   = "green",
            }

            if nsource ~= nil then
                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
            end

            local datanotify = {
                title   = "Tinder",
                message = _("new_match", data.nameto),
                icon    = "tinder",
                timeout = 5000,
                color   = "green",
            }
            TriggerClientEvent(GetCurrentResourceName()..":SendNotification", source, datanotify)
        end

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetTinderChats
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetTinderChats(data)
    local source   = source
    local user_id  = getUserId(source)
    local chats  = {}

    if user_id ~= nil then

        local result  = exports.oxmysql:executeSync("SELECT C.id, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message, A.name, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.id = C.number WHERE C.author = @user_id AND C.app = 'tinder' AND A.app = 'tinder' GROUP BY C.id ORDER BY id_message DESC",{
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        local result  = exports.oxmysql:executeSync("SELECT C.id, (SELECT message FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS message, (SELECT created FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS created, (SELECT `read` FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS `read`, (SELECT id FROM evo_phone_messages WHERE id_chat = C.id ORDER BY id DESC LIMIT 1) AS id_message, A.name, A.avatar FROM evo_phone_chats AS C LEFT JOIN evo_phone_accounts AS A ON A.id = C.author WHERE C.number = @user_id AND C.app = 'tinder' AND A.app = 'tinder' GROUP BY C.id ORDER BY id_message DESC",{
            ['@user_id'] = user_id
        })

        if result[1] ~= nil then
            for k, v in pairs(result) do
                table.insert(chats, result[k])
            end
        end

        return chats
    else
        return chats
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetTinderChat
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.GetTinderChat(data)
    local source   = source
    local user_id  = getUserId(source)
    local messages = {}

    if user_id ~= nil then

        local getmessages  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_messages WHERE id_chat = @id_chat ORDER BY id ASC",{
            ['@id_chat'] = data.id
        })

        if getmessages[1] ~= nil then
            messages = getmessages
        end

        return messages
    else
        return messages
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendMessageTinder
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.SendMessageTinder(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            if count[user_id] ~= nil then
                count[user_id] = count[user_id] + 1
            else
                count[user_id] = 1
            end

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.id..data.type..user_id

        local result  = exports.oxmysql:executeSync("SELECT * FROM evo_phone_chats WHERE id = @id AND app = 'tinder'",{
            ['@id'] = data.id
        })

        if result[1] ~= nil then

            local created = os.date("%Y-%m-%d %H:%I:%S")

            exports.oxmysql:insert("INSERT INTO evo_phone_messages (`id_chat`, `owner`, `type`, `message`, `created`, `read`) VALUES(@id_chat, @owner, @type, @message, @created, @read);",{
                ['@id_chat'] = result[1].id,
                ['@owner']   = user_id,
                ['@type']    = data.type,
                ['@message'] = data.message,
                ['@created'] = created,
                ['@read']    = 0,
            })

            local nuser_id = 0

            if result[1].user_id == user_id then
                nuser_id = result[1].user_from
            else
                nuser_id = result[1].user_id
            end

            local nsource = getUserSource(nuser_id)
            local message = nil

            if data.type == 'audio' then
                message = _("audio_message")
            elseif data.type == 'location' then
                message = _("location")
            else
                message = data.message
            end

            local datanotify = {
                title   = "Tinder",
                message = _("new_message", message),
                icon    = "tinder",
                timeout = 5000,
                color   = "green",
            }

            if nsource ~= nil then
                TriggerClientEvent(GetCurrentResourceName()..":SendNotification", nsource, datanotify)
                Wait(100)
                TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", nsource, "RefreshChatTinder")
            end

            Wait(100)
            TriggerClientEvent(GetCurrentResourceName()..":SendNUIMessage", source, "RefreshChatTinder")

            cache[user_id] = nil
            count[user_id] = 0

            return true
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetProfileTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetProfileTinder(nuser_id)
    local source  = source
    local user_id = getUserId(source)
    local profile = {
        posts   = {},
        account = {}
    }

    if nuser_id ~= nil then

        local account = DB.query(GetCurrentResourceName().."/tinder_account",{ user_id = tonumber(nuser_id) })
        local accountinsta = DB.query(GetCurrentResourceName().."/insta_account",{ user_id = tonumber(nuser_id) })

        if account[1] ~= nil then
            if accountinsta[1] ~= nil then
                local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts WHERE author = @username AND app = 'instagram' ORDER BY created DESC LIMIT 8",{
                    ['@username'] = accountinsta[1].username
                })

                if result ~= nil then
                    profile.posts = result
                end
            end

            profile.account = account[1]

            return profile

        else
            return profile
        end
    else
        return profile
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditAvatarTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditAvatarTinder(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.avatar..user_id

        exports.oxmysql:execute("UPDATE evo_phone_accounts SET avatar = @avatar WHERE id = @user_id AND app = 'tinder'",{
            ['@avatar']  = data.avatar,
            ['@user_id'] = user_id
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditProfileTinder
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.EditProfileTinder(data)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.name..user_id

        exports.oxmysql:execute("UPDATE evo_phone_accounts SET name = @name, birthdate = @birthdate, gender = @gender, interested = @interested, description = @description, passions = @passions WHERE id = @user_id AND app = 'tinder'",{
            ['@name']        = data.name,
            ['@birthdate']   = data.birthdate,
            ['@gender']      = data.gender,
            ['@interested']  = data.interested,
            ['@description'] = data.description,
            ['@passions']    = data.passions,
            ['@user_id']     = user_id
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostsOlx
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostsOlx(data)
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'olx' ORDER BY P.id DESC LIMIT 15")

        if result ~= nil then
            posts = result
            return posts
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddPostOlx
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddPostOlx(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.title ~= nil and data.description ~= nil and data.image ~= nil and data.price ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.title..user_id

        local created = os.date("%Y-%m-%d %H:%I:%S")

        exports.oxmysql:insert("INSERT INTO evo_phone_posts (`app`, `author`, `title`, `image`, `description`, `price`, `created`) VALUES('olx', @user_id, @title, @image, @description, @price, @created);",{
            ['@user_id']     = user_id,
            ['@title']       = data.title,
            ['@image']       = data.image,
            ['@description'] = data.description,
            ['@price']       = data.price,
            ['@created']     = created
        })

        cache[user_id] = nil
        count[user_id] = 0

        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostOlx
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostOlx(data)
    local source   = source
    local user_id  = getUserId(source)
    local datapost = {
        post = nil,
        user = nil
    }

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.id..user_id

        local user = {
                 name  = nil,
                 phone = nil
         }

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'olx' AND P.id = @id", {
            ['@id'] = data.id
        })

        if result[1] ~= nil then
            datapost.post = result[1]

            local identity = getUserIdentity(tonumber(result[1].author))
            user.name = getUserFullName(tonumber(result[1].author))
            user.phone = identity.phone
        end

        datapost.user = user

        cache[user_id] = nil
        count[user_id] = 0

        return datapost
    else
        return datapost
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SearchPostsOlx
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.SearchPostsOlx(data)
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        if data.search ~= nil then
            local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'olx' AND P.title LIKE '%"..data.search.."%' ORDER BY P.id DESC LIMIT 15")

            if result ~= nil then
                posts = result
                return posts
            else
                return posts
            end
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeletePostOlx
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeletePostOlx(data)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        exports.oxmysql:execute("DELETE FROM evo_phone_posts WHERE author = @user_id AND id = @id AND app = 'olx'",{
            ['@user_id'] = user_id,
            ['@id']      = data.id
        })
        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SaveImageGallery
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent(GetCurrentResourceName()..':SaveImageGallery')
AddEventHandler(GetCurrentResourceName()..':SaveImageGallery', function(url)
    local source  = source
    local user_id = getUserId(source)

    if user_id ~= nil and url ~= nil then
        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        local created = os.date("%Y-%m-%d %H:%I:%S")

        exports.oxmysql:insert("INSERT INTO evo_phone_posts (`app`, `author`, `image`, `created`) VALUES('gallery', @user_id, @image, @created);",{
            ['@user_id'] = user_id,
            ['@image']   = url,
            ['@created'] = created
        })

        cache[user_id] = nil
        count[user_id] = 0
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostsGallery
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostsGallery(data)
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'gallery' AND P.author = @user_id ORDER BY P.id DESC LIMIT 100",{
            ['@user_id'] = user_id
        })

        if result ~= nil then
            posts = result
            return posts
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeletePostGallery
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeletePostGallery(data)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        exports.oxmysql:execute("DELETE FROM evo_phone_posts WHERE author = @user_id AND id = @id AND app = 'gallery'",{
            ['@user_id'] = user_id,
            ['@id']      = data.id
        })
        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostsNews
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostsNews(data)
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'news' ORDER BY P.id DESC LIMIT 15")

        if result ~= nil then
            posts = result
            return posts
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostsNewsFull
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostsNewsFull()
    local source   = source
    local user_id  = getUserId(source)
    local posts    = {}

    if user_id ~= nil then

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'news' ORDER BY P.id DESC", {})

        if result ~= nil then
            posts = result
            return posts
        else
            return posts
        end
    else
        return posts
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddPostNews
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.AddPostNews(data)
    local source   = source
    local user_id  = getUserId(source)

    if user_id ~= nil and data.title ~= nil and data.description ~= nil and data.image ~= nil then

        local check = false
        local permissions = Config.NewsPermission

        for k, v in pairs(permissions) do
            if getHasPermission(user_id,v) then
                check = true
            end
        end

        if check then
            if cache[user_id] ~= nil then
                count[user_id] = count[user_id] + 1

                if count[user_id] >= 10 then
                    expulseUser(user_id,_("kick_flood"))
                end
                return false
            end

            cache[user_id] = data.title..user_id

            local created = os.date("%Y-%m-%d %H:%I:%S")

            exports.oxmysql:insert("INSERT INTO evo_phone_posts (`app`, `author`, `title`, `image`, `description`, `created`) VALUES('news', @user_id, @title, @image, @description, @created);",{
                ['@user_id']     = user_id,
                ['@title']       = data.title,
                ['@image']       = data.image,
                ['@description'] = data.description,
                ['@created']     = created
            })

            cache[user_id] = nil
            count[user_id] = 0

            return true
        else
            TriggerClientEvent("Notify",source, "negado",_("not_have_permission"),8000)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetPostNews
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.GetPostNews(data)
    local source   = source
    local user_id  = getUserId(source)
    local datapost = {
        post = nil,
        user = nil
    }

    if user_id ~= nil then

        if cache[user_id] ~= nil then
            count[user_id] = count[user_id] + 1

            if count[user_id] >= 10 then
                expulseUser(user_id,_("kick_flood"))
            end
            return false
        end

        cache[user_id] = data.id..user_id

        local user = {
                 name  = nil,
                 phone = nil
         }

        local result = exports.oxmysql:executeSync("SELECT * FROM evo_phone_posts AS P WHERE P.app = 'news' AND P.id = @id", {
            ['@id'] = data.id
        })

        if result[1] ~= nil then
            datapost.post = result[1]

            local identity = getUserIdentity(tonumber(result[1].author))
            user.name = getUserFullName(tonumber(result[1].author))
            user.phone = identity.phone
        end

        datapost.user = user

        cache[user_id] = nil
        count[user_id] = 0

        return datapost
    else
        return datapost
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EditPostNews
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.EditPostNews(data)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil and data.title ~= nil and data.description ~= nil and data.image ~= nil and data.id ~= nil then
        local check = false
        local permissions = Config.NewsPermission

        for k, v in pairs(permissions) do
            if getHasPermission(user_id,v) then
                check = true
            end
        end
        if check then

            exports.oxmysql:execute("UPDATE evo_phone_posts SET title = @title, description = @description, image = @image WHERE id = @id AND app = 'news'",{
                ['@title']       = data.title,
                ['@description'] = data.description,
                ['@image']       = data.image,
                ['@id']          = data.id
            })

            return true
        else
            TriggerClientEvent("Notify",source, "negado",_("not_have_permission"),8000)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeletePostNews
-----------------------------------------------------------------------------------------------------------------------------------------

function psRP.DeletePostNews(data)
 local source  = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        local check = false
        local permissions = Config.NewsPermission

        for k, v in pairs(permissions) do
            if getHasPermission(user_id,v) then
                check = true
            end
        end
        if check then
            exports.oxmysql:execute("DELETE FROM evo_phone_posts WHERE id = @id AND app = 'news'",{
                ['@id'] = data.id
            })
            return true
        else
            TriggerClientEvent("Notify",source, "negado",_("not_have_permission"),8000)
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CheckHandcuffed
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.CheckHandcuffed()
    local source = source
 local user_id = getUserId(source)
    if user_id ~= nil then
        return checkPlayerHandcuffed(source)
    else
        return false
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- checkPermissionNews
-----------------------------------------------------------------------------------------------------------------------------------------
function psRP.checkPermissionNews()
    local source  = source
    local user_id = getUserId(source)

    if user_id then
        local permissions = Config.NewsPermission

        for k, v in pairs(permissions) do
            if getHasPermission(user_id,v) then
                return true
            end
        end
    else
        TriggerClientEvent("Notify",source, "negado",_("not_have_permission"),8000)
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- string:split
-----------------------------------------------------------------------------------------------------------------------------------------
function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStop
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
         TriggerClientEvent(GetCurrentResourceName()..":ClosePhone", source)
         print('[' .. GetCurrentResourceName() .. '] Parado - www.evolutionfivem.com')
    end
end)