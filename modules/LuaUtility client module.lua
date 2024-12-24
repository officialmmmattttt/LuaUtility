local module = {}

function module:ChangeChatColor(service, player, color)
	local TextChatService = service
	local Players = game:GetService("Players")

	TextChatService.OnIncomingMessage = function(message)
		if not message.TextSource then return end
		local messagePlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
		if messagePlayer == player then
			local properties = Instance.new("TextChatMessageProperties")
			local hexColor = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
			properties.PrefixText = string.format("<font color='%s'>%s:</font>", hexColor, player.Name)
			return properties
		end
	end
end

function module:ChangeChatTag(service, player, tagName, color)
	local TextChatService = service
	local Players = game:GetService("Players")

	TextChatService.OnIncomingMessage = function(message)
		if not message.TextSource then return end
		local messagePlayer = Players:GetPlayerByUserId(message.TextSource.UserId)
		if messagePlayer == player then
			local properties = Instance.new("TextChatMessageProperties")
			local hexColor = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
			properties.PrefixText = string.format(`<font color='%s'>[{tagName}] %s:</font>`, hexColor, player.Name)
			return properties
		end
	end
end

function module:IsDivisibleBy(a, b)
	return a % b == a - math.floor(a/b)*b
end

function module:getWordCount(text)
	return #string.split(text,  " ")
end

function module:IsPerfectSquare(x)
	return math.sqrt(x) == math.floor(math.sqrt(x))
end

function module:ScientificFormat(number: number)
	if number == 0 then
		return 0
	else
		local exponent = math.floor(math.log10(math.abs(number)))
		local mantissa = number / (10 ^ exponent)
		return string.format("%.2fe%d", mantissa, exponent)
	end
end

function module:StandardFormat(number: number): string
	local formatted = tostring(number)
	local k
	while task.wait() do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then
			break
		end
	end
	return formatted
end

function module:CompactFormat(number)
	local absNumber = math.abs(number)
	local formatted

	if absNumber >= 1e63 then
		formatted = string.format("%.2fV", number / 1e63)
	elseif absNumber >= 1e60 then
		formatted = string.format("%.2fN", number / 1e60)
	elseif absNumber >= 1e57 then
		formatted = string.format("%.2fO", number / 1e57)
	elseif absNumber >= 1e54 then
		formatted = string.format("%.2fS", number / 1e54)
	elseif absNumber >= 1e51 then
		formatted = string.format("%.2fSx", number / 1e51)
	elseif absNumber >= 1e48 then
		formatted = string.format("%.2fQd", number / 1e48)
	elseif absNumber >= 1e45 then
		formatted = string.format("%.2fQ", number / 1e45)
	elseif absNumber >= 1e42 then
		formatted = string.format("%.2fT", number / 1e42)
	elseif absNumber >= 1e39 then
		formatted = string.format("%.2fD", number / 1e39) 
	elseif absNumber >= 1e36 then
		formatted = string.format("%.2fU", number / 1e36)
	elseif absNumber >= 1e33 then
		formatted = string.format("%.2fD", number / 1e33)
	elseif absNumber >= 1e30 then
		formatted = string.format("%.2fN", number / 1e30)
	elseif absNumber >= 1e27 then
		formatted = string.format("%.2fO", number / 1e27)
	elseif absNumber >= 1e24 then
		formatted = string.format("%.2fY", number / 1e24)
	elseif absNumber >= 1e21 then
		formatted = string.format("%.2fZ", number / 1e21)
	elseif absNumber >= 1e18 then
		formatted = string.format("%.2fE", number / 1e18)
	elseif absNumber >= 1e15 then
		formatted = string.format("%.2fP", number / 1e15)
	elseif absNumber >= 1e12 then
		formatted = string.format("%.2fT", number / 1e12)
	elseif absNumber >= 1e9 then
		formatted = string.format("%.2fB", number / 1e9)
	elseif absNumber >= 1e6 then
		formatted = string.format("%.2fM", number / 1e6)
	elseif absNumber >= 1e3 then
		formatted = string.format("%.2fK", number / 1e3)
	else
		formatted = tostring(number)
	end

	formatted = formatted:gsub(".00", "")

	return formatted
end

function module:Blur(frame)
	local Clone = script.BlurCreator:Clone()
	Clone.Parent = frame
	Clone.Enabled = true
end

function module:Scale(uiStroke)
	if typeof(uiStroke) == "UIStroke" then
		local BASE_SIZE = 1200

		local initialStrokeThickness = uiStroke.Thickness

		local camera = game:GetService("Workspace").CurrentCamera

		uiStroke.Thickness = initialStrokeThickness * camera.ViewportSize.X / BASE_SIZE
	end
end

function module:Shake(camera, intensity, duration)
	local runService = game:GetService("RunService")
	local startTime = tick()

	runService:BindToRenderStep("ShakeEffect", Enum.RenderPriority.Camera.Value + 1, function()
		local elapsed = tick() - startTime
		if elapsed > duration then
			runService:UnbindFromRenderStep("ShakeEffect")
		else
			camera.CFrame = camera.CFrame * CFrame.new(
				math.random(-intensity, intensity) * 0.01,
				math.random(-intensity, intensity) * 0.01,
				0
			)
		end
	end)
end

return module
