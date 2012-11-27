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
///////////////////////////////////////////////////////////////////////////////
//

  module start_stop_detector
    (
     input wire clk_i,
     input wire reset_i,
     input wire sda_i,
     input wire scl_i,
     output reg start_detected,
     output reg stop_detected
     );
   
   // Local Parameters
   //--------------------------------------------
   parameter S1 = 4'b0001;
   parameter S2 = 4'b0010;
   parameter S3 = 4'b0100;
   parameter S4 = 4'b1000;  
   
   // Local Variables
   //--------------------------------------------
   reg [3:0]    state_start;
   reg [3:0]    state_stop;
   
   // Start Detection
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i) begin
         state_start <= S1;
         start_detected <= 1'b0;
      end
      else begin
         case (state_start)
           S1: begin
              start_detected <= 1'b0;
              if (sda_i && scl_i) begin
                 state_start <= S2;
              end
           end

           S2: begin
              start_detected <= 1'b0;
              if (sda_i && scl_i) begin
                 state_start <= S2;
              end else
                if (~sda_i && scl_i) begin
                   state_start <= S3;
                end
                else begin
                   state_start <= S1;
                end
           end // case: S1
           
           S3: begin
              start_detected <= 1'b0;
              if (~sda_i && scl_i) begin
                 state_start <= S3;
              end
              else begin
                 if (~sda_i && ~scl_i) begin
                    state_start <= S4;
                 end
                 else begin
                    state_start <= S1;
                 end
              end // else: !if(~sda_i && scl_i)
           end // case: S3
           
           S4: begin
              start_detected <= 1'b1;
              state_start <= S1;
           end
         endcase // case (state_start)
      end // else: !if(reset_i)
   end // always @ (posedge clk)

   // Stop Detection
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i) begin
         state_stop <= S1;
         stop_detected <= 1'b0;
      end
      else begin
         case (state_stop)
           S1: begin
              stop_detected <= 1'b0;
              if (~sda_i && ~scl_i) begin
                 state_stop <= S2;
              end
           end

           S2: begin
              stop_detected <= 1'b0;
              if (~sda_i && ~scl_i) begin
                 state_stop <= S2;
              end else
                if (~sda_i && scl_i) begin
                   state_stop <= S3;
                end
                else begin
                   state_stop <= S1;
                end
           end // case: S1
           
           S3: begin
              stop_detected <= 1'b0;
              if (~sda_i && scl_i) begin
                 state_stop <= S3;
              end
              else begin
                 if (sda_i && scl_i) begin
                    state_stop <= S4;
                 end
                 else begin
                    state_stop <= S1;
                 end
              end // else: !if(~sda_i && scl_i)
           end // case: S3
           
           S4: begin
              stop_detected <= 1'b1;
              state_stop <= S1;
           end
         endcase // case (state_stop)
      end // else: !if(reset_i)
   end // always @ (posedge clk)


endmodule
