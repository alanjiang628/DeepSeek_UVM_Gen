`ifndef __SC_SEQ_PKG_SV__
`define __SC_SEQ_PKG_SV__

package sc_seq_pkg;
    import uvm_pkg::*;
    import sc_env_pkg::*;
	import enum_pkg::*;

    `include "base_sequence.sv"
    `include "reset_sequence.sv"
	//`include "timing_sequence.sv"
	`include "debounce_sequence.sv"
	//`include "glitch_sequence.sv"

endpackage

`endif    