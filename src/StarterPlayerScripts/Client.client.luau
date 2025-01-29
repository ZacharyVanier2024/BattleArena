--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Common = ReplicatedStorage.Common
local ClientModules = Common.ClientModules

type ModuleWithInit = {
	Init: () -> (boolean, string?)
}

local function requireModulesWithInit(parent: Instance): ()
	local modules: {ModuleWithInit} = {}
	
	local function scanFolder(folder: Instance): ()
		for _, item in folder:GetDescendants() do
			if item:IsA("ModuleScript") and not item:IsDescendantOf(ClientModules.OS) then
				local success, module = pcall(require, item)
				if success and typeof(module) == "table" and typeof(module.Init) == "function" then
					table.insert(modules, module :: ModuleWithInit)
				end
			end
		end
	end
	
	scanFolder(parent)

	for _, module in modules do
		task.spawn(function()
            return module.Init()
		end)
	end
end

requireModulesWithInit(ClientModules)