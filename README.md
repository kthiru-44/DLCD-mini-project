# Systolic Array Matrix Multiplication Engine (2x2)

A modular, beginner-friendly Verilog implementation of a **2x2 Systolic Array Matrix Multiplication Engine** designed for Digital Logic & Circuit Design (DLCD) course mini-project.

---

## 📌 Project Overview

A **Systolic Array** is an architecture consisting of a network of coupled data processing units called **Processing Elements (PEs)**. Data is pumped rhythmically through the array, similar to blood being pumped by the heart (systole):
- **Matrix A** inputs enter from the left and propagate horizontally.
- **Matrix B** inputs enter from the top and propagate vertically.
- Each PE executes a **Multiply-Accumulate (MAC)** operation:
  $$\text{ACC} \leftarrow \text{ACC} + (A \times B)$$

This architecture minimizes memory access bottlenecks by reusing data locally among neighboring PEs, which forms the hardware foundation for Google TPUs and modern AI accelerators.

---

## 📐 Architecture & Block Diagram

```text
                  Col 0 (B)        Col 1 (B)
                      │                │
                      ▼                ▼
Row 0 (A) ───► ┌─────────────┐ ───► ┌─────────────┐
               │    PE00     │      │    PE01     │
               └─────────────┘      └─────────────┘
                      │                    │
                      ▼                    ▼
Row 1 (A) ───► ┌─────────────┐ ───► ┌─────────────┐
               │    PE10     │      │    PE11     │
               └─────────────┘      └─────────────┘
```

### Processing Element (PE)
Each PE contains:
- Multiplier ($A \times B$)
- Accumulator register ($C \leftarrow C + A \times B$)
- Horizontal forwarding register ($A_{\text{out}} \leftarrow A_{\text{in}}$)
- Vertical forwarding register ($B_{\text{out}} \leftarrow B_{\text{in}}$)

---

## ⏱️ Cycle-by-Cycle Timing Flow

For multiplying:
$$A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}, \quad B = \begin{bmatrix} 5 & 6 \\ 7 & 8 \end{bmatrix} \implies C = \begin{bmatrix} 19 & 22 \\ 43 & 50 \end{bmatrix}$$

Because data takes 1 clock cycle to travel between neighboring PEs, row 1 of $A$ and column 1 of $B$ are **staggered (delayed by 1 cycle)**:

| Clock Cycle | Row 0 ($A$) | Row 1 ($A$) | Col 0 ($B$) | Col 1 ($B$) | What PEs Compute |
|:---:|:---:|:---:|:---:|:---:|---|
| **Cycle 1** | $a_{00} = 1$ | $0$ (skew) | $b_{00} = 5$ | $0$ (skew) | `PE00` computes: $1 \times 5 = 5$ |
| **Cycle 2** | $a_{01} = 2$ | $a_{10} = 3$ | $b_{10} = 7$ | $b_{01} = 6$ | `PE00` completes $5 + (2 \times 7) = \mathbf{19}$<br>`PE01` computes $1 \times 6 = 6$<br>`PE10` computes $3 \times 5 = 15$ |
| **Cycle 3** | $0$ | $a_{11} = 4$ | $0$ | $b_{11} = 8$ | `PE01` completes $6 + (2 \times 8) = \mathbf{22}$<br>`PE10` completes $15 + (4 \times 7) = \mathbf{43}$<br>`PE11` computes $3 \times 6 = 18$ |
| **Cycle 4** | $0$ | $0$ | $0$ | $0$ | `PE11` completes $18 + (4 \times 8) = \mathbf{50}$ |

At the end of Cycle 4, Matrix $C$ contains $\begin{bmatrix} 19 & 22 \\ 43 & 50 \end{bmatrix}$.

---

## 📂 Repository Structure

- [`pe.v`](pe.v): Processing Element module (MAC + pipeline registers).
- [`systolic_array_2x2.v`](systolic_array_2x2.v): Top-level 2x2 array connecting four PEs.
- [`tb_systolic_array_2x2.v`](tb_systolic_array_2x2.v): Self-checking testbench with waveform dumping.

---

## 🚀 How to Simulate

### Option 1: Using Icarus Verilog (`iverilog`)
Compile and run the testbench in bash:
```bash
iverilog -o sim_systolic pe.v systolic_array_2x2.v tb_systolic_array_2x2.v
vvp sim_systolic
```

View the generated waveform in GTKWave:
```bash
gtkwave systolic_array.vcd
```

### Option 2: Using QuestaSim / ModelSim
In the QuestaSim GUI or Transcript terminal:
```tcl
vlib work
vlog pe.v systolic_array_2x2.v tb_systolic_array_2x2.v
vsim tb_systolic_array_2x2
add wave -r /*
run -all
```

---

## 📊 Verification Result

```text
-----------------------------------------------------
Matrix A = [ [1, 2], [3, 4] ]
Matrix B = [ [5, 6], [7, 8] ]
-----------------------------------------------------
Result Matrix C:
[ 19  22 ]
[ 43  50 ]
-----------------------------------------------------
TEST PASSED: Output matches theoretical result perfectly!
-----------------------------------------------------
```
