type Profile = {
	Data: {
		Gems: number
	},
	AddUserId: (self: Profile, userId: number) -> (),
	OnLastSave: {
		Connect: (self: any, callback: (reason: string) -> ()) -> ()
	},
	Reconcile: (self: Profile) -> (),
	IsActive: (self: Profile) -> boolean,
	EndSession: (self: Profile) -> ()
}

type ProfileStore = {
	New: (name: string, template: {[string]: any}) -> ProfileStore,
	StartSessionAsync: (self: ProfileStore, key: string) -> Profile?
}

export type DataHandlerType = {
	GetProfile: (player: Player) -> Profile?,
	GetGems: (player: Player) -> number,
	AddGems: (player: Player, amount: number) -> (),
	RemoveGems: (player: Player, amount: number) -> boolean,
	Init: () -> ()
}

local DataHandler: DataHandlerType = {}

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local ProfileStore = require(ServerStorage.Common.ServerModules.Data.ProfileStore)

local PROFILE_TEMPLATE = {
	Gems = 0,
}

local profileStore = ProfileStore.New("PlayerData", PROFILE_TEMPLATE)
local profiles: {[Player]: Profile} = {}

local function updateLeaderboard(player: Player)
	local profile = profiles[player]
	if not profile then return end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		
		local gemsValue = Instance.new("NumberValue") 
		gemsValue.Name = "Gems"
		gemsValue.Value = profile.Data.Gems
		gemsValue.Parent = leaderstats
		
		leaderstats.Parent = player
		return
	end
	
	local gemsValue = leaderstats:FindFirstChild("Gems")
	if not gemsValue then return end
	
	gemsValue.Value = profile.Data.Gems
end

local function onPlayerAdded(player: Player)
	local profile = profileStore:StartSessionAsync(tostring(player.UserId))
	if not profile then
		player:Kick("Failed to load data. Please rejoin.")
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	
	profile.OnLastSave:Connect(function()
		profiles[player] = nil
	end)
	
	profiles[player] = profile
	updateLeaderboard(player)
	
	player.AncestryChanged:Connect(function(_, parent)
		if parent == nil and profile:IsActive() then
			profile:EndSession()
		end
	end)
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if not profile then return end
	
	profile:EndSession()
end

function DataHandler.GetProfile(player: Player): Profile?
	return profiles[player]
end

function DataHandler.GetGems(player: Player): number
	local profile = profiles[player]
	return if profile then profile.Data.Gems else 0
end

function DataHandler.AddGems(player: Player, amount: number)
	if amount <= 0 then return end
	
	local profile = profiles[player]
	if not profile then return end
	
	profile.Data.Gems += amount
	updateLeaderboard(player)
end

function DataHandler.RemoveGems(player: Player, amount: number): boolean
	if amount <= 0 then return false end
	
	local profile = profiles[player]
	if not profile then return false end
	
	if profile.Data.Gems < amount then return false end
	
	profile.Data.Gems -= amount
	updateLeaderboard(player)
	return true
end

function DataHandler.Init()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			onPlayerRemoving(player)
		end
	end)
end

return DataHandler