--https://github.com/SatheeshJM/Ascii85-Encoding-in-Pure-Lua/blob/master/ascii85.lua

--====================================================================--
-- Module: Ascii 85 Encoding in Pure Lua
-- Author : Satheesh
-- 
-- License: MIT

-- Version : 1.1
-- ChangeLog
-- 1.1
-- 		Minor bug fixed 
--		All-Zero group will be represented as 'z'
--		
--
-- Usage:
--
-- local ascii85 = require "ascii85"
--
-- local input = "Sample_Input"
-- local enc = ascii85.encode(input)
-- local dec = ascii85.decode(enc)
--====================================================================--


local floor = math.floor
local tostring = tostring
local table_insert = table.insert


local function decimalToBase85(num)
	local base = 85
	
	local final = {}
	while num > 0 do
		table_insert(final,1,num % base)
		num = floor(num / base)
	end
	
	while #final < 5 do
		table_insert(final,1,0)
	end
	
	return final
end

local function base85ToDecimal(b85)
	local base = 85
	
	local l = #b85
	local final = 0
	
	for i=l,1,-1 do
		local digit = b85[i]
		local val = digit * base^(l-i)
		final = final + val
	end
	
	return final
end


local function decimalToBinary(num)
	local base = 2
	local bits = 8
	
	local final = ""
	while num > 0 do
		final = "" ..  (num % base ) .. final
		num = floor(num / base)
	end
	
	local l = final:len()
	if l == 0 then
		final = "0"..final
	end
	
	while final:len()%8 ~=0 do
		final = "0"..final
	end
	
	return final
end

local function binaryToDecimal(bin)
	local base = 2
	
	local l = bin:len()
	local final = 0
	
	for i=l,1,-1 do
		local digit = bin:sub(i,i)
		local val = digit * base^(l-i)
		final = final + val
	end
	return final
end


local function encode(substr)
	local l = substr:len()
	local combine = ""
	for i=1,l do
		local char = substr:sub(i,i)
		local byte = char:byte()
		local bin = decimalToBinary(byte)
		combine = combine..bin
	end
	
	local num = binaryToDecimal(combine)
	local b85 = decimalToBase85(num)
	
	local final = ""
	for i=1,#b85 do
		local char = tostring(b85[i]+33)
		final = final .. char:char()
	end
	
	if final == "!!!!!" then
		final = "z"
	end
	
	return final
end

local function decode(substr)
	local final = "" 
	
	local l = substr:len()
	local combine = {}
	for i=1,l do
		local char = substr:sub(i,i)
		local byte = char:byte()
		byte = byte - 33
		combine[i] = byte
	end
	
	local num = base85ToDecimal(combine)
	local bin = decimalToBinary(num)
	
	while bin:len() < 32 do
		bin = "0"..bin
	end
	
	local l = bin:len()
	local split = 8
	for i=1,l,split do
		local sub = bin:sub(i,i+split-1)
		local byte = binaryToDecimal(sub)
		local char = tostring(byte):char()
		final = final..char
	end
	
	return final
end


local function ascii_encode(str)
	local final = ""
	
	local noOfZeros = 0
	while str:len()%4~=0 do
		noOfZeros = noOfZeros + 1
		str = str.."\0"
	end
	
	local l = str:len()
	
	for i=1,l,4 do
		local sub = str:sub(i,i+3)
		final = final .. encode(sub)
	end
	
	final = final:sub(1,-noOfZeros-1)
--	final = "<~"..final.."~>"
	return final
end

local function ascii_decode(str)
	local final = ""
	
--	str = str:sub(3,-3)
	str = str:gsub("z","!!!!!")
	
	local c = 5
	local noOfZeros = 0
	while str:len()%c~=0 do
		noOfZeros = noOfZeros + 1
		str = str.."u"
	end
	
	local l = str:len()
	for i=1,l,c do
		local sub = str:sub(i,i+c-1)
		final = final .. decode(sub)
	end
	
	final = final:sub(1,-noOfZeros-1)
	return final
end



-- the following was written by tbradm
local function id20()
	local id = ''
	local guid = game:GetService('HttpService'):GenerateGUID():gsub('[{}%-]', ''):lower()
	
	-- safety measure
	local l = guid:len()
	if l ~= 32 then warn('id20: Received bad GUID from HttpService ('..guid..')') end
	if l > 32 then
		guid = guid:sub(1, 32)
	elseif l < 32 then
		guid = guid .. ('b3eaa1070acb43c8b0a39cfbdc343fa2'):sub(l+1)
	end
	
	local hex = {}
	for i, c in pairs({'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}) do
		hex[c] = i-1
	end
	local function ch(s, i)
		return hex[s:sub(i,i)]*16+hex[s:sub(i+1,i+1)]
	end
	while guid:len() > 0 do
		local str = guid:sub(1, 8)
		guid = guid:sub(9)
		id = id .. encode(string.char(ch(str, 1), ch(str, 3), ch(str, 5), ch(str, 7)))
	end
	
	return id
end
--


return {encode = ascii_encode, decode = ascii_decode, uid = id20}