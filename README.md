# BezierConverter
任意の次数の[多項式](https://www.wikiwand.com/ja/%E5%A4%9A%E9%A0%85%E5%BC%8F)（[多項式基底](https://www.wikiwand.com/ja/%E5%A4%9A%E9%A0%85%E5%BC%8F%E5%9F%BA%E5%BA%95)）を[バーンスタイン多項式](https://www.wikiwand.com/ja/%E3%83%90%E3%83%BC%E3%83%B3%E3%82%B9%E3%82%BF%E3%82%A4%E3%83%B3%E5%A4%9A%E9%A0%85%E5%BC%8F)、つまり[ベジエ曲線](https://www.wikiwand.com/ja/%E3%83%99%E3%82%B8%E3%82%A7%E6%9B%B2%E7%B7%9A)へ基底変換します。

![](https://media.githubusercontent.com/media/LUXOPHIA/BezierConverter/master/--------/_SCREENSHOT/BezierConverter.png)

任意次元のベクトルを扱う `LUX.DN.TDoubleND` レコード型を利用している。`TDoubleND.DimN` プロパティが次元数を示す。
`Comb( n, k )` は [組合せ(Combination)](https://www.wikiwand.com/ja/%E7%B5%84%E5%90%88%E3%81%9B_(%E6%95%B0%E5%AD%A6))数、つまり [二項係数](https://www.wikiwand.com/ja/%E4%BA%8C%E9%A0%85%E4%BF%82%E6%95%B0) を返す関数。

### ▼ 多項式基底 ⇒ バーンスタイン基底

```pascal
function PolyToBezi( const P_:TDoubleND ) :TDoubleND;
var
   X, Y :Integer;
begin
     with Result do
     begin
          DimN := P_.DimN;
          for X := 0 to DimN-1 do _s[ X ] := P_[ X ] / Comb( DimN-1, X );
          for Y := 1 to DimN-1 do
          begin
               for X := DimN-1 downto Y do _s[ X ] := _s[ X ] + _s[ X-1 ];
          end;
     end;
end;
```

### ▼ バーンスタイン基底 ⇒ 多項式基底
```pascal
function BeziToPoly( const P_:TDoubleND ) :TDoubleND;
var
   X, Y :Integer;
begin
     with Result do
     begin
          _s := Copy( P_._s );
          for Y := 1 to DimN-1 do
          begin
               for X := DimN-1 downto Y do _s[ X ] := _s[ X ] - _s[ X-1 ];
          end;
          for X := 0 to DimN-1 do _s[ X ] := _s[ X ] * Comb( DimN-1, X );
     end;
end;
```

----

* [BYU Computer Science](https://cs.byu.edu)
    * [Thomas W. Sederberg](https://cs.byu.edu/faculty/tom)
    * [COMPUTER AIDED GEOMETRIC DESIGN](http://tom.cs.byu.edu/~557/text/cagd.pdf)
        * [Chapter 3 Polynomial Evaluation and Basis Conversion](http://cagd.cs.byu.edu/~557/text/ch3.pdf)

[![Delphi Starter](http://img.en25.com/EloquaImages/clients/Embarcadero/%7B063f1eec-64a6-4c19-840f-9b59d407c914%7D_dx-starter-bn159.png)](https://www.embarcadero.com/jp/products/delphi/starter)
