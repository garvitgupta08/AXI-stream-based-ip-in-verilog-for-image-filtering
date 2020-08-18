`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2020 01:20:06
// Design Name: 
// Module Name: image_proc_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define headerSize 1080
`define imageWidth 512
`define IW_BIT_NUM 9
module image_proc_tb(

    );
  
 reg clk,reset_n;  //all input signals to the IP are declared as variable
 reg image_Data_valid; // input to the IP indicating valid pixel data available on data bus
 reg [7:0] image_Data; // input pixel to the IP
 wire m_data_valid; // valid signal from IP
 wire [7:0] m_data; // processed pixel data from IP
 wire intr_out; // interrupt signal from IP 
 // We assume that the testbench (as SINK IP) is always ready to receive the data from IP. 
// This means IP is always to ready to accept the data from testbench. Hence, we ignore s_data_ready for now

// Initialization of input variables.
 initial begin
    clk =1'b1;  // clk variable initialization
    reset_n = 1'b0; // apply reset signal in the beginning.. active LOW reset
    image_Data = 0;
    image_Data_valid = 0;
 end   
 
 always
    #5 clk = ~clk; // generate the clock
 

integer i; // index variable for FOR loop
integer file_in,file_out; // file handlers
integer send_size; // variable to indicate amount of data to be transferred to IP

 
 initial begin
     #100 reset_n = 1'b1; // Remote the reset after  100 ns.. similar GSR of about 100 ns
     #100;
     // Send the actual image. First step is to open the file in binary format and read model
    // file_in = $fopen("lena512.bmp","rb"); // returns the pointer of integer type
    file_in = $fopen("C:/Users/Garvit/Downloads/lena512.bmp","rb");
    
     file_out = $fopen("C:/Users/Garvit/Downloads/out.bmp","wb"); // processed image writtent back
     
     // Initial header part needs to be written back as it is
     for (i=0;i<`headerSize;i=i+1)
     begin
        $fscanf(file_in,"%c",image_Data); // Read one byte at a time
        $fwrite(file_out,"%c",image_Data); // Write the byte to output file
     end
     
     // In the beginning, we need four lmage lines to fill up the four buffers of IP
     for (i=0;i<(`imageWidth*4);i=i+1) //if you have three line buffers, change it to 3.. image processing will take more time. (double)
     begin
             @(posedge clk); // wait for the positive edge of the clock
            $fscanf(file_in,"%c",image_Data); // Put pixel on the data bus of the IP
            image_Data_valid <= 1'b1;    // Make valid signal as one and wait for the handshake
            // since we assume that the IP is always ready, we do not need to check it explicitely. If this is not the case, we need to wait for the IP to become
            // ready before sending next pixel data. This can be done using wait signal
            // It is assumed that handshake has happend ...
     end
     // At this point, all four buffers of the IP are full.
     send_size = `imageWidth*4;
     @(posedge clk);
     image_Data_valid <= 1'b0;  // this indicates that data on input data bus of the IP is not valid.
     
     
     // We will write separate loop for receiving the data from IP. This loop is dedicated to writing the data to IP.
     //Below While loop will send the rest of image line by line as and when we receive interrupt from IP (indicating empty buffer)
     while(send_size < `imageWidth*`imageWidth)  
     begin
        @(posedge intr_out); // wait for interrupt
         for (i=0;i<`imageWidth;i=i+1) // send one row of the image
        begin
             @(posedge clk);// wait for the positive edge of the clock
            $fscanf(file_in,"%c",image_Data);// Put pixel on the data bus of the IP
            image_Data_valid <= 1'b1;    // Make valid signal as one and wait for the handshake
        end
        @(posedge clk);
        image_Data_valid <= 1'b0;  
        send_size = send_size + `imageWidth; //Completed sending one row of image
     end
     
//     @(posedge clk);
     image_Data_valid <= 1'b0;  
     
     // After filtering operation, out image has two rows less compared to input image. 
    // Hence, we need to send two dummry rows as we are using the same header
      @(posedge intr_out);
         for (i=0;i<`imageWidth;i=i+1)
        begin
             @(posedge clk);
            image_Data = 0; // send a row with all-zero pixel
            image_Data_valid <= 1'b1;    
        end
        
     @(posedge clk);
     image_Data_valid <= 1'b0;  
     
      @(posedge intr_out);
         for (i=0;i<`imageWidth;i=i+1)
        begin
             @(posedge clk);
            image_Data = 0;  // send a row with all-zero pixel
            image_Data_valid <= 1'b1;    
        end
        
        @(posedge clk);
        image_Data_valid <= 1'b0;  
     
     $fclose(file_in); // close the file
     
 end
 
 
 //Receive the processed image from the IP
 integer received_data = 0;
 always @(posedge clk)
 begin
    if(m_data_valid) // valid signal from the IP
    begin
         $fwrite(file_out,"%c",m_data);  //write the pixel from IP to output file
         received_data = received_data +1; // counter for the number of pixels received from IP
    end
    if(received_data == `imageWidth*`imageWidth-1) // check whether complete image is received
    begin
        $fclose(file_out);
        $stop;
    end
 end
top#
(.IMAGE_WIDTH(512),.IW_BIT_NUM(9))
s(
    .clk(clk),
    .reset_n(reset_n),
    //slave port
    .s_data_valid(image_Data_valid),
    .s_data(image_Data),
    .s_data_ready(),
    // masterport
    .m_data_valid(m_data_valid),
    .m_data(m_data),
    .m_data_ready(1'b1),
    .intr_out(intr_out)
    );
    
    
endmodule