# CLBellard
 Bellard's formula for PI implemented in OpenCL and HSP
![softimage0](https://user-images.githubusercontent.com/44022497/76437541-0b8eb900-63fd-11ea-8e9c-eac567151c77.png)
# normal mode
Calculate pi on one device.
# work mode
Calculate pi on multiple devices. To distribute the load, you need to create a job list in advance. Please refer to worklist_sample.txt.
After the calculation is completed, execute workmodeSum0_6.exe.

#Build options
## -cl-denorms-are-zero
This option controls how single precision and double precision denormalized numbers are handled. If specified as a build option, the single precision denormalized numbers may be flushed to zero and if the optional extension for double precision is supported, double precision denormalized numbers may also be flushed to zero. This is intended to be a performance hint and the OpenCL compiler can choose not to flush denorms to zero if the device supports single precision (or double precision) denormalized numbers.
In my environment, it contributed to 0-1% speedup, and there was no decrease in calculation precision.

## -cl-fast-relaxed-math
Sets the optimization options -cl-finite-math-only, -cl-mad-enable and -cl-no-signed-zeros.
In my environment, it contributed 3-5% speedup, but the calculation precision was reduced on AMD and Intel processors.

-cl-finite-math-only
Allow optimizations for floating-point arithmetic that assume that arguments and results are not NaNs or ±∞.

-cl-mad-enable
Allow a * b + c to be replaced by a mad. The mad computes a * b + c with reduced accuracy. For example, some OpenCL devices implement mad as truncate the result of a * b before adding it to c.

-cl-no-signed-zeros
Allow optimizations for floating-point arithmetic that ignore the signedness of zero. IEEE 754 arithmetic specifies the behavior of distinct +0.0 and -0.0 values, which then prohibits simplification of expressions such as x+0.0 or 0.0*x (even with -clfinite-math only). This option implies that the sign of a zero result isn't significant.

