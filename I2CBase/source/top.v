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
   
  module top
    (
     input wire        clk_i,
     input wire        reset_i,
     inout wire        sda_io,
     input wire        scl_i,
     output wire [7:0] data_o
     );
   
   // Local Variables
   //--------------------------------------------
   wire                clk_bufg_out;
   wire                reset_ibuf_out;
   wire                scl_ibuf_out;
   wire                sda_iobufe_out;
   wire                sda_iobufe_enable;
   wire [7:0]          data_obuf_in;
   
   // I2C Transiver
   //-------------------------------------------- 
   i2c_transiver
     #(
       .I2C_ADDRESS(7'h20),
       .NOF_DATA_WORDS(2),
       .NOF_ADDRESS_BITS(1)
       )
   i2c_transiver_inst
     (
      .clk_i(clk_bufg_out), 
      .reset_i(reset_ibuf_out), 
      .sda_i(sda_iobufe_out), 
      .scl_i(scl_ibuf_out),
      .sda_o(sda_iobufe_enable),
      .data_o(data_obuf_in)
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
   OBUF OBUF_data_inst[7:0] 
     (
      .O(data_o),            // Buffer output (connect directly to top-level port)
      .I(data_obuf_in[7:0])  // Buffer input 
      );
   
endmodule
