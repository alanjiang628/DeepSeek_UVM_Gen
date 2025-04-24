`ifndef __SIGNAL_CONDITIONER_IF_SV__
`define __SIGNAL_CONDITIONER_IF_SV__
interface signal_conditioner_if(input bit clk);

    logic reset_n;
    logic noisy_in;
    logic clean_out;

    clocking drv_cb @(posedge clk);
        output reset_n, noisy_in;
        input  clean_out;
    endclocking

    modport DRV  (clocking drv_cb);
    modport MON  (input clk, reset_n, noisy_in, clean_out);
endinterface

`endif