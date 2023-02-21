#ifndef H_DUT
#define H_DUT

#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vcore.h"

#include <memory>


class DUT
{
    static DUT _self;
    ~DUT();
    DUT();
    

    public:
        DUT(const DUT&) = delete;
        DUT& operator=(const DUT&) = delete;

        static DUT &get() noexcept {
            return _self;
        }
        void setup();
        void toggle_clock();
        void post_step();
        void trace(const int timestep);

        static void eval() {DUT::get().dut()->eval();};

        Vcore* dut();
    private:
        unsigned long int _sim_time;
        std::unique_ptr<Vcore> _dut;
        VerilatedFstC* _trace; // Should not be deleted

};

#endif // H_DUT