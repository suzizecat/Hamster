from math import log2

def estimate_operations(target : float, precision_rel : float, max_pow2 : int) :
    res = 0
    factors = list()
    saved_factors = list()
    saved_res=0
    saved_delta=0
    saved_delta_rel=0
    print(f"Finding factor tool.")
    print(f"Target is {target:10.8f} within a precision of {precision_rel:5.2f}% and a max shift of {max_pow2}.")
    print(f"{'':-^80s}")
    for i in range(1,max_pow2) :
        val = 1/(2**i)
        if val + res > target :
            delta = abs(target - (val + res))
            delta_rel = 100*(delta/target)
            mark = "*" if delta_rel < precision_rel else " "

            print(f"Overflow value : {mark}{val +res:8.5f} delta abs {delta:8.5f} delta rel {delta_rel:8.3f}%",factors,i)
            continue
        else :
            res += val
            delta = abs(res-target )
            delta_rel = 100*(delta/target)
            if delta_rel < precision_rel :

                if saved_res == 0 :
                    saved_factors = factors + [i]
                    saved_res = res
                    saved_delta = delta
                    saved_delta_rel = delta_rel
                    mark = "#"
                else :
                    mark = "*"
                if res == target :
                    mark = "="
                    break
            else :
                mark = " "
            print(f"Valid    value : {mark}{res:8.5f} delta abs {delta:8.5f} delta rel {delta_rel:8.3f}%",factors,i)
            factors.append(i)
    
    print(f"{'':-^80s}")
    print(f"Suggested factors are {saved_factors!r} = {saved_res:8.5f} delta abs {saved_delta:8.5f} delta rel {saved_delta_rel:7.3f}%")

def rounded_factor(v,factors,roundbits = None) :
    if roundbits is None :
        roundbits = min(factors)
    if roundbits > 0 :
        temp_v = v << roundbits
    else :
        temp_v = v
    divided = sum([temp_v >> f for f in factors])
    if roundbits <= 0 :
        return divided
    round_plus = 1 if divided & 1 << (roundbits-1) else 0
    return (divided >> roundbits) + round_plus


if __name__ == "__main__":
    target = 1/44
    estimate_operations(target,1,18)
    v = 0
    delta_abs = 0
    max_delta = 0
    factors = [6, 8, 9, 10, 12]
    for t in range(43,4200*10) :
        val = rounded_factor(t,factors,3) +1
        #sum([t >> f for f in factors])
        new_delta = abs(target-(val/t))
        
        if val != (expected_value := round(t/44)) :
            v = t
            delta_abs = new_delta
            nval = val
            if(abs(val-expected_value) > 1) :
                print(f"{v:6d} {nval:4d} (exp {expected_value:6d}) Delta = {delta_abs:8.6f} ({delta_abs/target:7.2%})")
        max_delta = max(max_delta,new_delta)
    print(f"Worst delta is {max_delta:8.6f} ({max_delta/target:%})")