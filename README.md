# **Cura G-code Fan Fix for Non-Bundled 3D Printers**

A **Bash script** that modifies Cura-generated G-code to correctly control **multiple cooling fans**. Designed for **3D printers without an official Cura profile**, such as **custom Marlin, Klipper, and RepRap setups**.

The script scans `.gcode` files in a folder and **duplicates or adjusts M106 fan speed commands**, applying custom multipliers where needed.

---

## **Features**

- ✅ **Supports multiple fans (`P1, P2, etc.`)** and updates them only if needed.
- ✅ **Applies fan speed multipliers** (e.g., reduce or increase cooling power).
- ✅ **Prevents duplicate fan commands** – updates existing `M106 P{N}` instead of appending.
- ✅ **Creates a `.bak` backup** of the original file before modifications.
- ✅ **Works on Linux, macOS, and Windows (WSL, Git Bash)**.
- ✅ **Dry-run mode (`--dry-run`)** to preview changes without modifying files.
- ✅ **Logging (`-l log.txt`)** to keep track of processed files.
- ✅ **No dependencies** – runs as a simple script.

---

## **Installation**

No installation required. Just download and run the script.

### **1. Download the script**
```bash
curl -O https://raw.githubusercontent.com/magiodev/cura-gcode-fan-fix/main/cura_gcode_fan_fix.sh
chmod +x cura_gcode_fan_fix.sh
```

### **2. Place it in your G-code folder**
Move the script to the directory where your `.gcode` files are stored.

### **3. Run it**
By default, it **clones the M106 command to `P1` at the same speed**:
```bash
./cura_gcode_fan_fix.sh
```

---

## **Usage Examples**

### **Modify Specific Fans (`-p`)**
Choose which fans (`P1, P2, P3`) to modify:
```bash
./cura_gcode_fan_fix.sh -p 1,2
```

### **Adjust Fan Speed (`-m`)**
Apply multipliers to adjust fan speed:
```bash
./cura_gcode_fan_fix.sh -p 1,2 -m 0.8,1.2
```
This sets `P1` to **80% speed** and `P2` to **120% speed**.

### **Prevent Backups (`--no-backup`)**
Skip creating `.bak` files:
```bash
./cura_gcode_fan_fix.sh --no-backup
```

### **Dry-Run Mode (`--dry-run`)**
Preview changes before applying:
```bash
./cura_gcode_fan_fix.sh -p 1,2 -m 1.2,1.5 --dry-run
```

### **Save Log to a File (`-l log.txt`)**
```bash
./cura_gcode_fan_fix.sh -p 1,2 -m 1.2,1.5 -l log.txt
```

---

## **Example Output**

#### **Input G-code**
```gcode
M106 S150
```

#### **After running the script**
```gcode
M106 S150
M106 P1 S120  ; 80% speed
M106 P2 S180  ; 120% speed
```

#### **Re-running the script does not duplicate fans**
```gcode
M106 S150
M106 P1 S120  ; 80% speed (unchanged)
M106 P2 S180  ; 120% speed (unchanged)
```

---

## **FAQ**

### **1. Does this work on Windows?**
Yes, via **Git Bash** or **WSL**.

### **2. What happens if I don’t specify `-p` or `-m`?**
It defaults to modifying **P1 with a 1.0 multiplier**.

### **3. Does this overwrite my original G-code files?**
Yes, but a **backup is created (`.bak`) before modification**. Use `--no-backup` to disable.

### **4. How do I check what will be modified before running it?**
Use **`--dry-run`** to preview changes without modifying any files.

### **5. How do I track which files were modified?**
Use the `-l log.txt` option to create a log file.

---

## **Contributing**
Fork the repo and submit a pull request for improvements.

## **License**
MIT License.

This script is open-source and designed for improving Cura-generated G-code fan handling.