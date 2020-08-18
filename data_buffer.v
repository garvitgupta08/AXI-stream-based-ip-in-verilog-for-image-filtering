`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2020 12:25:06
// Design Name: 
// Module Name: data_buffer
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


module data_buffer
#(
IMAGE_WIDTH=512,
IW_BIT_NUM=9
)
(
input clk,
input reset,
input [7:0]data_in_pixel,
input data_in_valid,
output [23:0]data_out_3pixel,
input data_out_read);
    
reg [7:0]data_buffer[IMAGE_WIDTH-1:0];
reg [IW_BIT_NUM-1:0] write_data_pointer_reg,write_data_pointer_next;

always@(posedge clk)
begin
    if(reset)
    write_data_pointer_reg<=0;
    else
    write_data_pointer_reg<=write_data_pointer_next;
end

always@(*)
begin
    write_data_pointer_next<=write_data_pointer_reg;
    if(data_in_valid)
     write_data_pointer_next<=write_data_pointer_reg+1'b1;
end

always@(posedge clk)
begin
    
    if(data_in_valid)
    data_buffer[write_data_pointer_reg]<=data_in_pixel;
end

reg [IW_BIT_NUM-1:0] read_data_pointer_reg,read_data_pointer_next;

always@(posedge clk)
begin
    if(reset)
    read_data_pointer_reg<=0;
    else
    read_data_pointer_reg<=read_data_pointer_next;
end

always@(*)
begin
    read_data_pointer_next<=0;
    if(data_out_read)
    read_data_pointer_next<=read_data_pointer_reg+1'b1;
end
assign data_out_3pixel={data_buffer[read_data_pointer_reg],data_buffer[read_data_pointer_reg+1],data_buffer[read_data_pointer_reg+2]};
endmodule
