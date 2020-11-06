
-- very simple test system in order to make every test function be as straight forward as possible.
-- tested functions are run in specific order so functions relying on other functions are tested last.

LApi.Tests = {}
local tests = LApi.Tests
tests.functions = {}

function tests:Run()
	local failure = false
	
	for _, fn in ipairs(self.functions) do
		local results = {self[fn]()}
		
		for i, result in ipairs(results) do
			
			if not result then
				LOG(string.format("Test %q failed on return value #%s", fn, i))
				
				failure = true
			end
		end
		
		if failure then
			break
		end
		
		LOG(string.format("Test %q succeeded", fn))
	end
end

function tests:AddTest(fn)
	table.insert(self.functions, fn)
end

function tests:AddTests(functions)
	for _, fn in ipairs(functions) do
		self:AddTest(fn)
	end
end
