

`include "defines.v"


module ctrl(

    input wire rst,

    // from ex
    input wire jump_flag_i,
    input wire[`InstAddrBus] jump_addr_i,
    input wire hold_flag_ex_i,

    // from rib
    input wire hold_flag_rib_i,

    // from jtag
    input wire jtag_halt_flag_i,

    // from clint
    input wire hold_flag_clint_i,

    output reg[`Hold_Flag_Bus] hold_flag_o,

    // to pc_reg
    output reg jump_flag_o,
    output reg[`InstAddrBus] jump_addr_o

    );


    always @ (*) begin
        if (rst == `RstEnable) begin
            hold_flag_o = `Hold_None;
            jump_flag_o = `JumpDisable;
            jump_addr_o = `ZeroWord;
        end else begin
            jump_addr_o = jump_addr_i;
            jump_flag_o = jump_flag_i;
            // ?
            hold_flag_o = `Hold_None;
            //?
            if (jump_flag_i == `JumpEnable || hold_flag_ex_i == `HoldEnable || hold_flag_clint_i == `HoldEnable) begin
                // 
                hold_flag_o = `Hold_Id;
            end else if (hold_flag_rib_i == `HoldEnable) begin
                // 
                hold_flag_o = `Hold_Pc;
            end else if (jtag_halt_flag_i == `HoldEnable) begin
                // 
                hold_flag_o = `Hold_Id;
            end else begin
                hold_flag_o = `Hold_None;
            end
        end
    end

endmodule
