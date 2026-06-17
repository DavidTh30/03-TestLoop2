unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,  StdCtrls,
  ExtCtrls, EpikTimer, BGRABitmap,BGRABitmapTypes, GraphType, LCLIntf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PaintBox2: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    timer_: TEpikTimer;
    Run_:Boolean;
    Speed_frame:Extended;
    Background_, bmp, bmp2: TBGRABitmap;
    Point_: array[1..4] of Integer;
    Grid_:TPOINT;
    c: TBGRAPixel;
    Trect_:Trect;
    Positioning:integer;
    Average_:Extended;
    Min_, Max_:integer;
    procedure Main_Loop();
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Main_Loop();
//Use Case 1 disable case 2; design for running one program only
//Use Case 2 disable case 2; design for Share CUP to other program

//Case 1 at 50F/S Maximum: 21000000 line/Sec;  Minimum: 17000000 Line/Sec;  400000 Line/Frame
//Case 2 at 50F/S Maximum: 700000 line/Sec;  Minimum: 500000 Line/Sec;  13000 Line/Frame

//const
//IO : array[0..1] of char = ('0','1');
var
  Frame_, Line_,OldLine_, BackgroundSpeed:integer;
  Timer_before:Extended;
  i:integer;
  ProcessWait:integer;
  IsOneSec,IsOneFrame:Boolean;
  s1:String;

begin
  if Not Run_ then
  begin
    Run_:=True;
    Timer_before:=0;
    Frame_:=0;
    Line_:=0;
    timer_.Clear;
    timer_.Start;
    IsOneSec:=False;
    IsOneFrame:=False;
    BackgroundSpeed:=0;
    ProcessWait:=200;
    s1:='';

    while Run_ do
    begin

      //application.ProcessMessages; //Work one program only   Case 1.
      //Run your program here
      //.
      //.
      //bmp.PutImage(0,0,Background_,dmDrawWithTransparency);
      Trect_.TopLeft.x:=BackgroundSpeed;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=PaintBox2.Width;
      Trect_.BottomRight.y:=PaintBox2.Height;
      bmp.PutImagePart(0,0,bmp,Trect_,dmDrawWithTransparency);

      Trect_.TopLeft.x:=Positioning;
      Trect_.TopLeft.y:=0;
      Trect_.BottomRight.x:=Positioning+1;
      Trect_.BottomRight.y:=bmp2.Height;
      c := ColorToBGRA(rgb(255,50,0));
      bmp.PutImagePart(PaintBox2.Width-1,0,bmp2,Trect_,dmDrawWithTransparency);

      //bmp.PutImage(0,0,Background_,dmDrawWithTransparency);
      if IsOneFrame then
      begin
      if (Point_[2]>0) then Point_[2]:=PaintBox2.Height-Point_[2];
      if (Point_[4]>0) then Point_[4]:=PaintBox2.Height-Point_[4];
      if (Point_[1]>0) and (Point_[2]>0) then
      begin
        i:=PaintBox2.Width;
        c := ColorToBGRA(rgb(0,05,108));  //ColorToBGRA(rgb(0,105,208));
        bmp.DrawPolyLineAntialias([PointF(i-1,Point_[1]), PointF(i,Point_[2])],c,5);
        c := ColorToBGRA(rgb(105,0,208));
        bmp.DrawPolyLineAntialias([PointF(i-1,Point_[3]), PointF(i,Point_[4])],c,5);
      end;
      Point_[1]:=Point_[2];
      Point_[3]:=Point_[4];
      end;

      //Any text information here
      //.
      //.

      BackgroundSpeed:=0;
      //Render here
      bmp.Draw(PaintBox2.Canvas,0,0,True);
      //bmp2.Draw(PaintBox3.Canvas,0,0,True);
      //PaintBox3.Canvas.TextOut(0,0,'test');
      //PaintBox3.Update;

      PaintBox2.Update;
      //PaintBox2.DisableAutoSizing;
      PaintBox2.UpdateRolesForForm;
      PaintBox2.InitiateAction;
      //PaintBox2.Invalidate;
      //PaintBox2.Refresh;
      bmp.InvalidateBitmap;
      bmp.LoadFromBitmapIfNeeded;
        application.ProcessMessages;
      //Clear your hardware here

      //application.StopOnException:=false;
      //if not application.StopOnException then
      if ((timer_.Elapsed -Timer_before >= Speed_frame) and (Run_)) then
      begin
        //Manage your timer here
        IsOneFrame:=True;
        Timer_before:=timer_.Elapsed;
        if timer_.Elapsed >= 1 then
        begin
          IsOneSec:=True;
          timer_.Stop;
          Timer_before:=0;
          timer_.Clear;
          timer_.Start;
        end;

        //If your hardware active then code hear
        //.
        //.

        //Moving object code hear
        Frame_:=Frame_+1;
        BackgroundSpeed:=1;
        Positioning:=Positioning+1;
        if Positioning = (bmp2.Width) then Positioning :=0;

        //Run_:=not Run_; //For run only 1 cycle
      end;

      //Other status here
      if IsOneFrame then
      begin
        if (Min_=0) or (Min_>Line_) then min_:=Line_;
        if (Max_=0) or (Max_<Line_) then Max_:=Line_;
        if (Min_>0) and (Max_>0) and (Max_-Min_>0) then i:=round(((Max_+(Max_/100*10))-Min_)/PaintBox2.Height);
        if i<=0 then i:=1;
        if (Min_>0) and (Max_>0) and (Line_>0) and (Max_-Min_>0) then
        begin
          Point_[2]:=round((Line_-Min_)/i);
          Average_:=(Average_+Point_[2])/2;
          Point_[4]:=round(Average_);
        end;
        OldLine_:=Line_;
        Line_:=0;
      end;

      //Clear something and do some other status here
      Line_:=Line_+1;
      if IsOneSec then
      begin
        S1:=IntToStr(Frame_) + ' Frame/Sec' + Chr(13);
        S1:=S1 + IntToStr(OldLine_) + ' Line/Frame' + Chr(13);
        S1:=S1 + 'Factor= '+IntToStr(i) + ' Offset at 10%='+FloatToStr(Max_/100*10);
        S1:=S1 + Chr(13);
        S1:=S1 + ' Min='+IntToStr(Min_)+' Max='+IntToStr(Max_);
        S1:=S1 + Chr(13);
        S1:=S1 + 'Point1='+IntToStr(Point_[1])+' Point2='+IntToStr(Point_[2]);
        S1:=S1 + ' PaintBox Height='+IntToStr(PaintBox2.Height);
        Label1.Caption:=S1;
        Frame_:=0;
        IsOneSec:=False;
      end;

      for i:=1 to ProcessWait do
        application.ProcessMessages; //Share CUP  Case 2
    end;

    If not Run_ then  timer_.Stop;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
  i2:integer;
  i3:integer;
begin
  Speed_frame:=0.02;
  timer_ := TEpikTimer.Create(nil);
  Run_:=False;
  Positioning:=0;

  Point_[1]:=0;
  Point_[2]:=0;
  Point_[3]:=0;
  Point_[4]:=0;
  Average_:=0;
  Max_:=0;
  Min_:=0;

  Grid_.X:=26;
  Grid_.y:=15;

  if Grid_.X<0 then Grid_.X:=0;
  if Grid_.Y<0 then Grid_.Y:=0;

  Background_ := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00000000));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp := TBGRABitmap.Create(PaintBox2.Width,PaintBox2.Height, ColorToBGRA($00CCCCCC));//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))
  bmp2 := TBGRABitmap.Create(Round(PaintBox2.Width/(Grid_.X+1))+1,PaintBox2.Height, ColorToBGRA($00CCCCCC));//ColorToBGRA($00CCCCCC)//clForeground //clBtnFace  //clWindow //ColorToBGRA(rgb(255,255,255))

  Background_.Canvas2D.lineWidth:=1;
  Background_.Canvas2D.strokeStyle ('rgb(55,255,55)');
  Background_.Canvas2D.stroke();

  Background_.JoinStyle := pjsBevel;
  Background_.PenStyle := psSolid;

  c := ColorToBGRA(rgb(50,50,50));
  i2:=Round(PaintBox2.Width/(Grid_.X+1));
  i3:=0;
  for i := 0 to Grid_.X do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(i3,0), PointF(i3,PaintBox2.Height)],c,1);
  end;

  i2:=Round(PaintBox2.Height/(Grid_.Y+1));
  i3:=0;
  for i := 0 to Grid_.Y do
  begin
    i3:=i3+i2;
    Background_.DrawPolyLineAntialias([PointF(0,i3), PointF(PaintBox2.Width,i3)],c,1);
  end;

  //for i := 0 to Grid_.X+1 do
  //begin
  //  Background_.DrawPolyLineAntialias([PointF(i*Grid_.X,0), PointF(i*Grid_.X,PaintBox2.Height)],c,1);
  //end;
  //
  //for i := 0 to Grid_.Y do
  //begin
  //  Background_.DrawPolyLineAntialias([PointF(0,i*Grid_.y), PointF(Grid_.X*21,i*Grid_.y)],c,1);
  //end;

  //c := ColorToBGRA(rgb(0,105,208));
  //Background_.DrawPolyLineAntialias([PointF(101+(0*20),10), PointF(101+(0*20),62)],c,1);
  //Background_.DrawPolyLineAntialias([PointF(121+(0*20),10), PointF(121+(0*20),62)],c,2);
  //Background_.Canvas2D.lineWidth:=1;
  //Background_.Canvas2D.strokeStyle ('rgb(0,0,0)');
  //Background_.Canvas2D.fillStyle(rgb(0,225,0));
  //Background_.Canvas2D.beginPath();
  //Background_.Canvas2D.moveTo(81,43);
  //Background_.Canvas2D.lineTo(81,52);
  //Background_.Canvas2D.lineTo(101,52);
  //Background_.Canvas2D.lineTo(101,43);
  //Background_.Canvas2D.closePath();
  //Background_.Canvas2D.fill();
  //Background_.Canvas2D.stroke();
  //Background_.TextOut(0,0,inttostr(round(timer_.Elapsed*1000))+ ' ms',BGRAWhite);
  //Background_.FillRect(0,70,20,90,BGRA(0,255,0,110), dmDrawWithTransparency);


  //bmp2.PutImage(5,2,Background_,dmDrawWithTransparency);
  //bmp2:=Background_.Resample(Grid_.X*2, PaintBox2.Height) as TBGRABitmap; //stretch
  //Trect_.TopLeft.x:=5;
  //Trect_.TopLeft.y:=2;
  //Trect_.BottomRight.x:=15;//Grid_.X*21;
  //Trect_.BottomRight.y:=PaintBox2.Height;
  //Background_.Draw(bmp2.Canvas,Trect_,True); //stretch
  //bmp2.Canvas2D.drawImage(bmp,5,2,15,PaintBox2.Height); //stretch

  bmp.PutImage(0,0,Background_,dmDrawWithTransparency);

  Trect_.TopLeft.x:=0;
  Trect_.TopLeft.y:=0;
  Trect_.BottomRight.x:=bmp2.Width;
  Trect_.BottomRight.y:=bmp2.Height;
  bmp2.PutImagePart(0,0,Background_,Trect_,dmDrawWithTransparency);
  Positioning:=(PaintBox2.Width mod (Trect_.BottomRight.x-1));
  //c := ColorToBGRA(rgb(250,50,50));
  //bmp2.DrawPolyLineAntialias([PointF(0,0), PointF(0,bmp2.Height)],c,1);

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Label2.Visible:=False;
  Main_Loop();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Speed_frame:=0.02;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Speed_frame:=0.029;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Label2.Visible:=True;
  Run_:=False;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Speed_frame:=0.0134;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Speed_frame:=0.1;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Run_:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  timer_.Free;
  Background_.Free;
  bmp.Free;
  bmp2.Free;
end;

end.

