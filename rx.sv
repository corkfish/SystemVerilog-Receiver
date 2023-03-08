`timescale 1ns / 1ps

`default_nettype none

module rx(
        input wire logic clk, Reset, Sin, Received,
        output logic Receive, parityErr, 
        output logic [7:0] Dout);
        
        logic [12:0] Q; 
        logic halfCount, timerDone, clrBit, incBit, bitDone, clrTimer;
        logic [3:0] bitNum;
        logic [8:0] shift;
        
        typedef enum logic [2:0] {IDLE, START, BITS, STOP, ERR='X} stateType;
        stateType ns, cs;
        
        always_ff @ (posedge clk)
            if(Reset || clrTimer || timerDone)
                Q <= 0;
            else
                Q <= Q + 1;
              
        
        assign halfCount = (Q == 2604 && ~Reset) ? 1'b1 : 1'b0;
        assign timerDone = (Q == 5208 && ~Reset) ? 1'b1 : 1'b0;
            
        always_ff @ (posedge clk)
            if(incBit)
                shift <= {Sin, shift[8:1]};
            else if(Reset)
                shift <= 0;
                
        assign Dout = shift[7:0];
        
        always_ff @ (posedge clk)
            if(clrBit)
                bitNum <= 0;
            else if(incBit)
                bitNum <= bitNum + 1;
                
        assign bitDone = (bitNum == 9) ? 1'b1 : 1'b0;
            
        always_comb
            if(Receive)
                parityErr = ~^shift;
            else
                parityErr = 0;
        
        always_comb
        begin
            ns=ERR;
            clrTimer = 0;
            clrBit = 0;
            incBit = 0;;
            Receive = 0;
            
            if(Reset)
                ns = IDLE;
            else
                case(cs)
                    IDLE:
                        begin
                            clrTimer = 1;
                            if(~Sin)
                                begin
                                    clrBit = 1;
                                    ns = START;
                                end
                            else
                                ns = IDLE;
                        end
                    START:
                        begin
                            if(halfCount)
                                begin
                                    clrTimer = 1;
                                    ns = BITS;
                                end
                            else
                                ns = START;
                        end
                    BITS:
                        begin
                            if(timerDone && bitDone)
                                ns = STOP;
                            else if(timerDone && ~bitDone)
                                begin
                                    incBit = 1;
                                    ns = BITS;
                                end
                            else
                                ns = BITS;
                        end
                    STOP:
                        begin
                            Receive = 1;
                            if(Received)
                                ns = IDLE;
                            else
                                ns = STOP;
                        end
                endcase
        end
        
        always_ff @ (posedge clk)
            cs <= ns;
        
endmodule
