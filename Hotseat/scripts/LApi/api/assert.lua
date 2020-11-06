
local function buildErrorMsg(signatures)
	local afterDivider = "^.-|"
	local msg = "No matching overload found, candidates:"
	
	for _, sig in ipairs(signatures) do
		msg = msg .. string.format("\n%s %s(", signatures.ret, signatures.func)
		
		for i = 1, #sig do
			msg = msg .. sig[i]:gsub(afterDivider, "")
			
			if i < #sig then
				msg = msg ..", "
			end
		end
		
		msg = msg ..")"
	end
	
	return msg
end

function LApi.AssertSignature(signatures)
	local beforeDivider = "|.+$"
	local signature_match_found
	
	for _, sig in ipairs(signatures) do
		signature_match_found = #sig == #signatures.params
		
		for i = 1, #sig do
			local param = signatures.params[i]
			local validParam = sig[i]:gsub(beforeDivider, "")
			
			if type(param) ~= validParam then
				signature_match_found = false
			end
		end
		
		if signature_match_found then
			break
		end
	end
	
	assert(signature_match_found, signature_match_found and "" or buildErrorMsg(signatures))
end
