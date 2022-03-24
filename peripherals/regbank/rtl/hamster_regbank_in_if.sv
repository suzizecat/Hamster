/* regbank in interface - file automatically generated - do not modify */

interface hamster_regbank_in_if;
    logic [15: 0] COMPID_COMP_ID;
    logic [15: 0] COMPTEST_COMP_TEST;
modport slave (
    input  COMPID_COMP_ID,
    input  COMPTEST_COMP_TEST
);
modport master (
    output COMPID_COMP_ID,
    output COMPTEST_COMP_TEST
);
endinterface : hamster_regbank_in_if
