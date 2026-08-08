# INT8 Matrix-Multiply Accelerator

A small **SystemVerilog hardware accelerator for INT8 matrix multiplication** using a **systolic array**.

The basic idea:

```text
Normal approach:

A × B
  ↓
Do multiplication
  ↓
Do another multiplication
  ↓
Do another...
  ↓
Eventually get C
```

Instead, this project builds a group of small Processing Elements (PEs) that work **at the same time**:

```text
             Data flows →
        ┌─────┐   ┌─────┐   ┌─────┐
Data →  │ PE  │ → │ PE  │ → │ PE  │
        └─────┘   └─────┘   └─────┘
           ↓         ↓         ↓
        ┌─────┐   ┌─────┐   ┌─────┐
        │ PE  │ → │ PE  │ → │ PE  │
        └─────┘   └─────┘   └─────┘
           ↓         ↓         ↓
        ┌─────┐   ┌─────┐   ┌─────┐
        │ PE  │ → │ PE  │ → │ PE  │
        └─────┘   └─────┘   └─────┘
```

Think of each PE as a tiny worker:

```text
        A ─────┐
               ▼
            ┌─────┐
        B → │  ×  │
            └──┬──┘
               │
               ▼
            ┌─────┐
            │  +  │ ← Accumulator
            └──┬──┘
               │
               ▼
          Pass data onward
```

Each PE repeatedly performs:

```text
accumulator = accumulator + (A × B)
```

So instead of one worker doing everything, many workers are doing their part simultaneously.

## How the pieces fit

```text
       Matrix A                    Matrix B
           │                          │
           ▼                          ▼
     ┌───────────┐              ┌───────────┐
     │   Buffer  │              │   Buffer  │
     └─────┬─────┘              └─────┬─────┘
           │                          │
           └──────────┬───────────────┘
                      ▼
              ┌───────────────┐
              │ Systolic Array│
              │               │
              │ PE PE PE PE   │
              │ PE PE PE PE   │
              │ PE PE PE PE   │
              │ PE PE PE PE   │
              └───────┬───────┘
                      │
                      ▼
                   Result
```

The main RTL blocks are:

```text
Multiplier
     ↓
Accumulator
     ↓
    MAC
     ↓
     PE
     ↓
Systolic Array
     ↓
Matrix Buffer + Controller
     ↓
Top-Level Accelerator
```

The **controller** is the traffic cop. It controls when the matrices are loaded, when computation starts, and when the array has finished producing its results.

```text
IDLE
  ↓
LOAD
  ↓
COMPUTE
  ↓
DRAIN
  ↓
FINISH
```

The result is a compact RTL implementation of **INT8 matrix multiplication using parallel MAC units and a systolic dataflow architecture**.
