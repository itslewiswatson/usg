fileDelete("account_c.lua")
screenW, screenH = guiGetScreenSize()

local tabGUI = {}
local tabs = {"Login","Register","Retrieve account"}
local buttonsInfo = {}

local buttonsGUI = {}

local scaleX,scaleY = screenW/1440, screenH/900 -- scale based on design resolution ( 1440x900 )
if screenW <= 800 and screenH <= 600 then
    scaleX,scaleY = 1024/1440, 768/900 -- scale based on design resolution ( 1440x900 )
end
    scaleX,scaleY = 1440/1440, 900/900 -- scale based on design resolution ( 1440x900 )

local bgDiscWidth, bgDiscHeight = scaleX*585,scaleY*585
local bgLogoWidth, bgLogoHeight = scaleX*399,scaleY*399

local bgDiscX, bgDiscY = (screenW-bgDiscWidth)/2,(screenH-bgDiscHeight)/2
local bgLogoX, bgLogoY = (screenW-bgLogoWidth)/2,(screenH-bgLogoHeight)/2

local bgDiscRotation = 0

local buttonBarWidth, buttonBarHeight = 600*scaleX,60*scaleY

local buttonBarX, buttonBarY = (screenW-buttonBarWidth)/2,bgLogoY+bgLogoHeight

local tabWidth,tabHeight = buttonBarWidth, 415*scaleY
local tabX,tabY = buttonBarX, buttonBarY-tabHeight

local tabTitleBarHeight = 30*scaleY

local buttonSectionWidth, buttonSectionHeight = buttonBarWidth/#tabs, buttonBarHeight
local buttonWidth, buttonHeight = 0.75*buttonSectionWidth, buttonSectionHeight*0.75

local statusWidth, statusHeight = buttonBarWidth, 45*scaleY
local statusX,statusY = buttonBarX, buttonBarY+buttonBarHeight
local statusFadeOut
local statusFadeStart
local statusFadeDuration = 650
local statusFullDuration = 3500
local statusFullStart
local statusR, statusG, statusB = 255,255,255

local showing = false
local fadingInterface = "in"
local fadeDuration = 500
local fadeStartTick

addEvent("USGaccounts.showLogin",true)
function showLoginScreen()
    if showing then return false end
    showing = true
    showPlayerHudComponent("radar",false)
    showPlayerHudComponent("area_name",false)
    exports.USGblur:setBlurEnabled ()
    fadeStartTick = getTickCount()
    setCameraMatrix(1248.1805419922, -1325.7033691406, 13.154000282288, 1249.1645507813, -1325.6772460938, 13.330354690552, 0, 70)
    --exports.system:showLoadingScreen(true,"Welcome to USG",true) -- show background, skip timeout timer
    addEventHandler("onClientRender",root,onRenderDrawInterface)
    addEventHandler("onClientRender",root,onRenderDrawTabs)
    for i=1,#tabs do
        local buttonX,buttonY = buttonBarX+(buttonSectionWidth*(i-1))+((buttonSectionWidth-buttonWidth)/2),buttonBarY+((buttonSectionHeight-buttonHeight)/2)
        buttonsGUI[i] = guiCreateLabel(buttonX,buttonY,buttonWidth, buttonHeight,"",false)
        addEventHandler("onClientGUIClick",buttonsGUI[i],onClickButton,false)
        buttonsInfo[i] = {x = buttonX, y = buttonY, width = buttonWidth, height = buttonHeight,color = tocolor(0,128,128,220), font = "default"}
    end
    showCursor(true)
end
addEventHandler("USGaccounts.showLogin",root,showLoginScreen)

local discRotationDuration = 9500 -- one full rotation
local discRotationStartTick

function onRenderDrawInterface()
    local discRotProgress = 0
    if not discRotationStartTick or ( getTickCount()-discRotationStartTick > discRotationDuration ) then
        discRotationStartTick = getTickCount()
    else
        discRotProgress = (getTickCount()-discRotationStartTick)/discRotationDuration
    end

    local logoRotation = 0
    if fadingInterface then
        local fadeProgress = (getTickCount()-fadeStartTick)/fadeDuration
        if fadingInterface == "in" then
            bgDiscX = fadeProgress*((screenW-bgDiscWidth)/2)
            bgLogoX = fadeProgress*((screenW-bgLogoWidth)/2)
            logoRotation = (fadeProgress)*360
        elseif fadingInterface == "out" then
            bgDiscX = (1-fadeProgress)*((screenW-bgDiscWidth)/2)
            bgLogoX = (1-fadeProgress)*((screenW-bgLogoWidth)/2)
            logoRotation = (1-fadeProgress)*360
        end
        if fadeProgress >= 1 then
            fadingInterface = false
        end
    else -- make sure it stays centered
        bgDiscX = (screenW-bgDiscWidth)/2
        bgLogoX = (screenW-bgLogoWidth)/2
    end
    dxDrawImage(bgDiscX, bgDiscY,bgDiscWidth, bgDiscHeight,"images\\disc.png",360*discRotProgress)
    dxDrawImage(bgLogoX, bgLogoY,bgLogoWidth, bgLogoHeight,"images\\disc-logo.png",logoRotation)
        dxDrawRectangle(0,  0, screenW, screenH*0.1, tocolor(0, 0, 0, 255), false)
        dxDrawRectangle(0, screenH-screenH*0.1 , screenW, screenH*0.1, tocolor(0, 0, 0, 255), false)
        
    if not fadingInterface then
        -- draw buttons
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX*screenW, cursorY*screenH

        dxDrawRectangle(buttonBarX,buttonBarY,buttonBarWidth, buttonBarHeight,tocolor(0,0,0,205))
        for i=1,#tabs do
            local width,height = buttonWidth, buttonHeight
            local x,y = buttonBarX+(buttonSectionWidth*(i-1))+((buttonSectionWidth-width)/2),buttonBarY+((buttonSectionHeight-height)/2)
            local focus = (cursorX >= x and cursorX <= x+width) and (cursorY >= y and cursorY <= y+buttonHeight)
            if(focus) then
                width,height = buttonWidth+5, buttonHeight+5
                x,y = buttonBarX+(buttonSectionWidth*(i-1))+((buttonSectionWidth-width)/2),buttonBarY+((buttonSectionHeight-height)/2)
            end
            local color = focus and tocolor(128,128,128,220) or tocolor(0,128,128,220)
            local font = focus and "default-bold" or "default"
        
            dxDrawRectangle(x,y,width, height,color)
            dxDrawText(tabs[i],x,y,x+width,y+height,tocolor(255,255,255),scaleX,scaleY,font,"center","center")
        end
    end

    if ( statusFadeStart and statusText ) then
        if statusFullStart and ( getTickCount()-statusFullStart >= statusFullDuration ) then
            statusFadeStart = getTickCount()
            statusFadeOut = true
            statusFullStart = nil
        end 
        local statusFadeProgress = math.min(1,(getTickCount()-statusFadeStart)/statusFadeDuration)
        if ( statusFadeProgress >= 1 and not statusFullStart ) then
            statusFullStart = getTickCount()
        end
        if ( statusFadeOut ) then
            statusFadeProgress = 1-statusFadeProgress
            if ( statusFadeProgress <= 0 ) then
                statusFadeStart = false
                statusText = false
                statusFadeOut = false
            end
        end
        if ( statusFadeProgress < 0 ) then
            statusFadeStart = false
        elseif ( statusText ) then
            local statusBgAlpha = statusFadeProgress*200
            dxDrawRectangle(statusX,statusY,statusWidth,statusHeight,tocolor( 0,0,0,statusBgAlpha))
            dxDrawText(statusText, statusX,statusY,statusX+statusWidth,statusY+statusHeight,tocolor( statusR,statusG,statusB,statusFadeProgress*255), scaleX,scaleY, "default-bold", "center", "center",false,true)
        end
    end
end

addEvent("showStatusNotice",true)
function showStatusLabel(text,r,g,b)
    statusFullStart = nil
    statusFadeOut = false
    statusText = text
    statusFadeStart = getTickCount()
    statusR, statusG, statusB = r or 255,g or 255,b or 255
    if ( tabGUI[1] and isElement(tabGUI[1].loginButton) ) then
        guiSetEnabled(tabGUI[1].loginButton,true)
    end
end
addEventHandler("showStatusNotice",root,showStatusLabel)

local tabTime = 275
local currentTabInfo = {}
local currentTab
local transitionStartTick
local tabInitialised
local openingTab
local closingTab
local openTabAfterClose

function onClickButton()
    for i=1,#buttonsGUI do
        if buttonsGUI[i] == source then
            if currentTab then
                killTab(currentTab)
                closeTab()
                if currentTab ~= i then
                    openTabAfterClose = i
                end
            else
                openTab(i)
            end
        end 
    end
end

function closeTab()
    if currentTab then
        killTab(currentTab)
        closingTab = true
        currentTabInfo = { 
            startx = tabX,
            starty = tabY,
            startwidth = tabWidth, 
            startheight = tabHeight,
            endx = buttonsInfo[currentTab].x,
            endy = buttonsInfo[currentTab].y,
            endwidth = 0,
            endheight = 0,
        }
        transitionStartTick = getTickCount()
    end
end

function openTab(tab)
    openingTab = true
    currentTab = tab
    currentTabInfo = { 
        startx = buttonsInfo[tab].x, 
        starty = buttonBarY, 
        startwidth = 0,
        startheight = 0,
        endx = tabX,
        endy = tabY,
        endwidth = tabWidth, 
        endheight = tabHeight,
    }
    transitionStartTick = getTickCount()
end

function onRenderDrawTabs()
    if not ( transitionStartTick and currentTabInfo and currentTab ) then return false end
    local tick = getTickCount()
    local progress = math.min( (tick-transitionStartTick)/tabTime, 1 )
    local x,y,_ = interpolateBetween(currentTabInfo.startx,currentTabInfo.starty,0,currentTabInfo.endx,currentTabInfo.endy,0,progress,"Linear")
    local width, height = interpolateBetween(currentTabInfo.startwidth,currentTabInfo.startheight,0,currentTabInfo.endwidth,currentTabInfo.endheight,0,progress,"Linear")
    
    local fadeProgress = progress
    if ( closingTab ) then fadeProgress = 1-progress end -- make it fadeout if closing ( instead of fading in )

    dxDrawRectangle(x,y,width,height,tocolor(0,0,0,240))
    
    dxDrawRectangle(x,y,width,tabTitleBarHeight,tocolor(10,10,10,fadeProgress*255))
    dxDrawText(tabs[currentTab],x,y,x+width,y+tabTitleBarHeight,tocolor(255,255,255,fadeProgress*255),1.2*scaleX,1.2*scaleY,"default","center","center")
    
    drawTab(currentTab,fadeProgress,x,y+tabTitleBarHeight,width,height-tabTitleBarHeight)
    
    if ( progress == 1 ) then
        if ( openingTab ) then
            initTab(currentTab,x,y+tabTitleBarHeight,width,height-tabTitleBarHeight)
            openingTab = false
        elseif ( closingTab ) then
            killTab(currentTab)
            currentTab = false
            closingTab = false
            if openTabAfterClose then
                openTab(openTabAfterClose)
                openTabAfterClose = false
            end
        end
    end
end

function hideLoginScreen(loginFailed)
    exports.USGblur:setBlurDisabled()
    closeTab()
    fadeInterface = "out"
    setTimer(function (loggedIn)
        removeEventHandler("onClientRender",root,onRenderDrawInterface)
        removeEventHandler("onClientRender",root,onRenderDrawTabs)
        for i=1,#buttonsGUI do
            destroyElement(buttonsGUI[i])
            buttonsInfo[i] = false
        end
        showCursor(false)
        showing = false
    end, fadeDuration,1, not loginFailed)
end
addEvent("USGaccounts.closeLogin",true)
addEventHandler("USGaccounts.closeLogin",root,hideLoginScreen)

--[[

all tab gui info below

-]]

local tabsInfo = { -- relative positions
    logo = {
        x='center',y=10,width=512*scaleX,height=128*scaleX
    },
    {   
        userLabel = {x=0,y=10*scaleY,width=tabWidth,height=25*scaleY},
        userEdit = {x='center',y=45*scaleY,width=460*scaleX,height=25*scaleY},
        passLabel = {x=0,y=90*scaleY,width=tabWidth,height=25*scaleY},
        passEdit = {x='center',y=120*scaleY,width=460*scaleX,height=25*scaleY},
        saveUserCheckbox = {x='center-half-1',y=150*scaleY,width=150*scaleX,height=25*scaleY},
        savePassCheckbox = {x='center-half-2',y=150*scaleY,width=150*scaleX,height=25*scaleY},
        loginButton = {x='center',y=250*scaleY,width=285*scaleX,height=35*scaleY},
        statusLabel = {x=0,y=330*scaleY,width=tabWidth,height=20*scaleY},
    },
    {
        userLabel = {x=0,y=10*scaleY,width=tabWidth,height=30*scaleY},
        passLabel = {x=0,y=60*scaleY,width=tabWidth,height=30*scaleY},
        cPassLabel = {x=0,y=115*scaleY,width=tabWidth,height=30*scaleY},
        emailLabel = {x=0,y=170*scaleY,width=tabWidth,height=30*scaleY},
        cEmailLabel = {x=0,y=225*scaleY,width=tabWidth,height=30*scaleY},
        userEdit = {x='center',y=35*scaleY,width=470*scaleX,height=25*scaleY},
        passEdit = {x='center',y=90*scaleY,width=470*scaleX,height=25*scaleY},
        cPassEdit = {x='center',y=145*scaleY,width=470*scaleX,height=25*scaleY},
        emailEdit = {x='center',y=200*scaleY,width=470*scaleX,height=25*scaleY},
        cEmailEdit = {x='center',y=250*scaleY,width=470*scaleX,height=25*scaleY},
        termsCheckBox = {x=10*scaleX,y=275*scaleY,width=300*scaleX,height=90*scaleY},
        registerBtn = {x="center-half-2",y=305*scaleY,width=175*scaleX,height=40*scaleY},
    },
    {
        userLabel = {x=0,y=20*scaleY,width=tabWidth,height=30*scaleY},
        emailLabel = {x=0,y=70*scaleY,width=tabWidth,height=30*scaleY},
        userEdit = {x='center',y=45*scaleY,width=470*scaleX,height=25*scaleY},
        emailEdit = {x='center',y=100*scaleY,width=470*scaleX,height=25*scaleY},
        infoLabel = {x=50*scaleX,y=125*scaleY,width=470*scaleX,height=250*scaleY},
        retrieveBtn = {x="center",y=305*scaleY,width=175*scaleX,height=40*scaleY},
    }
}

function getDimensions(info)
    local x,y
            
    local width,height = info.width, info.height
    if ( info.x == "center" ) then
        info.x = (tabWidth-width)/2
    elseif ( info.x == "center-half-1" ) then
        info.x = ((tabWidth/2)-width)/2 
    elseif ( info.x == "center-half-2" ) then
        info.x = (tabWidth/2)+((tabWidth/2)-width)/2    
    end
    local x,y = info.x+tabX,info.y+tabY+tabTitleBarHeight
    return {x=x,y=y,w=width,h=height}
end

    for key, tab in pairs(tabsInfo) do
        if tab.x then
            tabsInfo[key] = getDimensions(tab)
        else
            for element,info in pairs(tabsInfo[key]) do
                tabsInfo[key][element] = getDimensions(info)
            end
        end
    end

function drawTab(tab,progress,x,y,width,height)
    if tab == 1 then
    
    elseif tab == 2 then
    
    elseif tab == 3 then
    
    elseif tab == 4 then
    
    elseif tab == 5 then
    
    end
end

function initTab(tab,tX,tY,tWidth,tHeight)
    if tabInitialised or not tab then return false end

    if not tabGUI[tab] then tabGUI[tab] = {} end
    local dimInfo = {}
    if tabsInfo[tab] then
        for key, info in pairs(tabsInfo[tab]) do
            dimInfo[key] = info
        end
    end
    if tab == 1 then
        if not tabGUI[tab].created then
        
            tabGUI[tab].userLabel = guiCreateLabel(dimInfo.userLabel.x,dimInfo.userLabel.y,dimInfo.userLabel.w,dimInfo.userLabel.h,"Username",false)
                guiLabelSetVerticalAlign(tabGUI[tab].userLabel,"center")
                guiLabelSetHorizontalAlign(tabGUI[tab].userLabel,"center")
            tabGUI[tab].passLabel = guiCreateLabel(dimInfo.passLabel.x,dimInfo.passLabel.y,dimInfo.passLabel.w,dimInfo.passLabel.h,"Password",false)    
                guiLabelSetVerticalAlign(tabGUI[tab].passLabel,"center")
                guiLabelSetHorizontalAlign(tabGUI[tab].passLabel,"center")
            
            tabGUI[tab].userEdit = guiCreateEdit(dimInfo.userEdit.x,dimInfo.userEdit.y,dimInfo.userEdit.w,dimInfo.userEdit.h,"",false)
            tabGUI[tab].passEdit = guiCreateEdit(dimInfo.passEdit.x,dimInfo.passEdit.y,dimInfo.passEdit.w,dimInfo.passEdit.h,"",false)
            guiEditSetMasked(tabGUI[tab].passEdit,true)
            
            tabGUI[tab].saveUserCheckbox = guiCreateCheckBox(dimInfo.saveUserCheckbox.x,dimInfo.saveUserCheckbox.y,dimInfo.saveUserCheckbox.w,dimInfo.saveUserCheckbox.h,"Save Username",false, false)
                    
            tabGUI[tab].savePassCheckbox = guiCreateCheckBox(dimInfo.savePassCheckbox.x,dimInfo.savePassCheckbox.y,dimInfo.savePassCheckbox.w,dimInfo.savePassCheckbox.h,"Save Password",false, false)
            
            tabGUI[tab].loginButton = guiCreateButton(dimInfo.loginButton.x,dimInfo.loginButton.y,dimInfo.loginButton.w,dimInfo.loginButton.h,"Login",false)

            tabGUI[tab].statusLabel = guiCreateLabel(dimInfo.statusLabel.x,dimInfo.statusLabel.y,dimInfo.statusLabel.w,dimInfo.statusLabel.h,"Click login to play!",false)  
                guiLabelSetVerticalAlign(tabGUI[tab].statusLabel,"center")
                guiLabelSetHorizontalAlign(tabGUI[tab].statusLabel,"center")
            
            addEventHandler('onClientGUIClick',root,onLoginTabClick)
            
            tabGUI[tab].created = true
            local username, password, uTick, pTick = getXMLDetails() --gather the login information
            --outputDebugString("Username: "..tostring(username)..", Password: "..tostring(password))
            guiSetText(tabGUI[1].userEdit,tostring(username))
            guiSetText(tabGUI[1].passEdit,tostring(password))
            if (uTick == "true") then
                guiCheckBoxSetSelected(tabGUI[1].saveUserCheckbox,true)
            end
            if (pTick == "true") then
                guiCheckBoxSetSelected(tabGUI[1].savePassCheckbox,true)
            end
        else
            for i,element in pairs(tabGUI[tab]) do
                if isElement(element) then
                    guiSetVisible(element,true)
                end
            end     
        end
    elseif tab == 2 then
        -- http://pastebin.com/QbqGCCZj
        
        tabGUI[tab].userLabel = guiCreateLabel(dimInfo.userLabel.x,dimInfo.userLabel.y,dimInfo.userLabel.w,dimInfo.userLabel.h,"Username",false)
            guiLabelSetVerticalAlign(tabGUI[tab].userLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].userLabel,"center")      
        tabGUI[tab].passLabel = guiCreateLabel(dimInfo.passLabel.x,dimInfo.passLabel.y,dimInfo.passLabel.w,dimInfo.passLabel.h,"Password",false)
            guiLabelSetVerticalAlign(tabGUI[tab].passLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].passLabel,"center")          
        tabGUI[tab].cPassLabel = guiCreateLabel(dimInfo.cPassLabel.x,dimInfo.cPassLabel.y,dimInfo.cPassLabel.w,dimInfo.cPassLabel.h,"Confirm Password",false)
            guiLabelSetVerticalAlign(tabGUI[tab].cPassLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].cPassLabel,"center")         
        tabGUI[tab].emailLabel = guiCreateLabel(dimInfo.emailLabel.x,dimInfo.emailLabel.y,dimInfo.emailLabel.w,dimInfo.emailLabel.h,"Email",false)
            guiLabelSetVerticalAlign(tabGUI[tab].emailLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].emailLabel,"center")         
        tabGUI[tab].cEmailLabel = guiCreateLabel(dimInfo.cEmailLabel.x,dimInfo.cEmailLabel.y,dimInfo.cEmailLabel.w,dimInfo.cEmailLabel.h,"Confirm Email",false)
            guiLabelSetVerticalAlign(tabGUI[tab].cEmailLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].cEmailLabel,"center")
                
        tabGUI[tab].userEdit = guiCreateEdit(dimInfo.userEdit.x,dimInfo.userEdit.y,dimInfo.userEdit.w,dimInfo.userEdit.h,"",false)
        tabGUI[tab].passEdit = guiCreateEdit(dimInfo.passEdit.x,dimInfo.passEdit.y,dimInfo.passEdit.w,dimInfo.passEdit.h,"",false)
        tabGUI[tab].cPassEdit = guiCreateEdit(dimInfo.cPassEdit.x,dimInfo.cPassEdit.y,dimInfo.cPassEdit.w,dimInfo.cPassEdit.h,"",false)
            guiEditSetMasked(tabGUI[tab].passEdit,true)
            guiEditSetMasked(tabGUI[tab].cPassEdit,true)
        tabGUI[tab].emailEdit = guiCreateEdit(dimInfo.emailEdit.x,dimInfo.emailEdit.y,dimInfo.emailEdit.w,dimInfo.emailEdit.h,"",false)
        tabGUI[tab].cEmailEdit = guiCreateEdit(dimInfo.cEmailEdit.x,dimInfo.cEmailEdit.y,dimInfo.cEmailEdit.w,dimInfo.cEmailEdit.h,"",false)

        tabGUI[tab].termsCheckBox = guiCreateCheckBox(dimInfo.termsCheckBox.x,dimInfo.termsCheckBox.y,dimInfo.termsCheckBox.w,dimInfo.termsCheckBox.h,
        "I agree to the terms of privacy, the rules\n and any terms that USG has on the server\n and will take responsibility if these are broken."
        ,false,false)
        
        tabGUI[tab].registerBtn = guiCreateButton(dimInfo.registerBtn.x,dimInfo.registerBtn.y,dimInfo.registerBtn.w,dimInfo.registerBtn.h,"Register",false)
        addEventHandler('onClientGUIClick',tabGUI[tab].registerBtn,onRegisterClick, false)

    elseif tab == 3 then
        tabGUI[tab].userLabel = guiCreateLabel(dimInfo.userLabel.x,dimInfo.userLabel.y,dimInfo.userLabel.w,dimInfo.userLabel.h,"Username",false)
            guiLabelSetVerticalAlign(tabGUI[tab].userLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].userLabel,"center")
        tabGUI[tab].emailLabel = guiCreateLabel(dimInfo.emailLabel.x,dimInfo.emailLabel.y,dimInfo.emailLabel.w,dimInfo.emailLabel.h,"Email",false)
            guiLabelSetVerticalAlign(tabGUI[tab].emailLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].emailLabel,"center")                     
        tabGUI[tab].userEdit = guiCreateEdit(dimInfo.userEdit.x,dimInfo.userEdit.y,dimInfo.userEdit.w,dimInfo.userEdit.h,"",false)
        tabGUI[tab].emailEdit = guiCreateEdit(dimInfo.emailEdit.x,dimInfo.emailEdit.y,dimInfo.emailEdit.w,dimInfo.emailEdit.h,"",false)
        tabGUI[tab].infoLabel = guiCreateLabel(dimInfo.infoLabel.x,dimInfo.infoLabel.y,dimInfo.infoLabel.w,dimInfo.infoLabel.h,"Did you lose your password or username?\
        Fill in your email-address or username to get an email sent to you,\
        with your username and the possibility of reseting your password.",false)
            guiLabelSetVerticalAlign(tabGUI[tab].infoLabel,"center")
            guiLabelSetHorizontalAlign(tabGUI[tab].infoLabel,"left")                
        tabGUI[tab].retrieve = guiCreateButton(dimInfo.retrieveBtn.x, dimInfo.retrieveBtn.y, dimInfo.retrieveBtn.w, dimInfo.retrieveBtn.h,"Retrieve",false)
        addEventHandler('onClientGUIClick',tabGUI[tab].retrieve,onRetrieveClick, false)
    end
    tabInitialised = true
end

function killTab(tab)
    if tab then
        if isElement(tabGUI[tab].logo) then
            guiSetVisible(tabGUI[tab].logo,false)
        end
        if tab == 1 then
        elseif tab == 2 then    
        elseif tab == 3 then    
        elseif tab == 4 then    
        elseif tab == 5 then    
        end
        tabInitialised = false
        if tabGUI[tab] then
            for i,element in pairs(tabGUI[tab]) do
                if isElement(element) then
                    guiSetVisible(element,false)
                end
            end
        end
    end
end

function onLoginTabClick()
    if ( source == tabGUI[1].loginButton ) then
        local username = guiGetText(tabGUI[1].userEdit)
        local password = guiGetText(tabGUI[1].passEdit)
        local userTick,passTick = guiCheckBoxGetSelected(tabGUI[1].saveUserCheckbox),guiCheckBoxGetSelected(tabGUI[1].savePassCheckbox)
        if (username:match( "^%s*$" )) then
            guiSetText(tabGUI[1].statusLabel,"Please enter a username!")
            guiLabelSetColor(tabGUI[1].statusLabel,255,0,0)
            if (isTimer(resetTextTimer)) then
                killTimer(resetTextTimer)
            end
            resetTextTimer = setTimer(function() guiSetText(tabGUI[1].statusLabel,"Click login to play!") guiLabelSetColor(tabGUI[1].statusLabel,255,255,255) end, 3000, 1)
        elseif (password:match("^%s*$")) then
            guiSetText(tabGUI[1].statusLabel,"Please enter a password!")
            guiLabelSetColor(tabGUI[1].statusLabel,255,0,0)
            if (isTimer(resetTextTimer)) then
                killTimer(resetTextTimer)
            end
            resetTextTimer = setTimer(function() guiSetText(tabGUI[1].statusLabel,"Click login to play!") guiLabelSetColor(tabGUI[1].statusLabel,255,255,255) end, 3000, 1)
        else
            guiSetEnabled(source,false)
            triggerServerEvent("onPlayerAttemptLogin",localPlayer,username,password)
            updateXMLDetails(username,password,userTick,passTick)
        end
    elseif source == tabGUI[1].recoverButton then
    end
end

function onRegisterClick()
    local username = guiGetText(tabGUI[2].userEdit)
    local password = guiGetText(tabGUI[2].passEdit)
    local cPassword = guiGetText(tabGUI[2].cPassEdit)
    local email = guiGetText(tabGUI[2].emailEdit)
    local cEmail = guiGetText(tabGUI[2].cEmailEdit)
    if (username:match( "^%s*$" )) then
        showStatusLabel("Please enter a username.",255,0,0)
        return false
    elseif (password:match("^%s*$")) then
        showStatusLabel("Please enter a password",255,0,0)
        return false
    elseif (cPassword:match("^%s*$")) then
        showStatusLabel("Please repeat your password",255,0,0)
        return false
    elseif (password ~= cPassword) then
        showStatusLabel("Passwords do not match!",255,0,0)
        return false
    elseif (password == username) then
        showStatusLabel("Your username and password must be different!",255,0,0)
        return false
    elseif (email == "") then
        showStatusLabel("You must supply a email address!",255,0,0)
        return false
    --[[elseif ( ( string.match( email, "^.+@.+%.%a%a%a*%.*%a*%a*%a*") ) ) then -- email check?
        showStatusLabel("You must supply a valid email address!",255,0,0)
        return false]]--
    elseif (email ~= cEmail) then -- email check?
        showStatusLabel("Emails do not match.",255,0,0)
        return false
    elseif not ( guiCheckBoxGetSelected(tabGUI[2].termsCheckBox) ) then
        showStatusLabel("You must agree with out terms!",255,0,0)
        return false
    elseif (#password < 6) then
        showStatusLabel("The minimum length for a password is 6 characters, you have "..#password..".", 255,0,0)
    elseif (#username > 64) then
        showStatusLabel("The maximum length of an username is 64 characters, you have "..#username..".",255,0,0)
    else
        triggerServerEvent("onPlayerAttemptRegister",localPlayer,username,password,email)
    end
end

function onRetrieveClick()
    local username = guiGetText(tabGUI[3].userEdit)
    local email = guiGetText(tabGUI[3].emailEdit)
    if (username:match( "^%s*$" )) then
        showStatusLabel("Please enter an username.",255,0,0)
        return false
    elseif (email == "") then
        showStatusLabel("You must supply an email address!",255,0,0)
        return false
    else
        triggerServerEvent("USGaccounts.requestPassword",localPlayer,username,email)
    end
end

function updateXMLDetails(username,password,uTick,pTick)
    if (username) and (password) then
        local dataFile = xmlLoadFile("@accData.xml")
        if not (dataFile) then
            outputDebugString("[ACC] Account file not found, creating...",0,255,0,0)
            dataFile = xmlCreateFile("@accData.xml","accounts")
            xmlCreateChild(dataFile,"username")
            xmlCreateChild(dataFile,"password")
            xmlCreateChild(dataFile,"userTick")
            xmlCreateChild(dataFile,"passTick")
        end
        
        usernameNode = xmlFindChild(dataFile,"username",0)
        passwordNode = xmlFindChild(dataFile,"password",0)
        userTickNode = xmlFindChild(dataFile,"userTick",0)
        passTickNode = xmlFindChild(dataFile,"passTick",0)
        
        xmlNodeSetValue(userTickNode,tostring(uTick))
        xmlNodeSetValue(passTickNode,tostring(pTick))
        
        if (uTick or pTick) then
            xmlNodeSetValue(usernameNode,tostring(username))        
        else
            xmlNodeSetValue(usernameNode,"")
        end
        
        if (pTick) then
            xmlNodeSetValue(passwordNode,tostring(password))
        else
            xmlNodeSetValue(passwordNode,"")
        end
                
        xmlSaveFile(dataFile)
        xmlUnloadFile(dataFile)
    else
        outputDebugString("[ACC] Missing username and/or password, returning...",0,255,0,0)
    end
end

function getXMLDetails()
    local dataFile = xmlLoadFile("@accData.xml")
    if not (dataFile) then
        outputDebugString("[ACC] Account file not found, creating...",0,255,0,0)
        dataFile = xmlCreateFile("@accData.xml","accounts")
        xmlCreateChild(dataFile,"username")
        xmlCreateChild(dataFile,"password")
        xmlCreateChild(dataFile,"userTick")
        xmlCreateChild(dataFile,"passTick")
        xmlSaveFile(dataFile)
        return "",""
    end
    
    local usernameNode = xmlFindChild(dataFile,"username",0)
    local passwordNode = xmlFindChild(dataFile,"password",0)
    local userTickNode = xmlFindChild(dataFile,"userTick",0)
    local passTickNode = xmlFindChild(dataFile,"passTick",0)
    local username = xmlNodeGetValue(usernameNode)
    local password = xmlNodeGetValue(passwordNode)
    local uTick = xmlNodeGetValue(userTickNode)
    local pTick = xmlNodeGetValue(passTickNode)
    xmlUnloadFile(dataFile)
    
    return username,password,uTick,pTick
end

--- server interactment

addEventHandler("onServerPlayerLogin", localPlayer,
    function ()
        exports.system:showLoadingScreen(false) -- hide background, skip timeout timer
    end
)

addEvent("showLoginNotice",true)
addEventHandler("showLoginNotice",root,
function(text,r,g,b)
    guiSetText(tabGUI[1].statusLabel,tostring(text))
    guiLabelSetColor(tabGUI[1].statusLabel,tonumber(r),tonumber(g),tonumber(b))
    if (isTimer(resetTextTimer)) then
        killTimer(resetTextTimer)
    end
    resetTextTimer = setTimer(
        function() 
            guiSetText(tabGUI[1].statusLabel,"Click login to play!") 
            guiLabelSetColor(tabGUI[1].statusLabel,255,255,255) 
        end, 3000, 1)
end)

addEvent("closeTab",true)
addEventHandler("closeTab",root,
function(tabName)
    closeTab()
end)
