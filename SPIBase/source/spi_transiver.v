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

  module spi_transiver
    #(
      parameter NOF_DATA_WORDS   = 2,
      parameter NOF_ADDRESS_BITS = 1
      )
   (
    input wire                             clk_i,
    input wire                             reset_i,
    input wire                             miso_i,
    input wire                             scl_i,
    input wire                             cs_i, 
    output wire                            mosi_o, 
    output wire [NOF_DATA_WORDS * 8 - 1:0] data_o
    );
   

   // Local Parameters
   //--------------------------------------------
   parameter STATE_IDLE        = 3'b001;
   parameter STATE_ADDRESS     = 3'b010;
   parameter STATE_DATA        = 3'b011;
   parameter STATE_NEXT_DATA   = 3'b100;
 
   // Local Variables
   //--------------------------------------------
   wire                                    transfer_in_progress;
   reg [NOF_ADDRESS_BITS - 1:0]            data_address;
   (* KEEP = "TRUE" *) reg [7:0] data[NOF_DATA_WORDS - 1 :0];
   wire [7:0]                              rx_data_buffer;             
   reg [2:0]                               state;  
   reg [1:0]                               scl_edge_buffer;
   wire                                    scl_neg_edge_detected;
   wire                                    scl_pos_edge_detected;
   wire                                    data_ack;
   reg                                     data_receiver_en;
   reg                                     data_transmitter_en;
   
   // Out data mapper
   //--------------------------------------------
   assign data_o = {data[1] , data[0]};
   
   // Initial values
   //--------------------------------------------
   initial 
     begin
        data[0] = 0;
        data[1] = 0;
     end
   
   // Transfer detection
   //--------------------------------------------
   assign  transfer_in_progress = ~cs_i;
   
   // SCL edge detector 
   //--------------------------------------------
   always @(posedge clk_i) begin
      scl_edge_buffer <= {scl_edge_buffer[0] , scl_i};
   end
   
   assign scl_neg_edge_detected = (scl_edge_buffer == 2'b10) ? 1'b1 : 1'b0;
   assign scl_pos_edge_detected = (scl_edge_buffer == 2'b01) ? 1'b1 : 1'b0;
   
   // Data Receiver
   //--------------------------------------------   
   data_receiver data_receiver_inst 
     (
      .clk_i(clk_i), 
      .reset_i(reset_i), 
      .en_i(data_receiver_en), 
      .miso_i(miso_i), 
      .scl_pos_edge_detected_i(scl_pos_edge_detected),
      .data_ack_o(data_ack),
      .data_o(rx_data_buffer)
      );

   // Data Transmitter
   //--------------------------------------------   
   data_transmitter data_transmitter_inst 
     (
      .clk_i(clk_i), 
      .reset_i(reset_i), 
      .en_i(data_transmitter_en), 
      .scl_neg_edge_detected_i(scl_neg_edge_detected), 
      .data_i(data[data_address]), 
      .mosi_o(mosi_o)
      );
   
   // Transiver state machine
   //--------------------------------------------
   always @(posedge clk_i) begin
      if (reset_i) begin
         data_receiver_en <= 1'b0;
         data_transmitter_en <= 1'b0;
         state <= STATE_IDLE;
      end
      else begin
         case (state)
           STATE_IDLE : begin
              data_receiver_en <= 1'b0;
              data_transmitter_en <= 1'b0; 
              if (transfer_in_progress) begin
                 state <= STATE_ADDRESS;
              end
           end // case: STATE_IDLE 
           
           STATE_ADDRESS: begin
              if (transfer_in_progress) begin
                 data_receiver_en <= 1'b1;
                 if (data_ack) begin
                    data_address <= rx_data_buffer[NOF_ADDRESS_BITS - 1:0];
                    state <= STATE_DATA;
                 end
              end
              else begin
                 state <= STATE_IDLE;
              end
           end // case: STATE_ADDRESS
           
           STATE_DATA: begin
              if (transfer_in_progress) begin 
                 if (data_ack) begin
                    data[data_address] <= rx_data_buffer;
                    state <= STATE_NEXT_DATA;
                    data_receiver_en <= 1'b0;
                 end
              end
              else begin
                 state <= STATE_IDLE;
              end           
           end // case: STATE_DATA

           STATE_NEXT_DATA: begin
              if (transfer_in_progress) begin
                 data_receiver_en <= 1'b1;
                 state <= STATE_DATA;
              end
              else begin
                 state <= STATE_IDLE;
              end           
           end // case: STATE_DATA
           
           default: begin
              state <= STATE_IDLE;
           end // case: default
         endcase // case (state)
      end // else: !if(reset_i)
   end // always @ (posedge clk_i)
 
endmodule
