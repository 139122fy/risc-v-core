 

`include "defines.v"


module id(

	input wire rst,

    // from if_id
    input wire[`InstBus] inst_i,             // 
    input wire[`InstAddrBus] inst_addr_i,    // 

    // from regs
    input wire[`RegBus] reg1_rdata_i,        // 
    input wire[`RegBus] reg2_rdata_i,        // 

    // from csr reg
    input wire[`RegBus] csr_rdata_i,         // ?

    // from ex
    input wire ex_jump_flag_i,               // 

    // to regs
    output reg[`RegAddrBus] reg1_raddr_o,    // 
    output reg[`RegAddrBus] reg2_raddr_o,    //

    // to csr reg
    output reg[`MemAddrBus] csr_raddr_o,     // 

    output wire mem_req_o,                   // 

    // to ex
    output reg[`InstBus] inst_o,             // 
    output reg[`InstAddrBus] inst_addr_o,    // 
    output reg[`RegBus] reg1_rdata_o,        // 
    output reg[`RegBus] reg2_rdata_o,        // 
    output reg reg_we_o,                     // ?
    output reg[`RegAddrBus] reg_waddr_o,     // ?
    output reg csr_we_o,                     // ?
    output reg[`RegBus] csr_rdata_o,         // ?
    output reg[`MemAddrBus] csr_waddr_o      // ?

    );

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];

    reg mem_req;

    // 
    assign mem_req_o = ((mem_req == `RIB_REQ) && (ex_jump_flag_i == `JumpDisable));


    always @ (*) begin
        if (rst == `RstEnable) begin
            reg1_raddr_o = `ZeroReg;
            reg2_raddr_o = `ZeroReg;
            csr_raddr_o = `ZeroWord;
            inst_o = `INST_NOP;
            inst_addr_o = `ZeroWord;
            reg1_rdata_o = `ZeroWord;
            reg2_rdata_o = `ZeroWord;
            csr_rdata_o = `ZeroWord;
            reg_we_o = `WriteDisable;
            csr_we_o = `WriteDisable;
            reg_waddr_o = `ZeroReg;
            csr_waddr_o = `ZeroWord;
            mem_req = `RIB_NREQ;
        end else begin
            inst_o = inst_i;
            inst_addr_o = inst_addr_i;
            reg1_rdata_o = reg1_rdata_i;
            reg2_rdata_o = reg2_rdata_i;
            csr_rdata_o = csr_rdata_i;
            mem_req = `RIB_NREQ;
            csr_raddr_o = `ZeroWord;
            csr_waddr_o = `ZeroWord;
            csr_we_o = `WriteDisable;

            case (opcode)
                `INST_TYPE_I: begin
                    case (funct3)
                        `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRI: begin
                            reg_we_o = `WriteEnable;
                            reg_waddr_o = rd;
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = `ZeroReg;
                        end
                        default: begin
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                        end
                    endcase
                end
                `INST_TYPE_R_M: begin
                    if ((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
                        case (funct3)
                            `INST_ADD_SUB, `INST_SLL, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_SR, `INST_OR, `INST_AND: begin
                                reg_we_o = `WriteEnable;
                                reg_waddr_o = rd;
                                reg1_raddr_o = rs1;
                                reg2_raddr_o = rs2;
                            end
                            default: begin
                                reg_we_o = `WriteDisable;
                                reg_waddr_o = `ZeroReg;
                                reg1_raddr_o = `ZeroReg;
                                reg2_raddr_o = `ZeroReg;
                            end
                        endcase
                    end else if (funct7 == 7'b0000001) begin
                        case (funct3)
                            `INST_MUL, `INST_MULHU, `INST_MULH, `INST_MULHSU: begin
                                reg_we_o = `WriteEnable;
                                reg_waddr_o = rd;
                                reg1_raddr_o = rs1;
                                reg2_raddr_o = rs2;
                            end
                            `INST_DIV, `INST_DIVU, `INST_REM, `INST_REMU: begin
                                reg_we_o = `WriteDisable;
                                reg_waddr_o = rd;
                                reg1_raddr_o = rs1;
                                reg2_raddr_o = rs2;
                            end
                            default: begin
                                reg_we_o = `WriteDisable;
                                reg_waddr_o = `ZeroReg;
                                reg1_raddr_o = `ZeroReg;
                                reg2_raddr_o = `ZeroReg;
                            end
                        endcase
                    end else begin
                        reg_we_o = `WriteDisable;
                        reg_waddr_o = `ZeroReg;
                        reg1_raddr_o = `ZeroReg;
                        reg2_raddr_o = `ZeroReg;
                    end
                end
                `INST_TYPE_L: begin
                    case (funct3)
                        `INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU: begin
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteEnable;
                            reg_waddr_o = rd;
                            mem_req = `RIB_REQ;
                        end
                        default: begin
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                        end
                    endcase
                end
                `INST_TYPE_S: begin
                    case (funct3)
                        `INST_SB, `INST_SW, `INST_SH: begin
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = rs2;
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                            mem_req = `RIB_REQ;
                        end
                        default: begin
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                        end
                    endcase
                end
                `INST_TYPE_B: begin
                    case (funct3)
                        `INST_BEQ, `INST_BNE, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU: begin
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = rs2;
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                        end
                        default: begin
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                        end
                    endcase
                end
                `INST_JAL: begin
                    reg_we_o = `WriteEnable;
                    reg_waddr_o = rd;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
                `INST_JALR: begin
                    reg_we_o = `WriteEnable;
					reg1_raddr_o = rs1;
                    reg2_raddr_o = `ZeroReg;
                    reg_waddr_o = rd;
                end
                `INST_LUI: begin
                    reg_we_o = `WriteEnable;
                    reg_waddr_o = rd;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
                `INST_AUIPC: begin
                    reg_we_o = `WriteEnable;
                    reg_waddr_o = rd;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
                `INST_NOP_OP: begin
                    reg_we_o = `WriteDisable;
                    reg_waddr_o = `ZeroReg;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
                `INST_FENCE: begin
                    reg_we_o = `WriteDisable;
                    reg_waddr_o = `ZeroReg;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
                `INST_CSR: begin
                    reg_we_o = `WriteDisable;
                    reg_waddr_o = `ZeroReg;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                    csr_raddr_o = {20'h0, inst_i[31:20]};
                    csr_waddr_o = {20'h0, inst_i[31:20]};
                    case (funct3)
                        `INST_CSRRW, `INST_CSRRS, `INST_CSRRC: begin
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteEnable;
                            reg_waddr_o = rd;
                            csr_we_o = `WriteEnable;
                        end
                        `INST_CSRRWI, `INST_CSRRSI, `INST_CSRRCI: begin
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                            reg_we_o = `WriteEnable;
                            reg_waddr_o = rd;
                            csr_we_o = `WriteEnable;
                        end
                        default: begin
                            reg_we_o = `WriteDisable;
                            reg_waddr_o = `ZeroReg;
                            reg1_raddr_o = `ZeroReg;
                            reg2_raddr_o = `ZeroReg;
                            csr_we_o = `WriteDisable;
                        end
                    endcase
                end
                default: begin
                    reg_we_o = `WriteDisable;
                    reg_waddr_o = `ZeroReg;
                    reg1_raddr_o = `ZeroReg;
                    reg2_raddr_o = `ZeroReg;
                end
            endcase
        end
    end

endmodule
