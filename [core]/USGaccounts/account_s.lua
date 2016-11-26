function initLoginScreenForPlayer(player)
    -- show blur screen or w/e
    fadeCamera(player,true,2.0,0,0,0)
    showChat(source,false)
    triggerClientEvent(player,"USGaccounts.showLogin",player)
end

addEvent("checkForBan",true)
addEventHandler("checkForBan",root,
function()
    local serialBan = exports.USGbans:getSerialBan(getPlayerSerial(client))
    if (serialBan) then
        setElementData(client,"occupation","Banned")
        triggerClientEvent(client,"returnPlayerIsBanned",source,serialBan)
    elseif not ( isPlayerLoggedIn(source) ) then
        initLoginScreenForPlayer(source)
    end
end)

local LATEST_VERSION = 0

addEvent("onPlayerAttemptLogin",true)
addEventHandler("onPlayerAttemptLogin",root,
    function (username, password)
        if(username and password) then
            local username = username:lower()
            local player = getPlayerFromAccount(username)
            if(player) then
                triggerClientEvent(source,"showStatusNotice",source,
                    "This account is in use by "..getPlayerName(player),
                    255,0,0)
                return false
            end     
            local accountBan = exports.USGbans:getAccountBan(username)
            if(accountBan) then
                triggerClientEvent(source,"showStatusNotice",source,
                    "This account is banned until "..exports.USG:getDateTimeString(accountBan.endtimestamp).."\nReason: "..accountBan.reason,
                    255,0,0)
                return false
            end
            local q = query(attemptLoginCallback,{source,username, password},"SELECT password,playtime,version FROM accounts WHERE username=?",username)
            if(not q) then
                triggerClientEvent(source,"showStatusNotice",source,"Database offline, can't login! Try again later.",255,0,0)
            end
        end
    end
)

function attemptLoginCallback(result, player, username, password)
    outputServerLog("USGaccounts - attemptLoginCallback")
    if(not result or not result[1]) then
        outputServerLog("USGaccounts - no result")
        triggerClientEvent(player,"showStatusNotice",player,username.." doesn't exist! register it to use the username.",255,0,0)
        return false
    end

    local account = result[1]
    outputServerLog("USGaccounts - calculating hash with version "..account.version)
    local verified = verifyPassword(username, password, account.password, account.version)
    outputServerLog("USGaccounts - comparing")

    if(verified or account.version == 2) then -- log in
        if(false and account.version ~= LATEST_VERSION) then
            local newPass = hash(username, password, LATEST_VERSION)
            exports.MySQL:execute("UPDATE accounts SET password=?,version=? WHERE username=?",newPass,LATEST_VERSION,username)
        end
        if(account.version == 2) then
            local newPass = hash(username,password,0)
            exports.MySQL:execute("UPDATE accounts SET password=?,version=? WHERE username=?",newPass,0,username)
        end
        outputServerLog("USGaccounts - checking for mods")
        if ( not exports.USGanticheat:doesPlayerHaveIllegalMods(source) ) then
            outputServerLog("USGaccounts - no mods, logging in")
            loginPlayer(username, player, account.playtime)
        else
            outputServerLog("USGaccounts - has mods, sending info to client")
             triggerClientEvent(player, "USGaccounts.onShowModInfo",player,exports.USGanticheat:getPlayerAntiModInfo(player))
        end
    else
        outputServerLog("USGaccounts - pass incorrect")
        triggerClientEvent(player,"showStatusNotice",player,"Password is incorrect! please try again!",255,0,0)
        return false
    end
end

function loginPlayer(username, player, playtime)
    if(not username) then return false end
    setElementData(player,"account",username)
    setElementData(player,"loginTick",getRealTime().timestamp)
    if(playtime) then
        setElementData(player,"playTime", playtime)
    end
    triggerClientEvent(player,"USGaccounts.closeLogin",player)
    fadeCamera(player,false,1)
    triggerEvent("onServerPlayerLogin",player)
    triggerClientEvent("onServerPlayerLogin",player)
    exports.mysql:execute("INSERT INTO logins ( loginaccount,loginserial,loginnick,logindate,loginip ) VALUES (?,?,?,NOW(),?)",
        username, getPlayerSerial(player), getPlayerName(player), getPlayerIP(player))  
end

addEvent("USGaccounts.onRegister",true)
addEvent("onPlayerAttemptRegister",true)
addEventHandler("onPlayerAttemptRegister", root, 
    function (username,password,email)
        if(username and password and email) then
            local username = username:lower()
            if(#username > 64) then
                triggerClientEvent(source,"showStatusNotice",source,"Your username is too long ( "..#username.."/64 ).")
                return false
            end
            local q = singleQuery(attemptRegisterExistsCallback,{source,username,password,email},"SELECT username,email FROM accounts WHERE username=? OR email=? LIMIT 1",username, email)
            if(not q) then
                exports.USGmsg:msg(source,"Database offline, can't register! Try again later.", 255,0,0)
                return false
            end
        end
    end
)

function attemptRegisterExistsCallback(result,player,username,password,email)
    outputServerLog("USGaccounts - attemptRegisterExistsCallback")
    if(result) then
        if(result.username == username and result.email == email) then
            triggerClientEvent(player,"showStatusNotice",player,"Username and email are already registered! Try to recover your password.",255,0,0)
        elseif(result.username == username) then
            triggerClientEvent(player,"showStatusNotice",player,username.." is already registered! Please choose another username!",255,0,0)
        elseif(result.email == email) then
            triggerClientEvent(player,"showStatusNotice",player,email.." is already registered! Please choose another email!",255,0,0)
        end
        return false
    end
    local pass = hash(username,password)
    if (exports.mysql:execute("INSERT INTO accounts (username,password,email,registerserial,registerdate,registerIP) VALUES (?,?,?,?,NOW(),?)",
        username:lower(),pass,email,getPlayerSerial(player),getPlayerIP(player))) then
        exports.mysql:execute("INSERT INTO accountsdata (username, staffnotes) VALUES(?,?)",username,"") -- make the data row for this player
        exports.mysql:execute("INSERT INTO accountstats (username) VALUES(?)",username) -- make the stat row for this player
        triggerClientEvent(player,"showStatusNotice",player,"Your account "..username.." was successfully registered!",0,255,0)
        triggerClientEvent(player,"closeTab",player,"register")
        exports.system:log("Account - Register",getPlayerName(player).." has registered account "..username,player)
        loginPlayer(username, player)
    else
        triggerClientEvent(player,"showStatusNotice",player,"An error occured while trying to register "..username..", please contact a administrator.")
        exports.system:logError("USGaccounts","An error occured while trying to register "..username.." for "..getPlayerName(player).."!")
    end
end

addEvent("USGaccounts.requestPassword", true)
addEventHandler("USGaccounts.requestPassword", root, 
    function (username, email)
        if(username and email) then
            username = username:lower()
            singleQuery(requestPasswordCallback, {username, email, client}, "SELECt * FROM accounts WHERE username=? AND email=?",username,email)
        end
    end
)

function requestPasswordCallback(result, username, email, player)
    if(result) then
        local newPassword = generatePassword()
        if(exports.MySQL:execute("UPDATE accounts SET password=? WHERE username=?", hash(username,newPassword), username)) then
            callRemote("usgmta.net/password.php",function () end,username,email,newPassword)
            triggerClientEvent(player,"showStatusNotice",player,"Check your email for your new password ( wait a few minutes and make sure to check the spam folder ).",0,255,0)
        else
            triggerClientEvent(player,"showStatusNotice",player,"Something went wrong trying to change your password, try again later.",255,0,0)
        end
    else
        triggerClientEvent(player,"showStatusNotice",player,"No account found with this username and email!",255,0,0)
    end
end

function verifyPassword(username, password, dbPassword, version)
    if (username and password) then --make sure both are supplied
        if(version == 0) then
            return hash(username,password,version) == dbPassword
        elseif(version == 1) then
            return bcrypt_verify(username.."+"..password, dbPassword)
        end
    else
        return false --unable to hash, due to the username + password being required!
    end
end

function hash(username,password,version)
    if (username and password) then --make sure both are supplied
        if(not version) then version = LATEST_VERSION end
        if(version == 0) then
            local salt = tostring(#username + #password)
            return sha512(username.."-"..password.."-"..salt)
        elseif(version == 1) then
            local salt = bcrypt_salt(50000)
            return bcrypt_digest(username.."+"..password, salt)
        end
    else
        return false --unable to hash, due to the username + password being required!
    end
end

function checkForOldHash(username, password, inputPassword)
    return false
    --[[local passwordV2 = exports.security:stringEncryption(inputPassword, "SHA512")
    local passwordV3 = hash(username, inputPassword)
    if (password == passwordV2) then --Account is using the old hash
        outputDebugString("Account "..username.." has V2 hash, updating to V3 hash...",0,0,255,0)
        exports.mysql:execute("UPDATE accounts SET password=? WHERE username=?",passwordV3,username)
        return true
    else
        --outputDebugString("Account not found / account already has new hash!",0,0,255,0)
        return false --Account not found / Already has new hash.
    end--]]
end

local chars = {"a",'b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'}
function generatePassword()
    local pass = ""
    for i=1, 16 do
        pass = pass..(chars[math.random(#chars)])
    end
    return pass
end