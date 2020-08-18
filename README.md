# AXI stream based ip in verilog for image filtering
 This is the AXI stream based ip in verilog supporting two image filtering operations viz. blurring and edge detection. 
 For edge detection, we have used sobel filter. More details can be found here https://en.wikipedia.org/wiki/Sobel_operator#
 
 # Module specifications
 1. multi_acm: This is the module which contains the code for above two filter operations. 3 stage pipelining is used for bllurring operations each after multiplication, addtion and division. 4 stage pipelining has been used for edge detection each after multiplication, addition, squaring, and square root.
 
 2. data_buffer: This is the memory for storing the pixel received from outside the ip.
 
 3. control_block: This is the brain of the ip. This file contains code for receiving the data from DMA or some other external resource and then writing it to 4 data buffers instantiated in it, and also for sending in the data to multi_acm for filtering operations.
 
 4. top: This is the file of the ip connecting the modules. This file also contain a data buffer which stores the processed data from multi_acm unit before sending it outside
 
 5. image_proc_tb: This is the testbench for simulating the whole process. Specify the input and output path.
 
 # builtin ip
 1. cordic ip: It is used in multi_acm module for doing integer square root operations.
 2. Fifo generator: It is used for external buffer in top module.

 # Image specifiactions
 1. In testbench header is defined according to the .bmp image i.e. 1080. 
 
 # Results
 Input Image
 https://github.com/garvitgupta08/AXI-stream-based-ip-in-verilog-for-image-filtering/blob/master/lena512.bmp

 After Blurring operation
 https://raw.githubusercontent.com/garvitgupta08/AXI-stream-based-ip-in-verilog-for-image-filtering/master/out.bmp?token=AKNY4EQGIKQBR5YMQU56UDC7HPGJU
 
 After Edge detection
 https://raw.githubusercontent.com/garvitgupta08/AXI-stream-based-ip-in-verilog-for-image-filtering/master/out_5123.bmp?token=AKNY4EWIALMYI3XGXUBAMTS7HPGHI
 
