unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.StdCtrls, FMX.Edit, FMX.EditBox, FMX.SpinBox, FMX.Controls.Presentation,
  LUX, LUX.D1, LUX.D2, LUX.D3, LUX.D4, LUX.D5, LUX.DN, LUX.Curve.T1.D1,
  FrameGraph;

type
  TForm1 = class(TForm)
    GraphFrame1: TGraphFrame;
    Timer1: TTimer;
    Panel1: TPanel;
      Label1: TLabel;
        SpinBox1: TSpinBox;
    procedure FormCreate(Sender: TObject);
    procedure GraphFrame1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure Timer1Timer(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);
  private
    { private 宣言 }
    ///// メソッド
    procedure DrawPolyCurv( const Size_:Single; const Color_:TAlphaColor );
    procedure DrawBeziPoin( const Size_:Single; const Color_:TAlphaColor );
    procedure DrawBeziEdge( const Size_:Single; const Color_:TAlphaColor );
    procedure DrawBeziCurv( const Size_:Single; const Color_:TAlphaColor );
  public
    { public 宣言 }
    _PolyN  :Integer;
    _PolyKs :array [ 0..3 ] of TDoubleND;
    _FrameI :Cardinal;
    _PolyK  :TDoubleND;
    _BeziK  :TDoubleND;
    ///// メソッド
    procedure GenPolyK;
    procedure GenBeziK;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

procedure TForm1.DrawPolyCurv( const Size_:Single; const Color_:TAlphaColor );
begin
     GraphFrame1.DrawFunc(
          function ( const X_:Single ) :Single
          begin
               Result := Poly( X_, _PolyK );
          end,
          Size_,
          Color_ );
end;

//------------------------------------------------------------------------------

procedure TForm1.DrawBeziPoin( const Size_:Single; const Color_:TAlphaColor );
var
   I :Integer;
   P :TSingle2D;
begin
     for I := 0 to _BeziK.DimN-1 do
     begin
          P.X := I / ( _BeziK.DimN-1 );
          P.Y := _BeziK[ I ];

          GraphFrame1.DrawPoin( P, Size_, Color_ );
     end;
end;

procedure TForm1.DrawBeziEdge( const Size_:Single; const Color_:TAlphaColor );
var
   I :Integer;
   P0, P1 :TSingle2D;
begin
     for I := 0 to _BeziK.DimN-2 do
     begin
          P0.X := ( I+0 ) / ( _BeziK.DimN-1 );
          P0.Y := _BeziK[ I+0 ];

          P1.X := ( I+1 ) / ( _BeziK.DimN-1 );
          P1.Y := _BeziK[ I+1 ];

          GraphFrame1.DrawLine( P0, P1, Size_, Color_ );
     end;
end;

procedure TForm1.DrawBeziCurv( const Size_:Single; const Color_:TAlphaColor );
begin
     GraphFrame1.DrawFunc(
          function ( const X_:Single ) :Single
          begin
               Result := Bezier( X_, _BeziK );
          end,
          Size_,
          Color_ );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

procedure TForm1.GenPolyK;
const
     KeyW :Cardinal = 25{Frame};
var
   Id :Integer;
   Bs :TDouble4D;
begin
     Id := _FrameI mod KeyW;

     if Id = 0 then
     begin
          _PolyKs[ 0 ] := _PolyKs[ 1 ];
          _PolyKs[ 1 ] := _PolyKs[ 2 ];
          _PolyKs[ 2 ] := _PolyKs[ 3 ];

          _PolyKs[ 3 ] := BeziToPoly( TDoubleND.RandG( _PolyN ) );  // Bernstein → Power
     end;

     BSplin4( Id / KeyW, Bs );

     _PolyK := Bs._1 * _PolyKs[ 0 ]
             + Bs._2 * _PolyKs[ 1 ]
             + Bs._3 * _PolyKs[ 2 ]
             + Bs._4 * _PolyKs[ 3 ];
end;

procedure TForm1.GenBeziK;
begin
     _BeziK := PolyToBezi( _PolyK );  // Power → Bernstein
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     SpinBox1Change( Sender );

     _FrameI := 0;

     GenPolyK;
     GenBeziK;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.GraphFrame1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
     DrawPolyCurv( 9, $FF3C3C96 );

     DrawBeziEdge( 3, $FFF06060 );
     DrawBeziCurv( 3, $FF66FF66 );
     DrawBeziPoin( 6, $FFF06060 );
     DrawBeziPoin( 3, $FFFFFFFF );
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     GenPolyK;
     GenBeziK;

     GraphFrame1.Repaint;

     Inc( _FrameI );
end;

//------------------------------------------------------------------------------

procedure TForm1.SpinBox1Change(Sender: TObject);
begin
     _PolyN := Round( SpinBox1.Value ) + 1;
end;

end. //######################################################################### ■
