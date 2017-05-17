
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


