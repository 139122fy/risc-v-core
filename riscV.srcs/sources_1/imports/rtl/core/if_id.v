

`include "defines.v"

// ?
module if_id(

    input wire clk,
    input wire rst,

    input wire[`InstBus] inst_i,            // 
    input wire[`InstAddrBus] inst_addr_i,   // 

    input wire[`Hold_Flag_Bus] hold_flag_i, // ?

    input wire[`INT_BUS] int_flag_i,        // 
    output reg[`INT_BUS] int_flag_o,

    output reg[`InstBus] inst_o,            // 
    output reg[`InstAddrBus] inst_addr_o    // 

    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= `ZeroWord;
            int_flag_o <= `INT_NONE;
        // ?
        end else if (hold_flag_i >= `Hold_If) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= inst_addr_i;
            int_flag_o <= `INT_NONE;
        end else begin
            inst_o <= inst_i;
            inst_addr_o <= inst_addr_i;
            int_flag_o <= int_flag_i;
        end
    end

endmodule
