encSalt_begin = "CSG"
encSalt_end = "ENCRYPT"
encSalt_middle = "COMSOCGAM"

function stringEncryption(string,type)
	if (string) and (string ~= "") then	
		if (type == "SHASALT") then
			return SHA512(encSalt_begin.."-"..string.."-"..encSalt_middle.."-"..encSalt_end)
		elseif (type == "SHA512") then
			return SHA512(string)
		elseif (type == "SHA1") then
			return SHA1(string)
		elseif (type == "SHA224") then
			return SHA224(string)
		elseif (type == "SHA384") then
			return SHA384(string)
		else
			return false
		end
	end
end

function SHA512(string)
	hash = sha512(string)
	return hash
end

function SHA1(string)
	hash = sha1(string)
	return hash
end

function SHA224(string)
	hash = sha224(string)
	return hash
end

--UNSUPPORTED--
--[[function SHA256(string)
	hash = sha256(string)
	return hash
end]]--

function SHA384(string)
	hash = sha384(string)
	return hash
end