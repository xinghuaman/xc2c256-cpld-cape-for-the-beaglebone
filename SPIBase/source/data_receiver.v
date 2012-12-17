`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2012 Andreas Kingbäck
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////

  module data_receiver
  (
   input wire       clk_i,
   input wire       reset_i,
   input wire       en_i,
   input wire       miso_i,
   input wire       scl_pos_edge_detected_i,
   output reg       data_ack_o,
   output reg [7:0] data_o
   );

   // Local Variables
   //--------------------------------------------
   reg [3:0]        data_bit_cnt;
   reg              data_ack;
        
   // Data Receiver
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i || ~en_i) begin
         data_bit_cnt <= 4'd8;
         data_ack_o <= 1'b0;
         data_o <= 8'b00000000;
      end
      else begin
         if (scl_pos_edge_detected_i && en_i) begin
            if (data_bit_cnt > 0) begin
               data_bit_cnt <= data_bit_cnt - 1;
            end
            else begin
               data_bit_cnt <= 4'd8;
            end  
            if (data_bit_cnt > 1) begin
               data_o[data_bit_cnt - 1] <= miso_i;
            end
            if (data_bit_cnt == 1) begin
               data_o[data_bit_cnt - 1] <= miso_i;
               data_ack_o <= 1'b1;
            end
            else begin
               data_ack_o <= 1'b0;
            end 
         end // if (scl_neg_edge_detected_i && en_i)
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)

endmodule
