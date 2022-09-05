/* regbank out interface - file automatically generated - do not modify */

interface hamster_regbank_out_if;

  logic [ 1: 0] RADIOCFGR_DIR_CHAN  ;
  logic [ 1: 0] RADIOCFGR_PWR_CHAN  ;
  logic [ 1: 0] RADIOCFGR_REV_CHAN  ;
  logic [ 1: 0] RADIOCFGR_OTHER_CHAN;
  logic         RADIOPOL_DIR_POL    ;
  logic         RADIOPOL_PWR_POL    ;
  logic         RADIOPOL_REV_POL    ;
  logic         RADIOPOL_OTHER_POL  ;
  logic [15: 0] RADIO1DEAD_VAL      ;
  logic [15: 0] RADIO2DEAD_VAL      ;
  logic [15: 0] RADIO3DEAD_VAL      ;
  logic [15: 0] RADIO4DEAD_VAL      ;
  logic [15: 0] RADIOSKIP_VAL       ;
  logic [15: 0] RADIOPWRDIV_DIV     ;
  logic [ 2: 0] MOT1CR_I_STEP       ;
  logic         MOT1CR_ENC_POL      ;
  logic         MOT1CR_I_EN         ;
  logic         MOT1CR_PWR_MSB      ;
  logic         MOT1CR_PWR_ALL      ;
  logic [ 9: 0] MOT1PWM_MAX         ;
  logic [ 2: 0] MOT2CR_I_STEP       ;
  logic         MOT2CR_ENC_POL      ;
  logic         MOT2CR_I_EN         ;
  logic         MOT2CR_PWR_MSB      ;
  logic         MOT2CR_PWR_ALL      ;
  logic [ 9: 0] MOT2PWM_MAX         ;
  logic [14: 0] SPDLOW_SPDLOWTHR    ;
  logic         POWERCTRL1_STOPEN   ;
  logic         POWERCTRL1_CTRLEN   ;
  logic [ 7: 0] POWERCTRL1_HSTHR    ;
  logic [ 7: 0] POWERTHR_LTHR       ;
  logic [ 7: 0] POWERTHR_HTHR       ;

  modport slave (
    input  RADIOCFGR_DIR_CHAN  ,
    input  RADIOCFGR_PWR_CHAN  ,
    input  RADIOCFGR_REV_CHAN  ,
    input  RADIOCFGR_OTHER_CHAN,
    input  RADIOPOL_DIR_POL    ,
    input  RADIOPOL_PWR_POL    ,
    input  RADIOPOL_REV_POL    ,
    input  RADIOPOL_OTHER_POL  ,
    input  RADIO1DEAD_VAL      ,
    input  RADIO2DEAD_VAL      ,
    input  RADIO3DEAD_VAL      ,
    input  RADIO4DEAD_VAL      ,
    input  RADIOSKIP_VAL       ,
    input  RADIOPWRDIV_DIV     ,
    input  MOT1CR_I_STEP       ,
    input  MOT1CR_ENC_POL      ,
    input  MOT1CR_I_EN         ,
    input  MOT1CR_PWR_MSB      ,
    input  MOT1CR_PWR_ALL      ,
    input  MOT1PWM_MAX         ,
    input  MOT2CR_I_STEP       ,
    input  MOT2CR_ENC_POL      ,
    input  MOT2CR_I_EN         ,
    input  MOT2CR_PWR_MSB      ,
    input  MOT2CR_PWR_ALL      ,
    input  MOT2PWM_MAX         ,
    input  SPDLOW_SPDLOWTHR    ,
    input  POWERCTRL1_STOPEN   ,
    input  POWERCTRL1_CTRLEN   ,
    input  POWERCTRL1_HSTHR    ,
    input  POWERTHR_LTHR       ,
    input  POWERTHR_HTHR       
  );

  modport master (
    output RADIOCFGR_DIR_CHAN  ,
    output RADIOCFGR_PWR_CHAN  ,
    output RADIOCFGR_REV_CHAN  ,
    output RADIOCFGR_OTHER_CHAN,
    output RADIOPOL_DIR_POL    ,
    output RADIOPOL_PWR_POL    ,
    output RADIOPOL_REV_POL    ,
    output RADIOPOL_OTHER_POL  ,
    output RADIO1DEAD_VAL      ,
    output RADIO2DEAD_VAL      ,
    output RADIO3DEAD_VAL      ,
    output RADIO4DEAD_VAL      ,
    output RADIOSKIP_VAL       ,
    output RADIOPWRDIV_DIV     ,
    output MOT1CR_I_STEP       ,
    output MOT1CR_ENC_POL      ,
    output MOT1CR_I_EN         ,
    output MOT1CR_PWR_MSB      ,
    output MOT1CR_PWR_ALL      ,
    output MOT1PWM_MAX         ,
    output MOT2CR_I_STEP       ,
    output MOT2CR_ENC_POL      ,
    output MOT2CR_I_EN         ,
    output MOT2CR_PWR_MSB      ,
    output MOT2CR_PWR_ALL      ,
    output MOT2PWM_MAX         ,
    output SPDLOW_SPDLOWTHR    ,
    output POWERCTRL1_STOPEN   ,
    output POWERCTRL1_CTRLEN   ,
    output POWERCTRL1_HSTHR    ,
    output POWERTHR_LTHR       ,
    output POWERTHR_HTHR       
  );
endinterface : hamster_regbank_out_if
