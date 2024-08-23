`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.08.2024 18:54:42
// Design Name: 
// Module Name: SPI_master
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


module SPI_master(
                    input clk,
                    input cs_in,
                    input data_in,
                    input reset_n,
                    input miso,
                    output reg sclk,
                    output reg mosi,
                    output reg cs,
                    output reg [7:0] data_out
                    );

reg [3:0] count_master;                            //for clock dividing
reg [3:0] count2_master;                           //for counting the bits of data frame
reg read_flag_master;
reg i_sclk_master;
  
                
//for count variable ------> clock dividing
    
always @(posedge clk, negedge reset_n) begin                
    if(!reset_n) begin
        count_master <= 'b0;
   
    end
      else if({count_master[3],count_master[2],count_master[1],count_master[0]} == 4'b1000) begin
        count_master <= 'b0;
      end
    else begin
        count_master <= count_master + 1'b1;
    end
end    

//for count2 variable -------> counting data bits of data frame

always @(posedge i_sclk_master, negedge reset_n) begin                
    if(!reset_n) begin
        count2_master <= 'b0; 
    end
      else if({count2_master[3],count2_master[2],count2_master[1],count2_master[0]} == 4'b1000) 
        count2_master <= 'b0;
    else
        count2_master <= count2_master + 1'b1;
end    

//for capturing read bit(read_flag)

always @(posedge i_sclk_master, negedge reset_n) begin                
    if(!reset_n)
        read_flag_master <= 'b1;

      else if(count2_master == 'd0)begin
        read_flag_master <= data_in;
        end
end            

//CLK DIV FOR FPGA COMPATIBILITY
                  
always @(posedge clk, negedge reset_n) begin                
    if(!reset_n) begin
        sclk <= 'b1;
        i_sclk_master <= 'b1;
    end 
      else if({count_master[3],count_master[2],count_master[1],count_master[0]} == 4'b1000) begin
        sclk <= ~sclk;
        i_sclk_master <= ~i_sclk_master;
      end

    end 

//for cs

always @(posedge clk, negedge reset_n) begin                
    if(!reset_n) begin
        cs <= 'b1;
    end 
      else 
        cs <= cs_in;
end                            

//MOSI BLOCK. OUTPUT BUSES ARE NOT RESET

always @(posedge i_sclk_master, negedge reset_n) begin                       
    if(!reset_n) begin                                 
        mosi <= 'b0;
    end 

    else if(cs_in == 0) begin
        if(read_flag_master == 1'b0) begin
            mosi <= data_in;
           end
 
        else begin
            data_out <= {miso, data_out[7:1]};
        end

end                            
end
endmodule




