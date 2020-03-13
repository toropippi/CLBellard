# CLBellard
 Bellard's formula for PI implemented in OpenCL and HSP
![softimage0](https://user-images.githubusercontent.com/44022497/76437541-0b8eb900-63fd-11ea-8e9c-eac567151c77.png)
# normal mode
Calculate pi on one device.  
1つのデバイスでpiを計算します。  
# work mode
Calculate pi on multiple devices. To distribute the load, you need to create a job list in advance. Please refer to worklist_sample.txt.
After the calculation is completed, execute workmodeSum0_6.exe.  
複数のデバイスでpiを計算します。 負荷を分散するには、事前にジョブリストを作成する必要があります。 worklist_sample.txtを参照してください。  
計算が完了したら、workmodeSum0_6.exeを実行します。  
# input digits
Be sure to specify a multiple of 5 for the number of inputs. If it is not a multiple of 5, it will be a multiple of 5.  
必ず5の倍数で指定してください。5の倍数でない場合強制的に5の倍数になります。  
# Build options
## -cl-denorms-are-zero
This option controls how single precision and double precision denormalized numbers are handled. If specified as a build option, the single precision denormalized numbers may be flushed to zero and if the optional extension for double precision is supported, double precision denormalized numbers may also be flushed to zero. This is intended to be a performance hint and the OpenCL compiler can choose not to flush denorms to zero if the device supports single precision (or double precision) denormalized numbers.  
In my environment, it contributed to 0-1% speedup, and there was no decrease in calculation precision.  
このオプションは、単精度および倍精度の非正規化数の処理方法を制御します。 ビルドオプションとして指定された場合、単精度の非正規化数はゼロにフラッシュされ、倍精度のオプションの拡張機能がサポートされている場合、倍精度の非正規化数もゼロにフラッシュされます。 これはパフォーマンスのヒントとなることを目的としており、デバイスが単精度（または倍精度）の非正規化数をサポートしている場合、OpenCLコンパイラはデノラムをゼロにフラッシュしないことを選択できます。  
私の環境では、0-1％の高速化に貢献し、計算精度の低下はありませんでした。  
## -cl-fast-relaxed-math
Sets the optimization options -cl-finite-math-only, -cl-mad-enable and -cl-no-signed-zeros.  
In my environment, it contributed 3-5% speedup, but the calculation precision was reduced on AMD and Intel processors.  
最適化オプション-cl-finite-math-only、-cl-mad-enable、および-cl-no-signed-zerosを設定します。  
私の環境では、3〜5％の高速化に貢献しましたが、AMDおよびIntelプロセッサーでは計算精度が低下しました。  
  
-cl-finite-math-only  
Allow optimizations for floating-point arithmetic that assume that arguments and results are not NaNs or ±∞.  
引数と結果がNaNまたは±∞でないと仮定する浮動小数点演算の最適化を許可します。  
  
-cl-mad-enable  
Allow a * b + c to be replaced by a mad. The mad computes a * b + c with reduced accuracy. For example, some OpenCL devices implement mad as truncate the result of a * b before adding it to c.  
a* b + cをmadに置き換えることができます。 madは精度を下げてa * b + cを計算します。 たとえば、一部のOpenCLデバイスは、a * bの結果をcに追加する前に切り捨ててmadを実装します。  
  
-cl-no-signed-zeros  
Allow optimizations for floating-point arithmetic that ignore the signedness of zero. IEEE 754 arithmetic specifies the behavior of distinct +0.0 and -0.0 values, which then prohibits simplification of expressions such as x+0.0 or 0.0*x (even with -clfinite-math only). This option implies that the sign of a zero result isn't significant.  
ゼロの符号付きを無視する浮動小数点演算の最適化を許可します。 IEEE 754算術は、+ 0.0と-0.0の異なる値の動作を指定します。これにより、x + 0.0や0.0 * xなどの式の単純化が禁止されます（-clfinite-mathのみでも）。 このオプションは、ゼロの結果の符号が重要でないことを意味します。
