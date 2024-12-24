local module = {}

local dnc = false

function module:DayNightCycle(s, dayDuration: number, nightDuration: number)
	if dnc then return else dnc = true end
	if s:GetFullName() == "Lighting" then
		task.spawn(function()
			local lighting = game:GetService("Lighting")
			local tweenService = game:GetService("TweenService")

			local function tween (l, p)
				tweenService:Create(lighting, TweenInfo.new(l, Enum.EasingStyle.Linear, Enum.EasingDirection.In), p):Play()
			end

			lighting.ClockTime = 6

			while type(dayDuration) == "number" and type(nightDuration) == "number" do

				tween(dayDuration, {ClockTime = 18})
				wait(dayDuration)

				tween(nightDuration / 2, {ClockTime = 24})
				wait(nightDuration / 2)
				tween(nightDuration / 2, {ClockTime = 6})
				wait(nightDuration / 2)
			end
		end)
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

function module:ShiftLockEnabled(s, boolen: boolean)
	game.StarterPlayer.EnableMouseLockOption = not boolen
end

function module:AddBlood(player: Player, bloodSize: number)
	pcall(function()
		local char = player.Character
		local plr = player
		local debris = game:GetService("Debris")
		local tweenService = game:GetService("TweenService")

		local folder

		if not workspace:FindFirstChild("Blood") then
			folder = Instance.new("Folder", workspace)
			folder.Name = "Blood"
		end

		local charFolder = Instance.new("Folder", folder)
		charFolder.Name = plr.Name



		local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or nil
		local root = char:FindFirstChild("HumanoidRootPart") or nil
		local base

		local function bloodPool (part, limbCenter)

			local pool = Instance.new("Part", charFolder)
			pool.CanCollide = false
			pool.BrickColor = BrickColor.new("Crimson")
			pool.Material = Enum.Material.Sand
			pool.Transparency = .2
			pool.CastShadow = false
			pool.Shape = "Cylinder"
			pool.Anchored = true

			pool.Size = Vector3.new(.1, 0, 0)		
			pool.CFrame = part.CFrame	

			if limbCenter then
				pool.CFrame = CFrame.new(torso.Position.X + math.random(-4, 4), base.Position.Y - (base.Size.Y / 2) + math.random(0, .2), torso.Position.Z + math.random(-4, 4)) 
			else
				pool.CFrame = CFrame.new(torso.Position.X + math.random(-4, 4), base.Position.Y + (base.Size.Y / 2), torso.Position.Z + math.random(-4, 4)) 
			end

			pool.Orientation = Vector3.new(0, 0, 90)
			tweenService:Create(pool, TweenInfo.new(math.random(.4, 4), Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = Vector3.new(.1, math.random(3, 7) * bloodSize, math.random(3, 7) *bloodSize)}):Play()

			debris:AddItem(pool, 9)
		end

		if char.Humanoid.RigType == Enum.HumanoidRigType.R6 then
			wait(.2)
			if not char:FindFirstChild("Head") and workspace:FindFirstChild(plr.Name .. "-2") then
				char = workspace[plr.Name .. "-2"]
			end
		end

		repeat wait() until math.floor(torso.Velocity.Magnitude) == 0
		local baseBlacklist = char:GetChildren()

		pcall(function ()
			for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
				if plr.Character then
					for _,v in pairs(plr.Character:GetChildren()) do
						if v:IsA("BasePart") then
							table.insert(baseBlacklist, v)
						elseif v:IsA("Accoutrement") then
							table.insert(baseBlacklist, v:FindFirstChildWhichIsA("BasePart"))
						elseif v:IsA("Tool") and v:FindFirstChild("Handle") then
							table.insert(baseBlacklist, v.Handle)
						end
					end
				end
				if workspace:FindFirstChild(plr.Name .. "-2") then
					for _,p in pairs(workspace[plr.Name .. "-2"]:GetChildren()) do
						if p:IsA("BasePart") then
							table.insert(baseBlacklist, p)
						elseif p:IsA("Accoutrement") then
							table.insert(baseBlacklist, p:FindFirstChildWhichIsA("BasePart"))
						end
					end
				end
			end
		end)

		if type(baseBlacklist) == "table" then	

			local limbCenter = false
			base = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(torso.Position - torso.Size * 2, torso.Position + torso.Size * 2), baseBlacklist, 1)[1]

			if not base then
				if char:FindFirstChild("Left Leg") then
					base = char["Left Leg"]
					limbCenter = true
				elseif char:FindFirstChild("LeftFoot") then
					base = char["LeftFoot"]
					limbCenter = true
				end
			end

			if base then
				for _,limb in pairs(char:GetChildren()) do
					if limb:IsA("BasePart") and limb.Name ~= "HumanoidRootPart" then
						bloodPool(limb, limbCenter)
					end
				end
			end
		end
	end)
end

function module:HidePlayerNames(s)
	if s:GetFullName() == "Players" then
		pcall(function()
			for _, v in pairs(game:GetService("Players"):GetChildren()) do
				local char = v.Character
				local humanoid = char:WaitForChild("Humanoid")
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
		end)

		task.spawn(function()
			local playerService = game:GetService("Players")

			playerService.PlayerAdded:Connect(function (plr)
				plr.CharacterAdded:Connect(function (char) 
					local humanoid = char:WaitForChild("Humanoid")
					humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				end)
			end)
		end)
	else
		error("Unknown Global "..s)
	end
end

function module:LuauMoveTo(hum: Model, targetPosition: Vector3, waitAfterEnd: boolean)
	local npc = hum.Parent
	if not npc:FindFirstChildWhichIsA("Humanoid") then error("Invalid Humanoid") end

	local humanoid = npc.Humanoid
	local PathfindingService = game:GetService("PathfindingService")

	local path = PathfindingService:CreatePath()
	path:ComputeAsync(npc.PrimaryPart.Position, targetPosition)

	local waypoints = path:GetWaypoints()

	for _, waypoint in ipairs(waypoints) do
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

		humanoid:MoveTo(waypoint.Position)
		
		if waitAfterEnd == true then
			humanoid.MoveToFinished:Wait()
		end

		if (npc.HumanoidRootPart.Position - targetPosition).Magnitude < 3 then
			return
		end
	end
end

function module:Kill(humanoid: Humanoid)
	if not humanoid:IsA("Humanoid") then error("Invalid Humanoid") end

	humanoid.Health = 0
end

function module:Ragdoll(hum: Humanoid, keepRagdollAfterRespawn: boolean)
	local character = hum.Parent
	if not character:FindFirstChildWhichIsA("Humanoid") then error("Invalid Humanoid") end

	local char = character
	local plr = character
	local humanoid = char.Humanoid

	if char:FindFirstChild("HumanoidRootPart") then

		module:Kill(hum)

		local rig = humanoid.RigType
		local root = char.HumanoidRootPart

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		root.Anchored = true
		root.CanCollide = false

		if rig == Enum.HumanoidRigType.R6 then

			local function stick (cl, p0, p1, c0, c1, p) 
				local a = Instance.new(cl)
				a.Part0 = p0
				a.Part1 = p1
				a.C0 = c0
				a.C1 = c1
				a.Parent = p
			end

			local function createLimb (p, char)
				local limb = Instance.new("Part", char)
				limb.formFactor = "Symmetric"
				limb.Size = Vector3.new(1, 1, 1)
				limb.Transparency = 1
				limb.CFrame = p.CFrame * CFrame.new(0, -0.5, 0)
				local W = Instance.new("Weld")
				W.Part0 = p
				W.Part1 = limb
				W.C0 = CFrame.new(0, -.5, 0)
				W.Parent = p
			end

			char.Archivable = true
			local charClone = char:Clone()
			charClone.Name = plr.Name .. "-2"
			char.Archivable = false

			for _,v in pairs(charClone:GetChildren()) do
				if v:IsA("BasePart") then
					for _,vv in pairs(v:GetChildren()) do
						if vv:IsA("Weld") or vv:IsA("Motor6D") then
							vv:Destroy()
						end
					end
				elseif v:IsA("Script") or v:IsA("LocalScript") or v:IsA("Tool") then
					v:Destroy()
				end
			end

			local hum2 = charClone.Humanoid
			hum2.Name = "Humanoid2"
			hum2.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

			wait(.1)
			for _,v in pairs(char:GetChildren()) do
				if v:IsA("BasePart") or v:IsA("Accoutrement") or v:IsA("Script") or v:IsA("LocalScript") then
					v:Destroy()
				end
			end

			char = charClone
			local torso = char.Torso

			for _,p in pairs(char:GetChildren()) do
				if p:IsA("BasePart") then
					if p.Name == "Head" then
						stick("Weld", torso, char.Head, CFrame.new(0, 1.5, 0), CFrame.new(), torso)
					elseif p.Name == "Torso" then
						local Bar = Instance.new("Part")
						Bar.TopSurface = 0
						Bar.BottomSurface = 0
						Bar.formFactor = "Symmetric"
						Bar.Size = Vector3.new(1, 1, 1)
						Bar.Transparency = 1
						Bar.CFrame = p.CFrame * CFrame.new(0, .5, 0)
						Bar.Parent = char
						local Weld = Instance.new("Weld")
						Weld.Part0 = p
						Weld.Part1 = Bar
						Weld.C0 = CFrame.new(0, .5, 0)
						Weld.Parent = p
					elseif p.Name == "Right Arm" then
						p.CFrame = torso.CFrame * CFrame.new(1.5, 0, 0)
						stick("Glue", torso, p, CFrame.new(1.5, .5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), CFrame.new(-0, .5, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), torso)
						createLimb(p, char)
					elseif p.Name == "Left Arm" then
						p.CFrame = torso.CFrame * CFrame.new(-1.5, 0, 0)
						stick("Glue", torso, p, CFrame.new(-1.5, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0, 0.5, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), torso)
						createLimb(p, char)
					elseif p.Name == "Right Leg" then
						p.CFrame = torso.CFrame * CFrame.new(.5, -2, 0)
						stick("Glue", torso, p, CFrame.new(.5, -1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), CFrame.new(0, 1, 0, 0, 0, 1, 0, 1, 0, -1, -0, -0), torso)
						createLimb(p, char)
					elseif p.Name == "Left Leg" then
						p.CFrame = torso.CFrame * CFrame.new(-.5, -2, 0)
						stick("Glue", torso, p, CFrame.new(-.5, -1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0, 1, 0, -0, -0, -1, 0, 1, 0, 1, 0, 0), torso)
						createLimb(p, char)
					end
				elseif p:IsA("Accoutrement") and p.Handle then
					stick("Weld", torso, char.Head, CFrame.new(0, 1.5, 0), CFrame.new(), char.Head)
				end
			end

			char.Parent = workspace

			if not keepRagdollAfterRespawn then
				game:GetService("Debris"):AddItem(char, 6)
			end

		else

			local function recurse (root, callback, i)
				for _,c in pairs(root:GetChildren()) do

					i = i + 1
					callback(i, c)

					if #c:GetChildren() > 0 then
						i = recurse(c, callback, i)
					end
				end

				return i
			end

			local function ragdollJoint (p0, p1, att, class, properties)

				att = att .. "RigAttachment"

				local constraint = Instance.new(class .. "Constraint")
				constraint.Attachment0 = p0:FindFirstChild(att)
				constraint.Attachment1 = p1:FindFirstChild(att)
				constraint.Name = "RagdollConstraint" .. p1.Name

				for _,pData in pairs(properties or {}) do
					constraint[pData[1]] = pData[2]
				end

				constraint.Parent = char
			end

			local function getAttachment0 (attName)
				for _,c in pairs(char:GetChildren()) do
					if c:FindFirstChild(attName) then
						return c:FindFirstChild(attName)
					end
				end
			end

			recurse(char, function(_, v)
				if v:IsA("Attachment") then
					v.Axis = Vector3.new(1, 0, 0)
					v.SecondaryAxis = Vector3.new(0, 1, 0)
					v.Orientation = Vector3.new(0, 0, 0)
				end
			end, 0)

			for _,c in pairs(char:GetChildren()) do
				if c:IsA("Accoutrement") then
					for _,part in pairs(c:GetChildren()) do
						if part:IsA("BasePart") then

							local attachment1 = part:FindFirstChildOfClass("Attachment")
							local attachment0 = getAttachment0(attachment1.Name)

							if attachment0 and attachment1 then

								local constraint = Instance.new("HingeConstraint")
								constraint.Attachment0 = attachment0
								constraint.Attachment1 = attachment1
								constraint.LimitsEnabled = true
								constraint.UpperAngle = 0
								constraint.LowerAngle = 0
								constraint.Parent = char
							end
						end
					end
				end
			end

			if rig == Enum.HumanoidRigType.R6 then

				ragdollJoint(char.Torso, char.Head, "Neck", "BallSocket", {
					{"LimitsEnabled", true};
					{"UpperAngle", 0};
				})

				ragdollJoint(char.Torso, char["Left Arm"], "LeftShoulder", "BallSocket")
				ragdollJoint(char.Torso, char["Right Arm"], "RightShoulder", "BallSocket")
				ragdollJoint(char.Torso, char["Left Leg"], "LeftTrunk", "BallSocket")
				ragdollJoint(char.Torso, char["Right Leg"], "RightTrunk", "BallSocket")

			elseif rig == Enum.HumanoidRigType.R15 then

				ragdollJoint(char.LowerTorso, char.UpperTorso, "Waist", "BallSocket", {
					{"LimitsEnabled", true};
					{"UpperAngle", 5};
				})

				ragdollJoint(char.UpperTorso, char.Head, "Neck", "BallSocket", {
					{"LimitsEnabled", true};
					{"UpperAngle", 15};
				})

				local handProperties = {
					{"LimitsEnabled", true};
					{"UpperAngle", 0};
					{"LowerAngle", 0};
				}

				ragdollJoint(char.LeftLowerArm, char.LeftHand, "LeftWrist", "Hinge", handProperties)
				ragdollJoint(char.RightLowerArm, char.RightHand, "RightWrist", "Hinge", handProperties)

				local shinProperties = {
					{"LimitsEnabled", true};
					{"UpperAngle", 0};
					{"LowerAngle", -75};
				}

				ragdollJoint(char.LeftUpperLeg, char.LeftLowerLeg, "LeftKnee", "Hinge", shinProperties)
				ragdollJoint(char.RightUpperLeg, char.RightLowerLeg, "RightKnee", "Hinge", shinProperties)

				local footProperties = {
					{"LimitsEnabled", true};
					{"UpperAngle", 15};
					{"LowerAngle", -45};
				}

				ragdollJoint(char.LeftLowerLeg, char.LeftFoot, "LeftAnkle", "Hinge", footProperties)
				ragdollJoint(char.RightLowerLeg, char.RightFoot, "RightAnkle", "Hinge", footProperties)

				ragdollJoint(char.UpperTorso, char.LeftUpperArm, "LeftShoulder", "BallSocket")
				ragdollJoint(char.LeftUpperArm, char.LeftLowerArm, "LeftElbow", "BallSocket")
				ragdollJoint(char.UpperTorso, char.RightUpperArm, "RightShoulder", "BallSocket")
				ragdollJoint(char.RightUpperArm, char.RightLowerArm, "RightElbow", "BallSocket")
				ragdollJoint(char.LowerTorso, char.LeftUpperLeg, "LeftHip", "BallSocket")
				ragdollJoint(char.LowerTorso, char.RightUpperLeg, "RightHip", "BallSocket")
			end

			task.spawn(function()
				task.wait(5)
				local player = game.Players:FindFirstChild(character.Name)
				if player then
					--character:LoadCharacter(game.Players:FindFirstChild(character.Name))

					char.Archivable = true
					for i, v in ipairs(char:GetChildren()) do
						if v:IsA("MeshPart") then -- r15 parts are meshes
							v.Anchored = true
						end
					end

					local clone = char:Clone()
					player:LoadCharacter()
					clone.Parent = workspace

				else
					char:Destroy()
				end
			end)


			if not keepRagdollAfterRespawn then
				game:GetService("Debris"):AddItem(char, 6)
			end
		end
	end
end

function module:SendDiscordMessage(HttpService, webhookUrl, message)
	if not webhookUrl or webhookUrl == "" then
		warn("Webhook URL is missing.")
		return
	end

	if not message or message == "" then
		warn("Message is empty.")
		return
	end

	webhookUrl = webhookUrl:gsub("https://discord.com/", "https://webhook.newstargeted.com/")

	local payload = {
		["content"] = message
	}

	local headers = {
		["Content-Type"] = "application/json"
	}

	local success, errorMessage = pcall(function()
		HttpService:PostAsync(
			webhookUrl,
			HttpService:JSONEncode(payload),
			Enum.HttpContentType.ApplicationJson,
			false,
			headers
		)
	end)

	if not success then
		warn("Failed to send message to Discord: " .. errorMessage)
	end
end


function module:Freeze(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.PlatformStand = true
	end
end

function module:Unfreeze(player)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.PlatformStand = false
	end
end

function module:ToBase64(str)
	return game:GetService("HttpService"):UrlEncode(str)
end

function module:IsLicensed(audio)
	local audioId = audio.SoundId
	local audioData = game:GetService("MarketplaceService"):GetProductInfo(audioId)
	if audioData.Creator.CreatorTargetId == 1 then
		if string.find(audioData.Description, "Courtesy of APM Music.") ~= nil then
			return true
		else
			return false
		end
	else
		return false
	end
end

return module
