---@class PackageDefinition
---@field url string
---@field name string
---@field cache boolean

local mtable = {}

math.randomseed(os.time())

local PACKAGE_CACHE_DIR = "cache/pkgcache/"

---@class NetRequire
---@overload fun(url: string, name: string, cache: boolean)
---@overload fun(pkg: PackageDefinition)
local export = setmetatable({}, mtable)

---@param fn function[]
---@return { catch: function, error: any }
local function try(fn)
	local success, res = pcall(fn[1])

	local l = {}

	---@param func function[]
	function l:catch(func)
		if not success then
			local f = func[1]
			if f ~= nil then f(res) end
		end
	end
	l.error = success

	return l
end

--DRY
local function prepare(pkg, pkgname, pkgcache)
	local cache, url, name = true, "", ""
	if type(pkg) == "table" then
		cache 	= pkg.cache or true
		url 	= pkg.url
		name 	= pkg.name or pkg.url:match(".*/([^/]+)$")
	elseif type(pkg) == "string" then
		cache 	= pkgcache or true
		url 	= pkg
		name 	= pkgname or url:match(".*/([^/]+)$")
	else
		error("First argument of getpackage must be a string or a table!")
		return nil, nil, nil, nil, nil
	end

	if url == "" then
		error("You must input a URL!")
		return nil, nil, nil, nil, nil
	end

	if cache then fs.makeDir(PACKAGE_CACHE_DIR) end
	local valid, err = http.checkURL(url)
	if not valid then error("URL \"" .. url .. "\"is not valid!\nError: " .. err) end

	local cached, cached_path = true, PACKAGE_CACHE_DIR .. name
	if cache then
		try {
			function ()
				local f = fs.find(cached_path)[1]
				if f == nil then return error() end
				cached_path = f
			end
		}:catch {
			function (err)
				cached = false
			end
		}
	end

	return url, name, cache, cached, cached_path
end

---Gets a package from a URL
---@param url string | PackageDefinition
---@param name string | nil
---@param cache boolean | nil
---@return any | nil
function export:getpackage(url, name, cache)
	local cached, cached_path = false, ""
	url, name, cache, cached, cached_path = prepare(url, name, cache)
	if url == nil then return nil end
	if name == nil then name = "package-" .. tostring(math.random(0xFFFF)) .. ".lua" end

	if not cached then
		---@type { getResponseCode: function, readAll: function, close: function } | nil
		local req, err, resp = http.get(url)
	
		if req == nil then
			error("Could not create HTTP request\nError: " .. err)
			return nil
		end

		local code, res = req.getResponseCode()
		if code ~= 200 then
			error("Did not get proper response (200), got \"" .. tostring(code) .. "\" instead!\nError: " .. res)
			return nil
		end

		---@type { close: function, write: function }
		local f = fs.open(cached_path, "w")
		f.write(req.readAll())

		f.close()
		req.close()
	end

---@diagnostic disable-next-line: need-check-nil
	if name:sub(-4, -1) == ".lua" then name = name:sub(1, -5) end

	return require("cache.pkgcache." .. name)
end

mtable.__call = export.getpackage
return export
