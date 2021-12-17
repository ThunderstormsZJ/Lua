--用来区分nil
local USERTB_NIL = "33A3649E-53B4"

local UIUserTBDef = { }

---@class LogSuccDialogUserTB 日志上传成功对话框
---@field TitleText string 标题文字
---@field ContentText string 内容文本
---@field QRCodeContent string 二维码内容
UIUserTBDef.LogSuccDialogUserTB = {
    TitleText = "";
    ContentText = "";
    QRCodeContent = "";
}

return UIUserTBDef