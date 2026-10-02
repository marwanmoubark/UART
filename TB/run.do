# ==============================================================================
# ModelSim / QuestaSim DO Script
# Path: D:\17_ElTemsah\final_system\TB\run.do
# ==============================================================================

# 1. Quit any active simulation and create a fresh working library
quit -sim
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# 2. Compile Design Source Files
# --- ALU Subsystem ---

vlog ../*/*.*v


# 3. Optimize and Load Simulation
# Using +acc for full visibility of signals during waveform viewing
vsim -voptargs="+acc" work.sys_top_tb

# 4. Add Signals to Waveform Window
do wave.do
# 5. Run Simulation
run -all

# Zoom full on the waveform