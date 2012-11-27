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
//

module transfer_detector
  (
   input wire  clk_i,
   input wire  reset_i,
   input wire  sda_i,
   input wire  scl_i,
   output wire transfer_in_progress_o
   );
   
   // Local Variables
   //--------------------------------------------
   wire       start_detected;
   wire       stop_detected;
   reg        transfer_in_progress;
       
   // Generate transfer_in_progress_o (Handle restart)
   //--------------------------------------------
   assign transfer_in_progress_o = transfer_in_progress & ~start_detected;
   
   // I2C Start and stop condition detector
   //--------------------------------------------
   start_stop_detector start_stop_detector_inst 
    (
     .clk_i(clk_i), 
     .reset_i(reset_i), 
     .sda_i(sda_i), 
     .scl_i(scl_i), 
     .start_detected(start_detected), 
     .stop_detected(stop_detected)
     );

   // Transfer in progress detector
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i) begin
         transfer_in_progress <= 1'b0;
      end
      else begin
         if (start_detected) begin
            transfer_in_progress <= 1'b1;
         end
         else begin
            if (stop_detected) begin
               transfer_in_progress  <= 1'b0;
            end
         end
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)
   
endmodule
