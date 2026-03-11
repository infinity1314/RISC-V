-makelib xcelium_lib/xil_defaultlib -sv \
  "G:/vivado2019.1/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "G:/vivado2019.1/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../CPU_Top.srcs/sources_1/ip/PLL/PLL_clk_wiz.v" \
  "../../../../CPU_Top.srcs/sources_1/ip/PLL/PLL.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

