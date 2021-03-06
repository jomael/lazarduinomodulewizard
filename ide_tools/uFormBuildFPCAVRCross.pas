unit uFormBuildFPCAVRCross;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, Buttons;

{ TFormBuildFPCAVRCross }

type

TAVRBuildMode = (bmAvr5, bmAvr6);

  TFormBuildFPCAVRCross = class(TForm)
    Button2: TButton;
    Button3: TButton;
    ComboBoxArchitec: TComboBox;
    EditPathToArduinoIDE: TEdit;
    EditPathToFpc: TEdit;
    EditPathToFPCTrunk: TEdit;
    EditPathToFPCUnits: TEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Panel3: TPanel;
    RadioGroupInstruction: TRadioGroup;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    StatusBar1: TStatusBar;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure PageControl1Change(Sender: TObject);
    procedure RadioGroupInstructionClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);

  private
    FBuildMode: TAVRBuildMode;
    { private declarations }
  public
    { public declarations }

    procedure LoadSettings(const fileName: string);
    procedure SaveSettings(const fileName: string);
    procedure CopyCrossUnits(const SourceDirName: string;  TargetDirName: string);
    procedure FillComboArchitec();

  end;

var
  FormBuildFPCAVRCross: TFormBuildFPCAVRCross;

implementation

{$R *.lfm}

uses
  IDEExternToolIntf, LazIDEIntf, IniFiles;

{ TFormBuildFPCAVRCross }



procedure TFormBuildFPCAVRCross.Button2Click(Sender: TObject);
var
   pathToArduinoIDE: string;
   pathToFpcExecutables: string;
   pathToFpcSource: string;
   crossBinDIR: string;
   binutilsPath: string;
   auxStr, userString: string;
   Tool: TIDEExternalToolOptions;
   Params: TStringList;
   strExt, configFile: string;
   p: integer;
   instructionSet: string;
begin

   configFile:= LazarusIDE.GetPrimaryConfigPath+ DirectorySeparator+ 'AVRArduinoProject.ini';

   if FileExists(configFile) then
   begin
    with TIniFile.Create(configFile) do
    try
      pathToArduinoIDE:= ReadString('NewProject','PathToArduinoIDE', '');
      EditPathToArduinoIDE.Text:= pathToArduinoIDE;
    finally
      Free;
    end;
   end
   else
   begin
     Params:= TStringList.Create;
     Params.SaveToFile(configFile);
     Params.Free;
   end;

   if pathToArduinoIDE =  '' then
   begin
     userString:= 'C:\Program Files (x86)\Arduino';
     if InputQuery('Configure Path', 'Path to Arduino IDE', userString) then
        pathToArduinoIDE:= userString;
   end;

   Button2.Enabled:= False;
   pathToArduinoIDE:= Trim(EditPathToArduinoIDE.Text);
   pathToFpcExecutables:= Trim(EditPathToFpc.Text);
   pathToFpcSource:= Trim(EditPathToFPCTrunk.Text);

   if (pathToArduinoIDE = '') or  (pathToFpcExecutables = '') or (pathToFpcSource = '') then
   begin
     ShowMessage('Sorry... Empty Info...');
     Exit;
   end;

   with TIniFile.Create(configFile) do
   try
     writeString('NewProject','PathToArduinoIDE', pathToArduinoIDE);
   finally
     Free;
   end;

   //C:\laz4android\fpc\3.0.0\bin\i386-win32
   p:= Pos(DirectorySeparator+'bin', pathToFpcExecutables);
   auxStr:= Copy(pathToFpcExecutables,1,p);     //C:\laz4android\fpc\3.0.0\
   EditPathToFPCUnits.Text:= auxStr+ 'units';   //C:\laz4android\fpc\3.0.0\units

   strExt:= '';

   {$IFDEF WINDOWS}
      strExt:= '.exe';
   {$ENDIF}

   FBuildMode:= TAVRBuildMode(RadioGroupInstruction.ItemIndex);

   case FBuildMode of
      bmAvr5: instructionSet:= 'avr5';  //avr5/ATMega328p/UNO
      bmAvr6: instructionSet:= 'avr6';
   end;

   //C:\Program Files (x86)\Arduino\hardware\tools\avr\bin
   //http://svn2.freepascal.org/svn/fpcbuild/binaries/i386-win32/
   binutilsPath:= pathToArduinoIDE+DirectorySeparator+
                    'hardware'+DirectorySeparator+
                    'tools'+DirectorySeparator+
                    'avr'+DirectorySeparator+
                    'bin';

   //----------brute force ...
   CopyFile(binutilsPath+DirectorySeparator+'avr-ar'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ar'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-as'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-as'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-ld.bfd'+strExt,
              pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ld.bfd'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-ld'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ld'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-objcopy'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-objcopy'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-objdump'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-objdump'+strExt);

   CopyFile(binutilsPath+DirectorySeparator+'avr-strip'+strExt,
            pathToFpcSource+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-strip'+strExt);

   //--------------------

   Params:= TStringList.Create;
   Params.Delimiter:=' ';

   Tool := TIDEExternalToolOptions.Create;
   try
     Tool.Title := 'Running Extern [make] Tool ... ';
     Tool.WorkingDirectory := pathToFpcSource;

     //make clean crossall crossinstall FPC=%PPCBIN% OS_TARGET=embedded CPU_TARGET=avr SUBARCH=avr5
     //INSTALL_PREFIX=%INSTALL_PATH% CROSSBINDIR=%GNU_BIN_PATH% BINUTILSPREFIX=avr-embedded- CROSSOPT="-O3 -XX -CX"

     Params.Add('clean');
     Params.Add('crossall');
     Params.Add('crossinstall');
     Params.Add('FPC='+pathToFpcExecutables+DirectorySeparator+'fpc'+strExt);
     Params.Add('OS_TARGET=embedded');
     Params.Add('CPU_TARGET=avr');
     Params.Add('SUBARCH='+instructionSet);
     Params.Add('BINUTILSPREFIX=avr-embedded-');
     Params.Add('CROSSOPT="-O3 -XX -CX"');

     //crossBinDIR:='C:\Program Files (x86)\Arduino\hardware\tools\avr\avr\bin';

     crossBinDIR:= pathToArduinoIDE+DirectorySeparator+
                      'hardware'+DirectorySeparator+
                      'tools'+DirectorySeparator+
                      'avr'+DirectorySeparator+
                      'avr'+DirectorySeparator+
                      'bin';

     Params.Add('CROSSBINDIR='+crossBinDIR);
     Params.Add('INSTALL_PREFIX='+ pathToFpcSource);

     //Tool.EnvironmentOverrides.Add('set path=%path%;'+binutilsPath);  //
     Tool.Executable := pathToFpcExecutables + DirectorySeparator+ 'make'+strExt;
     Tool.CmdLineParams :=  Params.DelimitedText;
     Tool.Scanners.Add(SubToolDefault);

     if not RunExternalTool(Tool) then
       raise Exception.Create('Cannot Run Extern [make] Tool!');

   finally
     Tool.Free;
     Params.Free;
   end;

   StatusBar1.SimpleText:='Success! FPC cross Avr [Arduino] was Build!';

   Button2.Enabled:= False;
end;

procedure TFormBuildFPCAVRCross.Button3Click(Sender: TObject);
var
  fpcExecutablesPath: string;
  fpcPathTrunk: string;
  strExt: string;
  fpcUnitsPath: string;
  //sysTarget: string;
  //binutilsPath: string;
  //pathToArduinoIDE: string;
begin

  Button3.Enabled:= False;

  fpcExecutablesPath:= Trim(EditPathToFpc.Text); //C:\laz4android\fpc\3.0.0\bin\i386-win32
  fpcPathTrunk:= Trim(EditPathToFPCTrunk.Text);
  fpcUnitsPath:= Trim(EditPathToFPCUnits.Text);
  //pathToArduinoIDE:= Trim(EditPathToArduinoIDE.Text);

  if (fpcExecutablesPath = '') or  (fpcPathTrunk = '') or (fpcUnitsPath = '') then
  begin
    ShowMessage('Sorry... Empty Info...');
    Exit;
  end;

  //linux
  strExt:= '';
  //sysTarget:='i386-linux';

  {$IFDEF WINDOWS}
     strExt:= '.exe';
     //sysTarget:= 'i386-win32';
  {$ENDIF}

  if FileExists(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator +'ppcrossavr'+strExt) then
  begin
   //C:\adt32\fpctrunk300\compiler
   CopyFile(fpcPathTrunk+DirectorySeparator+
           'compiler'+DirectorySeparator +
           'ppcrossavr'+strExt,
           fpcExecutablesPath+DirectorySeparator+  //C:\laz4android\fpc\3.0.0\bin\i386-win32
           'ppcrossavr'+strExt);
  end
  else
  begin
    ShowMessage('Error. '+ sLineBreak+ fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator +'ppcrossavr'+strExt
                 +sLineBreak+'Not Exists. Please, you need "Build" ... ');
    Exit;
  end;

  //C:\adt32\fpctrunk300\compiler
  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ar'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-ar'+strExt);   //C:\laz4android\fpc\3.0.0\bin\i386-win32

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-as'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-as'+strExt);

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ld.bfd'+strExt,
             fpcExecutablesPath+DirectorySeparator+
             'avr-embedded-ld.bfd'+strExt);

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-ld'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-ld'+strExt);

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-objdump'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-objdump'+strExt);

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-objcopy'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-objcopy'+strExt);

  CopyFile(fpcPathTrunk+DirectorySeparator+'compiler'+DirectorySeparator+'avr-embedded-strip'+strExt,
           fpcExecutablesPath+DirectorySeparator+
           'avr-embedded-strip'+strExt);

  //copy units ...
  ForceDirectories(fpcUnitsPath + DirectorySeparator + 'avr-embedded');

  CopyCrossUnits(fpcPathTrunk+DirectorySeparator+
             'units'+DirectorySeparator+
             'avr-embedded',                    //C:\adt32\fpctrunk300\units\avr-embedded
             fpcUnitsPath+DirectorySeparator+   //C:\laz4android\fpc\3.0.0\units
             'avr-embedded');

  StatusBar1.SimpleText:='Success! [Installed]! FPC cross Avr [Arduino] Installed!';
  Button3.Enabled:= True;
end;

procedure TFormBuildFPCAVRCross.FillComboArchitec();
begin

  ComboBoxArchitec.Text:= '';
  ComboBoxArchitec.Items.Clear;
  if RadioGroupInstruction.ItemIndex = 0 then
  begin
    ComboBoxArchitec.Items.Add('atmega328p'); //default Arduino UNO r3/lilypad
    ComboBoxArchitec.Items.Add('atmega328');     //uno/lilypad
    ComboBoxArchitec.Items.Add('atmega168'); //Nano/pro
    ComboBoxArchitec.Items.Add('atmega32u4'); //leonardo/micro/esplora/yun/robot
   (*ComboBoxArchitec.Items.Add('atmega645');
    ComboBoxArchitec.Items.Add('atmega168p');
    ComboBoxArchitec.Items.Add('atmega165a');
    ComboBoxArchitec.Items.Add('atmega649a');
    ComboBoxArchitec.Items.Add('atmega3250pa');
    ComboBoxArchitec.Items.Add('atmega3290a');
    ComboBoxArchitec.Items.Add('atmega165p');
    ComboBoxArchitec.Items.Add('atmega16u4');
    ComboBoxArchitec.Items.Add('atmega6490p');
    ComboBoxArchitec.Items.Add('atmega324p');
    ComboBoxArchitec.Items.Add('atmega64m1');
    ComboBoxArchitec.Items.Add('atmega645p');
    ComboBoxArchitec.Items.Add('atmega329a');
    ComboBoxArchitec.Items.Add('atmega324pa');
    ComboBoxArchitec.Items.Add('atmega32hvb');
    ComboBoxArchitec.Items.Add('at90pwm316');
    ComboBoxArchitec.Items.Add('at90usb646');
    ComboBoxArchitec.Items.Add('atmega16');
    ComboBoxArchitec.Items.Add('atmega644');
    ComboBoxArchitec.Items.Add('at90can64');
    ComboBoxArchitec.Items.Add('at90can32');
    ComboBoxArchitec.Items.Add('at90pwm216');
    ComboBoxArchitec.Items.Add('atmega3250a');
    ComboBoxArchitec.Items.Add('atmega3290pa');
    ComboBoxArchitec.Items.Add('atmega325p');
    ComboBoxArchitec.Items.Add('atmega3250');
    ComboBoxArchitec.Items.Add('atmega329');
    ComboBoxArchitec.Items.Add('atmega32a');
    ComboBoxArchitec.Items.Add('atmega6490');
    ComboBoxArchitec.Items.Add('atmega168a');
    ComboBoxArchitec.Items.Add('atmega164pa');
    ComboBoxArchitec.Items.Add('atmega645a');
    ComboBoxArchitec.Items.Add('atmega3290p');
    ComboBoxArchitec.Items.Add('atmega644p');
    ComboBoxArchitec.Items.Add('atmega164a');
    ComboBoxArchitec.Items.Add('atmega162');
    ComboBoxArchitec.Items.Add('atmega32c1');
    ComboBoxArchitec.Items.Add('atmega324a');
    ComboBoxArchitec.Items.Add('atmega169a');
    ComboBoxArchitec.Items.Add('atmega644a');
    ComboBoxArchitec.Items.Add('atmega3290');
    ComboBoxArchitec.Items.Add('atmega64a');
    ComboBoxArchitec.Items.Add('atmega169p');
    ComboBoxArchitec.Items.Add('atmega32');
    ComboBoxArchitec.Items.Add('atmega168pa');
    ComboBoxArchitec.Items.Add('atmega16m1');
    ComboBoxArchitec.Items.Add('atmega16hvb');
    ComboBoxArchitec.Items.Add('atmega164p');
    ComboBoxArchitec.Items.Add('atmega325a');
    ComboBoxArchitec.Items.Add('atmega640');
    ComboBoxArchitec.Items.Add('atmega6450');
    ComboBoxArchitec.Items.Add('atmega329p');
    ComboBoxArchitec.Items.Add('at90usb647');
    ComboBoxArchitec.Items.Add('atmega6490a');
    ComboBoxArchitec.Items.Add('atmega32m1');
    ComboBoxArchitec.Items.Add('atmega64c1');
    ComboBoxArchitec.Items.Add('atmega644pa');
    ComboBoxArchitec.Items.Add('atmega325pa');
    ComboBoxArchitec.Items.Add('atmega6450a');
    ComboBoxArchitec.Items.Add('atmega329pa');
    ComboBoxArchitec.Items.Add('atmega6450p');
    ComboBoxArchitec.Items.Add('atmega64');
    ComboBoxArchitec.Items.Add('atmega165pa');
    ComboBoxArchitec.Items.Add('atmega16a');
    ComboBoxArchitec.Items.Add('atmega649');
    ComboBoxArchitec.Items.Add('atmega649p');
    ComboBoxArchitec.Items.Add('atmega3250p');
    ComboBoxArchitec.Items.Add('atmega325');
    ComboBoxArchitec.Items.Add('atmega169pa');
    ComboBoxArchitec.Items.Add('avrsim');*)
  end else
  if RadioGroupInstruction.ItemIndex = 1 then
  begin
    ComboBoxArchitec.Items.Add('atmega2560'); //Mega/Yun
   //ComboBoxArchitec.Items.Add('atmega2561 ');
  end;
end;

procedure TFormBuildFPCAVRCross.FormActivate(Sender: TObject);
begin

  PageControl1.PageIndex:= 0;
  Self.LoadSettings(LazarusIDE.GetPrimaryConfigPath + DirectorySeparator + 'AVRArduinoProject.ini');


  RadioGroupInstruction.ItemIndex:= 0;
  FBuildMode:= bmAvr5;

  FillComboArchitec();
  ComboBoxArchitec.ItemIndex:= 0;
end;

procedure TFormBuildFPCAVRCross.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Self.SaveSettings(LazarusIDE.GetPrimaryConfigPath +  DirectorySeparator + 'AVRArduinoProject.ini' );
end;

procedure TFormBuildFPCAVRCross.PageControl1Change(Sender: TObject);
begin

  StatusBar1.SimpleText:='';
  if PageControl1.ActivePageIndex <> 0 then
  begin
    if EditPathToFPCTrunk.Text = '' then
    begin
       ShowMessage('Please, Enter Path to FPC Source [trunk]...');
       PageControl1.ActivePageIndex:= 0;
       Exit;
    end;
    if EditPathToFpc.Text = '' then
    begin
       ShowMessage('Please, Enter Path to FPC [make]...');
       PageControl1.ActivePageIndex:= 0;
       Exit;
    end;
  end;

  if PageControl1.PageIndex = 1 then
  begin
     case FBuildMode of
        bmAvr5: GroupBox3.Caption:= 'Install Cross Avr5 Arduino';
        bmAvr6: GroupBox3.Caption:= 'Install Cross Avr6 Arduino';
     end;
  end;

end;

procedure TFormBuildFPCAVRCross.RadioGroupInstructionClick(Sender: TObject);
begin
  case RadioGroupInstruction.ItemIndex of
    0: FBuildMode:= bmAvr5;
    1: FBuildMode:= bmAvr6;
  end;

  FillComboArchitec();
  ComboBoxArchitec.ItemIndex:= 0;

end;

procedure TFormBuildFPCAVRCross.SpeedButton2Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
      EditPathToFPCTrunk.Text:=SelectDirectoryDialog1.FileName;
end;

procedure TFormBuildFPCAVRCross.SpeedButton3Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
     EditPathToArduinoIDE.Text:=SelectDirectoryDialog1.FileName;
end;

procedure TFormBuildFPCAVRCross.SpeedButton4Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
     EditPathToFpc.Text:=SelectDirectoryDialog1.FileName;
end;

procedure TFormBuildFPCAVRCross.SpeedButton5Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
     EditPathToFPCUnits.Text:=SelectDirectoryDialog1.FileName;
end;

//ref. http://stackoverflow.com/questions/9278513/lazarus-free-pascal-how-to-recursively-copy-a-source-directory-of-files-to-a
procedure TFormBuildFPCAVRCross.CopyCrossUnits(const SourceDirName: string; TargetDirName: string);
var
  i, NoOfFilesCopiedOK : integer;
  FilesFoundToCopy : TStringList;
  SourceDirectoryAndFileName,
  SubDirStructure, FinalisedDestDir, FinalisedFileName : string;
  count: integer;
  auxPath: string;
begin

  SubDirStructure := '';
  FinalisedDestDir := '';

  NoOfFilesCopiedOK := 0;

  // Ensures the selected source directory is set as the directory to be searched
  // and then fina all the files and directories within, storing as a StringList.

  SetCurrentDir(SourceDirName);
  FilesFoundToCopy := FindAllFiles(SourceDirName, '*', True);

  Memo1.Clear;
  try
    for i := 0 to FilesFoundToCopy.Count -1 do
    begin

      Memo1.Lines.Add(FilesFoundToCopy.Strings[i]);

      SourceDirectoryAndFileName := ChompPathDelim(CleanAndExpandDirectory(FilesFoundToCopy.Strings[i]));

      // Determine the source sub-dir structure, from selected dir downwards
      SubDirStructure := ExtractFileDir(SourceDirectoryAndFileName);
      //fixed
      count:= Length(SourceDirName);
      auxPath:= Copy(SubDirStructure, count+1, length(SubDirStructure) );

      // Now concatenate the original sub directory to the destination directory and form the total path, inc filename
      // Note : Only directories containing files will be recreated in destination. Empty dirs are skipped.
      // Zero byte files are copied, though, even if the directory contains just one zero byte file.

      FinalisedDestDir := TargetDirName + auxPath;
      FinalisedFileName := ExtractFileName(FilesFoundToCopy.Strings[i]);

        // Now create the destination directory structure,
        //if it is not yet created. If it exists, just copy the file.

      if not DirPathExists(FinalisedDestDir) then
      begin
          if not ForceDirectories(FinalisedDestDir) then
            begin
              ShowMessage(FinalisedDestDir+' cannot be created.');
            end;
      end;

       // Now copy the files to the destination dir
      if not FileUtil.CopyFile(SourceDirectoryAndFileName, FinalisedDestDir+DirectorySeparator+FinalisedFileName, true) then
          ShowMessage('Failed to copy file : ' + SourceDirectoryAndFileName)
      else NoOfFilesCopiedOK := NoOfFilesCopiedOK + 1;

    end; //for

    Memo1.Lines.Add('Done. Success !!!');   //need ?

  finally
    FilesFoundToCopy.free;
  end;

end;

procedure TFormBuildFPCAVRCross.LoadSettings(const fileName: string);
begin
  if FileExists(fileName) then
  begin
    with TIniFile.Create(fileName) do
    try
      EditPathToArduinoIDE.Text := ReadString('NewProject','PathToArduinoIDE', '');
    finally
      Free;
    end;
  end;
end;

procedure TFormBuildFPCAVRCross.SaveSettings(const fileName: string);
var
  list: TStringList;
begin
  if FileExists(fileName) then
  begin
    with TInifile.Create(fileName) do
    try
      WriteString('NewProject', 'PathToArduinoIDE', EditPathToArduinoIDE.Text);
    finally
      Free;
    end;
  end
  else
  begin
     list:= TStringList.Create;
     list.SaveToFile(fileName);
     list.Free;
     with TInifile.Create(fileName) do
     try
      WriteString('NewProject', 'PathToArduinoIDE', EditPathToArduinoIDE.Text);
     finally
      Free;
     end;
  end;
end;


end.

