from math import log2

def estimate_operations(target : float, precision_rel : float, max_pow2 : int) :
    res = 0
    factors = list()
    for i in range(1,max_pow2) :
        val = 1/(2**i)
        if val + res > target :
            delta = abs(target - (val + res))
            delta_rel = 100*(delta/target)
            mark = "*" if delta_rel < precision_rel else " "

            print(f"Overflow value : {mark}{res:8.5f} delta abs {delta:8.5f} delta rel {delta_rel:7.3f}%",factors,i)
            continue
        else :
            res += val
            delta = abs(res-target )
            delta_rel = 100*(delta/target)
            mark = "*" if delta_rel < precision_rel else " "
            print(f"Valid    value : {mark}{res:8.5f} delta abs {delta:8.5f} delta rel {delta_rel:7.3f}%",factors,i)
            factors.append(i)



if __name__ == "__main__":
    estimate_operations(0.1,1,24)
    v = 0
    delta_abs = 0
    for t in range(1403,3031500*2) :
        val = (t >> 4) + (t >> 5) + (t >> 8) + (t >> 9)
        if (new_delta := abs(0.1-(val/t))) > delta_abs :
            v = t
            delta_abs = new_delta
        
    print(v,delta_abs,100*(delta_abs/0.1))
