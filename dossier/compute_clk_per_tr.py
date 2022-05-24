from math import pi
from math import log2
from math import floor, ceil
def convert_speed(val, m_factor = 1000, sec_factor = 3600):
    return val *(sec_factor/m_factor)

def clk_per_step(speed,freq=80e6,diameter = 0.7, step_per_tr = 6*40//2):
    tr_per_meter = pi*diameter
    tr_per_s = tr_per_meter * speed
    step_per_s = step_per_tr * tr_per_s
    _clk_per_step = freq/step_per_s
    return step_per_s, _clk_per_step

if __name__ == "__main__" :
    fast_sps, fast_cps = clk_per_step(convert_speed(30))
    slow_sps, slow_cps = clk_per_step(0.01)
    
    print(f"Fast")
    print(f"    Clock cycles per steps : {fast_cps:11.2f} - {log2(fast_cps):11.2f}")
    print(f"    Step per seconds       : {fast_sps:11.2f} - {log2(fast_sps):11.2f}")
    print("Slow")
    print(f"    Clock cycles per steps : {slow_cps:11.2f} - {log2(slow_cps):11.2f}")
    print(f"    Step per seconds       : {slow_sps:11.2f} - {log2(slow_sps):11.2f}")
    print()
    print(f"Dynamic bits : {ceil(log2(slow_cps))-floor(log2(fast_cps))}")
  
    step_abi_per_step_mot = 300 / (6*40//2)
    print(step_abi_per_step_mot * 4)