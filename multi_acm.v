`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
 Company: 
 Engineer: 
 
 Create Date: 12.08.2020 11:43:54
 Design Name: 
 Module Name: multi_acm
 Project Name: 
 Target Devices: 
 Tool Versions: 
 Description: 
 
 Dependencies: 
 
 Revision:
 Revision 0.01 - File Created
 Additional Comments:
 
////////////////////////////////////////////////////////////////////////////////

//////////////////////blurring operation//////////////////

module multi_acm(
input clk,
input reset,
input [71:0]data_in_box,
input data_in_valid,
output reg[7:0]data_out_pixel,
output reg data_out_valid);

reg[7:0] filter_coeff_1 [8:0];

initial
begin
    filter_coeff_1[0]=1;
    filter_coeff_1[1]=1;
    filter_coeff_1[2]=1;
    filter_coeff_1[3]=1;
    filter_coeff_1[4]=1;
    filter_coeff_1[5]=1;
    filter_coeff_1[6]=1;
    filter_coeff_1[7]=1;
    filter_coeff_1[8]=1;
end 

reg[15:0]multi_data_1_reg[8:0];
reg[15:0]multi_data_1_next[8:0];
reg multi_data_valid=0;
integer i;
always@(posedge clk)
begin
    for(i=0;i<9;i=i+1)
    begin
        multi_data_1_reg[i]<=multi_data_1_next[i];
    end
    multi_data_valid<=data_in_valid;
end

always@(*)
begin
    for(i=0;i<9;i=i+1)
    begin
        multi_data_1_next[i]<=filter_coeff_1[i]*data_in_box[i*8+:8];
    end
end

reg[15:0]aggr_data_next_1,aggr_data_reg_1;
reg aggr_data_valid=0;
always@(posedge clk)
begin
    aggr_data_reg_1<=aggr_data_next_1;
    aggr_data_valid<=multi_data_valid;
end

always@(*)
begin
    aggr_data_next_1=0;
    for(i=0;i<9;i=i+1)
    begin
         aggr_data_next_1=0;
         for(i=0;i<9;i=i+1)
         begin
            aggr_data_next_1=(aggr_data_next_1+multi_data_1_reg[i]);
         end
    end
end

wire [7:0] data_out_pixel_next;
always@(posedge clk)
begin
    data_out_pixel<=data_out_pixel_next;
    data_out_valid<=aggr_data_valid;
end

assign data_out_pixel_next=(aggr_data_reg_1)/9;

endmodule

////////////////////// Edge detection sobel filter ////////////////////
//module multi_acm(
//  input clk,
//  input reset,
//  input [71:0] data_in_box, // total 9 pixels (3 from each line buffer)
//  input data_in_valid,
//  input ctrl_last,
//  output  [7:0] data_out_pixel, //output pixel after filtering using kernel
//  output  data_out_valid
//    );
    
//  reg [7:0] filter_coef_1 [8:0];
//  reg [7:0] filter_coef_2 [8:0];
//  reg [15:0] mult_data_1_reg[8:0]; // size is double.. ideally 11 bits are sufficient
//  reg [15:0] mult_data_1_next[8:0];
//  reg [15:0] mult_data_2_reg [8:0];
//  reg [15:0] mult_data_2_next [8:0];
//  reg [15:0] aggr_data_next_1, aggr_data_reg_1;
//  reg [15:0] aggr_data_next_2, aggr_data_reg_2;
//  reg [30:0] sqr_data_reg_1, sqr_data_reg_2,sqr_data_next_1, sqr_data_next_2;
//  integer i;
//  reg mult_data_valid=0;
//  reg aggr_data_valid=0;
//  reg sqr_data_valid = 0;

  
//  // Negative numbers will be stored in 2's complement form
//  initial
//  begin
//    filter_coef_1[0] = 1; 
//    filter_coef_1[1] = 0; 
//    filter_coef_1[2] = -1; 
//    filter_coef_1[3] =2; 
//    filter_coef_1[4] = 0; 
//    filter_coef_1[5] = -2; 
//    filter_coef_1[6] = 1; 
//    filter_coef_1[7] =0; 
//    filter_coef_1[8] = -1; 
//  end

//  initial
//  begin
//    filter_coef_2[0] = 1; 
//    filter_coef_2[1] = 2; 
//    filter_coef_2[2] = 1; 
//    filter_coef_2[3] =0; 
//    filter_coef_2[4] = 0; 
//    filter_coef_2[5] = 0; 
//    filter_coef_2[6] = -1; 
//    filter_coef_2[7] =-2; 
//    filter_coef_2[8] = -1; 
//  end
/////////////////////////////////////////////////////////////////////////////////////////////

//    always @(posedge clk)
//    begin
//           for(i=0;i<9;i=i+1)
//            begin
//            mult_data_1_reg[i] <= mult_data_1_next[i];
//            mult_data_2_reg[i] <= mult_data_2_next[i];
//            end
//            mult_data_valid <= data_in_valid;
//    end
    
//    always @(*)
//    begin
//        for(i=0;i<9;i=i+1)
//            begin
//            mult_data_1_next[i] <= $signed(filter_coef_1[i])*$signed({1'b0,data_in_box[i*8+:8]});
//            mult_data_2_next[i] <= $signed(filter_coef_2[i])*$signed({1'b0,data_in_box[i*8+:8]}); 
//            end
//    end
    
    
    
//    always @(*)
//    begin
//        aggr_data_next_1 = $signed(0);
//        for(i=0;i<9;i=i+1)
//                 aggr_data_next_1 = ($signed(aggr_data_next_1) +  $signed(mult_data_1_reg[i]));
//    end
    
//    always @(*)
//    begin
//        aggr_data_next_2 = $signed(0);
//        for(i=0;i<9;i=i+1)
//                 aggr_data_next_2 = ($signed(aggr_data_next_2) +  $signed(mult_data_2_reg[i]));
//    end
    
//    always @(posedge clk)
//    begin
//        aggr_data_reg_1 <= aggr_data_next_1;
//        aggr_data_reg_2 <= aggr_data_next_2;
//        aggr_data_valid <= mult_data_valid;
//    end      
    
//     always @(posedge clk)
//    begin
//        sqr_data_reg_1 <= sqr_data_next_1;
//        sqr_data_reg_2 <= sqr_data_next_2;
//        sqr_data_valid <= aggr_data_valid;
//    end
//    always @(*)
//    begin
//        sqr_data_next_1 <= $signed(aggr_data_reg_1)*$signed(aggr_data_reg_1);
//        sqr_data_next_2 <= $signed(aggr_data_reg_2)*$signed(aggr_data_reg_2);
//    end
    
//    cordic_0 sd (
//  .aclk(clk),                                        // input wire aclk
//  .s_axis_cartesian_tvalid(sqr_data_valid),  // input wire s_axis_cartesian_tvalid
//  .s_axis_cartesian_tdata(sqr_data_reg_1+sqr_data_reg_2),    // input wire [31 : 0] s_axis_cartesian_tdata
//  .m_axis_dout_tvalid(data_out_valid),            // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata(data_out_pixel)              // output wire [23 : 0] m_axis_dout_tdata
//);
    
    
    
    
    
    
//endmodule