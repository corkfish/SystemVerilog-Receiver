`timescale 1ns / 1ps

`default_nettype none

module uart_rx_top(
        input wire logic clk, reset, ser_in, Received,
        output logic Receive, parityErr,
        output logic [7:0] rxData);
        
        rx RX_inst(.clk(clk), .Reset(reset), .Sin(ser_in), .Received(Received), .Receive(Receive), .parityErr(parityErr), .Dout(rxData));
endmodule
