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
     input wire        miso_i,
     input wire        scl_i,
     input wire        cs_i,
     output wire       mosi_o, 
     output wire [7:0] data_o
     );
   
   // Local Variables
   //--------------------------------------------
   wire                clk_bufg_out;
   wire                reset_ibuf_out;
   wire                miso_ibuf_out;
   wire                mosi_obuf_in;
   wire                cs_ibuf_out;
   wire                scl_ibuf_out;             
   wire [7:0]          data_obuf_in;
   
   // SPI Transiver
   //-------------------------------------------- 
   spi_transiver
     #(
       .NOF_DATA_WORDS(2),
       .NOF_ADDRESS_BITS(1)
       )
   spi_transiver_inst
     (
      .clk_i(clk_bufg_out), 
      .reset_i(reset_ibuf_out), 
      .miso_i(miso_ibuf_out), 
      .mosi_o(mosi_obuf_in),
      .scl_i(scl_ibuf_out),
      .cs_i(cs_ibuf_out),
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
   
   IBUF IBUF_miso_inst 
     (
      .O(miso_ibuf_out),    // Buffer output
      .I(miso_i)            // Buffer input (connect directly to top-level port)
      );

   IBUF IBUF_cs_inst 
     (
      .O(cs_ibuf_out),    // Buffer output
      .I(cs_i)            // Buffer input (connect directly to top-level port)
      );

   // Output Buffers
   //--------------------------------------------
   OBUF OBUF_mosi_inst 
     (
      .O(mosi_o),         // Buffer output (connect directly to top-level port)
      .I(mosi_obuf_in)    // Buffer input 
      ); 

   OBUF OBUF_data_inst[7:0] 
     (
      .O(data_o),            // Buffer output (connect directly to top-level port)
      .I(data_obuf_in[7:0])  // Buffer input 
      );
   
endmodule
