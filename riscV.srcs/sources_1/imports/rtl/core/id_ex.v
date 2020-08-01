 

`include "defines.v"

// ??
module id_ex(

    input wire clk,
    input wire rst,

    input wire[`InstBus] inst_i,            // 
    input wire[`InstAddrBus] inst_addr_i,   // 
    input wire reg_we_i,                    // ?
    input wire[`RegAddrBus] reg_waddr_i,    // 
    input wire[`RegBus] reg1_rdata_i,       // 
    input wire[`RegBus] reg2_rdata_i,       // ?
    input wire csr_we_i,                    // ?
    input wire[`MemAddrBus] csr_waddr_i,    // ?
    input wire[`RegBus] csr_rdata_i,        // 

    input wire[`Hold_Flag_Bus] hold_flag_i, // ?

    output reg[`InstBus] inst_o,            // 
    output reg[`InstAddrBus] inst_addr_o,   // 
    output reg reg_we_o,                    // 
    output reg[`RegAddrBus] reg_waddr_o,    // ?
    output reg[`RegBus] reg1_rdata_o,       // 
    output reg[`RegBus] reg2_rdata_o,       // ?
    output reg csr_we_o,                    // 
    output reg[`MemAddrBus] csr_waddr_o,    // ?
    output reg[`RegBus] csr_rdata_o         // 

    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            inst_o <= `INST_NOP;
            inst_addr_o <= `ZeroWord;
            reg_we_o <= `WriteDisable;
            reg_waddr_o <= `ZeroWord;
            reg1_rdata_o <= `ZeroWord;
            reg2_rdata_o <= `ZeroWord;
            csr_we_o <= `WriteDisable;
            csr_waddr_o <= `ZeroWord;
            csr_rdata_o <= `ZeroWord;
        end else begin
            //?
            if (hold_flag_i >= `Hold_Id) begin
                inst_o <= `INST_NOP;
                inst_addr_o <= inst_addr_i;
                reg_we_o <= `WriteDisable;
                reg_waddr_o <= `ZeroWord;
                reg1_rdata_o <= `ZeroWord;
                reg2_rdata_o <= `ZeroWord;
                csr_we_o <= `WriteDisable;
                csr_waddr_o <= `ZeroWord;
                csr_rdata_o <= `ZeroWord;
            end else begin
                inst_o <= inst_i;
                inst_addr_o <= inst_addr_i;
                reg_we_o <= reg_we_i;
                reg_waddr_o <= reg_waddr_i;
                reg1_rdata_o <= reg1_rdata_i;
                reg2_rdata_o <= reg2_rdata_i;
                csr_we_o <= csr_we_i;
                csr_waddr_o <= csr_waddr_i;
                csr_rdata_o <= csr_rdata_i;
            end
        end
    end

endmodule
