ETOMARAT = ETOMARAT or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}

local MOD_NAME = ETOMARAT.PlayerAccounting.MOD_NAME

---@return AccountingTotal
local getTotal = function ()
    local username = getPlayer():getUsername()
    return ModData.get("CoinBalance")[username]
end

---@return modDataEntry[]
local getLog = function ()
    local username = getPlayer():getUsername()
    return ModData.getOrCreate(MOD_NAME)[username]
end

local initGlobalModData = function (isNewGame)
    
    if ModData.exists(MOD_NAME) then
        ModData.remove(MOD_NAME);
    end
	ModData.request(MOD_NAME)
end

Events.OnInitGlobalModData.Add(initGlobalModData);

local onReceiveGlobalModData = function(tableName, data)
	if tableName == MOD_NAME and getPlayer() then
        local username = getPlayer():getUsername()
        data = data or {}
        local log = data[username]
        if log and #log > 0 then
            triggerEvent('onPlayerAccountingChange')
        end
    end
end

Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData);

return {
    getTotal = getTotal,
    getLog = getLog
}