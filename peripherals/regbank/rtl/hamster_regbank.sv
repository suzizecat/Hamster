/* registers bank design - file automatically generated - do not modify */

//-----------------------------------------------------------------------------
//    this confidential and proprietary file may be used only as authorized
//                 by a licensing agreement from EASii IC sas
//                       Copyright 2022 EASii IC SAS
//                    legal statement: all rights reserved
//     the entire notice above must be reproduced on all authorized copies
//-----------------------------------------------------------------------------
// Generated on 2022-03-22
//-----------------------------------------------------------------------------

// ----------------------------------------------------------------------------

`include "hamster_regs_map.svh"

//! 
//! # COMPID
//! - Offset : 0x00
//! {reg:[{name:'COMPID_COMP_ID',bits:16,attr:['RO']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # COMPID
//! - Offset : 0x00
//! {reg:[{name:'COMPID_COMP_ID',bits:16,attr:['RO']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIOCFGR
//! - Offset : 0x01
//! {reg:[{name:'RADIOCFGR_DIR_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_PWR_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_REV_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_OTHER_CHAN',bits:2,attr:['RW']},{bits:2}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIOCFGR
//! - Offset : 0x01
//! {reg:[{name:'RADIOCFGR_DIR_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_PWR_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_REV_CHAN',bits:2,attr:['RW']},{bits:2},{name:'RADIOCFGR_OTHER_CHAN',bits:2,attr:['RW']},{bits:2}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIOPOL
//! - Offset : 0x02
//! {reg:[{name:'RADIOPOL_DIR_POL',bits:1,attr:['RW']},{name:'RADIOPOL_PWR_POL',bits:1,attr:['RW']},{name:'RADIOPOL_REV_POL',bits:1,attr:['RW']},{name:'RADIOPOL_OTHER_POL',bits:1,attr:['RW']},{bits:12}],config:{bits:16,fontsize:5.5,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIOPOL
//! - Offset : 0x02
//! {reg:[{name:'RADIOPOL_DIR_POL',bits:1,attr:['RW']},{name:'RADIOPOL_PWR_POL',bits:1,attr:['RW']},{name:'RADIOPOL_REV_POL',bits:1,attr:['RW']},{name:'RADIOPOL_OTHER_POL',bits:1,attr:['RW']},{bits:12}],config:{bits:16,fontsize:5.5,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIO1DEAD
//! - Offset : 0x03
//! {reg:[{name:'RADIO1DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIO1DEAD
//! - Offset : 0x03
//! {reg:[{name:'RADIO1DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIO2DEAD
//! - Offset : 0x04
//! {reg:[{name:'RADIO2DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIO2DEAD
//! - Offset : 0x04
//! {reg:[{name:'RADIO2DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIO3DEAD
//! - Offset : 0x05
//! {reg:[{name:'RADIO3DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIO3DEAD
//! - Offset : 0x05
//! {reg:[{name:'RADIO3DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
//! 
//! # RADIO4DEAD
//! - Offset : 0x06
//! {reg:[{name:'RADIO4DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # RADIO4DEAD
//! - Offset : 0x06
//! {reg:[{name:'RADIO4DEAD_VAL',bits:16,attr:['RW']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 

//! ## MOT1CR_PWR_ALL
//! 
//! Override on_msb and use all output for power
//! 
//! ## MOT1CR_PWR_ALL
//! 
//! Override on_msb and use all output for power
//! 

//! ## MOT1PWM_MAX
//! 
//! Motor1 PWM
//! 
//! ## MOT1PWM_MAX
//! 
//! Motor1 PWM
//! 

//! ## MOT2CR_PWR_ALL
//! 
//! Override on_msb and use all output for power
//! 
//! ## MOT2CR_PWR_ALL
//! 
//! Override on_msb and use all output for power
//! 

//! ## MOT2PWM_MAX
//! 
//! Motor2 PWM
//! 
//! ## MOT2PWM_MAX
//! 
//! Motor2 PWM
//! 
//! 
//! # COMPTEST
//! - Offset : 0xA9
//! {reg:[{name:'COMPTEST_COMP_TEST',bits:16,attr:['RO']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! //! 
//! # COMPTEST
//! - Offset : 0xA9
//! {reg:[{name:'COMPTEST_COMP_TEST',bits:16,attr:['RO']}],config:{bits:16,fontsize:9.0,vspace:70,margin:{top:15,bottom:15}}}
//! 
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

// ----------------------------------------------------------------------------
// Register variables
// ----------------------------------------------------------------------------
logic [`K_DWIDTH-1:0] COMPID    ;
logic [`K_DWIDTH-1:0] RADIOCFGR ;
logic [`K_DWIDTH-1:0] RADIOPOL  ;
logic [`K_DWIDTH-1:0] RADIO1DEAD;
logic [`K_DWIDTH-1:0] RADIO2DEAD;
logic [`K_DWIDTH-1:0] RADIO3DEAD;
logic [`K_DWIDTH-1:0] RADIO4DEAD;
logic [`K_DWIDTH-1:0] MOT1CR    ;
logic [`K_DWIDTH-1:0] MOT1PWM   ;
logic [`K_DWIDTH-1:0] MOT2CR    ;
logic [`K_DWIDTH-1:0] MOT2PWM   ;
logic [`K_DWIDTH-1:0] COMPTEST  ;


// ----------------------------------------------------------------------------
// Write control signals
// ----------------------------------------------------------------------------
logic WR_RADIOCFGR ;
logic WR_RADIOPOL  ;
logic WR_RADIO1DEAD;
logic WR_RADIO2DEAD;
logic WR_RADIO3DEAD;
logic WR_RADIO4DEAD;
logic WR_MOT1CR    ;
logic WR_MOT1PWM   ;
logic WR_MOT2CR    ;
logic WR_MOT2PWM   ;


// ----------------------------------------------------------------------------
// Register fields declaration
// ----------------------------------------------------------------------------
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
logic [15: 0] F_COMPTEST_COMP_TEST  ;

// Register write control -- Address decoding
assign WR_RADIOCFGR  = ((sif_reg_wrchan.addr == `RADIOCFGR_OFFSET ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_RADIOPOL   = ((sif_reg_wrchan.addr == `RADIOPOL_OFFSET  ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_RADIO1DEAD = ((sif_reg_wrchan.addr == `RADIO1DEAD_OFFSET) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_RADIO2DEAD = ((sif_reg_wrchan.addr == `RADIO2DEAD_OFFSET) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_RADIO3DEAD = ((sif_reg_wrchan.addr == `RADIO3DEAD_OFFSET) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_RADIO4DEAD = ((sif_reg_wrchan.addr == `RADIO4DEAD_OFFSET) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_MOT1CR     = ((sif_reg_wrchan.addr == `MOT1CR_OFFSET    ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_MOT1PWM    = ((sif_reg_wrchan.addr == `MOT1PWM_OFFSET   ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_MOT2CR     = ((sif_reg_wrchan.addr == `MOT2CR_OFFSET    ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;
assign WR_MOT2PWM    = ((sif_reg_wrchan.addr == `MOT2PWM_OFFSET   ) && (sif_reg_wrchan.write == 1'b1)) ? 1'b1 : 1'b0;

// -----------------------------------------------------------------------------------
// Shadow read control
// -----------------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Register field update
// ----------------------------------------------------------------------------
always_ff @(posedge i_clk or negedge i_rst_n) begin : p_COMPID_COMP_ID
    if (i_rst_n == 1'b0) begin
        F_COMPID_COMP_ID       <= 16'hA001;
    end else begin
        F_COMPID_COMP_ID <= sif_regbank_in.COMPID_COMP_ID; //RO Access
    end
end : p_COMPID_COMP_ID

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOCFGR_DIR_CHAN
    if (i_rst_n == 1'b0) begin
        F_RADIOCFGR_DIR_CHAN   <= 2'h0;
    end else begin
        for (int i = 1; i >= 0; i--) begin
            if ((WR_RADIOCFGR  == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIOCFGR_DIR_CHAN[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIOCFGR_DIR_CHAN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOCFGR_PWR_CHAN
    if (i_rst_n == 1'b0) begin
        F_RADIOCFGR_PWR_CHAN   <= 2'h1;
    end else begin
        for (int i = 5; i >= 4; i--) begin
            if ((WR_RADIOCFGR  == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIOCFGR_PWR_CHAN[i - 4] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIOCFGR_PWR_CHAN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOCFGR_REV_CHAN
    if (i_rst_n == 1'b0) begin
        F_RADIOCFGR_REV_CHAN   <= 2'h2;
    end else begin
        for (int i = 9; i >= 8; i--) begin
            if ((WR_RADIOCFGR  == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIOCFGR_REV_CHAN[i - 8] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIOCFGR_REV_CHAN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOCFGR_OTHER_CHAN
    if (i_rst_n == 1'b0) begin
        F_RADIOCFGR_OTHER_CHAN <= 2'h3;
    end else begin
        for (int i = 13; i >= 12; i--) begin
            if ((WR_RADIOCFGR  == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIOCFGR_OTHER_CHAN[i - 12] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIOCFGR_OTHER_CHAN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOPOL_DIR_POL
    if (i_rst_n == 1'b0) begin
        F_RADIOPOL_DIR_POL     <= 1'h0;
    end else begin
        if ((WR_RADIOPOL   == 1'b1) && (sif_reg_wrchan.bmask[0] == 1'b0)) begin
            F_RADIOPOL_DIR_POL <= sif_reg_wrchan.data[0]; //RW
        end
    end
end : p_RADIOPOL_DIR_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOPOL_PWR_POL
    if (i_rst_n == 1'b0) begin
        F_RADIOPOL_PWR_POL     <= 1'h0;
    end else begin
        if ((WR_RADIOPOL   == 1'b1) && (sif_reg_wrchan.bmask[1] == 1'b0)) begin
            F_RADIOPOL_PWR_POL <= sif_reg_wrchan.data[1]; //RW
        end
    end
end : p_RADIOPOL_PWR_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOPOL_REV_POL
    if (i_rst_n == 1'b0) begin
        F_RADIOPOL_REV_POL     <= 1'h0;
    end else begin
        if ((WR_RADIOPOL   == 1'b1) && (sif_reg_wrchan.bmask[2] == 1'b0)) begin
            F_RADIOPOL_REV_POL <= sif_reg_wrchan.data[2]; //RW
        end
    end
end : p_RADIOPOL_REV_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIOPOL_OTHER_POL
    if (i_rst_n == 1'b0) begin
        F_RADIOPOL_OTHER_POL   <= 1'h0;
    end else begin
        if ((WR_RADIOPOL   == 1'b1) && (sif_reg_wrchan.bmask[3] == 1'b0)) begin
            F_RADIOPOL_OTHER_POL <= sif_reg_wrchan.data[3]; //RW
        end
    end
end : p_RADIOPOL_OTHER_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIO1DEAD_VAL
    if (i_rst_n == 1'b0) begin
        F_RADIO1DEAD_VAL       <= 16'h4;
    end else begin
        for (int i = 15; i >= 0; i--) begin
            if ((WR_RADIO1DEAD == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIO1DEAD_VAL[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIO1DEAD_VAL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIO2DEAD_VAL
    if (i_rst_n == 1'b0) begin
        F_RADIO2DEAD_VAL       <= 16'h4;
    end else begin
        for (int i = 15; i >= 0; i--) begin
            if ((WR_RADIO2DEAD == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIO2DEAD_VAL[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIO2DEAD_VAL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIO3DEAD_VAL
    if (i_rst_n == 1'b0) begin
        F_RADIO3DEAD_VAL       <= 16'h4;
    end else begin
        for (int i = 15; i >= 0; i--) begin
            if ((WR_RADIO3DEAD == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIO3DEAD_VAL[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIO3DEAD_VAL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_RADIO4DEAD_VAL
    if (i_rst_n == 1'b0) begin
        F_RADIO4DEAD_VAL       <= 16'h4;
    end else begin
        for (int i = 15; i >= 0; i--) begin
            if ((WR_RADIO4DEAD == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_RADIO4DEAD_VAL[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_RADIO4DEAD_VAL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1CR_I_STEP
    if (i_rst_n == 1'b0) begin
        F_MOT1CR_I_STEP        <= 3'h0;
    end else begin
        for (int i = 2; i >= 0; i--) begin
            if ((WR_MOT1CR     == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_MOT1CR_I_STEP[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_MOT1CR_I_STEP

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1CR_ENC_POL
    if (i_rst_n == 1'b0) begin
        F_MOT1CR_ENC_POL       <= 1'h0;
    end else begin
        if ((WR_MOT1CR     == 1'b1) && (sif_reg_wrchan.bmask[4] == 1'b0)) begin
            F_MOT1CR_ENC_POL <= sif_reg_wrchan.data[4]; //RW
        end
    end
end : p_MOT1CR_ENC_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1CR_I_EN
    if (i_rst_n == 1'b0) begin
        F_MOT1CR_I_EN          <= 1'h0;
    end else begin
        if ((WR_MOT1CR     == 1'b1) && (sif_reg_wrchan.bmask[5] == 1'b0)) begin
            F_MOT1CR_I_EN <= sif_reg_wrchan.data[5]; //RW
        end
    end
end : p_MOT1CR_I_EN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1CR_PWR_MSB
    if (i_rst_n == 1'b0) begin
        F_MOT1CR_PWR_MSB       <= 1'h0;
    end else begin
        if ((WR_MOT1CR     == 1'b1) && (sif_reg_wrchan.bmask[6] == 1'b0)) begin
            F_MOT1CR_PWR_MSB <= sif_reg_wrchan.data[6]; //RW
        end
    end
end : p_MOT1CR_PWR_MSB

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1CR_PWR_ALL
    if (i_rst_n == 1'b0) begin
        F_MOT1CR_PWR_ALL       <= 1'h0;
    end else begin
        if ((WR_MOT1CR     == 1'b1) && (sif_reg_wrchan.bmask[7] == 1'b0)) begin
            F_MOT1CR_PWR_ALL <= sif_reg_wrchan.data[7]; //RW
        end
    end
end : p_MOT1CR_PWR_ALL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT1PWM_MAX
    if (i_rst_n == 1'b0) begin
        F_MOT1PWM_MAX          <= 10'h100;
    end else begin
        for (int i = 9; i >= 0; i--) begin
            if ((WR_MOT1PWM    == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_MOT1PWM_MAX[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_MOT1PWM_MAX

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2CR_I_STEP
    if (i_rst_n == 1'b0) begin
        F_MOT2CR_I_STEP        <= 3'h0;
    end else begin
        for (int i = 2; i >= 0; i--) begin
            if ((WR_MOT2CR     == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_MOT2CR_I_STEP[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_MOT2CR_I_STEP

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2CR_ENC_POL
    if (i_rst_n == 1'b0) begin
        F_MOT2CR_ENC_POL       <= 1'h0;
    end else begin
        if ((WR_MOT2CR     == 1'b1) && (sif_reg_wrchan.bmask[4] == 1'b0)) begin
            F_MOT2CR_ENC_POL <= sif_reg_wrchan.data[4]; //RW
        end
    end
end : p_MOT2CR_ENC_POL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2CR_I_EN
    if (i_rst_n == 1'b0) begin
        F_MOT2CR_I_EN          <= 1'h0;
    end else begin
        if ((WR_MOT2CR     == 1'b1) && (sif_reg_wrchan.bmask[5] == 1'b0)) begin
            F_MOT2CR_I_EN <= sif_reg_wrchan.data[5]; //RW
        end
    end
end : p_MOT2CR_I_EN

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2CR_PWR_MSB
    if (i_rst_n == 1'b0) begin
        F_MOT2CR_PWR_MSB       <= 1'h0;
    end else begin
        if ((WR_MOT2CR     == 1'b1) && (sif_reg_wrchan.bmask[6] == 1'b0)) begin
            F_MOT2CR_PWR_MSB <= sif_reg_wrchan.data[6]; //RW
        end
    end
end : p_MOT2CR_PWR_MSB

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2CR_PWR_ALL
    if (i_rst_n == 1'b0) begin
        F_MOT2CR_PWR_ALL       <= 1'h0;
    end else begin
        if ((WR_MOT2CR     == 1'b1) && (sif_reg_wrchan.bmask[7] == 1'b0)) begin
            F_MOT2CR_PWR_ALL <= sif_reg_wrchan.data[7]; //RW
        end
    end
end : p_MOT2CR_PWR_ALL

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_MOT2PWM_MAX
    if (i_rst_n == 1'b0) begin
        F_MOT2PWM_MAX          <= 10'h100;
    end else begin
        for (int i = 9; i >= 0; i--) begin
            if ((WR_MOT2PWM    == 1'b1) && (sif_reg_wrchan.bmask[i] == 1'b0)) begin
                F_MOT2PWM_MAX[i - 0] <= sif_reg_wrchan.data[i]; //RW
            end
        end
        
    end
end : p_MOT2PWM_MAX

always_ff @(posedge i_clk or negedge i_rst_n) begin : p_COMPTEST_COMP_TEST
    if (i_rst_n == 1'b0) begin
        F_COMPTEST_COMP_TEST   <= 16'hCAFE;
    end else begin
        F_COMPTEST_COMP_TEST <= sif_regbank_in.COMPTEST_COMP_TEST; //RO Access
    end
end : p_COMPTEST_COMP_TEST


// ----------------------------------------------------------------------------
// Registers fields assignments
// ----------------------------------------------------------------------------
always_comb begin : p_comb_reg_fields
    COMPID     = { F_COMPID_COMP_ID };
    RADIOCFGR  = { 2'b0, F_RADIOCFGR_OTHER_CHAN, 2'b0, F_RADIOCFGR_REV_CHAN, 2'b0, F_RADIOCFGR_PWR_CHAN, 2'b0, F_RADIOCFGR_DIR_CHAN };
    RADIOPOL   = { 12'b0, F_RADIOPOL_OTHER_POL, F_RADIOPOL_REV_POL, F_RADIOPOL_PWR_POL, F_RADIOPOL_DIR_POL };
    RADIO1DEAD = { F_RADIO1DEAD_VAL };
    RADIO2DEAD = { F_RADIO2DEAD_VAL };
    RADIO3DEAD = { F_RADIO3DEAD_VAL };
    RADIO4DEAD = { F_RADIO4DEAD_VAL };
    MOT1CR     = { 8'b0, F_MOT1CR_PWR_ALL, F_MOT1CR_PWR_MSB, F_MOT1CR_I_EN, F_MOT1CR_ENC_POL, 1'b0, F_MOT1CR_I_STEP };
    MOT1PWM    = { 6'b0, F_MOT1PWM_MAX };
    MOT2CR     = { 8'b0, F_MOT2CR_PWR_ALL, F_MOT2CR_PWR_MSB, F_MOT2CR_I_EN, F_MOT2CR_ENC_POL, 1'b0, F_MOT2CR_I_STEP };
    MOT2PWM    = { 6'b0, F_MOT2PWM_MAX };
    COMPTEST   = { F_COMPTEST_COMP_TEST };
end : p_comb_reg_fields

// ----------------------------------------------------------------------------
// Regbank output interface (Write access)
// ----------------------------------------------------------------------------
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
    end : p_comb_wr_out

// ----------------------------------------------------------------------------
// Registers read access
// ----------------------------------------------------------------------------
always_comb begin : p_comb_read_reg
    rdata = sif_reg_rdchan.data;
    if (sif_reg_rdchan.read == 1'b1) begin
        case (sif_reg_rdchan.addr)
            `COMPID_OFFSET    : rdata = COMPID;
            `RADIOCFGR_OFFSET : rdata = RADIOCFGR;
            `RADIOPOL_OFFSET  : rdata = RADIOPOL;
            `RADIO1DEAD_OFFSET: rdata = RADIO1DEAD;
            `RADIO2DEAD_OFFSET: rdata = RADIO2DEAD;
            `RADIO3DEAD_OFFSET: rdata = RADIO3DEAD;
            `RADIO4DEAD_OFFSET: rdata = RADIO4DEAD;
            `MOT1CR_OFFSET    : rdata = MOT1CR;
            `MOT1PWM_OFFSET   : rdata = MOT1PWM;
            `MOT2CR_OFFSET    : rdata = MOT2CR;
            `MOT2PWM_OFFSET   : rdata = MOT2PWM;
            `COMPTEST_OFFSET  : rdata = COMPTEST;
            default: rdata = {`K_DWIDTH{1'b0}};
        endcase
    end
end : p_comb_read_reg

// ----------------------------------------------------------------------------
// Read data pipeline stage
// ----------------------------------------------------------------------------
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