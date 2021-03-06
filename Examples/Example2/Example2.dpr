(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example5.dpr                                  *)
(*      last modify     : 24.12.11                                      *)
(*      license         : BSD                                           *)
(*                                                                      *)
(*      created by      : Maksym Tymkovych (niello)                     *)
(*      Site            : www.niello.org.ua                             *)
(*      e-mail          : muxamed13@ukr.net                             *)
(*      ICQ             : 446-769-253                                   *)
(*                                                                      *)
(*      and             : Alexander Kiselev (Igroman)                   *)
(*      Site            : http://Igroman14.livejournal.com              *)
(*      e-mail          : Igroman14@yandex.ru                           *)
(*      ICQ             : 207-381-695                                   *)
(*                                                                      *)
(************************delphi-opencl2010-2011**************************)

program Example2;

{$APPTYPE CONSOLE}
{$INCLUDE ..\..\Source\OpenCL.inc}

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  DelphiCL in '..\..\Source\DelphiCL.pas',
  SysUtils;

const
  Width  = 512;
  Height = 512;

var
  host_image: array [0 .. Width * Height * 4] of Byte;

{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$REGION 'SaveToFile'}{$ENDIF}
procedure SaveToFile(const FileName: String);
type
  DWORD = LongWord;

  TBitmapFileHeader = packed record
    bfType: Word;
    bfSize: DWORD;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: DWORD;
  end;

  TBitmapInfoHeader = packed record
    biSize: DWORD;
    biWidth: Longint;
    biHeight: Longint;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: DWORD;
    biSizeImage: DWORD;
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: DWORD;
    biClrImportant: DWORD;
  end;

const
  BI_RGB = 0;
var
  F: File;
  BFH: TBitmapFileHeader;
  BIH: TBitmapInfoHeader;
begin
  Assign(F, FileName);
  Rewrite(F, 1);
  FillChar(BFH, SizeOf(BFH), 0);
  FillChar(BIH, SizeOf(BIH), 0);
  with BFH do
  begin
    bfType := $4D42;
    bfSize := SizeOf(BFH) + SizeOf(BIH) + Width * Height * 4;
    bfOffBits := SizeOf(BIH) + SizeOf(BFH);
  end;
  BlockWrite(F, BFH, SizeOf(BFH));
  with BIH do
  begin
    biSize := SizeOf(BIH);
    biWidth := Width;
    biHeight := Height;
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biSizeImage := Width * Height * 4;
  end;
  BlockWrite(F, BIH, SizeOf(BIH));
  BlockWrite(F, host_image, Width * Height * 4 * SizeOf(Byte));
  Close(F);
end;
{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$ENDREGION}{$ENDIF}

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  FractalProgram: TDCLProgram;
  Kernel : TDCLKernel;
  FractalBuffer: TDCLBuffer;
  FileName: TFileName;
begin
  // specify program
  FileName := ExtractFilePath(ParamStr(0)) +  '..\..\Resources\Example2.cl';
  Assert(FileExists(FileName));

  InitOpenCL;
  Platforms := TDCLPlatforms.Create;
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  try
    CommandQueue := CreateCommandQueue;
    try
      FractalBuffer := CreateBuffer(Width * Height * 4 * SizeOf(Byte), nil, [mfWriteOnly]);
      FractalProgram := CreateProgram(FileName);

      // create kernel and specify arguments
      Kernel := FractalProgram.CreateKernel('render');
      Kernel.SetArg(0, FractalBuffer);

      CommandQueue.Execute(Kernel, [TSize_t(Width), TSize_t(Height)]);
      CommandQueue.ReadBuffer(FractalBuffer, Width * Height * 4 * SizeOf(Byte),
        @host_image[0]);
      SaveToFile(ExtractFilePath(ParamStr(0)) + 'Example2.bmp');

      FreeAndNil(Kernel);
      FreeAndNil(FractalProgram);
      FreeAndNil(FractalBuffer);
    finally
      FreeAndNil(CommandQueue);
    end;
  finally
    FreeAndNil(Platforms);
  end;
  Writeln('press any key...');
  Readln;
end.
