local toolBar = plugin:CreateToolbar("LuaUtility")

local info = toolBar:CreateButton("Macros", "Edit your Macros!", "rbxassetid://16411790722")

local Macros = nil

local read = nil

local key = "customMacros"

local whatToSave = {}

local existingValue1 = plugin:GetSetting(key)

if existingValue1 then
	for i = 1, #existingValue1, 3 do
		local newScript = Instance.new("Script", script.Parent.replacing.savedMacros)
		newScript.Name = existingValue1[i]
		newScript.Enabled = false
		newScript.Source = existingValue1[i + 2]
	end
end

info.Click:Connect(function()
	if game.ServerStorage:FindFirstChild("Macros") then
		Macros = game.ServerStorage.Macros
		read = Macros.README
		-- save the work
		
		whatToSave = {}

		for i, v in pairs(Macros:GetChildren()) do
			if v:IsA("Script") then
				table.insert(whatToSave, v.Name)
				table.insert(whatToSave, v.Enabled)
				table.insert(whatToSave, v.Source)
			end
		end
		
		plugin:SetSetting(key, whatToSave)
		
		read = nil
		Macros:Destroy()
		Macros = nil
		
		print("Macros successfully saved!")
		
		local existingValue1 = plugin:GetSetting(key)
		
		if script.Parent:FindFirstChild("replacing") then
			script.Parent.replacing.savedMacros:ClearAllChildren()
		end
		
		if existingValue1 then
			for i = 1, #existingValue1, 3 do
				local newScript = Instance.new("Script", script.Parent.replacing.savedMacros)
				newScript.Name = existingValue1[i]
				newScript.Enabled = existingValue1[i + 1]
				newScript.Source = existingValue1[i + 2]
			end
		end
		
	else
		Macros = script.Macros:Clone()
		read = Macros.README
		
		
		-- unload the work
		
		local existingValue = plugin:GetSetting(key)
		
		if existingValue then
			
			for i, v in pairs(Macros:GetChildren()) do
				v:Destroy()
			end
			
			for i = 1, #existingValue, 3 do
				local newScript = Instance.new("Script", Macros)
				newScript.Name = existingValue[i]
				newScript.Enabled = existingValue[i + 1]
				newScript.Source = existingValue[i + 2]
			end
		end
		Macros.Parent = game.ServerStorage
		if Macros:FindFirstChild("README") then
			Macros:FindFirstChild("README").Source = script.Macros.README.Source
		end
		
		local Selection = game:GetService("Selection")
		Selection:Set({Macros})
	end
end)



game["Run Service"].RenderStepped:Connect(function()
	if Macros ~= nil then
		Macros.Name = "Macros"
		Macros.Archivable = true
		if Macros.Parent ~= game.ServerStorage then
			Macros.Parent = game.ServerStorage
		end
	end
end)
