local Ragdoll = {}

function Ragdoll:RigPlayer(Character : Model)
	local Humanoid : Humanoid? = Character:WaitForChild("Humanoid")
	local HumanoidRootPart : BasePart? = Character:WaitForChild("HumanoidRootPart")

	assert(Humanoid,Character.Name.." isnt a humanoid")

	Humanoid.BreakJointsOnDeath = false
	local WeldConstranint = Instance.new("WeldConstraint",HumanoidRootPart)
	for _,v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if not v.Part1:GetAttribute("NotRagdollable") then
				local BallSocket = Instance.new("BallSocketConstraint",v.Part0)
				BallSocket.Name = "BallConstraint"
				if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
					v.Part1.CanCollide = false
					v.Part0.CanCollide = false
				end

				local att1 = Instance.new("Attachment",v.Part0) att1.Name = "AttRag"
				local att2 = Instance.new("Attachment",v.Part1) att1.Name = "AttRag"
				att2.Position = v.C1.Position
				att1.WorldPosition= att2.WorldPosition

				BallSocket.LimitsEnabled = true
				BallSocket.TwistLimitsEnabled = true

				BallSocket.Attachment0 = att1
				BallSocket.Attachment1 = att2

				if v.Part0 == Character.PrimaryPart and v.Part1 ~= Character.PrimaryPart then
					WeldConstranint.Part0 = Character.PrimaryPart
					WeldConstranint.Part1 = v.Part1
					WeldConstranint.Enabled = false
				end
			end
		end
	end
end

function Ragdoll:Ragdoll(Character : Model)
	local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

	local Player = game.Players:GetPlayerFromCharacter(Character)
	if Player then
		game.ReplicatedStorage.Events.Ragdoll:FireClient(Player, true)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Humanoid.PlatformStand = true
	end
	task.delay(0.05, function()
		for _, v in ipairs(Character:GetDescendants()) do
			if v:IsA("Motor6D") then
				if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
					v.Part1.CanCollide = true
					v.Enabled = false
				end
			end
		end
	end)

end

function Ragdoll:Recover(Character : Model)
	local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = false
				v.Enabled = true
			end
		end
	end

	local Player = game.Players:GetPlayerFromCharacter(Character)
	if Player then
		game.ReplicatedStorage.Events.Ragdoll:FireClient(Player, false)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		Humanoid.PlatformStand = false
	end
end

function Ragdoll:DeathPhysics(Character : Model)
	for _, v in ipairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if v.Part1 ~= Character.PrimaryPart and v.Part0 ~= Character.PrimaryPart then
				v.Part1.CanCollide = true
				v:Destroy()
			else
				Character.PrimaryPart:FindFirstChild("WeldConstraint").Enabled = true
				Character.PrimaryPart.CanCollide = false
			end
		end
	end
end

return Ragdoll