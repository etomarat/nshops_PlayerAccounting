if isClient() then return end

ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}

local MOD_NAME = ETOMARAT.PlayerAccounting.MOD_NAME
local EVENT_TYPES = ETOMARAT.PlayerAccounting.EVENT_TYPES

local base_BServer = {}


local getDateTimeStr = function ()
    local gt = getGameTime()
    local minutes = tostring(gt:getMinutes())
    local hours = tostring(gt:getHour())
    if #minutes == 1 then
        minutes = '0'..minutes
    end
    if #hours == 1 then
        hours = '0'..hours
    end
    return ('%s/%s/%s %s:%s'):format(gt:getDay(), gt:getMonth(), gt:getYear(), hours, minutes)
end

---@class ServerAccaunting
local ServerAccaunting = {}

function ServerAccaunting:new(modData)
	local o = {}
	setmetatable(o, self)
	self.__index = self
    ---@type modData
    self.data = modData
    return o
end

function ServerAccaunting:transmit()
    ModData.add(MOD_NAME, self.data)
    ModData.transmit(MOD_NAME)
end

---@param player IsoPlayer | string
---@param event_type event_type
---@param coin integer | nil
---@param specialCoin integer | nil
---@param recipient string | nil
function ServerAccaunting:insert(player, event_type, coin, specialCoin, recipient)
    local username = player
    if type(player) ~= "string" then
        username = player:getUsername()
    end
    local dt = getDateTimeStr()
    local old_table = self.data[username] or {}
    table.insert(old_table, {
        dt,
        event_type,
        coin,
        specialCoin,
        recipient
    })
    self.data[username] = old_table
    self:transmit()
end

---@param player IsoPlayer
function ServerAccaunting:CreateAccount(player)
    local username = player:getUsername()
    local account = ModData.get("CoinBalance")[username]
    local type = EVENT_TYPES.Create
    if account then
        type = EVENT_TYPES.Linked
    end
    self:insert(player, type)
end

---@param player IsoPlayer
---@param args integer[]
function ServerAccaunting:Deposit(player, args)
    local coin, specialCoin = unpack(args)
    self:insert(player, EVENT_TYPES.Deposit, coin, specialCoin)
end

---@param player IsoPlayer
---@param args integer[]
function ServerAccaunting:Withdraw(player, args)
    local coin, specialCoin = unpack(args)
    self:insert(player, EVENT_TYPES.Withdraw, coin, specialCoin)
end

---@param player IsoPlayer
---@param args (integer | string)[]
function ServerAccaunting:Transfer(player, args)
    local coin, specialCoin, recipient = unpack(args)
    ---@cast coin integer
    self:insert(player, EVENT_TYPES.TransferOut, coin, specialCoin, recipient)
    self:insert(recipient, EVENT_TYPES.TransferIn, coin, specialCoin, player:getUsername())
end

---@type ServerAccaunting
local serverAccaunting = nil

local function initGlobalModData(isNewGame)
    local modData = ModData.getOrCreate(MOD_NAME);
    serverAccaunting = ServerAccaunting:new(modData)
	ModData.transmit(MOD_NAME)
end

Events.OnInitGlobalModData.Add(initGlobalModData);



local PlayerAccounting = {}
function PlayerAccounting.CreateAccount(player, args)
    serverAccaunting:CreateAccount(player)
end

function PlayerAccounting.Deposit(player, args)
    serverAccaunting:Deposit(player, args)
end

function PlayerAccounting.Transfer(player, args)
    serverAccaunting:Transfer(player, args)
end

function PlayerAccounting.Withdraw(player, args)
    serverAccaunting:Withdraw(player, args)
end

local function onClientCommand(module, command, player, args)
    if module == "BS" and PlayerAccounting[command] then
        PlayerAccounting[command](player, args)
    end
end

Events.OnClientCommand.Add(onClientCommand)