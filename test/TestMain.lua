---@type UIUserTB
local UIUserTB = require("UICore.UIUserTB")

---@type LogSuccDialogUserTB
local TB = UIUserTB:New("LogSuccDialogUserTB")
TB.ContentText = "Content"
TB.QRCodeContent = "RCode"
TB.TitleText = "Title"


print(TB)
