--===UIUserTBDefDef.lua
-- (c) copyright 2018, Tencent
-- All Rights Reserved.
--=======================================
-- filename:  UIUserTBDefDef.lua
-- author:
-- created:   2018/01/17
-- descrip:   OpenPanel 时给Panel 传递的UserData Table结构定义
--=======================================

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