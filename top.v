`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2020 00:44:29
// Design Name: 
// Module Name: top
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


module top#
(IMAGE_WIDTH=512,
IW_BIT_NUM=9)
(input clk,input reset_n,
//slave port
input s_data_valid,
input [7:0] s_data,  // IP will get data pixel by pixel
output s_data_ready,
//master port
output m_data_valid,
output [7:0]m_data,
input m_data_ready,
output intr_out);

    wire [71:0] data_box;
    wire data_box_valid;
    //wire [1:0] wr_buffer_ind_reg;
    control_block #
    (
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IW_BIT_NUM(IW_BIT_NUM)
    )
    c1 (
    .clk(clk),
    .reset(!reset_n),
    .data_in_pixel(s_data), // input pixel received from SOURCE IP (testbench)
    .data_in_valid(s_data_valid), // input pixel valid received from SOURCE IP (testbench)
    .data_out_box(data_box), // 9 pixels received from control block (Receive FSM in control block)
    .data_out_box_valid(data_box_valid), // valid signal for 9 pixel data
    .intr_out(intr_out) // interrupt out signal indicating request for new row
    );

  wire mult_acm_valid;  
  wire [7:0]mult_acm_data;
  multi_acm m1(
  .clk(clk),
  .reset(!reset_n),
  .data_in_box(data_box), //9-pixels received from control unit
  .data_in_valid(data_box_valid), // valid signal for 9-pixel data
  .data_out_pixel(mult_acm_data), // output of the MAC unit
  .data_out_valid(mult_acm_valid) // valid signal corresponding to MAC output
    );
wire axis_prog_full;
    fifo_generator_0 f1 (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(clk),                  // input wire s_aclk
  .s_aresetn(reset_n),            // input wire s_aresetn
  .s_axis_tvalid(mult_acm_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(mult_acm_data),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(m_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(m_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(m_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);

assign s_data_ready = !axis_prog_full; // putting backpressure on the source of the pixel to stop sending the data
endmodule
