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

module servo_pulse_generator
  (
   input wire        clk_i,
   input wire        reset_i,
   input wire [15:0] servo_control_value_i,
   output reg [1:0]  servo_pulse_o
   );
   
   // Local Parameters (Given 18.432MHz Clock)
   //--------------------------------------------
   parameter PERIOD_CNT = 15'd23040;  // 20ms period
   parameter PERIOD_1MS_CNT = 1152;   // 1.0ms pulse
   parameter PERIOD_15MS_CNT = 1728;  // 1.5ms pulse

   // Local Variables
   //--------------------------------------------
   reg [14:0] period_cnt;
   reg [11:0] pulse_with_cnt[1:0];
   reg [3:0]  clk_div_cnt;
   reg        clk_div16;
   
   // Clock divider 16
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i) begin
         clk_div_cnt <= 4'd0;
         clk_div16 <= 1'b1; 
      end
      else begin
         clk_div16 <= clk_div_cnt[3];
         clk_div_cnt <= clk_div_cnt + 4'd1;
      end
   end
   
   // Period control
   //--------------------------------------------
   always @(posedge clk_div16) begin
      if (reset_i) begin
         period_cnt <= 15'd0;
      end
      else begin
         if (period_cnt > PERIOD_CNT) begin  
            period_cnt <= 15'd0;
         end
         else begin
            period_cnt <= period_cnt + 15'd1;
         end
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)

   // Servo control value calculation 
   //-------------------------------------------- 
   always @(posedge clk_div16) begin:adder
      if (reset_i) begin
         pulse_with_cnt[0] <= PERIOD_15MS_CNT;
         pulse_with_cnt[1] <= PERIOD_15MS_CNT;
      end
      else begin
         pulse_with_cnt[0] <= PERIOD_1MS_CNT + {servo_control_value_i[7:0]  , 3'b000};
         pulse_with_cnt[1] <= PERIOD_1MS_CNT + {servo_control_value_i[15:8] , 3'b000};
      end
   end

   // Servo pulse generation
   //-------------------------------------------- 
   always @(posedge clk_div16) begin
      if (reset_i) begin
         servo_pulse_o <= 2'b0;
      end
      else begin
         if (period_cnt < pulse_with_cnt[0]) begin
            servo_pulse_o[0] <= 1'b1;
         end
         else begin
            servo_pulse_o[0] <= 1'b0;
         end
         if (period_cnt < pulse_with_cnt[1]) begin
            servo_pulse_o[1] <= 1'b1;
         end
         else begin
            servo_pulse_o[1] <= 1'b0;
         end
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)
   
endmodule
