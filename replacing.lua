local RunService = game:GetService("RunService")
local ses = game:GetService('ScriptEditorService')

local function changeCode(code, doc)
	if code ~= doc.Source then
		ses:UpdateSourceAsync(doc, function(oldContent)
			return code
		end)
	end
end

local function functions(doc)
	local code = doc.Source
	local newCode = code

	local regFunctions = require(script.regFunctions)
	local allFunctions = require(script.allFunctions)
	local LocalFunctions = require(script.localFunctions)
	if doc.Name == "README" or doc.Name == "WARNING" then return end
	if doc.Parent.Name == "Macros" then return end
	if doc.Parent == script.Parent.macrosScript.Macros then 
	else
		if game.ServerStorage:FindFirstChild("Macros") then
			if doc.Parent == game.ServerStorage.Macros then
			else
				if doc:IsA("Script") and not doc:IsA("LocalScript") then
					for abbreviation, service in pairs(regFunctions) do
						local servicePattern = "//"..abbreviation
						local replacement = service
						newCode = newCode:gsub(servicePattern, replacement)
						changeCode(newCode, doc)
					end
				end

				for abbreviation, service in pairs(allFunctions) do
					local servicePattern = "//"..abbreviation
					local replacement = service
					newCode = newCode:gsub(servicePattern, replacement)
					changeCode(newCode, doc)
				end

				for abbreviation, service in pairs(LocalFunctions) do
					local servicePattern = "//"..abbreviation
					local replacement = service
					newCode = newCode:gsub(servicePattern, replacement)
					changeCode(newCode, doc)
				end
			end
		end

		if doc:IsA("Script") and not doc:IsA("LocalScript") then
			for abbreviation, service in pairs(regFunctions) do
				local servicePattern = "//"..abbreviation
				local replacement = service
				newCode = newCode:gsub(servicePattern, replacement)
				changeCode(newCode, doc)
			end
		end

		for abbreviation, service in pairs(allFunctions) do
			local servicePattern = "//"..abbreviation
			local replacement = service
			newCode = newCode:gsub(servicePattern, replacement)
			changeCode(newCode, doc)
		end

		for abbreviation, service in pairs(LocalFunctions) do
			local servicePattern = "//"..abbreviation
			local replacement = service
			newCode = newCode:gsub(servicePattern, replacement)
			changeCode(newCode, doc)
		end
	end
end

local function customMacros(doc)
	local code = doc.Source
	local newCode = code

	for i, Script in pairs(script.savedMacros:GetChildren()) do
		local servicePattern = "//"..Script.Name
		local replacement = Script.Source
		if Script.Enabled == true then
			newCode = newCode:gsub(servicePattern, replacement)
			changeCode(newCode, doc)
		end
	end
end

local function selectionMacro(doc)
	local code : string = doc.Source

	local selection = game:GetService("Selection"):Get()[1]

	if selection and selection.Parent ~= nil then
		changeCode(code:gsub(string.lower("//Selection"), `local {selection.Name} = game.{selection:GetFullName()}`), doc)
	end	
end

local activeScript = nil

function OnActiveScriptChanged()
	local sc = game:GetService("StudioService").ActiveScript
	activeScript = sc
end

game:GetService("StudioService"):GetPropertyChangedSignal("ActiveScript"):Connect(OnActiveScriptChanged)

game:GetService("RunService").Heartbeat:Connect(function()
	if activeScript == nil then return end
	if activeScript:IsA("Script") or activeScript:IsA("LocalScript") then
		if game.ServerStorage:FindFirstChild("ScriptFaster") then
			if activeScript.Parent == game.ServerStorage.ScriptFaster then
				return
			end
		end

		functions(activeScript)
		customMacros(activeScript)
		selectionMacro(activeScript)
	end
end)
