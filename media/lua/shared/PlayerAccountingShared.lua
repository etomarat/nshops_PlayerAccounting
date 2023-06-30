ETOMARAT = ETOMARAT or {}
ETOMARAT.Utils = ETOMARAT.Utils or {}
ETOMARAT.PlayerAccounting = ETOMARAT.PlayerAccounting or {}
ETOMARAT.PlayerAccounting.MOD_NAME = 'PlayerAccounting'
---@enum event_type
ETOMARAT.PlayerAccounting.EVENT_TYPES = {
    Create = 'Create',
    Linked = 'Linked',
    Deposit = 'Deposit',
    Withdraw = 'Withdraw',
    TransferIn = 'TransferIn',
    TransferOut = 'TransferOut',
}

LuaEventManager.AddEvent("onPlayerAccountingChange")


---@param r integer
---@param g integer
---@param b integer
---@return string
local makeColor = function (r,g,b)
    local R = r / 255
    local G = g / 255
    local B = b / 255
    return ' <RGB:'..R..','..G..','..B..'> '
end

if not ETOMARAT.Utils['makeColor'] then
    ETOMARAT.Utils.makeColor = makeColor
end


---@alias modDataEntry (string | integer)[]
---@alias modData table<string, modDataEntry[]>

---@class AccountingTotal
---@field coin integer
---@field specialCoin integer