local pedModels = { ['cj']=true, ['truth']=true, ['maccer']=true, ['andre']=true, ['bbthin']=true, ['bb']=true, ['emmet']=true, ['male01']=true, ['janitor']=true, ['bfori']=true, ['bfost']=true, ['vbfycrp']=true, ['bfyri']=true, ['bfyst']=true, ['bmori']=true, ['bmost']=true, ['bmyap']=true, ['bmybu']=true, ['bmybe']=true, ['bmydj']=true, ['bmyri']=true, ['bmycr']=true, ['bmyst']=true, ['wmybmx']=true, ['wbdyg1']=true, ['wbdyg2']=true, ['wmybp']=true, ['wmycon']=true, ['bmydrug']=true, ['wmydrug']=true, ['hmydrug']=true, ['dwfolc']=true, ['dwmolc1']=true, ['dwmolc2']=true, ['dwmylc1']=true, ['hmogar']=true, ['wmygol1']=true, ['wmygol2']=true, ['hfori']=true, ['hfost']=true, ['hfyri']=true, ['hfyst']=true, ['jethro']=true, ['hmori']=true, ['hmost']=true, ['hmybe']=true, ['hmyri']=true, ['hmycr']=true, ['hmyst']=true, ['omokung']=true, ['wmymech']=true, ['bmymoun']=true, ['wmymoun']=true, ['Unknown']=true, ['ofost']=true, ['ofyri']=true, ['ofyst']=true, ['omori']=true, ['omost']=true, ['omyri']=true, ['omyst']=true, ['wmyplt']=true, ['wmopj']=true, ['bfypro']=true, ['hfypro']=true, ['kendl']=true, ['bmypol1']=true, ['bmypol2']=true, ['wmoprea']=true, ['sbfyst']=true, ['wmosci']=true, ['wmysgrd']=true, ['swmyhp1']=true, ['swmyhp2']=true, ['swfopro']=true, ['wfystew']=true, ['swmotr1']=true, ['wmotr1']=true, ['bmotr1']=true, ['vbmybox']=true, ['vwmybox']=true, ['vhmyelv']=true, ['vbmyelv']=true, ['vimyelv']=true, ['vwfypro']=true, ['ryder3']=true, ['vwfyst1']=true, ['wfori']=true, ['wfost']=true, ['wfyjg']=true, ['wfyri']=true, ['wfyro']=true, ['wfyst']=true, ['wmori']=true, ['wmost']=true, ['wmyjg']=true, ['wmylg']=true, ['wmyri']=true, ['wmyro']=true, ['wmycr']=true, ['wmyst']=true, ['ballas1']=true, ['ballas2']=true, ['ballas3']=true, ['fam1']=true, ['fam2']=true, ['fam3']=true, ['lsv1']=true, ['lsv2']=true, ['lsv3']=true, ['maffa']=true, ['maffb']=true, ['mafboss']=true, ['vla1']=true, ['vla2']=true, ['vla3']=true, ['triada']=true, ['triadb']=true, ['sindaco']=true, ['triboss']=true, ['dnb1']=true, ['dnb2']=true, ['dnb3']=true, ['vmaff1']=true, ['vmaff2']=true, ['vmaff3']=true, ['vmaff4']=true, ['dnmylc']=true, ['dnfolc1']=true, ['dnfolc2']=true, ['dnfylc']=true, ['dnmolc1']=true, ['dnmolc2']=true, ['sbmotr2']=true, ['swmotr2']=true, ['sbmytr3']=true, ['swmotr3']=true, ['wfybe']=true, ['bfybe']=true, ['hfybe']=true, ['sofybu']=true, ['sbmyst']=true, ['sbmycr']=true, ['bmycg']=true, ['wfycrk']=true, ['hmycm']=true, ['wmybu']=true, ['bfybu']=true, ['smokev']=true, ['wfybu']=true, ['dwfylc1']=true, ['wfypro']=true, ['wmyconb']=true, ['wmybe']=true, ['wmypizz']=true, ['bmobar']=true, ['cwfyhb']=true, ['cwmofr']=true, ['cwmohb1']=true, ['cwmohb2']=true, ['cwmyfr']=true, ['cwmyhb1']=true, ['bmyboun']=true, ['wmyboun']=true, ['wmomib']=true, ['bmymib']=true, ['wmybell']=true, ['bmochil']=true, ['sofyri']=true, ['somyst']=true, ['vwmybjd']=true, ['vwfycrp']=true, ['sfr1']=true, ['sfr2']=true, ['sfr3']=true, ['bmybar']=true, ['wmybar']=true, ['wfysex']=true, ['wmyammo']=true, ['bmytatt']=true, ['vwmycr']=true, ['vbmocd']=true, ['vbmycr']=true, ['vhmycr']=true, ['sbmyri']=true, ['somyri']=true, ['somybu']=true, ['swmyst']=true, ['wmyva']=true, ['copgrl3']=true, ['gungrl3']=true, ['mecgrl3']=true, ['nurgrl3']=true, ['crogrl3']=true, ['gangrl3']=true, ['cwfofr']=true, ['cwfohb']=true, ['cwfyfr1']=true, ['cwfyfr2']=true, ['cwmyhb2']=true, ['dwfylc2']=true, ['dwmylc2']=true, ['omykara']=true, ['wmykara']=true, ['wfyburg']=true, ['vwmycd']=true, ['vhfypro']=true, ['suzie']=true, ['omonood']=true, ['omoboat']=true, ['wfyclot']=true, ['vwmotr1']=true, ['vwmotr2']=true, ['vwfywai']=true, ['sbfori']=true, ['swfyri']=true, ['wmyclot']=true, ['sbfost']=true, ['sbfyri']=true, ['sbmocd']=true, ['sbmori']=true, ['sbmost']=true, ['shmycr']=true, ['sofori']=true, ['sofost']=true, ['sofyst']=true, ['somobu']=true, ['somori']=true, ['somost']=true, ['swmotr5']=true, ['swfori']=true, ['swfost']=true, ['swfyst']=true, ['swmocd']=true, ['swmori']=true, ['swmost']=true, ['shfypro']=true, ['sbfypro']=true, ['swmotr4']=true, ['swmyri']=true, ['smyst']=true, ['smyst2']=true, ['sfypro']=true, ['vbfyst2']=true, ['vbfypro']=true, ['vhfyst3']=true, ['bikera']=true, ['bikerb']=true, ['bmypimp']=true, ['swmycr']=true, ['wfylg']=true, ['wmyva2']=true, ['bmosec']=true, ['bikdrug']=true, ['wmych']=true, ['sbfystr']=true, ['swfystr']=true, ['heck1']=true, ['heck2']=true, ['bmycon']=true, ['wmycd1']=true, ['bmocd']=true, ['vwfywa2']=true, ['wmoice']=true, ['tenpen']=true, ['pulaski']=true, ['Hernandez']=true, ['dwayne']=true, ['smoke']=true, ['sweet']=true, ['ryder']=true, ['forelli']=true, ['tbone']=true, ['laemt1']=true, ['lvemt1']=true, ['sfemt1']=true, ['lafd1']=true, ['lvfd1']=true, ['sffd1']=true, ['lapd1']=true, ['sfpd1']=true, ['lvpd1']=true, ['csher']=true, ['lapdm1']=true, ['swat']=true, ['fbi']=true, ['army']=true, ['dsher']=true, ['zero']=true, ['rose']=true, ['paul']=true, ['cesar']=true, ['ogloc']=true, ['wuzimu']=true, ['torino']=true, ['jizzy']=true, ['maddogg']=true, ['cat']=true, ['claude']=true }
local vehicleModels = {
	["landstal"] = true, ["bravura"] = true, ["buffalo"] = true, ["linerun"] = true, ["peren"] = true, ["sentinel"] = true, 
	["dumper"] = true, ["firetruk"] = true, ["trash"] = true, ["stretch"] = true, ["manana"] = true, ["infernus"] = true, 
	["voodoo"] = true, ["pony"] = true, ["mule"] = true, ["cheetah"] = true, ["ambulan"] = true, ["leviathn"] = true, 
	["moonbeam"] = true, ["esperant"] = true, ["taxi"] = true, ["washing"] = true, ["bobcat"] = true, ["mrwhoop"] = true, 
	["bfinject"] = true, ["hunter"] = true, ["premier"] = true, ["enforcer"] = true, ["securica"] = true, ["banshee"] = true, 
	["predator"] = true, ["bus"] = true, ["rhino"] = true, ["barracks"] = true, ["hotknife"] = true, ["artict1"] = true, 
	["previon"] = true, ["coach"] = true, ["cabbie"] = true, ["stallion"] = true, ["rumpo"] = true, ["rcbandit"] = true, 
	["romero"] = true, ["packer"] = true, ["monster"] = true, ["admiral"] = true, ["squalo"] = true, ["seaspar"] = true, 
	["pizzaboy"] = true, ["tram"] = true, ["artict2"] = true, ["turismo"] = true, ["speeder"] = true, ["reefer"] = true, 
	["tropic"] = true, ["flatbed"] = true, ["yankee"] = true, ["caddy"] = true, ["solair"] = true, ["topfun"] = true, 
	["skimmer"] = true, ["pcj600"] = true, ["faggio"] = true, ["freeway"] = true, ["rcbaron"] = true, ["rcraider"] = true, 
	["glendale"] = true, ["oceanic"] = true, ["sanchez"] = true, ["sparrow"] = true, ["patriot"] = true, ["quad"] = true, 
	["coastg"] = true, ["dinghy"] = true, ["hermes"] = true, ["sabre"] = true, ["rustler"] = true, ["zr350"] = true, 
	["walton"] = true, ["regina"] = true, ["comet"] = true, ["bmx"] = true, ["burrito"] = true, ["camper"] = true, 
	["marquis"] = true, ["baggage"] = true, ["dozer"] = true, ["maverick"] = true, ["vcnmav"] = true, ["rancher"] = true, 
	["fbiranch"] = true, ["virgo"] = true, ["greenwoo"] = true, ["jetmax"] = true, ["hotring"] = true, ["sandking"] = true, 
	["blistac"] = true, ["polmav"] = true, ["boxville"] = true, ["benson"] = true, ["mesa"] = true, ["rcgoblin"] = true, 
	["hotrina"] = true, ["hotrinb"] = true, ["bloodra"] = true, ["rnchlure"] = true, ["supergt"] = true, ["elegant"] = true, 
	["journey"] = true, ["bike"] = true, ["mtbike"] = true, ["beagle"] = true, ["cropdust"] = true, ["stunt"] = true, 
	["petro"] = true, ["rdtrain"] = true, ["nebula"] = true, ["majestic"] = true, ["buccanee"] = true, ["shamal"] = true, 
	["hydra"] = true, ["fcr900"] = true, ["nrg500"] = true, ["copbike"] = true, ["cement"] = true, ["towtruck"] = true, 
	["fortune"] = true, ["cadrona"] = true, ["fbitruck"] = true, ["willard"] = true, ["forklift"] = true, ["tractor"] = true, 
	["combine"] = true, ["feltzer"] = true, ["remingtn"] = true, ["slamvan"] = true, ["blade"] = true, ["freight"] = true, 
	["streak"] = true, ["vortex"] = true, ["vincent"] = true, ["bullet"] = true, ["clover"] = true, ["sadler"] = true, 
	["firela"] = true, ["hustler"] = true, ["intruder"] = true, ["primo"] = true, ["cargobob"] = true, ["tampa"] = true, 
	["sunrise"] = true, ["merit"] = true, ["utility"] = true, ["nevada"] = true, ["yosemite"] = true, ["windsor"] = true, 
	["monstera"] = true, ["monsterb"] = true, ["uranus"] = true, ["jester"] = true, ["sultan"] = true, ["stratum"] = true, 
	["elegy"] = true, ["raindanc"] = true, ["rctiger"] = true, ["flash"] = true, ["tahoma"] = true, ["savanna"] = true, 
	["bandito"] = true, ["freiflat"] = true, ["streakc"] = true, ["kart"] = true, ["mower"] = true, ["duneride"] = true, 
	["sweeper"] = true, ["broadway"] = true, ["tornado"] = true, ["at400"] = true, ["dft30"] = true, ["huntley"] = true, 
	["stafford"] = true, ["bf400"] = true, ["newsvan"] = true, ["tug"] = true, ["petrotr"] = true, ["car"] = true, 
	["bike"] = true, ["euros"] = true, ["hotdog"] = true, ["club"] = true, ["freibox"] = true, ["artict3"] = true, 
	["androm"] = true, ["plane"] = true, ["rccam"] = true, ["launch"] = true, ["copcarla"] = true, ["copcarsf"] = true, 
	["copcarvg"] = true, ["copcarru"] = true, ["picador"] = true, ["swatvan"] = true, ["alpha"] = true, ["phoenix"] = true, 
	["glenshit"] = true, ["sadlshit"] = true, ["bagboxa"] = true, ["bagboxb"] = true, ["tugstair"] = true, ["boxburg"] = true, 
	["farmtr1"] = true, ["utiltr1"] = true,	
}

-------
local playerModInfo = {}
local playerBadModInfo = {}
local raceRooms = { dd = true, dm = true, str = true}

function receivePlayerModInfo(file, modList)
	if(not playerModInfo[source]) then playerModInfo[source] = {} end
	playerModInfo[source][file] = modList
	if(file == "gta3.img") then
		for i, mod in ipairs(modList) do
			if(mod.name:find("%.ifp")) then
				if(not playerBadModInfo[source]) then playerBadModInfo[source] = { global = {} } end
				if(not playerBadModInfo[source].global) then playerBadModInfo[source].global = {} end
				table.insert(playerBadModInfo[source].global, mod.name)
			elseif(pedModels[mod.name:sub(1, -5)]) then
				if(not playerBadModInfo[source]) then playerBadModInfo[source] = { cnr = {} } end
				if(not playerBadModInfo[source].cnr) then playerBadModInfo[source].cnr = {} end
				table.insert(playerBadModInfo[source].cnr, mod.name)
			elseif(vehicleModels[mod.name:gsub("%..+", "")]) then
				if(not playerBadModInfo[source]) then playerBadModInfo[source] = { race = {} } end
				if(not playerBadModInfo[source].race) then playerBadModInfo[source].race = {} end
				table.insert(playerBadModInfo[source].race, mod.name)
			end
		end
		if(playerBadModInfo[source]) then
			if(playerBadModInfo[source].global) then
				kickPlayer(source, "Illegal files found: "..table.concat(playerBadModInfo[source].global,","), 255, 0, 0)
			elseif(playerBadModInfo[source].cnr and exports.USGrooms:getPlayerRoom(source) == "cnr") then
				exports.USGrooms:removePlayerFromRoom(source)
				exports.USGmsg:msg(source, "Illegal mods found: "..table.concat(playerBadModInfo[source].cnr,","), 255, 0, 0)
				triggerClientEvent(source, "USGanticheat.onShowModInfo", source, playerBadModInfo[source].cnr)
			elseif(playerBadModInfo[source].race and raceRooms[exports.USGrooms:getPlayerRoom(source)]) then
				exports.USGrooms:removePlayerFromRoom(source)
				exports.USGmsg:msg(source, "Illegal mods found: "..table.concat(playerBadModInfo[source].race,","), 255, 0, 0)
				triggerClientEvent(source, "USGanticheat.onShowModInfo", source, playerBadModInfo[source].race)
			end
		end
	end
end
--addEventHandler("onPlayerModInfo",root,receivePlayerModInfo)

addEvent("onPlayerPreJoinRoom")
function onPlayerPreJoinRoom(room)
	if(raceRooms[room]) then
		if(playerBadModInfo[source] and playerBadModInfo[source].race) then
			cancelEvent(true, "Illegal mods found")
			exports.USGmsg:msg(source, "You can't join DD/shooter with car mods.", 255, 0, 0)
			triggerClientEvent(source, "USGanticheat.onShowModInfo", source, playerBadModInfo[source].race)
		end
	elseif(room == "cnr") then
		if(playerBadModInfo[source] and playerBadModInfo[source].cnr) then
			cancelEvent(true, "Illegal mods found")
			exports.USGmsg:msg(source, "You can't join CNR with modified ped skins.", 255, 0, 0)
			triggerClientEvent(source, "USGanticheat.onShowModInfo", source, playerBadModInfo[source].cnr)
		end
	end
end
--addEventHandler("onPlayerPreJoinRoom", root, onPlayerPreJoinRoom)

addEventHandler("onPlayerQuit", root,
	function ()
		playerModInfo[source] = nil
		playerBadModInfo[source] = nil
	end
)

function getPlayerAntiModInfo(player)
	return playerBadModInfo[player]
end

function doesPlayerHaveIllegalMods(player)
	if ( playerBadModInfo[player] ) then
		return true
	else
		return false
	end
end
addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			resendPlayerModInfo(player)
		end
	end
)