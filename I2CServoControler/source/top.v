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
  
// i2c_transiver black box
//--------------------------------------------  
module i2c_transiver
  (
   input wire         clk_i,
   input wire         reset_i,
   input wire         sda_i,
   input wire         scl_i,
   output wire        sda_o, 
   output wire [15:0] data_o
   );
endmodule // i2c_transiver

// I2C Transiver example
//--------------------------------------------
module top
  (
   input wire        clk_i,
   input wire        reset_i,
   inout wire        sda_io,
   input wire        scl_i,
   output wire [1:0] servo_pulse_o
   );
   
   // Local Variables
   //--------------------------------------------
   wire        clk_bufg_out;
   wire        reset_ibuf_out;
   wire        scl_ibuf_out;
   wire        sda_iobufe_out;
   wire        sda_iobufe_enable;
   wire [15:0] data_obuf_in;
   wire [1:0]  servo_pulse;
   
   
   // I2C Transiver
   //-------------------------------------------- 
   i2c_transiver i2c_transiver_inst
     (
      .clk_i(clk_bufg_out), 
      .reset_i(reset_ibuf_out), 
      .sda_i(sda_iobufe_out), 
      .scl_i(scl_ibuf_out),
      .sda_o(sda_iobufe_enable),
      .data_o(data_obuf_in)
      );

   // Servo Pulse Generator
   //-------------------------------------------- 
   servo_pulse_generator servo_pulse_generato_inst
     (
      .clk_i(clk_bufg_out), 
      .reset_i(reset_ibuf_out), 
      .servo_control_value_i(data_obuf_in), 
      .servo_pulse_o(servo_pulse)
      );
   
   // Input Buffers
   //--------------------------------------------
   BUFG clk_BUFG_inst 
     (
      .O(clk_bufg_out),     // Clock buffer output
      .I(clk_i)             // Clock buffer input
      );
   
   IBUF IBUF_reset_inst 
     (
      .O(reset_ibuf_out), // Buffer output
      .I(reset_i)         // Buffer input (connect directly to top-level port)
      );
   
   IBUF IBUF_scl_inst 
     (
      .O(scl_ibuf_out),    // Buffer output
      .I(scl_i)            // Buffer input (connect directly to top-level port)
      );
   
   IOBUFE IOBUFE_sda_io_inst 
     (
      .O(sda_iobufe_out),     // Buffer output
      .IO(sda_io),            // Buffer inout port (connect directly to top-level port)
      .I(1'b0),               // Buffer input (Open -> Drain)
      .E(~sda_iobufe_enable)  // 3-state enable input
       );

   // Output Buffers
   //--------------------------------------------
   OBUF OBUF_servo_pulse_inst [0:1]
     (
      .O(servo_pulse_o),  // Buffer output (connect directly to top-level port)
      .I(servo_pulse)     // Buffer input 
      );
   
endmodule
