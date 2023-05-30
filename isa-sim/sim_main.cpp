#include <memory>
#include <verilated.h>
#include "Vtop.h"

int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);
    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};

    // Set Vtop's input signals
    top->reset = 0;
    top->clk = 0;
    
    while (!contextp->gotFinish()) {
        top->clk = !top->clk;
        if (!top->clk) {
            if (contextp->time() > 0*50 && contextp->time() < 9*50) {
                top->reset = 1;  // Assert reset
            } else {
                top->reset = 0;  // Deassert reset
            }
        }
        top->eval();

        contextp->timeInc(50);
    }

    // Final model cleanup
    top->final();

    return 0;
}
