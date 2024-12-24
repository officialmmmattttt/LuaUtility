local module = {
	uis = [[local uis = game:GetService("UserInputService")

uis.InputBegan:Connect(function(input, GPE) -- This will detect the input, Connecting to the input that got in, GPE = Game Processed Event and is if the game processed it and if the player is busy, like typing in the chat for an example
	if GPE then return end
	print(input.KeyCode)
end)]];
}

return module
