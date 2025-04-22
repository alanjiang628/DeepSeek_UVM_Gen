`ifndef __ENUM_PKG_SV__
`define __ENUM_PKG_SV__

package enum_pkg;
    typedef enum bit [1:0] {
		RESET_GLITCH =0,    // 复位毛刺
   		CLOCK_GLITCH =1,    // 时钟抖动
   		DATA_GLITCH =2,     // 数据异常
   		POWER_DROP =3      // 电源跌落
    } glitch_type_e;

	typedef enum {
		SETUP_VIOL,
		HOLD_VIOL
	} violation_type;

endpackage

`endif