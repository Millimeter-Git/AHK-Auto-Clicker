/*
	Tác giả: Phạm Ngọc Đức
	Sử dụng:
		F2: lưu thao tác
		F3: chạy
		F4: dừng
		Chuột trái vào listview: chỉnh sửa, xóa, lưu, mở thao tác
		Hỗ trợ kéo thả file đã lưu
*/
/*
-Cập nhật
	10/7/2018  : phát hành bản beta.
	15/2/2019 : thêm chức năng lặp lại một số lần xác định, nâng cấp hàm RequireAdmin().
	3/7/2019  :
		Năng cấp script: thay thế lệnh sleep sẵn có, thay thế win hwnd do hwnd là duy nhất vì thế không thể click cho cửa sổ mới xuất hiện.
		Thêm chức năng gửi phím.
	4/7/2019  : thêm chức năng lưu mở thao tác.
-Bug
	ControlClick dừng lại khi giữ chuột (@-@) chưa biết làm thế nào.
*/

RequireAdmin()
#NoEnv
#NoTrayIcon
#SingleInstance Off
playing:=0
CoordMode Mouse,Window
SetBatchLines,-1
; Hạn chế lỗi khi người dùng thao tác chuột
SetControlDelay -1
SetKeyDelay,10,10
FileEncoding,UTF-8
Opt:=[]

Gui +Alwaysontop +hwndhGui
Gui Add, Text, x16 y8, Hành động:
Gui Add, DropDownList, x81 y5 w120 vModeClick, Left||Middle|Right
Gui Add, Text, x215 y8 ,Delay:
Gui Add, Edit, x250 y5 w120 h21 vDelayTime number,100
Gui Add, Text, x374 y11 ,(ms)
Gui Add, Text, x16 y34 w60 h23 +0x200, Gửi phím: 
Gui Add, Edit, x81 y36 w120 h21 vSendKey, 
Gui Add, CheckBox, x215 y35 w120 h23 vIsCtrlSend Checked, Control Send
Gui Add, Text, x16 y64 w60 h23 +0x200, Số lần chạy: ; Đặt 0 để chạy vô hạn lần
Gui Add, Edit, x81 y66 w65 h21 number vtimes, 
Gui Add, UpDown, x128 y66 w18 h21, 1
Gui Add, ListView, x16 y96 w391 h150 vMyListView, X|Y|Hành động|Gửi phím|Control Send|Delay|Cửa sổ
Gui,Add,StatusBar
SB_SetText("Kiếm gì cho tui làm đê :(",1)
SB_SetIcon("Shell32.dll", 44,1)
Gui Add, Button, x152 y258 w80 h23 gRunAuto , Chạy (F3)
Gui Add, Button, x240 y258 w80 h23 gStopAuto , Dừng (F4)
Gui Add, Button, x328 y258 w80 h23 gDellList, Xóa 
Gui Show, ,Simple Auto Clicker


Menu, MyContextMenu, Add, Xóa, DellList
Menu, MyContextMenu, Icon, Xóa,shell32.dll,132
Menu, MyContextMenu, Add, Xóa tất cả, DellList
Menu, MyContextMenu, Icon, Xóa tất cả,shell32.dll,272
Menu, MyContextMenu, Add, 
Menu, MyContextMenu, Add, Mở..., File
Menu, MyContextMenu, Icon, Mở..., shell32.dll, 4
Menu, MyContextMenu, Add, Lưu, File
Menu, MyContextMenu, Icon, Lưu, shell32.dll, 259

Return

F2::
; Không ghi khi đang auto
if playing
	return
; Lưu mấy nội dung của mấy cái control vào biến
Gui,Submit,Nohide
; Quá trình lấy cửa sổ khá mất thời gian nên khóa di chuột tránh người dùng di tùm lum gây sai sót
BlockInput,MouseMove
MouseGetPos,,,WinHWND
WinGetTitle,WinTitle,ahk_id %WinHWND%
WinGetClass,WinClass,ahk_id %WinHWND%
; Phải activate lên mới lấy đc chính xác vị trí click
WinActivate,ahk_id %WinHWND%
WinWaitActive,ahk_id %WinHWND%
MouseGetPos,X,Y
BlockInput,MouseMoveOff
LV_Add("",X,Y,ModeClick,SendKey,IsCtrlSend,DelayTime,WinTitle " ahk_class " WinClass)
; Canh cột 1,2 cho ngay lại
LV_ModifyCol(1)
LV_ModifyCol(2)
return

F3::
RunAuto:
; Ngăn khi người dùng bấm thêm và ngưng khi chưa ghi thao tác
if playing or (LV_GetCount()=0)
	return
Gui,Submit,Nohide
; CountTimes: ghi lại số lần lặp
CountTimes:=0
; index: ghi lại số dòng đã đọc của listview
index:=0
playing:=1
; Đặt times=-1, do vậy CountTimes không thể đạt tới vì thế vòng lặp ở dưới chạy liên tục
if (Times=0)
	Times=-1
SB_SetText("Trạng thái: Đang chạy auto",1)
Loop 
{
	; Hết một lần chạy
	if (index=7)
	{
		; Đọc lại số dòng từ đầu
		index:=0
		; Tăng số lần chạy
		CountTimes++
	}
	; Do CountTimes ban đầu = 0 và nó sẽ +1 qua từng vòng lặp, nếu times=-1 thì vòng lặp sẽ chạy vô tận
	if (Stop || CountTimes=Times)
		break
	; Sang dòng tiếp theo trong listview
	index++
	; Lấy dữ liệu từng dòng
	Loop 7
		LV_GetText(Data_%A_Index%,index,A_Index)
	; Thay thế lệnh Sleep sẵn có do khi biến stop=0 thì vẫn phải đợi hết sleep mới dừng
	Delay(Data_6,Stop)
	if Stop
		break 
	ControlClick,x%Data_1% y%Data_2%,%Data_7%,,%Data_3%,,NA
	; Bỏ qua khi không gửi phím
	if !Data_4
		continue
	Sleep 100
	; gửi phím bằng ControlSend khi tick vào CheckBox
	if Data_5
		ControlSend,,% Data_4,% Data_7
	; gửi chiếm màng hình, k chiếm bàn phím nhá
	else
	{
		WinActivate,% Data_7
		SendInput,{Blind}%Data_4%
	}
}
stop:=0
playing:=0
SB_SetText("Trạng thái: Đã dừng auto",1)
return

F4::
StopAuto:
if not playing
	return
Stop:=1
return

GuiDropFiles:
DirFile:=A_GuiEvent
gosub,Open
return

GuiContextMenu: 
if A_GuiControl <> MyListView 
    return
Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

DellList: 
; Đang chạy thì không đc xóa
if playing
	return
; Cái này là bấm nút xóa trên gui
if (A_GuiControl="Xóa")
	LV_Delete()
; Khi click vào menu "xóa"
else if (A_ThisMenuItem="Xóa")
	Loop
	{
		RowNumber := LV_GetNext()
		if not RowNumber
			break 
		LV_Delete(RowNumber)
	}
else
	LV_Delete()
return

File:
Gui +OwnDialogs
Opt:=(A_ThisMenuItem="Lưu") ? ["S18","Lưu","Save.sac"] : ["3","Mở"]
; Mở hộp thoại mở hoặc lưu 
FileSelectFile,DirFile,% Opt[1],% Opt[3],% Opt[2],Simple Auto Clicker (*.sac)
if ErrorLevel
	return
if (A_ThisMenuItem="Lưu")
	gosub,Save
else
	gosub,Open
return

Save:
if !LV_GetCount()
{
	MsgBox, 262144, ,Có gì đâu mà lưu ta ??
	return
}
SplitPath,DirFile,FileName
; Nếu người dùng không bỏ đôi vào file thì mình thêm vào (sac = Simple Auto Clicker)
IfNotInString,FileName,.
	FileName.=.sac
; Nếu đã có file tên giống vậy trước đó thì xóa đi
if FileExist(DirFile)
	FileDelete,% DirFile
; Lấy dữ liệu từ listview
ControlGet, Items, List, , SysListView321, ahk_id %hGui%
; Ghi vào tệp
FileAppend,% Items,% FileName
MsgBox, 262208, ,Đã lưu
SB_SetText("Trạng thái: Đã lưu",1)
return

Open:
; Cái này khỏi nói nhá
if LV_GetCount()
	MsgBox, 262180, ,Bạn có muốn xóa toàn bộ nội dung trong playlist?
	IfMsgBox,Yes
		LV_Delete()
; Dùng vòng lặp đọc từng dòng sau đó lưu vào listview
Loop,Read,% DirFile 
	LV_Add("",StrSplit(A_LoopReadLine,A_Tab)*)
LV_ModifyCol(1)
LV_ModifyCol(2)
SB_SetText("Trạng thái: Đã mở",1)
return


GuiClose:
    ExitApp
	
RequireAdmin()
{
CommandLine := DllCall("GetCommandLine", "Str")

If !(A_IsAdmin || RegExMatch(CommandLine, " /restart(?!\S)")) {
    Try {
        If (A_IsCompiled) {
            Run *RunAs "%A_ScriptFullPath%" /restart
        } Else {
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
    }
    ExitApp
}
}

Delay(time,ByRef cancel) {
start:=A_TickCount
While !cancel && A_TickCount<(Start+time)
	Sleep 10
}