local toolBar = plugin:CreateToolbar("LuaUtility")
local one = "("
local two = ")"
local info = toolBar:CreateButton("Find Scripts", "Find Scripts Faster!", "rbxassetid://16385627537")

info.Click:Connect(function()
	local oldText = nil

	if game.CoreGui:FindFirstChild("findScripts") then
		game.CoreGui:FindFirstChild("findScripts"):Destroy()
	else
		local find = script.findScripts:Clone()
		find.Parent = game.CoreGui

		find.Frame.x.MouseButton1Click:Connect(function()
			find:Destroy()
		end)

		find.Frame.filter.MouseButton1Click:Connect(function()
			find.Frame.filterDropDown.Visible = not find.Frame.filterDropDown.Visible
		end)

		find.Frame.filterDropDown.secondFilter.MouseButton1Click:Connect(function()
			find.Frame.filter.Text = find.Frame.filterDropDown.secondFilter.Text
			if find.Frame.filter.Text == "Filter: Name" then
				find.Frame.filterDropDown.secondFilter.Text = "Filter: Source"
			else
				find.Frame.filterDropDown.secondFilter.Text = "Filter: Name"
			end
			find.Frame.filterDropDown.Visible = false
		end)

		game["Run Service"].RenderStepped:Connect(function()
			pcall(function()


				if find.Parent == game.CoreGui then

					local bar = find.Frame.bar
					local filter = find.Frame.filter.Text

					local reg = "rbxassetid://16361332208"
					local localS = "rbxassetid://16361314998"
					local module = "rbxassetid://16361322334"

					if find.Frame.bar.Text ~= oldText then 
						oldText = find.Frame.bar.Text



						for i, v in pairs(find.Frame.scripts:GetChildren()) do
							if v:IsA("TextButton") then 
								v:Destroy()
							end
						end

						find.Frame.error.Visible = false

						for i, v in pairs(game:GetDescendants()) do
							if filter == "Filter: Name" then
								if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
									if string.find(string.lower(v.Name), tostring(bar.Text)) then
										local template = script.template:Clone()
										template.Name = v.Name
										template.name.Text = v.Name

										if v:IsA("Script") or v:IsA("LocalScript") then
											if v.Enabled == false then
												template.name.Text = "[Disabled] "..v.Name
											end
										end

										template.location.Text = "game."..v:GetFullName()
										template.loc.Value = v
										if v:IsA("Script") and not v:IsA("LocalScript") then
											template.scriptImage.Image = reg
										elseif v:IsA("ModuleScript") then
											template.scriptImage.Image = module
										end
										if not string.find(v:GetFullName(), "CoreGui") then
											template.Parent = find.Frame.scripts
										end
									end
								end
							end
						end

						for i, v in pairs(game:GetDescendants()) do
							if filter == "Filter: Source" then
								if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
									local source = v.Source
									if string.find(string.lower(source), tostring(bar.Text)) then
										local template = script.template:Clone()
										template.Name = v.Name
										template.name.Text = v.Name

										if v:IsA("Script") or v:IsA("LocalScript") then	
											if v.Enabled == false then
												template.name.Text = "[Disabled] "..v.Name
											end
										end

										template.location.Text = v:GetFullName()
										template.loc.Value = v
										if v:IsA("Script") and not v:IsA("LocalScript") then
											template.scriptImage.Image = reg
										elseif v:IsA("ModuleScript") then
											template.scriptImage.Image = module
										end
										if not string.find(v:GetFullName(), "CoreGui") then
											template.Parent = find.Frame.scripts
										end
									end
								end
							end
						end

						local amount = 0

						for i, v in pairs(find.Frame.scripts:GetChildren()) do
							if v:IsA("TextButton") then
								amount += 1
							end
						end

						if amount == 0 then
							find.Frame.error.Visible = true
							find.Frame.error.Text = "No Results"
						end

						for i, v in pairs(find.Frame.scripts:GetChildren()) do
							if v:IsA("TextButton") then
								v.MouseButton1Up:Connect(function()
									local Selection = game:GetService("Selection")
									Selection:Set({v.loc.Value})
								end)
							end
						end
					end
				end
			end)
		end)
	end
end)
