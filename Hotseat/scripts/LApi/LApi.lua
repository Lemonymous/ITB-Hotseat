
local path = GetParentPath(...)

VERSION = "0.2.0"

if LApi == nil or modApi:isVersion(VERSION, LApi.version) then
	LApi = LApi or {
		initialized = false,
		finalized = false
	}

	function LApi:init()
		if self.initialized then
			return
		end
		
		self.initialized = true
	end
	
	function LApi:load()
		self.finalized = false
		
		modApi:addModsLoadedHook(function()
			if self.finalized then
				return
			end
			
			self:finalize()
			self.finalized = true
		end)
	end
	
	function LApi:finalize()
		require(path .."dll/cutils")
		require(path .."api/__scripts")
		require(path .."utils/utils")
		
		if self.file_exists then
			require(path .."tests/__scripts")
		end
	end
end

return LApi
