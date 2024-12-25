local libraries = {
	["uiTransitions"] = "client",
	["MathFunctions"] = "server",
	["Physics"] = "both",
	["Date"] = "both",
	["Vector"] = "both",
	["math"] = "both"
}

local server = {
	":Ragdoll",
	":Kill",
	":ShiftLockEnabled",
	":AddBlood",
	":HidePlayerNames",
	":LuauMoveTo",
	":DayNightCycle",
	":SendDiscordMessage",
	":Freeze",
	":Unfreeze",
	":ToBase64",
	":IsLicensed"
}

local client = {
	":ChangeChatColor",
	":ChangeChatTag",
	":Blur",
	":Scale",
	":Shake",
}

local both = {
	":getWordCount",
	":IsPerfectSquare",
	":CompactFormat", 
	":ScientificFormat", 
	":StandardFormat",
	":IsDivisibleBy",
	":IsPalindrome",
	":IsPrime",
	":Clamp",
	":ToRomanNumerals",
	":ToOrdinal",
	":ToTitleCase",
	":IsEven",
	":TweenTo",
	":ToHexadecimal",
	":ValueExists",
	":ConvertToEscape",
	":ToHex",
	":Sort"
}

for v, i in libraries do
	if i == "client" then
		table.insert(client, v)
	elseif i == "server" then
		table.insert(server, v)
	else
		table.insert(server, v)
		table.insert(client, v)
	end
end

local ses = game:GetService('ScriptEditorService')

local function changeCode(code, doc)
	if code ~= doc.Source then
		ses:UpdateSourceAsync(doc, function(oldContent)
			return code
		end)
	end
end

local Toolbar = plugin:CreateToolbar("LuaUtility")
local ToggleButton = Toolbar:CreateButton("Settings", "Configure the settings of LuaUtility", "rbxassetid://136242807953199")

local saveAll = false

local key = "settings"

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	200,
	50,
	200,
	50
)

local widget = plugin:CreateDockWidgetPluginGui("SampleWidget", widgetInfo)
widget.Title = "LuaUtility Settings"
widget.Enabled = false

local saved = plugin:GetSetting(key)

if saved then
	if saved[1] == true then
		saveAll = true
	end
end

ToggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

local f = script.Frame.Frame:Clone()
f.Parent = widget

if saveAll then
	f.Frame1.fill.BackgroundColor3 = Color3.new(0.168627, 0.694118, 1)
else
	f.Frame1.fill.BackgroundColor3 = Color3.new(1, 1, 1)
end

f.Frame1.fill.ImageLabel.Visible = saveAll

f.Frame1.MouseButton1Click:Connect(function()
	local script = f.Frame1.TextLabel

	if script.Parent.fill.ImageLabel.Visible == false then
		script.Parent.fill.BackgroundColor3 = Color3.new(0.168627, 0.694118, 1)
		saveAll = true
	else
		script.Parent.fill.BackgroundColor3 = Color3.new(1, 1, 1)
		saveAll = false
	end

	plugin:SetSetting(key, {saveAll})
	script.Parent.fill.ImageLabel.Visible = not script.Parent.fill.ImageLabel.Visible
end)

local StudioService = game:GetService("StudioService")

local customSyntaxTable = {}

for _, v in server do
	if libraries[v] then
		customSyntaxTable["(%w+)%." .. v .. "%.(%w+)%((.*)%)"] = function(obj, method, args)
			return string.format("MainModule:%s(\"%s\", %s)", v:gsub("^%l", string.upper), method, args)
		end
	else
		customSyntaxTable["(%w+)" .. v .. "%((.*)%)"] = v:gsub(":", "")
	end
end

for _, v in client do
	if libraries[v] then
		customSyntaxTable["(%w+)%." .. v .. "%.(%w+)%((.*)%)"] = function(obj, method, args)
			return string.format("MainModule:%s(\"%s\", %s)", v:gsub("^%l", string.upper), method, args)
		end
	else
		customSyntaxTable["(%w+)" .. v .. "%((.*)%)"] = v:gsub(":", "")
	end
end

--for _, v in both do
--	if libraries[v] then
--		customSyntaxTable["(%w+)%." .. v .. "%.(%w+)%((.*)%)"] = function(obj, method, args)
--			return string.format("MainModule:%s(\"%s\", %s)", v:gsub("^%l", string.upper), method, args)
--		end
--	else
--		customSyntaxTable["(%w+)" .. v .. "%((.*)%)"] = v:gsub(":", "")
--	end
--end

local scriptSource = script.both.Source

if scriptSource then
	local insideFunction = false
	local functionBlock = ""

	for line in string.gmatch(scriptSource, "[^\r\n]+") do
		task.wait()
		if string.match(line, "^function module:%w+%(") then
			insideFunction = true
		end
		if insideFunction then
			functionBlock = functionBlock .. line .. "\n"
		end
		if insideFunction and string.match(line, "^end%s*$") then
			insideFunction = false

			local a, b = script["LuaUtility client module"], script.LuauMainModule

			local function ab(c)
				c.Source = c.Source:gsub("return module", "")
				c.Source = c.Source..`\n\n`..functionBlock.."\nreturn module"
			end

			ab(a)
			ab(b)

			functionBlock = ""
		end
	end
end

local function extractFunctionSignature(sourceCode, functionName)
	local signature = "()"
	local pattern = functionName .. "%s*%((.-)%)"
	local args = sourceCode:match(pattern)
	if args then
		signature = "(" .. args .. ")"
	end
	return signature
end

local function appendLibraryFunctions(activeScript)
	local libCode = ""

	local librariesToInclude = {}

	for libraryName, libraryType in pairs(libraries) do
		if (activeScript:IsA("LocalScript") and libraryType == "client") or
			(activeScript:IsA("Script") and libraryType == "server") or 
			libraryType == "both" then

			table.insert(librariesToInclude, libraryName)
		end
	end

	for _, libraryName in ipairs(librariesToInclude) do
		libCode = libCode .. "local " .. libraryName .. " = {} "

		local module = script.libraries:FindFirstChild(libraryName)

		if module then
			local moduleSource = module.Source
			local library = require(module)

			for functionName, func in pairs(library) do
				if type(func) == "function" then
					local args = extractFunctionSignature(moduleSource, functionName)

					local cleanFunctionName = functionName:gsub(libraryName, ""):gsub("_", "")
					libCode = libCode .. "function " .. libraryName .. "." .. cleanFunctionName .. args .. " end "
				end
			end
		end
	end

	return libCode
end

for v, _ in libraries do
	task.wait()
	local scriptSource = script.libraries:FindFirstChild(v).Source
	if scriptSource then

		local a, b = script["LuaUtility client module"], script.LuauMainModule

		local function ab(c: Script)
			local n = script.libraries:FindFirstChild(v).Source
			n = n:gsub("return module", "")
			n = n:gsub("local module = {}", "")
			c.Source = c.Source:gsub("return module", "")
			c.Source = c.Source .. "\n" .. n .. "\n return module"

			for _, v in script.libraries:FindFirstChild(v):GetChildren() do
				v:Clone().Parent = c
			end
		end

		if table.find(both, v) then
			ab(a)
			ab(b)
		elseif table.find(server, v) then
			ab(b)
		elseif table.find(client, v) then
			ab(a)
		end

		functionBlock = ""
	end
end

local activeScript

local function transformCode(scriptSource, s)
	if s == nil or s.Parent == nil then return end

	if s == activeScript then
		return scriptSource
	end

	local transformedSource = scriptSource

	local thirdThing = "local MainModule = require(game:GetService('ServerScriptService'):WaitForChild('LuaUtility'):WaitForChild('LuauMainModule'))\n"

	if s:IsA("LocalScript") then
		thirdThing = "local MainModule = require(game:GetService('ServerScriptService'):WaitForChild('LuaUtility'):WaitForChild('LuaUtility client module'))\n"
	end

	local function valueExists(tbl, val)
		for _, v in tbl do
			if v == val then
				return true
			end
		end
		return false
	end

	local cases = {
		"print",
		"warn",
		"error"
	}

	local function esc(x)
		return (x:gsub('%%', '%%%%')
			:gsub('^%^', '%%^')
			:gsub('%$$', '%%$')
			:gsub('%(', '%%(')
			:gsub('%)', '%%)')
			:gsub('%.', '%%.')
			:gsub('%[', '%%[')
			:gsub('%]', '%%]')
			:gsub('%*', '%%*')
			:gsub('%+', '%%+')
			:gsub('%-', '%%-')
			:gsub('%?', '%%?'))
	end

	transformedSource = transformedSource:gsub(
		"([%w_.%(%)]+)%s*:%s*(%w+)%((.-)%)",
		function(object, functionName, args)
			if valueExists(server, ":"..functionName) or valueExists(client, ":"..functionName) or valueExists(both, ":"..functionName) then
				local transformedArgs = args--:gsub('("ssda")', 'tostring("ssda")')
				local ending = ""

				for _, v in cases do
					ending ..= object:match(v) or ""
				end

				if ending ~= "" then
					ending ..= "("
				end

				object = object:gsub(ending..esc("("), "")

				local a = (ending.."MainModule:" .. functionName .. "(" .. object .. (transformedArgs ~= "" and (", " .. transformedArgs) or "") .. ")")

				return a
			else
				return object .. ":" .. functionName .. "(" .. args .. ")"
			end
		end
	)

	transformedSource = transformedSource:gsub(
		"(%w+)%s*%.%s*(%w+)%((.-)%)",
		function(library, functionName, args)
			if libraries[library] then
				return "MainModule:" .. library .. "_" .. functionName .. "(" .. args .. ")"
			else
				return library .. "." .. functionName .. "(" .. args .. ")"
			end
		end
	)

	for v, _ in libraries do
		transformedSource = transformedSource:gsub("local%s+" .. v .. "%s*=%s*%b{}%s*", "")

		transformedSource = transformedSource:gsub("function%s+MainModule:" .. v .. "_[%w_]+%s*%b()%s*end", "")
	end

	transformedSource = transformedSource
		:gsub(string.lower("Luauu"), "")
		:gsub(",%s*%)", ")")
		:gsub(thirdThing, "")

	transformedSource = thirdThing .. transformedSource


	return transformedSource
end

local sss = game:GetService("ServerScriptService")

local function save(scriptToTransform)
	if scriptToTransform.Name ~= "LuaUtility Script" then
		local transformedSource = transformCode(scriptToTransform.Source, scriptToTransform)
		local luauContainer = sss:FindFirstChild("LuaUtility")

		if not luauContainer then
			luauContainer = script:FindFirstChild("LuaUtility")
			luauContainer.Parent = sss
		end

		local luauScript = scriptToTransform:FindFirstChild("LuaUtility Script") or Instance.new(scriptToTransform.ClassName, scriptToTransform)
		luauScript.Source = scriptToTransform.Source
		luauScript.Name = `LuaUtility Script`

		luauScript.Enabled = false

		if activeScript ~= scriptToTransform then
			changeCode(transformedSource, scriptToTransform)
		end
	end
end

local function saveScript(scriptToTransform)
	if scriptToTransform.ClassName:find("Script") and scriptToTransform.Source then
		if scriptToTransform.Parent == nil then return end

		if scriptToTransform:IsA("ModuleScript") then
			if scriptToTransform.Name:find("LuaUtility Script") then return end

			if scriptToTransform.Source:find(string.lower("--LuaUtility")) and not scriptToTransform.Parent.Name:lower():find("LuaUtility") then
				save(scriptToTransform)
			elseif saveAll and not scriptToTransform.Parent.Name:lower():find("LuaUtility") then
				save(scriptToTransform)
			end

			return
		end

		if scriptToTransform.Name:find("LuaUtility Script") or scriptToTransform.Enabled == false then return end

		if scriptToTransform.Source:find(string.lower("--LuaUu")) and not scriptToTransform.Parent.Name:lower():find("LuaU") then
			save(scriptToTransform)
		elseif saveAll and not scriptToTransform.Parent.Name:lower():find("LuaUtility") then
			save(scriptToTransform)
		end
	end
end

viewableServices = {
	[game.Workspace] = true,
	[game.ServerStorage] = true,
	[game.ReplicatedStorage] = true,
	[game.Players] = true,
	[game.ReplicatedFirst] = true,
	[game.StarterGui] = true,
	[game.StarterPack] = true,
	[game.StarterPlayer] = true,
	[game.TextChatService] = true,
}

f.Frame.MouseButton1Click:Connect(function()
	for _, v: Script in game:GetDescendants() do
		task.wait()
		if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
			for service, _ in viewableServices do
				if v:IsDescendantOf(service) then
					saveScript(v)
				end
			end
		end
	end

	print("Converted All Scripts Successfully!")
end)

local lastScript = nil

local function checks(t, args)
	local RunService = game:GetService("RunService")

	if t ~= nil then
		local newActiveScript = args

		if newActiveScript == nil or RunService:IsRunning() then return false end
		if newActiveScript.Name == "LuaUtility Script" then return false end
		if newActiveScript.Parent.Name == "LuaUtility" then return false end
	else
		local luauSource = args[1]
		local lastSource = args[2]
		local luauScript = args[3]

		if lastScript.Name == "LuaUtility Script" then return false end
		if not luauSource then return false end
		if not lastSource then return false end
		if luauScript == activeScript then return false end
		if not lastSource:find("local Date = {}") then return false end
	end

	return true
end

local function changeTo(newActiveScript : Script)
	local RunService = game:GetService("RunService")
	if not RunService:IsRunning() then
		if lastScript and lastScript.Parent and lastScript:FindFirstChild("LuaUtility Script") then
			if lastScript ~= activeScript then
				-- close
				local luauScript = lastScript:FindFirstChild("LuaUtility Script")
				local lastSource = lastScript.Source
				local luauSource = luauScript.Source

				if checks(nil, {luauSource, lastSource, luauScript}) then
					changeCode(lastSource, luauScript)
					changeCode(transformCode(lastSource, lastScript), lastScript)
				end
			end
		end
	end

	if checks("hi there!", newActiveScript) then
		lastScript = activeScript

		local luauScript = activeScript:FindFirstChild("LuaUtility Script")
		if luauScript ~= nil and luauScript.Parent ~= nil then
			if newActiveScript == nil or newActiveScript.Parent == nil then return end
			--open
			local activeSource = newActiveScript.Source
			local luauSource = luauScript.Source

			if not luauSource:find("local Date = {}") then
				warn("Orginial script detected as corrupted")
			end

			task.wait(.1)

			changeCode(luauSource, activeScript)
			changeCode("-- nothing here :(", luauScript)
		end
	end
end

local function onActiveScriptChanged()
	local newActiveScript = StudioService.ActiveScript

	activeScript = newActiveScript

	if activeScript or (lastScript ~= nil and lastScript.Parent ~= nil) then
		changeTo(activeScript)

		if not activeScript then
			saveScript(lastScript)
		end
	end
end

StudioService:GetPropertyChangedSignal("ActiveScript"):Connect(onActiveScriptChanged)

if not sss:FindFirstChild("LuaUtility") then
	local luauContainer = script:FindFirstChild("LuaUtility"):Clone()
	luauContainer.Parent = sss

	local m = script.LuauMainModule:Clone()
	m.Parent = luauContainer
end

if sss:FindFirstChild("LuaUtility") then
	local c = sss:FindFirstChild("LuaUtility"):FindFirstChild("LuaUtility client module")
	local m = sss:FindFirstChild("LuaUtility"):FindFirstChild("LuauMainModule")

	local cf, cm = false, false

	if c then
		c.Source = script["LuaUtility client module"].Source
		cf = true
	else
		script["LuaUtility client module"]:Clone().Parent = sss:FindFirstChild("LuaUtility")
	end

	if m then
		m.Source = script["LuauMainModule"].Source
		cm = true
	else
		script["LuauMainModule"]:Clone().Parent = sss:FindFirstChild("LuaUtility")
	end

	if cf then
		c:ClearAllChildren()
	end

	if cm then
		m:ClearAllChildren()
	end

	for _, v in script.LuauMainModule:GetChildren() do
		v:Clone().Parent = m
	end

	for _, v in script["LuaUtility client module"]:GetChildren() do
		v:Clone().Parent = c
	end
end

game:GetService("RunService").Heartbeat:Connect(function()
	if activeScript == nil then return end

	if activeScript:IsA("Script") or activeScript:IsA("LocalScript") then
		if game.ServerStorage:FindFirstChild("ScriptFaster") then
			if activeScript.Parent == game.ServerStorage:FindFirstChild("LuaUtility") then
				return
			end
		end

		local newCode = activeScript.Source
		if newCode:find(string.lower("--LuaUu")) and not newCode:find("local uiTransitions = {}") and not newCode:find("local MathFunctions = {}") then
			local libraryFunctions = appendLibraryFunctions(activeScript)
			newCode = newCode:gsub(string.lower("--LuaUu"), libraryFunctions .. `\n{string.lower("--LuaUu")}\n`)

			if libraryFunctions ~= "" then
				changeCode(newCode, activeScript)
			end
		end
	end
end)
