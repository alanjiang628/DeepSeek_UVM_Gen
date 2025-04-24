`ifndef __SC_ENV_PKG_SV__
`define __SC_ENV_PKG_SV__
`include "sva_lib.sv"
`include "sc_agent_pkg.sv"
package sc_env_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import sc_agent_pkg::*; 
	import enum_pkg::*;
	`include "sc_config.sv"
    `include "sc_scoreboard.sv"
	`include "sc_coverage.sv"
    `include "sc_env.sv"
endpackage

`endif