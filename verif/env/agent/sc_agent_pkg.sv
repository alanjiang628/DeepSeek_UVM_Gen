`ifndef __SC_AGENT_PKG_SV__
`define __SC_AGENT_PKG_SV__
`include "enum_pkg.sv"
package sc_agent_pkg;
  import uvm_pkg::*;
  import enum_pkg::*;
  `include "sc_transaction.sv"  // 事务类需先编译
  `include "sc_driver.sv"
  `include "sc_monitor.sv"
  `include "sc_sequencer.sv"
  `include "sc_agent.sv"       // Agent最后编译
endpackage
`endif