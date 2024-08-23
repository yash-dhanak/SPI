`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2024 18:56:31
// Design Name: 
// Module Name: SPI_slave
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

//README:
//---> count variable is to count the no. of bits of the frame.
//---> read_flag is the first bit of the data frame.
//---> read_flag = 0 for write into slave by mosi line.
//---> read_flag = 1 for read through slave, by sending data to master, on miso line.

module SPI_slave(
                input sclk, mosi,cs,i_reset_n,
                output reg [7:0] dout,
                output reg miso
               );
               
integer count_slave;             
reg  read_flag_slave;

//FOR COUNT ------>COUNTER FOR BITS OF DATA FRAME 

always @(posedge sclk,negedge i_reset_n) begin
    if(!i_reset_n)
        count_slave <= 0;
    else if(!cs && count_slave == 8) 
            count_slave <= 0;
        else
            count_slave <= count_slave + 1;           
    end

//to sample read_flag
 
always @(posedge sclk,negedge i_reset_n) begin
   if(!i_reset_n)
        read_flag_slave <= 1;
   else if(!cs && (count_slave == 0)) 
        read_flag_slave <= mosi;  
 end
 
//to write in slave

always @(posedge sclk) begin
   if(!cs && (read_flag_slave==0) && (count_slave > 0) && (count_slave <= 8))
            dout <= {mosi,dout[7:1]};        //right shift register 
 end  

//to drive MISO

always @(posedge sclk) begin
   if(!cs && read_flag_slave && (count_slave > 0) && (count_slave <= 8))
        miso <= dout[count_slave - 1]; 
end

endmodule


