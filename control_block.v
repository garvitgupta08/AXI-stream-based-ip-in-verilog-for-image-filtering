`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.08.2020 03:06:37
// Design Name: 
// Module Name: control_block
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

module control_block#
(
 IMAGE_WIDTH = 512,
 IW_BIT_NUM = 9
)
(
    input clk,
    input reset,
    input [7:0] data_in_pixel, // single pixel received and forwarded to appropriate line buffer
    input data_in_valid,
    output reg [71:0] data_out_box, // 9 pixels from line buffers are read and forwarded to accumulator block
    output data_out_box_valid,
    output reg intr_out);
    
     wire [3:0] num_bits;
    assign num_bits = IW_BIT_NUM;

  reg [IW_BIT_NUM-1:0] wr_counter_reg; // 9 bit since image row width is 512
 // This counts the number of data in a given line buffer.
 // It is incremented by 1 when data_in_valid is set.
 // It is resetted when it is reaches (IMAGE_WIDTH-1) starting from 0. 
  reg [IW_BIT_NUM-1:0] wr_counter_next;
    always@(posedge clk)
    begin
        if(reset)
            wr_counter_reg <= 0;
        else
            wr_counter_reg <= wr_counter_next;
    end
    
    always@(*)
    begin
        wr_counter_next = wr_counter_reg;
        if(data_in_valid) // whenever we receive new pixel at the input
            wr_counter_next = wr_counter_reg + 1'b1; // since it is 9 bit, it is resetted when we have 512 pixels
    end
    
    
    // This points to which data buffer the data needs to be written. 
    //we are using total 4 data buffer.
    reg [1:0] wr_buffer_ind_reg;
    reg [1:0] wr_buffer_ind_next;
    always@(posedge clk)
    begin
        if(reset)
            wr_buffer_ind_reg <= 0;
        else
            wr_buffer_ind_reg <= wr_buffer_ind_next;
    end

    always@(*)
    begin
        wr_buffer_ind_next = wr_buffer_ind_reg;
        if(wr_counter_reg==(IMAGE_WIDTH-1) & data_in_valid) // we have received 511 pixels and new pixel has arrived.
            wr_buffer_ind_next = wr_buffer_ind_reg + 1'b1; 
    end
    
    
    
    //Generating the valid signal for appropriate data buffers.
    reg [3:0] buffer_in_valid; // only one bit is HIGH since the input pixel is written to only one buffer
    always@(*)
    begin
        buffer_in_valid = 0;
        buffer_in_valid[wr_buffer_ind_reg] = data_in_valid;
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 
   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Reading from buffers  
    // Reading from data buffers.    
    
    reg [3:0] buffer_out_ready;
    reg [19:0] rd_counter_long_next;
    
    reg rd_data_buffer=1'b0;
    reg [IW_BIT_NUM-1:0] rd_counter_next, rd_counter_reg;    
     // Read counter which increments after every read operation from buffer. 
     // We are reading from three buffers simulateneously. 
     // We need to read 512 times when rd_data_buffer is set (FSM in Read state) 
    always@(posedge clk)
    begin
        if(reset)
            rd_counter_reg <= 0;
        else
            rd_counter_reg <= rd_counter_next;
    end
    
    always@(*)
    begin
        rd_counter_next = rd_counter_reg;
        if(rd_data_buffer) // controlled  from FSM written below
            rd_counter_next = rd_counter_reg + 1'b1;
    end
    

    // This indicates the starting buffers from which we are reading. 
    // Since there are four buffers, we can read from (1,2,3), (2,3,4), (3,4,1) and (4,1,2)
    //rd_buffer_ind_reg points to first buffer
    reg [1:0] rd_buffer_ind_reg, rd_buffer_ind_next;
     always@(posedge clk)
    begin
        if(reset)
            rd_buffer_ind_reg <= 0;
        else
            rd_buffer_ind_reg <= rd_buffer_ind_next;
    end
        
    always@(*)
    begin
        rd_buffer_ind_next = rd_buffer_ind_reg;
        if(rd_counter_reg==(IMAGE_WIDTH-1) & rd_data_buffer)
            rd_buffer_ind_next = rd_buffer_ind_reg + 1'b1;
    end

    always@(*)
    begin
        case(rd_buffer_ind_reg)
            0: begin
                buffer_out_ready = {1'b0,rd_data_buffer,rd_data_buffer,rd_data_buffer};
            end
            
            1: begin
                buffer_out_ready = {rd_data_buffer,rd_data_buffer,rd_data_buffer,1'b0};
            end
            
            2: begin
                buffer_out_ready = {rd_data_buffer,rd_data_buffer,1'b0,rd_data_buffer};
            end
            
            3: begin
                buffer_out_ready = {rd_data_buffer,1'b0,rd_data_buffer,rd_data_buffer};
            end
        endcase
    end
    
    
    // send the ready signal to buffer to read the data. rd_data_buffer is internally generated signal
    wire [23:0] data_out_3pixel_1,data_out_3pixel_2,data_out_3pixel_3,data_out_3pixel_4;
    // data (3 pixels) from 3 buffers are concatenated.
    always@(*)
    begin
        case(rd_buffer_ind_reg) // indicates the buffers from which data to be read
            0: begin
                data_out_box = {data_out_3pixel_3,data_out_3pixel_2,data_out_3pixel_1};
            end
            
            1: begin
                data_out_box = {data_out_3pixel_4,data_out_3pixel_3,data_out_3pixel_2};
            end
            
            2: begin
                data_out_box = {data_out_3pixel_1,data_out_3pixel_4,data_out_3pixel_3};
            end
            
            3: begin
                data_out_box = {data_out_3pixel_2,data_out_3pixel_1,data_out_3pixel_4};
            end
        endcase
    end
    
    // To keep the track of number of pixels received and send from the control unit..
   reg [IW_BIT_NUM+3-1:0] buffer_data_count_reg; // size of four buffers
    reg [IW_BIT_NUM+3-1:0] buffer_data_count_next;    
    always@(posedge clk)
    begin
        if(reset)
            buffer_data_count_reg <= 0;
        else
            buffer_data_count_reg <= buffer_data_count_next;
    end
    
    always@(*)
    begin
        buffer_data_count_next = buffer_data_count_reg;
        if(data_in_valid & !rd_data_buffer)
            buffer_data_count_next = buffer_data_count_reg + 1'b1;
        else if(!data_in_valid & rd_data_buffer)
            buffer_data_count_next = buffer_data_count_reg - 1'b1;
    end
    
    reg present_state;
    reg next_state;
    localparam IDLE = 1'b0, RD_BUFFER = 1'b1;
    always@(posedge clk)
    begin
        if(reset)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end
    
    always@(*)
    begin
    next_state = present_state;
    case(present_state)
        IDLE: begin
            if(buffer_data_count_reg >= (IMAGE_WIDTH*3)) // 512*3 Total data available is more than three rows
                next_state = RD_BUFFER;
        end 
        RD_BUFFER: begin
            if(rd_counter_reg == (IMAGE_WIDTH-1)) // read counter overflows i.e convolution over entire width is done
                next_state = IDLE;
        end   
        endcase      
    end
    
    always@(*)
    begin
    case(present_state)
        IDLE: begin
             rd_data_buffer = 1'b0;  // dont read from data buffer since we dont three full buffers
            if(buffer_data_count_reg >= (IMAGE_WIDTH*3)) // 512*3 Total data available is more than three rows
                rd_data_buffer = 1'b1; //used as ready signal for reading from data buffer 
        end 
        RD_BUFFER: begin
            rd_data_buffer = 1'b1;
            if(rd_counter_reg == (IMAGE_WIDTH-1)) // read counter overflows i.e convolution over entire width is done
                rd_data_buffer = 1'b0;
        end   
        endcase      
    end
    
    always@(*)
    begin
    case(present_state)
        IDLE: begin
             intr_out = 1'b0;            // interrupt is generated after completing one row.

        end 
        RD_BUFFER: begin

            intr_out = 1'b0;
            if(rd_counter_reg == (IMAGE_WIDTH-1)) // read counter overflows i.e convolution over entire width is done
            begin
                intr_out = 1'b1; // interrupt will be used to inform that new interrupt is needed
            end
            
        end   
        endcase      
    end
    
    assign data_out_box_valid = rd_data_buffer;
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Instantiation of four data buffer storing four rows of image
    data_buffer #
    (
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IW_BIT_NUM(IW_BIT_NUM)
    )
   d1 (
    .clk(clk),
    .reset(reset),
    .data_in_pixel(data_in_pixel),
    .data_in_valid(buffer_in_valid[0]),
    .data_out_3pixel(data_out_3pixel_1),
    .data_out_read(buffer_out_ready[0])    
    );
    
   data_buffer #
    (
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IW_BIT_NUM(IW_BIT_NUM)
    )
   d2(
    .clk(clk),
    .reset(reset),
    .data_in_pixel(data_in_pixel),
    .data_in_valid(buffer_in_valid[1]),
    .data_out_3pixel(data_out_3pixel_2),
    .data_out_read(buffer_out_ready[1])    
    );
    
  data_buffer #
    (
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IW_BIT_NUM(IW_BIT_NUM)
    )
   d3(
    .clk(clk),
    .reset(reset),
    .data_in_pixel(data_in_pixel),
    .data_in_valid(buffer_in_valid[2]),
    .data_out_3pixel(data_out_3pixel_3),
    .data_out_read(buffer_out_ready[2])    
    );
    
  data_buffer #
    (
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IW_BIT_NUM(IW_BIT_NUM)
    )
   d4(
    .clk(clk),
    .reset(reset),
    .data_in_pixel(data_in_pixel),
    .data_in_valid(buffer_in_valid[3]),
    .data_out_3pixel(data_out_3pixel_4),
    .data_out_read(buffer_out_ready[3])    
    );
    
    
endmodule