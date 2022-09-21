#!/usr/bin/env python3

import siliconcompiler                            # import python package
import os  

def main():
    chip = siliconcompiler.Chip(design="core_top")                 # create chip object
    root_peripheral = "../rtl"
    sources = [
        "/pwm/pwm_gen_left.sv",
        "/pwm/pwm_capture.sv",

        "/maths/div.sv",

        "/motor/encoder_reader.sv",
        "/motor/motor_control_top.sv",
        "/motor/pattern_generator.sv",
        "/motor/speed_meter.sv",

        "/regbank/reg_rdchan_if.sv",
        "/regbank/reg_wrchan_if.sv",
        "/regbank/hamster_regbank_in_if.sv",
        "/regbank/hamster_regbank_out_if.sv",
        "/regbank/hamster_regbank.sv",
        
        "/spi/spi_slave.sv",
        
        "/top/timebase.sv",
        "/top/channels_decoder.sv",
        "/top/spi_rb_interface.sv",
        "/top/core_top.sv"
    ]
    sources = [f"{root_peripheral}{x}" for x in sources]

    chip.set('input',"verilog", sources)             # define list of source files
    chip.set('option','frontend', 'systemverilog')
    chip.set('input', 'sdc', 'hamster.sdc')     # set constraints file
    #chip.set('constraint','worst','file','hamster.sdc')        # set constraints file
    
    chip.set('option','idir','../rtl/regbank')

    chip.set('asic', 'diearea', [(0,0),(2920,3520)])
    chip.set('asic', 'corearea', [(10,10),(2910,3510)])

    chip.load_target('skywater130_demo')          # load predefined target

    flow = "syndbg_flow"
    chip.node(flow,"import","surelog")
    chip.node(flow,"convert","sv2v")
    chip.node(flow,"syn","yosys")
    chip.edge(flow,"import","convert")
    chip.edge(flow,"convert","syn")
    chip.set("option","flow",flow)
    #chip.target('asicflow_csky130hd')           # load predefined target
    #chip.target('asicflow_idealcsky130hd')           # load predefined target
    #chip.target('asicflow_freepdk45')           # load predefined target
    #update_yosys_options(chip)
    #quit()

    chip.run()                                    # run compilation
    chip.summary()                                # print results summary
    # chip.show()                                   # show layout file

def configure_chip(design) :
    pass


if __name__ == '__main__':
    main()

