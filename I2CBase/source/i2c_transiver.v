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

module i2c_transiver
  #(
    parameter I2C_ADDRESS      = 7'h20,
    parameter NOF_DATA_WORDS   = 2,
    parameter NOF_ADDRESS_BITS = 1
    )
   (
    input wire                             clk_i,
    input wire                             reset_i,
    input wire                             sda_i,
    input wire                             scl_i,
    output wire                            sda_o, 
    output wire [NOF_DATA_WORDS * 8 - 1:0] data_o
    );
   

   // Local Parameters
   //--------------------------------------------
   parameter STATE_IDLE              = 3'b000;
   parameter STATE_ADDRESS_MATCH     = 3'b001;
   parameter STATE_ADDRESS_MATCH_ACK = 3'b010;
   parameter STATE_ADDRESS           = 3'b011;
   parameter STATE_ADDRESS_ACK       = 3'b100;
   parameter STATE_DATA              = 3'b101;
   parameter STATE_DATA_ACK          = 3'b110;
   parameter STATE_SEND_DATA         = 3'b111;
   parameter WRITE_OP                = 1'b0;
   parameter READ_OP                 = 1'b1; 

   // Local Variables
   //--------------------------------------------
   wire                          transfer_in_progress;
   reg [NOF_ADDRESS_BITS - 1:0]  data_address;
   (* KEEP = "TRUE" *) reg [7:0] data[NOF_DATA_WORDS - 1 :0];
   wire [7:0]                    rx_data_buffer;             
   reg [2:0]                     state;  
   reg [1:0]                     scl_edge_buffer;
   wire                          address_match;
   wire                          transfer_type;
   wire                          scl_neg_edge_detected;
   wire                          data_ack;
   wire                          data_out;
   wire                          address_match_ack;
   reg                           address_match_en;
   reg                           data_receiver_en;
   reg                           data_transmitter_en;
    
   // Out data mapper
   //--------------------------------------------
   //assign data_o = {data[1] , data[0]};
   
   assign data_o[0] = 1'b0; // HW Broken?
   assign data_o[1] = data_transmitter_en; 
   assign data_o[2] = data_out;
   assign data_o[3] = transfer_type;
   assign data_o[4] = address_match_ack;
   assign data_o[5] = data_ack;
   assign data_o[7:6] = 2'b11;
   
   assign sda_o = (address_match & transfer_in_progress & (address_match_ack | data_ack | !data_out)) ? 1'b0 : 1'b1;

   // SCL edge detector 
   //--------------------------------------------
   always @(posedge clk_i) begin
      scl_edge_buffer <= {scl_edge_buffer[0] , scl_i};
   end
   
   assign scl_neg_edge_detected = (scl_edge_buffer == 2'b10) ? 1'b1 : 1'b0;
   
   // Transfer in progress detector
   //--------------------------------------------
   transfer_detector transfer_detector_inst
     (
      .clk_i(clk_i), 
      .reset_i(reset_i), 
      .sda_i(sda_i), 
      .scl_i(scl_i), 
      .transfer_in_progress_o(transfer_in_progress)
      );

   // Address match detector
   //--------------------------------------------
   address_match_detector address_match_detector_inst
     (
      .clk_i(clk_i), 
      .reset_i(reset_i), 
      .en_i(address_match_en), 
      .sda_i(sda_i), 
      .transfer_in_progress_i(transfer_in_progress), 
      .scl_neg_edge_detected_i(scl_neg_edge_detected), 
      .address_match_o(address_match), 
      .address_match_ack_o(address_match_ack), 
      .transfer_type_o(transfer_type)
      );

   // Data Receiver
   //--------------------------------------------   
   data_receiver data_receiver_inst 
     (
      .clk_i(clk_i), 
      .reset_i(reset_i), 
      .en_i(data_receiver_en), 
      .sda_i(sda_i), 
      .scl_neg_edge_detected_i(scl_neg_edge_detected),
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
      .sda_o(data_out)
      );
   
   // Transiver state machine
   //--------------------------------------------
    always @(posedge clk_i) begin
       if (reset_i) begin
          address_match_en <= 1'b0;
          data_receiver_en <= 1'b0;
          data_transmitter_en <= 1'b0;
          state <= STATE_IDLE;
       end
       else begin
          case (state)
             STATE_IDLE : begin
                address_match_en <= 1'b0;
                data_receiver_en <= 1'b0;
                data_transmitter_en <= 1'b0; 
                if (transfer_in_progress) begin
                   state <= STATE_ADDRESS_MATCH;
                end
             end // case: STATE_IDLE 

            STATE_ADDRESS_MATCH: begin
               address_match_en <= 1'b1;
               data_receiver_en <= 1'b0;
               if (address_match) begin
                  if (address_match_ack) begin
                     state <= STATE_ADDRESS_MATCH_ACK;
                  end
               end
               else begin
                  state <= STATE_IDLE;
               end
            end // case: STATE_ADDRESS_MATCH
            
            STATE_ADDRESS_MATCH_ACK: begin
               if (transfer_in_progress) begin
                  if (~address_match_ack) begin
                     if (transfer_type == WRITE_OP) begin
                        data_transmitter_en <= 1'b0;
                        data_receiver_en <= 1'b1;
                        state <= STATE_ADDRESS; 
                     end
                     else begin
                        data_receiver_en <= 1'b0;
                        data_transmitter_en <= 1'b1;
                        state <= STATE_SEND_DATA;
                     end    
                  end // if (~address_match_ack)
               end // if (transfer_in_progress)
               else begin
                  state <= STATE_IDLE;
               end // else: !if(transfer_in_progress)  
            end // case: STATE_ADDRESS_MATCH_ACK
            
            
            STATE_ADDRESS: begin
               if (transfer_in_progress) begin
                  data_receiver_en <= 1'b1;
                  if (data_ack) begin
                     data_address <= rx_data_buffer[NOF_ADDRESS_BITS - 1:0];
                     state <= STATE_ADDRESS_ACK;
                  end
               end
               else begin
                  state <= STATE_IDLE;
               end
            end // case: STATE_ADDRESS

            STATE_ADDRESS_ACK: begin
               if (transfer_in_progress) begin
                  if (~data_ack) begin
                     state <= STATE_DATA;
                  end // if (~data_ack)
               end // if (transfer_in_progress)
               else begin
                  state <= STATE_IDLE;
               end // else: !if(transfer_in_progress)
            end // case: STATE_ADDRESS_ACK
            
            STATE_DATA: begin
               if (transfer_in_progress) begin 
                  if (data_ack) begin
                     data[data_address] <= rx_data_buffer;
                     state <= STATE_DATA_ACK;
                  end
               end
               else begin
                  state <= STATE_IDLE;
               end           
            end // case: STATE_DATA

            STATE_DATA_ACK: begin
               if (transfer_in_progress) begin
                  if (~data_ack) begin
                     state <= STATE_IDLE;
                  end
               end
               else begin
                  state <= STATE_IDLE;
               end
            end

            STATE_SEND_DATA: begin
               if (transfer_in_progress) begin
                  data_transmitter_en <= 1'b1;
               end
               else begin
                  state <= STATE_IDLE;
               end
            end   
            
            default: begin
               state <= STATE_IDLE;
            end // case: default
          endcase // case (state)
       end // else: !if(reset_i)
    end // always @ (posedge clk_i)
   
endmodule
