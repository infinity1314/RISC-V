Coach_pipeline 目录说明
========================

与 Coach/ 同步的多周期 RISC-V 文件（根目录）
---------------------------------------------
  riscv.v          — 多周期顶层，例化 IM、RF、DM、ControlUnit、PC、NPC 等
  IM.v DM.v RF.v ALU.v PC.v NPC.v IR.v Flopr.v EXT.v MUX_*.v ControlUnit.v
  includes/        — instruction_def.v、ctrl_signal_def.v、global_def.v

流水线扩展（本目录 pipeline/）
----------------------------
  riscv_pipeline.v — 五级流水线顶层，例化上级 IM.v + pipeline 内各段
  pl_ALU.v         — 流水线 ALU（与 Coach ALU.v 区分，勿重名）
  pl_regfile.v     — 流水线寄存器堆（与 Coach RF.v 区分）
  IF IF_ID ID ID_EX EX MEM WB ctrl EX_MEM MEM_WB dmem — 流水段与数据 RAM

编译示例（在 Coach_pipeline 目录下，iverilog，一行即可）：
  iverilog -g2012 -I includes -I pipeline -o sim_pl.vvp pipeline/riscv_pipeline.v IM.v pipeline/IF.v pipeline/IF_ID.v pipeline/ID.v pipeline/ID_EX.v pipeline/EX.v pipeline/pl_ALU.v pipeline/MEM.v pipeline/dmem.v pipeline/EX_MEM.v pipeline/MEM_WB.v pipeline/WB.v pipeline/ctrl.v pipeline/pl_regfile.v

多周期仿真（根目录）示例：
  iverilog -g2012 -I includes -o sim_mc.vvp riscv.v IM.v DM.v RF.v ALU.v PC.v NPC.v IR.v Flopr.v EXT.v MUX_2to1_A.v MUX_3to1.v MUX_3to1_B.v MUX_3to1_LMD.v ControlUnit.v
