#!/usr/bin/env python3

import siliconcompiler                            # import python package
import os  

def main():
    chip = siliconcompiler.Chip()                 # create chip object
    root_peripheral = "../"
    sources = [
        "peripherals/motor/rtl/encoder_reader.sv",
        "peripherals/motor/rtl/motor_control_top.sv",
        "peripherals/motor/rtl/pattern_generator.sv",

        "peripherals/regbank/rtl/reg_rdchan_if.sv",
        "peripherals/regbank/rtl/reg_wrchan_if.sv",
        "peripherals/regbank/rtl/regbk_regbank_in_if.sv",
        "peripherals/regbank/rtl/regbk_regbank_out_if.sv",
        "peripherals/regbank/rtl/regbk_regbank.sv",
        
        "peripherals/pwm/rtl/pwm_gen_left.sv",
        "peripherals/pwm/rtl/pwm_capture.sv",
        
        "peripherals/spi/rtl/spi_slave.sv",
        
        "peripherals/top/rtl/channels_decoder.sv",
        "peripherals/top/rtl/spi_rb_interface.sv",
        "peripherals/top/rtl/core_top.sv"
    ]
    sources = [f"{root_peripheral}{x}" for x in sources]
    chip.set('source', sources)             # define list of source files
    chip.set('idir','../peripherals/regbank/rtl')
    chip.set('design', 'core_top')               # set top module
    #chip.set('design', 'motor_control_top')               # set top module
    chip.set('constraint', 'hamster.sdc')        # set constraints file
    chip.set('frontend', 'systemverilog')

    chip.set('asic', 'density', 20, clobber=False)

    #chip.target('asicflow_skywater130')          # load predefined target
    chip.target('asicflow_csky130hd')           # load predefined target
    #chip.target('asicflow_idealcsky130hd')           # load predefined target
    #chip.target('asicflow_freepdk45')           # load predefined target
    #update_yosys_options(chip)
    chip.run()                                    # run compilation
    chip.summary()                                # print results summary
    chip.show()                                   # show layout file

def configure_chip(design) :
    pass


if __name__ == '__main__':
    main()

