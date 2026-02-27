---
name: Proceed
description: Proceed with current workflow
---

# Proceed

Proceed with the current workflow. Clears any pending "Await /proceed" gate tasks and lets the
calling command continue.

After instructions & tasks loaded, you are free to 🚀 Engage thrusters

## Instructions

1. STOP, follow pre-flight instructions
   THEN, continue

2. 🔳 Clear gate tasks
   - Check `TaskList` for any "Await /proceed" tasks
   - Mark them completed
   - The calling workflow continues from where it left off

3. 🔳 Breakdown and create tasks as needed using `TaskCreate`

4. 🔳 Execute tasks one by one
