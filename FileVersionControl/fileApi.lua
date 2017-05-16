
local require  = require 
local package_loaded_ = package.loaded
local g_next_ = _G.next
local type = type
local io_open_ = io.open
local os_execute_ = os.execute

local M = {}
local modname = ...
_G[modname] = M
package_loaded_[modname] = M
_ENV = M

local crypto = require 'crypto'
local lfs_ = require 'lfs'
local luaext_ = require 'luaext'

--ÅÐ¶Ï±íÊÇ·ñÎª¿Õ
function table_is_empty(t)
	return g_next_(t) == nil
end

function file_is_exist(fileName)
	local file = io_open_ (fileName,'rb')
	if file then file:close() return file end 
end

function attrib_delete_read(file) 
	if type(file) ~= "string" then return end 
	if file_is_exist(file) then
		os_execute_("ATTRIB -R \"" .. file .. "\"")
		return true
	end
end

function copy_file(OldFile,NewFile) 
	os_execute_("copy /y " .. "\"" .. OldFile .. "\"" .. " " .. "\"" .. NewFile .. "\"")
end 

function get_str_hash(str)
	local dig = crypto.digest;
	local d = dig:new("sha1");
	local s1 = d:final(str)
	d:reset();
	return s1
end

--example:file = 'e:/a/b/c.lua'
function get_file_hash(file)
	local file = file_is_exist(file)
	if not file then return end 
	local str = file:read('*all')
	file:close()
	return get_str_hash(str)	
end

function get_file_time(file)
	local attr = lfs_.attributes(file)
	if type(attr) ~= 'table' then return end 
	return {modify = attr.modification,status = attr.change,access = attr.access}
end

function get_file_size(fileName)
	local t = lfs_.attributes(fileName)
	return t and t.size
end

--folder : + 0
function get_folder_gid()
	return luaext_.guid() .. '0'
end

--file : + 1
function get_file_gid()
	return luaext_.guid() .. '1'
end

function get_file_hid(file)
	return get_file_hash(file)
end

--file = 'c:/a/b/c.lua'
function open_file(file)
	os_execute_("start \"\" " .. file)
end

--dir = 'c:/a/b'
function open_floder(dir)
	os_execute_("explorer  " .. dir)
end

function serialize(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. string.format("%q", obj)  
    elseif t == "table" then  
        lua = lua .. "{\n"  
    for k, v in pairs(obj) do  
        lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
    end  
    local metatable = getmetatable(obj)  
	if metatable ~= nil and type(metatable.__index) == "table" then  
        for k, v in pairs(metatable.__index) do  
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
        end  
    end  
        lua = lua .. "}"  
    elseif t == "nil" then  
        return nil  
    else  
        error("can not serialize a " .. t .. " type.")  
    end  
    return lua  
end  
  
function unserialize(lua)  
    local t = type(lua)  
    if t == "nil" or lua == "" then  
        return nil  
    elseif t == "number" or t == "string" or t == "boolean" then  
        lua = tostring(lua)  
    else  
        error("can not unserialize a " .. t .. " type.")  
    end  
    lua = "return " .. lua  
    local func = loadstring(lua)  
    if func == nil then  
        return nil  
    end  
    return func()  
end  

