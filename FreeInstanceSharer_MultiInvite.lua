if not _G.FreeInstanceSharer then return end
local F, L, P, G = unpack(_G.FreeInstanceSharer)

local originIsInviteOnWhisperMsg = F.IsInviteOnWhisperMsg
F.IsInviteOnWhisperMsg = function(self, sender, text, ...)
    if not F.db.MultiInvite.Enable then
        return originIsInviteOnWhisperMsg(self, sender, text, ...)
    end

    return tContains(F.db.MultiInvite.List, text)
end

P["MultiInvite"] = {
    ["Enable"] = true,
    ["List"] = {},
}

local currentSelectList

F.Options.args.Message.args.InviteOnWhisperMsg.hidden = function() return F.db.MultiInvite.Enable end
F.Options.args.Plugins.args.MultiInvite = {
    name = "多邀请指令",
    type = 'group',
    get = function(info) return F.db.MultiInvite[info[#info]] end,
    set = function(info, value) F.db.MultiInvite[info[#info]] = value end,
    args = {
        Enable = {
            order = 1,
            name = "启用",
            type = 'toggle',
        },
        List = {
            order = 10,
            name = "进组指令列表",
            type = 'group',
            guiInline = true,
            disabled = function() return not F.db.MultiInvite.Enable end,
            args = {
                Add = {
                    order = 1,
                    name = ADD,
                    type = 'input',
                    get = function() end,
                    set = function(_, value) tinsert(F.db.MultiInvite.List, value) end,
                },
                List = {
                    order = 2,
                    name = "进组指令",
                    type = 'select',
                    get = function() return currentSelectList end,
                    set = function(_, value) currentSelectList = value end,
                    values = function()
                        local result = {}
                        for _, name in ipairs(F.db.MultiInvite.List) do
                            result[name] = name
                        end
                        return result
                    end,
                },
                Delete = {
                    order = 3,
                    name = DELETE,
                    type = 'execute',
                    func = function() tDeleteItem(F.db.MultiInvite.List, currentSelectList); currentSelectList = nil end,
                    disabled = function() return not F.db.MultiInvite.Enable or not currentSelectList end,
                },
            },
        },
    },
}
