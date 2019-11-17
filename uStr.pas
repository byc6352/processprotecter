unit uStr;

interface
const
  user32    = 'user32.dll';
  kernel32  ='kernel32.dll';
  gdi32     = 'gdi32.dll';
type
  DWORD=cardinal;
  BOOL = LongBool;

    _SYSTEMTIME = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  TSystemTime = _SYSTEMTIME;
var
  active:longbool=true; //���Ʒ����Ƿ�ر�
  //t     :longbool=false;//���Կ���
procedure GetLocalTime(var lpSystemTime: TSystemTime); stdcall;
function wsprintf(Output: PansiChar; Format: PansiChar): Integer; stdcall;
function Inttostr(i:integer;str:pansiChar):pansiChar;
function NowToStr(Str:pansiChar):PansiChar;
function ExTractFileDir(FileName,FileDir:pansiChar):pansiChar;
function GetHttpDir(httpFullFile,httpDir:pansiChar):pansiChar;
function GetHttpSvr(httpFullFile,httpSvr:pansiChar):pansiChar;
function strtoint(str:pansiChar;var i:integer):BOOL;
function GenStr(ansiCharCount:integer;str:pansiChar):pansiChar;

function _wsprintf(lpOut: PansiChar; lpFmt: PansiChar; lpVars: Array of Const):Integer; assembler;
function extractfilename(str:pansiChar):pansiChar;
function UpperCase(Str:pansiChar): pansiChar;
function StrFromTime(Str:pansiChar):PansiChar;
function StrPos(const Str1, Str2: PansiChar): PansiChar; assembler;
function StrComp(const Str1, Str2: PansiChar): Integer; assembler;
function StrLen(const Str: PansiChar): Cardinal; assembler;
function StrCopy(Dest: PansiChar; const Source: PansiChar): PansiChar;
function StrCat(Dest: PansiChar; const Source: PansiChar): PansiChar;
function StrEnd(const Str: PansiChar): PansiChar; assembler;
function StrLCopy(Dest: PansiChar; const Source: PansiChar; MaxLen: Cardinal): PansiChar; assembler;
function StrIComp(const Str1, Str2: PansiChar): Integer; assembler;
function StrScan(const Str: PansiChar; Chr: ansiChar): PansiChar; assembler;
function StrRScan(const Str: PansiChar; Chr: ansiChar): PansiChar; assembler;
implementation
procedure GetLocalTime; external kernel32 name 'GetLocalTime';
function wsprintf; external user32 name 'wsprintfA';

function _wsprintf(lpOut: PansiChar; lpFmt: PansiChar; lpVars: Array of Const):Integer; assembler;
var
  Count:integer;
  v1,v2:integer;
asm
  mov v1,eax
  mov v2,edx
  mov eax,ecx
  mov ecx,[ebp+$08]
  inc ecx
  mov Count,ecx
  dec ecx
  imul ecx,8
  add eax,ecx
  mov ecx,Count
  @@1:
  mov edx,[eax]
  push edx
  sub eax,8
  loop @@1
  push v2
  push v1
  Call wsprintf
  mov ecx,Count
  imul ecx,4
  add ecx,8
  add esp,ecx
end;

function StrComp(const Str1, Str2: PansiChar): Integer; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        MOV     EDI,EDX
        MOV     ESI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     EAX,EAX
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,EDX
        XOR     EDX,EDX
        REPE    CMPSB
        MOV     AL,[ESI-1]
        MOV     DL,[EDI-1]
        SUB     EAX,EDX
        POP     ESI
        POP     EDI
end;
function StrPos(const Str1, Str2: PansiChar): PansiChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        OR      EAX,EAX
        JE      @@2
        OR      EDX,EDX
        JE      @@2
        MOV     EBX,EAX
        MOV     EDI,EDX
        XOR     AL,AL
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        DEC     ECX
        JE      @@2
        MOV     ESI,ECX
        MOV     EDI,EBX
        MOV     ECX,0FFFFFFFFH
        REPNE   SCASB
        NOT     ECX
        SUB     ECX,ESI
        JBE     @@2
        MOV     EDI,EBX
        LEA     EBX,[ESI-1]
@@1:    MOV     ESI,EDX
        LODSB
        REPNE   SCASB
        JNE     @@2
        MOV     EAX,ECX
        PUSH    EDI
        MOV     ECX,EBX
        REPE    CMPSB
        POP     EDI
        MOV     ECX,EAX
        JNE     @@1
        LEA     EAX,[EDI-1]
        JMP     @@3
@@2:    XOR     EAX,EAX
@@3:    POP     EBX
        POP     ESI
        POP     EDI
end;
function StrLen(const Str: PansiChar): Cardinal; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        MOV     EAX,0FFFFFFFEH
        SUB     EAX,ECX
        MOV     EDI,EDX
end;
function StrEnd(const Str: PansiChar): PansiChar; assembler;
asm
        MOV     EDX,EDI
        MOV     EDI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        LEA     EAX,[EDI-1]
        MOV     EDI,EDX
end;
function StrCat(Dest: PansiChar; const Source: PansiChar): PansiChar;
begin
  StrCopy(StrEnd(Dest), Source);
  Result := Dest;
end;
function StrCopy(Dest: PansiChar; const Source: PansiChar): PansiChar;
asm
        PUSH    EDI
        PUSH    ESI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,ECX
        MOV     EAX,EDI
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EDX
        AND     ECX,3
        REP     MOVSB
        POP     ESI
        POP     EDI
end;
function StrLCopy(Dest: PansiChar; const Source: PansiChar; MaxLen: Cardinal): PansiChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;
function StrIComp(const Str1, Str2: PansiChar): Integer; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        MOV     EDI,EDX
        MOV     ESI,EAX
        MOV     ECX,0FFFFFFFFH
        XOR     EAX,EAX
        REPNE   SCASB
        NOT     ECX
        MOV     EDI,EDX
        XOR     EDX,EDX
@@1:    REPE    CMPSB
        JE      @@4
        MOV     AL,[ESI-1]
        CMP     AL,'a'
        JB      @@2
        CMP     AL,'z'
        JA      @@2
        SUB     AL,20H
@@2:    MOV     DL,[EDI-1]
        CMP     DL,'a'
        JB      @@3
        CMP     DL,'z'
        JA      @@3
        SUB     DL,20H
@@3:    SUB     EAX,EDX
        JE      @@1
@@4:    POP     ESI
        POP     EDI
end;
function StrScan(const Str: PansiChar; Chr: ansiChar): PansiChar; assembler;
asm
        PUSH    EDI
        PUSH    EAX
        MOV     EDI,Str
        MOV     ECX,$FFFFFFFF
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        POP     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        DEC     EAX
@@1:    POP     EDI
end;
function StrRScan(const Str: PansiChar; Chr: ansiChar): PansiChar; assembler;
asm
        PUSH    EDI
        MOV     EDI,Str
        MOV     ECX,0FFFFFFFFH
        XOR     AL,AL
        REPNE   SCASB
        NOT     ECX
        STD
        DEC     EDI
        MOV     AL,Chr
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        INC     EAX
@@1:    CLD
        POP     EDI
end;
function NowToStr(Str:pansiChar):PansiChar;
var
  St: TSystemTime;
begin
  GetLocalTime(st);
  _wsprintf(str,'%d��%d��%d��%d��%d��%d��',[st.wYear,st.wMonth,st.wDay,st.wHour,st.wMinute,st.wSecond]);
  result:=str;
end;
function StrFromTime(Str:pansiChar):PansiChar;
var
  St: TSystemTime;
begin
  GetLocalTime(st);
  _wsprintf(str,'%d%d%d%d%d',[st.wMonth,st.wDay,st.wHour,st.wMinute,st.wSecond]);
  result:=str;
end;
function Inttostr(i:integer;str:pansiChar):pansiChar;
begin
  _wsprintf(str,'%d',[i]);
  result:=str;
end;
function UpperCase(Str:pansiChar): pansiChar;
var
  Ch: ansiChar;
  L: Integer;
  Source: PansiChar;
begin
  L := Strlen(Str);
  Source := Pointer(Str);
  //Dest := Pointer(Result);
  while L <> 0 do
  begin
    Ch := Source^;
    if (Ch >= 'a') and (Ch <= 'z') then Dec(Ch, 32);
    Source^ := Ch;
    Inc(Source);
    Dec(L);
  end;
  result:=Str;
end;
function extractfilename(str:pansiChar):pansiChar;
var
  i,j:integer;
  p:pansiChar;
begin
  j:=strlen(str);
  p:=str;
  for i:=j downto 0 do
  begin
    if str[i]='\' then
    begin
      p:=@str[i+1];
      break;
    end;//if
  end;//for
  result:=p;
end;
function ExTractFileDir(FileName,FileDir:pansiChar):pansiChar;
var
  i,j:integer;
  p:pansiChar;
begin
  j:=strlen(FileName);
  p:=FileName;
  for i:=j downto 0 do
  begin
    if FileName[i]='\' then
    begin
      p:=@FileName[i];
      break;
    end;//if
  end;//for
  strLcopy(FileDir,FileName,p-FileName);
  result:=FileDir;
end;
function GetHttpDir(httpFullFile,httpDir:pansiChar):pansiChar;
//����httpFile
var
  p:pansiChar;
begin
  result:=httpFullFile;
  p:=strRscan(httpFullFile,'/');
  if(p=nil) then exit;
  strLcopy(httpDir,httpFullFile,p-httpFullFile);
  result:=p+1;
end;
function GetHttpSvr(httpFullFile,httpSvr:pansiChar):pansiChar;
//����httpDir+httpFile
var
  p:pansiChar;
begin
  result:=httpFullFile;
  p:=strscan(httpFullFile,'/');
  if(p=nil) then exit;
  strLcopy(httpSvr,httpFullFile,p-httpFullFile);
  result:=p; // /photo/ip1.dat
  //result:=p+1;photo/ip1.dat
end;

function strtoint(str:pansiChar;var i:integer):BOOL;
var
  t,j,q,f:Shortint;
  b:byte;
begin
  result:=false;i:=0;
  if (str=nil) or (strlen(str)=0) then exit;
  t:=0;
  if ord(str[0])=45 then
  begin
    q:=1;f:=-1;
  end //-88
  else begin
    q:=0;f:=1;
  end;
  for j:=strlen(str)-1 downto q do
  begin
    b:=ord(str[j]);if (b<48) or (b>57) then exit;
    b:=b-48;
    case t of
    0:i:=i+b*1;
    1:i:=i+b*10;
    2:i:=i+b*100;
    3:i:=i+b*1000;
    4:i:=i+b*10000;
    5:i:=i+b*100000;
    6:i:=i+b*1000000;
    7:i:=i+b*10000000;
    8:i:=i+b*100000000;
    9:i:=i+b*1000000000;
    10:i:=i+b*10000000000;
    end;
    inc(t);
  end;//for
  result:=true;
end;
function GenStr(ansiCharCount:integer;str:pansiChar):pansiChar;
var
  i,r,o:integer;
begin
  Randomize;result:=nil;
  if ansiCharCount<=0 then exit;
  for i:=0 to ansiCharCount-1 do
  begin
    r:=random(25);
    o:=r+97;
    str[i]:=ansiChar(o);
  end;
  str[ansiCharCount]:=#0;
  result:=str;
end;
end.
