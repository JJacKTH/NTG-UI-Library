--[[
    NTG UI Library - Config Manager
    Auto Save/Load system
    
    โครงสร้าง:
    NTGUI/
    └── {Username}/
        └── {GameName}/
            └── Config.json
]]

local ConfigManager = {}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

ConfigManager.BaseFolder = "NTGUI"
ConfigManager.Configs = {}
ConfigManager.CurrentGame = "Default"

-- Check if file system functions exist (executor support)
local function hasFileSystem()
    return typeof(readfile) == "function" and 
           typeof(writefile) == "function" and
           typeof(isfolder) == "function" and
           typeof(makefolder) == "function"
end

-- Get Username
local function getUsername()
    local player = Players.LocalPlayer
    return player and player.Name or "Unknown"
end

-- Get UserId (for backup)
local function getUserId()
    local player = Players.LocalPlayer
    return player and tostring(player.UserId) or "0"
end

-- Set game name for config
function ConfigManager:SetGame(gameName)
    self.CurrentGame = gameName or "Default"
end

-- Get folder path for current user and game
function ConfigManager:GetFolderPath()
    local username = getUsername()
    return string.format("%s/%s/%s", self.BaseFolder, username, self.CurrentGame)
end

-- Get config file path
function ConfigManager:GetPath(configName)
    configName = configName or "Config"
    return string.format("%s/%s.json", self:GetFolderPath(), configName)
end

-- Ensure all folders exist
function ConfigManager:EnsureFolders()
    if not hasFileSystem() then return false end
    
    local username = getUsername()
    
    -- Create base folder
    if not isfolder(self.BaseFolder) then
        makefolder(self.BaseFolder)
    end
    
    -- Create user folder
    local userFolder = string.format("%s/%s", self.BaseFolder, username)
    if not isfolder(userFolder) then
        makefolder(userFolder)
    end
    
    -- Create game folder
    local gameFolder = self:GetFolderPath()
    if not isfolder(gameFolder) then
        makefolder(gameFolder)
    end
    
    return true
end

-- Save config to file
function ConfigManager:Save(configName, data)
    if not hasFileSystem() then
        warn("[NTGUI] File system not available - config will not persist")
        return false
    end
    
    self:EnsureFolders()
    
    local path = self:GetPath(configName)
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(data)
        writefile(path, json)
    end)
    
    if success then
        self.Configs[configName] = data
        --print("[NTGUI] Config saved:", path)
        return true
    else
        warn("[NTGUI] Failed to save config:", err)
        return false
    end
end

-- Load config from file
function ConfigManager:Load(configName)
    if not hasFileSystem() then
        warn("[NTGUI] File system not available")
        return nil
    end
    
    local path = self:GetPath(configName)
    
    if not isfile(path) then
        return nil
    end
    
    local success, result = pcall(function()
        local content = readfile(path)
        return HttpService:JSONDecode(content)
    end)
    
    if success then
        self.Configs[configName] = result
        print("[NTGUI] Config loaded:", path)
        return result
    else
        warn("[NTGUI] Failed to load config:", result)
        return nil
    end
end

-- Delete config file
function ConfigManager:Delete(configName)
    if not hasFileSystem() then
        return false
    end
    
    local path = self:GetPath(configName)
    
    if isfile(path) then
        local success = pcall(function()
            delfile(path)
        end)
        
        if success then
            self.Configs[configName] = nil
            return true
        end
    end
    
    return false
end

-- Check if config exists
function ConfigManager:Exists(configName)
    if not hasFileSystem() then
        return false
    end
    
    local path = self:GetPath(configName)
    return isfile(path)
end

-- List all configs in current game folder
function ConfigManager:ListConfigs()
    if not hasFileSystem() then
        return {}
    end
    
    self:EnsureFolders()
    
    local configs = {}
    local folderPath = self:GetFolderPath()
    
    if typeof(listfiles) == "function" and isfolder(folderPath) then
        local files = listfiles(folderPath)
        for _, file in ipairs(files) do
            local fileName = file:match("([^/\\]+)$")
            if fileName and fileName:match("%.json$") then
                local configName = fileName:gsub("%.json$", "")
                table.insert(configs, configName)
            end
        end
    end
    
    return configs
end

-- List all games for current user
function ConfigManager:ListGames()
    if not hasFileSystem() then
        return {}
    end
    
    local games = {}
    local username = getUsername()
    local userFolder = string.format("%s/%s", self.BaseFolder, username)
    
    if typeof(listfiles) == "function" and isfolder(userFolder) then
        local folders = listfiles(userFolder)
        for _, folder in ipairs(folders) do
            if isfolder(folder) then
                local gameName = folder:match("([^/\\]+)$")
                if gameName then
                    table.insert(games, gameName)
                end
            end
        end
    end
    
    return games
end

-- Create a config handler for a window
function ConfigManager:CreateHandler(gameName, configName, autoSave, autoLoad, baseFolder)
    -- Update base folder if provided
    if baseFolder then
        self.BaseFolder = baseFolder
    end
    
    -- Set current game
    self:SetGame(gameName)
    
    local handler = {
        GameName = gameName,
        ConfigName = configName or "Config",
        AutoSave = autoSave or false,
        AutoLoad = autoLoad or false,
        Data = {},
        Elements = {},
        SaveDebounce = false
    }
    
    -- Register an element
    function handler:Register(id, elementType, getValue, setValue)
        self.Elements[id] = {
            Type = elementType,
            GetValue = getValue,
            SetValue = setValue
        }
    end
    
    -- Unregister an element
    function handler:Unregister(id)
        self.Elements[id] = nil
    end
    
    -- Save all registered elements
    function handler:Save()
        local data = {}
        
        for id, element in pairs(self.Elements) do
            local success, value = pcall(element.GetValue)
            if success then
                data[id] = {
                    Type = element.Type,
                    Value = value
                }
            end
        end
        
        return ConfigManager:Save(self.ConfigName, data)
    end
    
    -- Load and apply to all elements
    function handler:Load()
        local data = ConfigManager:Load(self.ConfigName)
        
        if data then
            self.Data = data
            
            for id, savedData in pairs(data) do
                local element = self.Elements[id]
                if element and element.Type == savedData.Type then
                    local success, err = pcall(function()
                        element.SetValue(savedData.Value)
                    end)
                    
                    if not success then
                        warn("[NTGUI] Failed to load value for", id, ":", err)
                    end
                end
            end
            
            return true
        end
        
        return false
    end
    
    -- Trigger auto save with debounce
    function handler:TriggerAutoSave()
        if not self.AutoSave or self.SaveDebounce then
            return
        end
        
        self.SaveDebounce = true
        
        task.delay(1, function()
            self.SaveDebounce = false
            self:Save()
        end)
    end
    
    -- Delete config
    function handler:Delete()
        return ConfigManager:Delete(self.ConfigName)
    end
    
    -- Auto load on creation if enabled
    -- task.delay(0) ensures all components finish Register() before Load() applies values
    if autoLoad and ConfigManager:Exists(configName or "Config") then
        task.delay(0, function()
            handler:Load()
        end)
    end
    
    return handler
end

return ConfigManager
