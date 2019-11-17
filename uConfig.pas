unit uConfig;

interface
uses
  Vcl.Forms,System.SysUtils;
const
  WORK_DIR:string='protect';
  PROCESS_NAME:ansiString='transmiter.exe';
  PROCESS_DIR:ansiString='C:\works';
  LOG_NAME:string='protectLog.txt';

var
  logfile:string;
  workdir:string;//¹¤×÷Ä¿Â¼
  isInit:boolean=false;
  procedure init();
implementation
procedure init();
var
    me:String;
begin
  isInit:=true;
    me:=application.ExeName;
    workdir:=extractfiledir(me)+'\'+WORK_DIR;
    if(not DirectoryExists(workdir))then ForceDirectories(workdir);
    logfile:=workdir+'\'+LOG_NAME;
end;
end.
