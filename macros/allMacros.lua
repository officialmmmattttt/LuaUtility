local module = {
	
	anim = [[
local animationID = "" -- give the id of the animation
if not string.find(animationID, 'rbxassetid://') then animationID = 'rbxassetid://'..animationID end -- don't delete but ignore
local animation = Instance.new("Animation", script)
animation.AnimationId = animationID
local npc = script.Parent -- location of the npc
local humanoid= npc:WaitForChild('Humanoid')
local dance = humanoid:LoadAnimation(animation)
dance:Play()]];
	
	ts = [[
local part = script.Parent -- the part you want to tween

local TweenService = game:GetService("TweenService")

local goal = {Size = Vector3.new(1,1,1)}

local tweenInfo = TweenInfo.new(
	5, --Time

	Enum.EasingStyle.Linear, --Easing Style

	Enum.EasingDirection.Out, --EasingDirection

    -1, --Repeat Count

	true, --Reverse

	0 --DelayTime
)

local tween = TweenService:Create(part, tweenInfo, goal)

tween:Play()]]
	
}

return module
