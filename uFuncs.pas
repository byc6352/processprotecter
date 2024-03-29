unit uFuncs;

interface
uses
  windows,uStr;
type
  PProcessProtecter=^stProcessProtecter;
  stProcessProtecter=record
    bProtect:bool;
    filename:array[0..MAX_PATH-1] of ansiChar;
  end;
var
  ProcessProtecter:stProcessProtecter;

function GetMyPriviliges:BOOL;
function RunFile(name:pansiChar;ShowType:DWORD;suspended:BOOL=false;bCMD:BOOL=false):PROCESS_INFORMATION;
function GetProcessesInfo2000(var s:ansiString;const showDLL:boolean=true):bool;
procedure processProtectThread(p:pointer);stdcall;
procedure startProtect(filename:ansiString);
procedure stopProtect();
implementation
uses
  uLog;
procedure stopProtect();
begin
  ProcessProtecter.bProtect:=false;
end;
procedure startProtect(filename:ansiString);
var
  id,hd:cardinal;
begin
  ProcessProtecter.bProtect:=true;
  copymemory(@ProcessProtecter.filename[0],@filename[1],length(filename));
  hd:=CreateThread(nil,0,@processProtectThread,@ProcessProtecter,0,id);
  CloseHandle(hd);
end;
procedure processProtectThread(p:pointer);stdcall;
var
  pi:PROCESS_INFORMATION;
  pp:PProcessProtecter;
begin
  pp:=p;
  while pp^.bProtect do
  begin
    uLog.Log('----------------启动----------');
    pi:=RunFile(pp^.filename,sw_show);
    WaitForSingleObject( pi.hProcess, INFINITE );
  end;
end;

function GetProcessesInfo2000(var s:ansiString;const showDLL:boolean=true):bool;
//列举win2000进程及其DLL
label 1;
type
  tEnumProcesses=function (lpidProcess, cb, cbNeeded: DWORD):Integer; stdcall;
  tGetModuleFileNameExA=function (hProcess: THandle; HMODULE: HMODULE; lpFileName: PansiChar; nSize: DWORD):Integer; stdcall;
  tEnumProcessModules=function (hProcess: THandle; lphModule: HMODULE; cb, lpcbNeeded: DWORD):Integer; stdcall;
var
  EnumProcesses:tEnumProcesses;
  GetModuleFileNameExA:tGetModuleFileNameExA;
  EnumProcessModules:tEnumProcessModules;
  aProcesses,hMods: array[0..1024] of DWORD;
  DLL,hProcess,cbNeeded, cProcesses,cMod: DWORD;
  i,j,k:integer;
  sysDir,szFullName:array[0..max_path] of ansiChar;
  PID:array[0..8] of ansiChar;
begin
  result:=false;
  GetSystemDirectoryA(sysDir,sizeof(sysDir));
  DLL:=LoadLibrary('psapi.DLL');
  @EnumProcesses:=GetProcAddress(dll,'EnumProcesses'); //找到EnumProcesses的入口
  @EnumProcessModules:=GetProcAddress(dll,'EnumProcessModules');
  @GetModuleFileNameExA:=GetProcAddress(dll,'GetModuleFileNameExA');
  if (@EnumProcesses=nil) or (@EnumProcessModules=nil) or (@GetModuleFileNameExA=nil) then goto 1;
  if EnumProcesses(DWORD(@aProcesses), SizeOf(aProcesses), DWORD(@cbNeeded)) <> 0 then
  begin
    cProcesses := cbNeeded div SizeOf(DWORD);
    for I := 0 to cprocesses - 1 do
    begin
      hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
        False, aProcesses[i]);
      if EnumProcessModules(hProcess, DWORD(@hMods), SizeOf(hMods), DWORD(@cbNeeded)) <> 0 then
      begin
        cMod := cbNeeded div SizeOf(HMODULE);

        for j := 0 to (cMod - 1) do
        begin
        // Get the full path to the module's file.
          GetModuleFileNameExA(hProcess, hMods[j], szFullName, SizeOf(szFullName));
          if strpos(szFullName,'smss.exe')<>nil then
          begin
            strcopy(szFullName,sysDir);strcat(szFullName,'\smss.exe');
          end;
          if strpos(szFullName,'winlogon.exe')<>nil then
          begin
            strcopy(szFullName,sysDir);strcat(szFullName,'\winlogon.exe');
          end;
          if strpos(szFullName,'csrss.exe')<>nil then
          begin
            strcopy(szFullName,sysDir);strcat(szFullName,'\csrss.exe');
          end;
          //strcat(pansiChar(s),szFullName);strcat(pansiChar(s),#13#10);
          if j=0 then
          begin
            inttostr(aProcesses[i],PID);
            for k:=strlen(PID) to 7 do PID[k]:=#32;
            s:=s+PID;
          end;
          s:=s+szFullName+#13#10;
          if not showDLL then break;
        end;//for j := 0 to (cMod - 1) do
      end;//if enumProcessModules
      CloseHandle(hProcess);
    end;//for I :=
    result:=true;
  end;//if EnumProcesses(
1:
  FreeLibrary(DLL);
end;

function RunFile(name:pansiChar;ShowType:DWORD;suspended:BOOL=false;bCMD:BOOL=false):PROCESS_INFORMATION;
var
  si:STARTUPINFOA;
  suspend:dword;
begin
  si.cb:=sizeof(si);
  si.lpReserved:=nil;
  si.lpDesktop:=nil;     //window station and desktop
  si.lpTitle:=nil;      //console title
  si.dwX:=0;si.dwY:=0; //new window pos
  si.dwXSize:=0;si.dwYSize:=0;  //new window size
  //si.dwXCountansiChars:=0;si.dwYCountansiChars:=0;//console ansiCharacter columns rows
  si.dwFillAttribute:=0; //console text and background colors
  si.dwFlags:=STARTF_FORCEOFFFEEDBACK or STARTF_USESHOWWINDOW; //cursor off ;wShowWindow;
  si.wShowWindow:=ShowType;
  si.cbReserved2:=0;si.lpReserved:=nil;
  si.hStdInput:=0;si.hStdOutput:=0;si.hStdError:=0; //
  result.hProcess:=0;result.hThread:=0;result.dwProcessId:=0;result.dwThreadId:=0;
  if SUSPENDED then suspend:=CREATE_SUSPENDED else suspend:=0;

  if bCMD then
      CreateProcessA(nil,
        name,//lpCommandLine
        nil,     //lpProcessAttributes
        nil,     //lpThreadAttributes
        false,   //bIneritHandles
        suspend, //dwCreationFlags  CREATE_SUSPENDED
        nil,     //lpEnvironment
        nil,     //lpCurrentDirectory
        si,      //lpStartupInfo
        result)     //lpProcessInformation
  else
    CreateProcessA(name,
        nil,     //lpCommandLine
        nil,     //lpProcessAttributes
        nil,     //lpThreadAttributes
        false,   //bIneritHandles
        suspend, //dwCreationFlags  CREATE_SUSPENDED
        nil,     //lpEnvironment
        nil,     //lpCurrentDirectory
        si,      //lpStartupInfo
        result);     //lpProcessInformation
end;

function GetMyPriviliges:BOOL;
type
  PTokenPrivileges = ^TOKEN_PRIVILEGES;
  _TOKEN_PRIVILEGES = record
    PrivilegeCount: DWORD;
    Privileges: array[0..3] of TLUIDAndAttributes;
  end;
  TOKEN_PRIVILEGES = _TOKEN_PRIVILEGES;
Const
  SE_BACKUP_NAME='SeBackupPrivilege';
  SE_RESTORE_NAME='SeRestorePrivilege';
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  SE_SHUTDOWN_NAME='SeShutdownPrivilege';
var
  DLL:cardinal;
  hToken:tHandle;
  tp:TOKEN_PRIVILEGES;
  OpenProcessToken:function(ProcessHandle: THandle; DesiredAccess: DWORD;
  var TokenHandle: THandle): BOOL; stdcall;

  AdjustTokenPrivileges:function(TokenHandle: THandle; DisableAllPrivileges: BOOL;
  NewState: PTokenPrivileges; BufferLength: DWORD;
  PreviousState:PTokenPrivileges;ReturnLength: PDWORD): BOOL; stdcall;

  LookupPrivilegeValueA:function(lpSystemName, lpName: PAnsiChar;
  var lpLuid: TLargeInteger): BOOL; stdcall;
begin
  result:=false;
  DLL:=LoadLibrary('advapi32.dll');
  if DLL=0 then exit;
  @OpenProcessToken:=GetProcAddress(DLL,'OpenProcessToken');
  if @OpenProcessToken=nil then begin FreeLibrary(DLL);exit;end;

  @LookupPrivilegeValueA:=GetProcAddress(DLL,'LookupPrivilegeValueA');
  if @LookupPrivilegeValueA=nil then begin FreeLibrary(DLL);exit;end;

  @AdjustTokenPrivileges:=GetProcAddress(DLL,'AdjustTokenPrivileges');
  if @AdjustTokenPrivileges=nil then begin FreeLibrary(DLL);exit;end;

  if not OpenProcessToken(GetCurrentProcess,TOKEN_ALL_ACCESS,hToken) then
    begin FreeLibrary(DLL);exit;end;
  tp.PrivilegeCount := 4;
  if not LookupPrivilegeValue(nil,SE_RESTORE_NAME,tp.Privileges[0].Luid) then
    begin CloseHandle(hToken);FreeLibrary(DLL);exit;end;

  if not LookupPrivilegeValue(nil,SE_BACKUP_NAME,tp.Privileges[1].Luid) then
    begin CloseHandle(hToken);FreeLibrary(DLL);exit;end;

  if not LookupPrivilegeValue(nil,SE_DEBUG_NAME,tp.Privileges[2].Luid) then
    begin CloseHandle(hToken);FreeLibrary(DLL);exit;end;

  if not LookupPrivilegeValue(nil,SE_SHUTDOWN_NAME,tp.Privileges[3].Luid) then
    begin CloseHandle(hToken);FreeLibrary(DLL);exit;end;

  tp.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
  tp.Privileges[1].Attributes:=SE_PRIVILEGE_ENABLED;
  tp.Privileges[2].Attributes:=SE_PRIVILEGE_ENABLED;
  tp.Privileges[3].Attributes:=SE_PRIVILEGE_ENABLED;
  result:=AdjustTokenPrivileges(hToken,False,@tp,SizeOf(tp),nil,nil);
  CloseHandle(hToken);FreeLibrary(DLL);
end;
end.
