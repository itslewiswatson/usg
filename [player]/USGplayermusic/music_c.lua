local defaultLibrary = {  
	{ name = "Power 181 (Top 40)", url = "http://www.181.fm/winamp.pls?station=181-power&style=mp3&description=Power%20181%20(Top%2040)&file=181-power.pls"},
	{ name = "Hardstyle", url = "http://listen.hardstyle.nu/listen.pls"},
	{ name = "Hardbase", url = "http://listen.hardbase.fm/aacplus.pls"},
	{ name = "Slam!FM", url = "http://82.201.100.23/slamfm.m3u"},
	{ name = "Dance FM", url = "http://true.nl/streams/dancetunes.asx"},
	{ name = "Best blues", url = "http://64.62.252.130:9032/listen.pls"},
	{ name = "Classic music", url = "http://sc1.abacast.com:8220/listen.pls"},
	{ name = "Country", url = "http://shoutcast.internet-radio.org.uk:10656/listen.pls"},
	{ name = "Electro, dance, house", url = "http://stream.electroradio.ch:26630/listen.pls"},
	{ name = "90s grunge rock", url = "http://173.193.14.170:8006/listen.pls"},
	{ name = "Rock, metal and alternative", url = "http://screlay-dtc0l-1.shoutcast.com:8012/listen.pls"},
	{ name = "60s 70s 80s 90s rock", url = "http://cp.internet-radio.org.uk:15476/listen.pls"},
	{ name = "Pop, dance, trance", url = "http://cp.internet-radio.org.uk:15114/listen.pls"},
	{ name = "Psychedelic, Progressive rock", url = "http://krautrock.pop-stream.de:7592/listen.pls"},
	{ name = "Hip hop, rap, rnb", url = "http://mp3uplink.duplexfx.com:8054/listen.pls"},
	{ name = "Filth FM", url = "http://lemon.citrus3.com/castcontrol/playlist.php?id=51&type=pls"},
	{ name = "Reggae and Dancehall music", url = "http://www.raggakings.net/listen.wax"},
	{ name = "Dirty South FM", url = "http://www.dirtysouthradioonline.com/broadband-128.asx"},
	{ name = "Smooth Beats", url = "http://www.smoothbeats.com/hiphop.asx"},
	{ name = "Smooth Jazz", url = "http://www.1.fm/go/baysmoothjazz128k.asx"},
	{ name = "Rock web", url = "http://100xr.redirectme.net/100xr.asx"},
	{ name = "Dubstep", url = "http://dubstep.fm/listen.pls"},
}

-- util and starting
function isResourceReady(res)
	return getResourceFromName(res) and getResourceState(getResourceFromName(res)) == "running"
end

addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(isResourceReady("USGaccounts") and exports.USGaccounts:isPlayerLoggedIn()) then
			loadLibraryFromFile()
		else
			addEvent("onServerPlayerLogin", true)
			addEventHandler("onServerPlayerLogin", localPlayer, loadLibraryFromFile)
		end
	end
)

-- loading / saving

local library = {}
function loadLibraryFromFile()
	local file = xmlLoadFile("library.xml")
	if(file) then
		local items = xmlNodeGetChildren(file)
		for i, item in ipairs(items) do
			local name = xmlNodeGetAttribute(item, "name")
			local url = xmlNodeGetValue(item)
			if(url and #url > 4) then
				table.insert(library, {name = name or url, url = url})	
			end
		end
		xmlUnloadFile(file)
		return true
	else
		library = defaultLibrary
		return true
	end
end

function saveLibrary()
	local file = xmlCreateFile("library.xml", "library")
	if(file) then
		for i, item in ipairs(library) do
			local node = xmlCreateChild(file, "item")
			xmlNodeSetValue(node, item.url)
			if(item.name ~= item.url) then
				xmlNodeSetAttribute(node, "name", item.name)
			end
		end
		xmlSaveFile(file)
		xmlUnloadFile(file)
		return true
	else
		error("Could not save music into XML!")
	end
end
addEventHandler("onClientResourceStop", resourceRoot, saveLibrary)

-- exports etc.

function getLibrary()
	return library
end

function addToLibrary(url, name)
	local existing = false
	for i, item in ipairs(library) do
		if(item.url == url) then
			item.name = name or item.name
			existing = true
			break
		end
	end
	if(not existing) then
		table.insert(library, {name = name or url, url = url})
	end
	return true
end

function removeFromLibrary(url)
	for i, item in ipairs(library) do
		if(item.url == url) then
			table.remove(library, i)
			return true
		end
	end
	return false
end