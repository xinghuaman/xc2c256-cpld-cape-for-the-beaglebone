`timescale 1ns / 1ps
`default_nettype none

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
  
  module address_match_detector
    #(
      parameter I2C_ADDRESS = 7'h20
      )
   (
    input wire clk_i,
    input wire reset_i,
    input wire en_i,
    input wire sda_i,
    input wire transfer_in_progress_i,
    input wire scl_neg_edge_detected_i,
    output reg address_match_o,
    output reg address_match_ack_o,
    output reg transfer_type_o
    );

   // Local Parameters
   //--------------------------------------------
   parameter WRITE_OP = 1'b0;
   parameter READ_OP = 1'b1;

   // Local Variables
   //--------------------------------------------
   reg [3:0]  address_match_bit_counter;
   
   // Address match detector
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i || ~transfer_in_progress_i) begin
         address_match_o <= 1'b1;
         address_match_bit_counter <= 4'd8;
         address_match_ack_o <= 1'b0;
         transfer_type_o <= READ_OP;
      end
      else begin
         if (scl_neg_edge_detected_i && en_i) begin
            if (address_match_bit_counter > 4'd1) begin 
               address_match_o <= I2C_ADDRESS[address_match_bit_counter - 2] != sda_i ? 1'b0 : address_match_o;
            end
            else begin
               if (address_match_bit_counter == 4'd1) begin
                  transfer_type_o <= (sda_i == 1'b0) ? WRITE_OP : READ_OP;
                  address_match_ack_o <= 1'b1;
               end
               else begin
                  address_match_ack_o <= 1'b0;
               end
            end // if !(bit_cnt > 4'd1)
            if (address_match_bit_counter > 3'd0) begin
               address_match_bit_counter <= address_match_bit_counter - 3'd1;
            end
         end // if (scl_neg_edge_detected_i && en_i)
      end // else: !if(reset_i || ~transfer_in_progress_i)
   end // always @ (posedge clk_i)
  
endmodule
