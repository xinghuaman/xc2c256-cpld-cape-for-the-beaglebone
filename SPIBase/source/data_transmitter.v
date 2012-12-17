`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
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

module data_transmitter
  (
   input wire       clk_i,
   input wire       reset_i,
   input wire       en_i,
   input wire       scl_neg_edge_detected_i,
   input wire [7:0] data_i, 
   output reg       mosi_o
   );
   
   // Local Variables
   //--------------------------------------------
   reg [3:0]        data_bit_cnt;
   reg [1:0]        en_edge_buffer;
   wire             en_pos_edge_detected;
   
   // en_i edge detector 
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i || ~en_i) begin
         en_edge_buffer <= 2'b00;
      end
      else begin 
         en_edge_buffer <= {en_edge_buffer[0] , en_i};
      end
   end
   
   assign en_pos_edge_detected = (en_edge_buffer == 2'b01) ? 1'b1 : 1'b0;
   
   // Data Transmitter
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i || ~en_i) begin
         data_bit_cnt <= 4'd8;
         mosi_o <= 1'b1;
      end
      else begin
         if (scl_neg_edge_detected_i || en_pos_edge_detected) begin
            if (data_bit_cnt > 4'd0) begin
               data_bit_cnt <= data_bit_cnt - 4'd1;
               mosi_o <= data_i[data_bit_cnt - 1];
            end
            else begin
               mosi_o <= 1'b1;
            end  
         end // if (scl_neg_edge_detected_i && en_i)
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)
   

endmodule
