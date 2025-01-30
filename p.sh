#!/bin/bash

iverilog -o dsn proc_tb.v proc.v
vvp dsn
gtkwave proc_tb.vcd &
