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
    Panel1: TPanel;
    Timer1: TTimer;
    SpinBox1: TSpinBox;
    Label1: TLabel;
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
    _BeziFs :array [ 0..3 ] of TDoubleND;
    _FrameI :Cardinal;
    _BeziF  :TDoubleND;
    _PolyK  :TDoubleND;
    _BeziK  :TDoubleND;
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
     for I := 0 to _BeziF.DimN-1 do
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
     for I := 0 to _BeziF.DimN-2 do
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

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     SpinBox1Change( Sender );
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.GraphFrame1Paint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
     DrawPolyCurv( 6, TAlphaColors.Black );

     DrawBeziEdge( 3, TAlphaColors.Lime  );
     DrawBeziPoin( 6, TAlphaColors.Lime  );
     DrawBeziPoin( 3, TAlphaColors.White );
     DrawBeziCurv( 3, TAlphaColors.Red   );
end;

//------------------------------------------------------------------------------

procedure TForm1.Timer1Timer(Sender: TObject);
const
     KeyW :Cardinal = 20{Frame};
var
   Id :Integer;
   Bs :TDouble4D;
begin
     Id := _FrameI mod KeyW;

     if Id = 0 then
     begin
          _BeziFs[ 0 ] := _BeziFs[ 1 ];
          _BeziFs[ 1 ] := _BeziFs[ 2 ];
          _BeziFs[ 2 ] := _BeziFs[ 3 ];

          _BeziFs[ 3 ] := 2 * TDoubleND.RandBS1( _PolyN );
     end;

     BSplin4( Id / KeyW, Bs );

     _BeziF := Bs._1 * _BeziFs[ 0 ]
             + Bs._2 * _BeziFs[ 1 ]
             + Bs._3 * _BeziFs[ 2 ]
             + Bs._4 * _BeziFs[ 3 ];

     _PolyK := BeziToPoly( _BeziF );  // Bernstein → Power

     _BeziK := PolyToBezi( _PolyK );  // Power → Bernstein

     GraphFrame1.Repaint;

     Inc( _FrameI );
end;

//------------------------------------------------------------------------------

procedure TForm1.SpinBox1Change(Sender: TObject);
begin
     _PolyN := Round( SpinBox1.Value ) + 1;

     _BeziFs[ 1 ] := TDoubleND.Create( 0, _PolyN );
     _BeziFs[ 2 ] := TDoubleND.Create( 0, _PolyN );
     _BeziFs[ 3 ] := TDoubleND.Create( 0, _PolyN );

     _FrameI := 0;

     Timer1Timer( Sender );
end;

end. //######################################################################### ■
