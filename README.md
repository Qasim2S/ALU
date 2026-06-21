# Arithmetic Logic Unit (ALU)

## Overview

The Arithmetic Logic Unit (ALU) is a fundamental component of a processor that performs arithmetic and logical operations.

## Features

The ALU supports the following operations:
- Signed addition, subtraction, and multiplication
- Multiply-Accumulator
- Bitwise XNOR
- ReLU
- Mean
- Absolute Max

The ALU receives instruction and data inputs and produces three outputs: the resulting data, a valid signal, and an overflow signal.

The valid signal is asserted high for one clock cycle when the output result is valid.

The overflow signal is asserted when the result exceeds the representable range of the output data type.