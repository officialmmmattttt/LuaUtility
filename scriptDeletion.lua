local services = {
	"ServerScriptService",
	"StarterGui"
}

game:GetService("RunService").Heartbeat:Connect(function()
	if game:GetService("RunService"):IsStudio() then
		for _, service in services do
			local serviceObject = game:GetService(service)
			local luauFolder = serviceObject:FindFirstChild("Luau+")
			if luauFolder then
				for _, script: Script in luauFolder:GetChildren() do
					local luauObj = script:FindFirstChild("LuauObj")
					if luauObj and luauObj:IsA("ObjectValue") then
						local luauObjValue = luauObj.Value
						if not luauObjValue or not luauObjValue.Parent then
							script:Destroy()
						end
					end
				end
			end
		end
	end
end)
