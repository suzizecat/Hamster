/* registers bank design - file automatically generated - do not modify */

//-----------------------------------------------------------------------------
//    this confidential and proprietary file may be used only as authorized
//                 by a licensing agreement from EASii IC sas
//                       Copyright 2022 EASii IC SAS
//                    legal statement: all rights reserved
//     the entire notice above must be reproduced on all authorized copies
//-----------------------------------------------------------------------------
// Generated on 2022-09-06
//-----------------------------------------------------------------------------
// Generation parameters : --lang sv --lib work --uniquify-fields
// ----------------------------------------------------------------------------

`include "hamster_regs_map.svh"

// No documentation generated. Use --doc to generate it

module hamster_regbank (
  input logic                           i_clk,
  input logic                           i_rst_n,
  // Register interface
  reg_wrchan_if.slave                   sif_reg_wrchan,
  reg_rdchan_if.slave                   sif_reg_rdchan,
  // Recorded signals
  hamster_regbank_in_if.slave  sif_regbank_in,
  // Registers outputs
  hamster_regbank_out_if.master mif_regbank_out
);

genvar                    i;
logic [`K_DWIDTH-1:0] rdata;

  // --------------------------------------------------------------------------
  // Register variables
  // --------------------------------------------------------------------------
  logic [`K_DWIDTH-1:0] COMPID     ;
  logic [`K_DWIDTH-1:0] RADIOCFGR  ;
  logic [`K_DWIDTH-1:0] RADIOPOL   ;
  logic [`K_DWIDTH-1:0] RADIO1DEAD ;
  logic [`K_DWIDTH-1:0] RADIO2DEAD ;
  logic [`K_DWIDTH-1:0] RADIO3DEAD ;
  logic [`K_DWIDTH-1:0] RADIO4DEAD ;
  logic [`K_DWIDTH-1:0] RADIOSKIP  ;
  logic [`K_DWIDTH-1:0] RADIOPWRDIV;
  logic [`K_DWIDTH-1:0] MOT1CR     ;
  logic [`K_DWIDTH-1:0] MOT1PWM    ;
  logic [`K_DWIDTH-1:0] MOT2CR     ;
  logic [`K_DWIDTH-1:0] MOT2PWM    ;
  logic [`K_DWIDTH-1:0] SPDLOW     ;
  logic [`K_DWIDTH-1:0] POWERCTRL1 ;
  logic [`K_DWIDTH-1:0] POWERTHR   ;
  logic [`K_DWIDTH-1:0] COMPTEST   ;


  // --------------------------------------------------------------------------
  // Write control signals
  // --------------------------------------------------------------------------
  logic WR_RADIOCFGR;
  logic WR_RADIOPOL;
  logic WR_RADIO1DEAD;
  logic WR_RADIO2DEAD;
  logic WR_RADIO3DEAD;
  logic WR_RADIO4DEAD;
  logic WR_RADIOSKIP;
  logic WR_RADIOPWRDIV;
  logic WR_MOT1CR;
  logic WR_MOT1PWM;
  logic WR_MOT2CR;
  logic WR_MOT2PWM;
  logic WR_SPDLOW;
  logic WR_POWERCTRL1;
  logic WR_POWERTHR;


  // --------------------------------------------------------------------------
  // Register fields declaration
  // --------------------------------------------------------------------------
  logic [15: 0] F_COMPID_COMP_ID      ;
  logic [ 1: 0] F_RADIOCFGR_DIR_CHAN  ;
  logic [ 1: 0] F_RADIOCFGR_PWR_CHAN  ;
  logic [ 1: 0] F_RADIOCFGR_REV_CHAN  ;
  logic [ 1: 0] F_RADIOCFGR_OTHER_CHAN;
  logic         F_RADIOPOL_DIR_POL    ;
  logic         F_RADIOPOL_PWR_POL    ;
  logic         F_RADIOPOL_REV_POL    ;
  logic         F_RADIOPOL_OTHER_POL  ;
  logic [15: 0] F_RADIO1DEAD_VAL      ;
  logic [15: 0] F_RADIO2DEAD_VAL      ;
  logic [15: 0] F_RADIO3DEAD_VAL      ;
  logic [15: 0] F_RADIO4DEAD_VAL      ;
  logic [15: 0] F_RADIOSKIP_VAL       ;
  logic [15: 0] F_RADIOPWRDIV_DIV     ;
  logic [ 2: 0] F_MOT1CR_I_STEP       ;
  logic         F_MOT1CR_ENC_POL      ;
  logic         F_MOT1CR_I_EN         ;
  logic         F_MOT1CR_PWR_MSB      ;
  logic         F_MOT1CR_PWR_ALL      ;
  logic [ 9: 0] F_MOT1PWM_MAX         ;
  logic [ 2: 0] F_MOT2CR_I_STEP       ;
  logic         F_MOT2CR_ENC_POL      ;
  logic         F_MOT2CR_I_EN         ;
  logic         F_MOT2CR_PWR_MSB      ;
  logic         F_MOT2CR_PWR_ALL      ;
  logic [ 9: 0] F_MOT2PWM_MAX         ;
  logic [14: 0] F_SPDLOW_SPDLOWTHR    ;
  logic         F_POWERCTRL1_STOPEN   ;
  logic         F_POWERCTRL1_CTRLEN   ;
  logic [ 7: 0] F_POWERCTRL1_HSTHR    ;
  logic [ 7: 0] F_POWERTHR_LTHR       ;
  logic [ 7: 0] F_POWERTHR_HTHR       ;
  logic [15: 0] F_COMPTEST_COMP_TEST  ;

  // --------------------------------------------------------------------------
  // Register write control -- Address decoding
  // --------------------------------------------------------------------------
  assign WR_RADIOCFGR = ((sif_reg_wrchan.addr == `RADIOCFGR_OFFSET  ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIOPOL = ((sif_reg_wrchan.addr == `RADIOPOL_OFFSET   ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIO1DEAD = ((sif_reg_wrchan.addr == `RADIO1DEAD_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIO2DEAD = ((sif_reg_wrchan.addr == `RADIO2DEAD_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIO3DEAD = ((sif_reg_wrchan.addr == `RADIO3DEAD_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIO4DEAD = ((sif_reg_wrchan.addr == `RADIO4DEAD_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIOSKIP = ((sif_reg_wrchan.addr == `RADIOSKIP_OFFSET  ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_RADIOPWRDIV = ((sif_reg_wrchan.addr == `RADIOPWRDIV_OFFSET) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_MOT1CR = ((sif_reg_wrchan.addr == `MOT1CR_OFFSET     ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_MOT1PWM = ((sif_reg_wrchan.addr == `MOT1PWM_OFFSET    ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_MOT2CR = ((sif_reg_wrchan.addr == `MOT2CR_OFFSET     ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_MOT2PWM = ((sif_reg_wrchan.addr == `MOT2PWM_OFFSET    ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_SPDLOW = ((sif_reg_wrchan.addr == `SPDLOW_OFFSET     ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_POWERCTRL1 = ((sif_reg_wrchan.addr == `POWERCTRL1_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
  assign WR_POWERTHR = ((sif_reg_wrchan.addr == `POWERTHR_OFFSET   ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;

  // --------------------------------------------------------------------------
  // Register field update
  // --------------------------------------------------------------------------
  // Update code for field COMPID.COMPID_COMP_ID
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_COMPID_COMP_ID
    if (~i_rst_n) begin
      F_COMPID_COMP_ID       <= 16'b1010000000000001;
    end else begin
      // Field update
      F_COMPID_COMP_ID <= sif_regbank_in.COMPID_COMP_ID; //RO Access

    end
  end // p_seq_update_field_COMPID_COMP_ID

  // Update code for field RADIOCFGR.RADIOCFGR_DIR_CHAN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOCFGR_DIR_CHAN
    if (~i_rst_n) begin
      F_RADIOCFGR_DIR_CHAN   <= 2'b00;
    end else begin
      // Field update
      for (int i = 0; i < 2; i++) begin
        if ((WR_RADIOCFGR & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOCFGR_DIR_CHAN[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOCFGR_DIR_CHAN

  // Update code for field RADIOCFGR.RADIOCFGR_PWR_CHAN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOCFGR_PWR_CHAN
    if (~i_rst_n) begin
      F_RADIOCFGR_PWR_CHAN   <= 2'b01;
    end else begin
      // Field update
      for (int i = 4; i < 6; i++) begin
        if ((WR_RADIOCFGR & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOCFGR_PWR_CHAN[i-4] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOCFGR_PWR_CHAN

  // Update code for field RADIOCFGR.RADIOCFGR_REV_CHAN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOCFGR_REV_CHAN
    if (~i_rst_n) begin
      F_RADIOCFGR_REV_CHAN   <= 2'b10;
    end else begin
      // Field update
      for (int i = 8; i < 10; i++) begin
        if ((WR_RADIOCFGR & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOCFGR_REV_CHAN[i-8] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOCFGR_REV_CHAN

  // Update code for field RADIOCFGR.RADIOCFGR_OTHER_CHAN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOCFGR_OTHER_CHAN
    if (~i_rst_n) begin
      F_RADIOCFGR_OTHER_CHAN <= 2'b11;
    end else begin
      // Field update
      for (int i = 12; i < 14; i++) begin
        if ((WR_RADIOCFGR & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOCFGR_OTHER_CHAN[i-12] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOCFGR_OTHER_CHAN

  // Update code for field RADIOPOL.RADIOPOL_DIR_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOPOL_DIR_POL
    if (~i_rst_n) begin
      F_RADIOPOL_DIR_POL     <= 1'b0;
    end else begin
      // Field update
      if ((WR_RADIOPOL & ~sif_reg_wrchan.bmask[0])) begin
        F_RADIOPOL_DIR_POL <= sif_reg_wrchan.data[0]; //RW
      end

    end
  end // p_seq_update_field_RADIOPOL_DIR_POL

  // Update code for field RADIOPOL.RADIOPOL_PWR_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOPOL_PWR_POL
    if (~i_rst_n) begin
      F_RADIOPOL_PWR_POL     <= 1'b0;
    end else begin
      // Field update
      if ((WR_RADIOPOL & ~sif_reg_wrchan.bmask[1])) begin
        F_RADIOPOL_PWR_POL <= sif_reg_wrchan.data[1]; //RW
      end

    end
  end // p_seq_update_field_RADIOPOL_PWR_POL

  // Update code for field RADIOPOL.RADIOPOL_REV_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOPOL_REV_POL
    if (~i_rst_n) begin
      F_RADIOPOL_REV_POL     <= 1'b0;
    end else begin
      // Field update
      if ((WR_RADIOPOL & ~sif_reg_wrchan.bmask[2])) begin
        F_RADIOPOL_REV_POL <= sif_reg_wrchan.data[2]; //RW
      end

    end
  end // p_seq_update_field_RADIOPOL_REV_POL

  // Update code for field RADIOPOL.RADIOPOL_OTHER_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOPOL_OTHER_POL
    if (~i_rst_n) begin
      F_RADIOPOL_OTHER_POL   <= 1'b0;
    end else begin
      // Field update
      if ((WR_RADIOPOL & ~sif_reg_wrchan.bmask[3])) begin
        F_RADIOPOL_OTHER_POL <= sif_reg_wrchan.data[3]; //RW
      end

    end
  end // p_seq_update_field_RADIOPOL_OTHER_POL

  // Update code for field RADIO1DEAD.RADIO1DEAD_VAL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIO1DEAD_VAL
    if (~i_rst_n) begin
      F_RADIO1DEAD_VAL       <= 16'b0000000000000100;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIO1DEAD & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIO1DEAD_VAL[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIO1DEAD_VAL

  // Update code for field RADIO2DEAD.RADIO2DEAD_VAL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIO2DEAD_VAL
    if (~i_rst_n) begin
      F_RADIO2DEAD_VAL       <= 16'b0000000000000100;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIO2DEAD & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIO2DEAD_VAL[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIO2DEAD_VAL

  // Update code for field RADIO3DEAD.RADIO3DEAD_VAL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIO3DEAD_VAL
    if (~i_rst_n) begin
      F_RADIO3DEAD_VAL       <= 16'b0000000000000100;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIO3DEAD & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIO3DEAD_VAL[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIO3DEAD_VAL

  // Update code for field RADIO4DEAD.RADIO4DEAD_VAL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIO4DEAD_VAL
    if (~i_rst_n) begin
      F_RADIO4DEAD_VAL       <= 16'b0000000000000100;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIO4DEAD & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIO4DEAD_VAL[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIO4DEAD_VAL

  // Update code for field RADIOSKIP.RADIOSKIP_VAL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOSKIP_VAL
    if (~i_rst_n) begin
      F_RADIOSKIP_VAL        <= 16'b0000000001100100;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIOSKIP & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOSKIP_VAL[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOSKIP_VAL

  // Update code for field RADIOPWRDIV.RADIOPWRDIV_DIV
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_RADIOPWRDIV_DIV
    if (~i_rst_n) begin
      F_RADIOPWRDIV_DIV      <= 16'b0000000000001010;
    end else begin
      // Field update
      for (int i = 0; i < 16; i++) begin
        if ((WR_RADIOPWRDIV & ~sif_reg_wrchan.bmask[i])) begin
          F_RADIOPWRDIV_DIV[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_RADIOPWRDIV_DIV

  // Update code for field MOT1CR.MOT1CR_I_STEP
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1CR_I_STEP
    if (~i_rst_n) begin
      F_MOT1CR_I_STEP        <= 3'b000;
    end else begin
      // Field update
      for (int i = 0; i < 3; i++) begin
        if ((WR_MOT1CR & ~sif_reg_wrchan.bmask[i])) begin
          F_MOT1CR_I_STEP[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_MOT1CR_I_STEP

  // Update code for field MOT1CR.MOT1CR_ENC_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1CR_ENC_POL
    if (~i_rst_n) begin
      F_MOT1CR_ENC_POL       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT1CR & ~sif_reg_wrchan.bmask[4])) begin
        F_MOT1CR_ENC_POL <= sif_reg_wrchan.data[4]; //RW
      end

    end
  end // p_seq_update_field_MOT1CR_ENC_POL

  // Update code for field MOT1CR.MOT1CR_I_EN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1CR_I_EN
    if (~i_rst_n) begin
      F_MOT1CR_I_EN          <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT1CR & ~sif_reg_wrchan.bmask[5])) begin
        F_MOT1CR_I_EN <= sif_reg_wrchan.data[5]; //RW
      end

    end
  end // p_seq_update_field_MOT1CR_I_EN

  // Update code for field MOT1CR.MOT1CR_PWR_MSB
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1CR_PWR_MSB
    if (~i_rst_n) begin
      F_MOT1CR_PWR_MSB       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT1CR & ~sif_reg_wrchan.bmask[6])) begin
        F_MOT1CR_PWR_MSB <= sif_reg_wrchan.data[6]; //RW
      end

    end
  end // p_seq_update_field_MOT1CR_PWR_MSB

  // Update code for field MOT1CR.MOT1CR_PWR_ALL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1CR_PWR_ALL
    if (~i_rst_n) begin
      F_MOT1CR_PWR_ALL       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT1CR & ~sif_reg_wrchan.bmask[7])) begin
        F_MOT1CR_PWR_ALL <= sif_reg_wrchan.data[7]; //RW
      end

    end
  end // p_seq_update_field_MOT1CR_PWR_ALL

  // Update code for field MOT1PWM.MOT1PWM_MAX
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT1PWM_MAX
    if (~i_rst_n) begin
      F_MOT1PWM_MAX          <= 10'b0100000000;
    end else begin
      // Field update
      for (int i = 0; i < 10; i++) begin
        if ((WR_MOT1PWM & ~sif_reg_wrchan.bmask[i])) begin
          F_MOT1PWM_MAX[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_MOT1PWM_MAX

  // Update code for field MOT2CR.MOT2CR_I_STEP
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2CR_I_STEP
    if (~i_rst_n) begin
      F_MOT2CR_I_STEP        <= 3'b000;
    end else begin
      // Field update
      for (int i = 0; i < 3; i++) begin
        if ((WR_MOT2CR & ~sif_reg_wrchan.bmask[i])) begin
          F_MOT2CR_I_STEP[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_MOT2CR_I_STEP

  // Update code for field MOT2CR.MOT2CR_ENC_POL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2CR_ENC_POL
    if (~i_rst_n) begin
      F_MOT2CR_ENC_POL       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT2CR & ~sif_reg_wrchan.bmask[4])) begin
        F_MOT2CR_ENC_POL <= sif_reg_wrchan.data[4]; //RW
      end

    end
  end // p_seq_update_field_MOT2CR_ENC_POL

  // Update code for field MOT2CR.MOT2CR_I_EN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2CR_I_EN
    if (~i_rst_n) begin
      F_MOT2CR_I_EN          <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT2CR & ~sif_reg_wrchan.bmask[5])) begin
        F_MOT2CR_I_EN <= sif_reg_wrchan.data[5]; //RW
      end

    end
  end // p_seq_update_field_MOT2CR_I_EN

  // Update code for field MOT2CR.MOT2CR_PWR_MSB
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2CR_PWR_MSB
    if (~i_rst_n) begin
      F_MOT2CR_PWR_MSB       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT2CR & ~sif_reg_wrchan.bmask[6])) begin
        F_MOT2CR_PWR_MSB <= sif_reg_wrchan.data[6]; //RW
      end

    end
  end // p_seq_update_field_MOT2CR_PWR_MSB

  // Update code for field MOT2CR.MOT2CR_PWR_ALL
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2CR_PWR_ALL
    if (~i_rst_n) begin
      F_MOT2CR_PWR_ALL       <= 1'b0;
    end else begin
      // Field update
      if ((WR_MOT2CR & ~sif_reg_wrchan.bmask[7])) begin
        F_MOT2CR_PWR_ALL <= sif_reg_wrchan.data[7]; //RW
      end

    end
  end // p_seq_update_field_MOT2CR_PWR_ALL

  // Update code for field MOT2PWM.MOT2PWM_MAX
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_MOT2PWM_MAX
    if (~i_rst_n) begin
      F_MOT2PWM_MAX          <= 10'b0100000000;
    end else begin
      // Field update
      for (int i = 0; i < 10; i++) begin
        if ((WR_MOT2PWM & ~sif_reg_wrchan.bmask[i])) begin
          F_MOT2PWM_MAX[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_MOT2PWM_MAX

  // Update code for field SPDLOW.SPDLOW_SPDLOWTHR
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_SPDLOW_SPDLOWTHR
    if (~i_rst_n) begin
      F_SPDLOW_SPDLOWTHR     <= 15'b000101001010000;
    end else begin
      // Field update
      for (int i = 0; i < 15; i++) begin
        if ((WR_SPDLOW & ~sif_reg_wrchan.bmask[i])) begin
          F_SPDLOW_SPDLOWTHR[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_SPDLOW_SPDLOWTHR

  // Update code for field POWERCTRL1.POWERCTRL1_STOPEN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_POWERCTRL1_STOPEN
    if (~i_rst_n) begin
      F_POWERCTRL1_STOPEN    <= 1'b0;
    end else begin
      // Field update
      if ((WR_POWERCTRL1 & ~sif_reg_wrchan.bmask[0])) begin
        F_POWERCTRL1_STOPEN <= sif_reg_wrchan.data[0]; //RW
      end

    end
  end // p_seq_update_field_POWERCTRL1_STOPEN

  // Update code for field POWERCTRL1.POWERCTRL1_CTRLEN
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_POWERCTRL1_CTRLEN
    if (~i_rst_n) begin
      F_POWERCTRL1_CTRLEN    <= 1'b0;
    end else begin
      // Field update
      if ((WR_POWERCTRL1 & ~sif_reg_wrchan.bmask[1])) begin
        F_POWERCTRL1_CTRLEN <= sif_reg_wrchan.data[1]; //RW
      end

    end
  end // p_seq_update_field_POWERCTRL1_CTRLEN

  // Update code for field POWERCTRL1.POWERCTRL1_HSTHR
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_POWERCTRL1_HSTHR
    if (~i_rst_n) begin
      F_POWERCTRL1_HSTHR     <= 8'b00000000;
    end else begin
      // Field update
      for (int i = 8; i < 16; i++) begin
        if ((WR_POWERCTRL1 & ~sif_reg_wrchan.bmask[i])) begin
          F_POWERCTRL1_HSTHR[i-8] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_POWERCTRL1_HSTHR

  // Update code for field POWERTHR.POWERTHR_LTHR
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_POWERTHR_LTHR
    if (~i_rst_n) begin
      F_POWERTHR_LTHR        <= 8'b00000000;
    end else begin
      // Field update
      for (int i = 0; i < 8; i++) begin
        if ((WR_POWERTHR & ~sif_reg_wrchan.bmask[i])) begin
          F_POWERTHR_LTHR[i-0] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_POWERTHR_LTHR

  // Update code for field POWERTHR.POWERTHR_HTHR
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_POWERTHR_HTHR
    if (~i_rst_n) begin
      F_POWERTHR_HTHR        <= 8'b00000000;
    end else begin
      // Field update
      for (int i = 8; i < 16; i++) begin
        if ((WR_POWERTHR & ~sif_reg_wrchan.bmask[i])) begin
          F_POWERTHR_HTHR[i-8] <= sif_reg_wrchan.data[i]; //RW
        end
      end

    end
  end // p_seq_update_field_POWERTHR_HTHR

  // Update code for field COMPTEST.COMPTEST_COMP_TEST
  always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_update_field_COMPTEST_COMP_TEST
    if (~i_rst_n) begin
      F_COMPTEST_COMP_TEST   <= 16'b1100101011111110;
    end else begin
      // Field update
      F_COMPTEST_COMP_TEST <= sif_regbank_in.COMPTEST_COMP_TEST; //RO Access

    end
  end // p_seq_update_field_COMPTEST_COMP_TEST


  // --------------------------------------------------------------------------
  // Registers fields assignments
  // --------------------------------------------------------------------------
always_comb begin : p_comb_reg_fields
    COMPID      = F_COMPID_COMP_ID ;
    RADIOCFGR   = { 2'b0, F_RADIOCFGR_OTHER_CHAN, 2'b0, F_RADIOCFGR_REV_CHAN, 2'b0, F_RADIOCFGR_PWR_CHAN, 2'b0, F_RADIOCFGR_DIR_CHAN } ;
    RADIOPOL    = { 12'b0, F_RADIOPOL_OTHER_POL, F_RADIOPOL_REV_POL, F_RADIOPOL_PWR_POL, F_RADIOPOL_DIR_POL } ;
    RADIO1DEAD  = F_RADIO1DEAD_VAL ;
    RADIO2DEAD  = F_RADIO2DEAD_VAL ;
    RADIO3DEAD  = F_RADIO3DEAD_VAL ;
    RADIO4DEAD  = F_RADIO4DEAD_VAL ;
    RADIOSKIP   = F_RADIOSKIP_VAL ;
    RADIOPWRDIV = F_RADIOPWRDIV_DIV ;
    MOT1CR      = { 8'b0, F_MOT1CR_PWR_ALL, F_MOT1CR_PWR_MSB, F_MOT1CR_I_EN, F_MOT1CR_ENC_POL, 1'b0, F_MOT1CR_I_STEP } ;
    MOT1PWM     = { 6'b0, F_MOT1PWM_MAX } ;
    MOT2CR      = { 8'b0, F_MOT2CR_PWR_ALL, F_MOT2CR_PWR_MSB, F_MOT2CR_I_EN, F_MOT2CR_ENC_POL, 1'b0, F_MOT2CR_I_STEP } ;
    MOT2PWM     = { 6'b0, F_MOT2PWM_MAX } ;
    SPDLOW      = { 1'b0, F_SPDLOW_SPDLOWTHR } ;
    POWERCTRL1  = { F_POWERCTRL1_HSTHR, 6'b0, F_POWERCTRL1_CTRLEN, F_POWERCTRL1_STOPEN } ;
    POWERTHR    = { F_POWERTHR_HTHR, F_POWERTHR_LTHR } ;
    COMPTEST    = F_COMPTEST_COMP_TEST ;
end : p_comb_reg_fields

  // --------------------------------------------------------------------------
  // Regbank output interface (Write access)
  // --------------------------------------------------------------------------
  always_comb begin : p_comb_wr_out
    mif_regbank_out.RADIOCFGR_DIR_CHAN   = F_RADIOCFGR_DIR_CHAN;
    mif_regbank_out.RADIOCFGR_PWR_CHAN   = F_RADIOCFGR_PWR_CHAN;
    mif_regbank_out.RADIOCFGR_REV_CHAN   = F_RADIOCFGR_REV_CHAN;
    mif_regbank_out.RADIOCFGR_OTHER_CHAN = F_RADIOCFGR_OTHER_CHAN;
    mif_regbank_out.RADIOPOL_DIR_POL     = F_RADIOPOL_DIR_POL;
    mif_regbank_out.RADIOPOL_PWR_POL     = F_RADIOPOL_PWR_POL;
    mif_regbank_out.RADIOPOL_REV_POL     = F_RADIOPOL_REV_POL;
    mif_regbank_out.RADIOPOL_OTHER_POL   = F_RADIOPOL_OTHER_POL;
    mif_regbank_out.RADIO1DEAD_VAL       = F_RADIO1DEAD_VAL;
    mif_regbank_out.RADIO2DEAD_VAL       = F_RADIO2DEAD_VAL;
    mif_regbank_out.RADIO3DEAD_VAL       = F_RADIO3DEAD_VAL;
    mif_regbank_out.RADIO4DEAD_VAL       = F_RADIO4DEAD_VAL;
    mif_regbank_out.RADIOSKIP_VAL        = F_RADIOSKIP_VAL;
    mif_regbank_out.RADIOPWRDIV_DIV      = F_RADIOPWRDIV_DIV;
    mif_regbank_out.MOT1CR_I_STEP        = F_MOT1CR_I_STEP;
    mif_regbank_out.MOT1CR_ENC_POL       = F_MOT1CR_ENC_POL;
    mif_regbank_out.MOT1CR_I_EN          = F_MOT1CR_I_EN;
    mif_regbank_out.MOT1CR_PWR_MSB       = F_MOT1CR_PWR_MSB;
    mif_regbank_out.MOT1CR_PWR_ALL       = F_MOT1CR_PWR_ALL;
    mif_regbank_out.MOT1PWM_MAX          = F_MOT1PWM_MAX;
    mif_regbank_out.MOT2CR_I_STEP        = F_MOT2CR_I_STEP;
    mif_regbank_out.MOT2CR_ENC_POL       = F_MOT2CR_ENC_POL;
    mif_regbank_out.MOT2CR_I_EN          = F_MOT2CR_I_EN;
    mif_regbank_out.MOT2CR_PWR_MSB       = F_MOT2CR_PWR_MSB;
    mif_regbank_out.MOT2CR_PWR_ALL       = F_MOT2CR_PWR_ALL;
    mif_regbank_out.MOT2PWM_MAX          = F_MOT2PWM_MAX;
    mif_regbank_out.SPDLOW_SPDLOWTHR     = F_SPDLOW_SPDLOWTHR;
    mif_regbank_out.POWERCTRL1_STOPEN    = F_POWERCTRL1_STOPEN;
    mif_regbank_out.POWERCTRL1_CTRLEN    = F_POWERCTRL1_CTRLEN;
    mif_regbank_out.POWERCTRL1_HSTHR     = F_POWERCTRL1_HSTHR;
    mif_regbank_out.POWERTHR_LTHR        = F_POWERTHR_LTHR;
    mif_regbank_out.POWERTHR_HTHR        = F_POWERTHR_HTHR;
  end : p_comb_wr_out

  // --------------------------------------------------------------------------
  // Registers read access
  // --------------------------------------------------------------------------
  always_comb begin : p_comb_read_reg
    case (sif_reg_rdchan.addr)
      `COMPID_OFFSET     : rdata = COMPID     ;
      `RADIOCFGR_OFFSET  : rdata = RADIOCFGR  ;
      `RADIOPOL_OFFSET   : rdata = RADIOPOL   ;
      `RADIO1DEAD_OFFSET : rdata = RADIO1DEAD ;
      `RADIO2DEAD_OFFSET : rdata = RADIO2DEAD ;
      `RADIO3DEAD_OFFSET : rdata = RADIO3DEAD ;
      `RADIO4DEAD_OFFSET : rdata = RADIO4DEAD ;
      `RADIOSKIP_OFFSET  : rdata = RADIOSKIP  ;
      `RADIOPWRDIV_OFFSET: rdata = RADIOPWRDIV;
      `MOT1CR_OFFSET     : rdata = MOT1CR     ;
      `MOT1PWM_OFFSET    : rdata = MOT1PWM    ;
      `MOT2CR_OFFSET     : rdata = MOT2CR     ;
      `MOT2PWM_OFFSET    : rdata = MOT2PWM    ;
      `SPDLOW_OFFSET     : rdata = SPDLOW     ;
      `POWERCTRL1_OFFSET : rdata = POWERCTRL1 ;
      `POWERTHR_OFFSET   : rdata = POWERTHR   ;
      `COMPTEST_OFFSET   : rdata = COMPTEST   ;
    default: rdata = {`K_DWIDTH{1'b0}};
    endcase
  end : p_comb_read_reg

  // --------------------------------------------------------------------------
  // Read data pipeline stage
  // --------------------------------------------------------------------------
always_ff @(posedge i_clk or negedge i_rst_n) begin : p_seq_rdata_pipe
   if (i_rst_n == 1'b0) begin
     sif_reg_rdchan.valid <= 1'b0;
     sif_reg_rdchan.data  <= {`K_DWIDTH{1'b0}};
   end
   else begin
      sif_reg_rdchan.valid <= sif_reg_rdchan.read;
     sif_reg_rdchan.data  <= rdata;
   end
end : p_seq_rdata_pipe
endmodule