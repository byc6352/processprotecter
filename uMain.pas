unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uFuncs,uConfig, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfMain = class(TForm)
    Panel1: TPanel;
    btnStart: TButton;
    memoOut: TMemo;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    btnClose: TButton;
    Button1: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    filename:ansiString;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}

procedure TfMain.btnCloseClick(Sender: TObject);
begin
  close();
end;

procedure TfMain.btnStartClick(Sender: TObject);
begin
  uFuncs.startProtect(filename);
  fmain.Caption:=fmain.Caption+'(正在保护...)';
end;

procedure TfMain.Button1Click(Sender: TObject);
begin
  uFuncs.stopProtect();
  fmain.Caption:=fmain.Caption+'(已关闭保护)';
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  filename:=uConfig.PROCESS_DIR+'\'+uConfig.PROCESS_NAME;
  GetMyPriviliges;
end;

procedure TfMain.Timer1Timer(Sender: TObject);
var
  s,filename:ansiString;
begin
  uFuncs.GetProcessesInfo2000(s,false);
  memoOut.Lines.Text:=s;
  {
  if(pos(uConfig.PROCESS_NAME,s)<=0)then
  begin
    uFuncs.RunFile(filename,SW_SHOW);
  end;
  }
end;

end.
