
# 📘 **Klipper Service Macros**
A streamlined toolhead service suite for Klipper—making nozzle changes, diagnostics, and maintenance simple, guided, and safe through the Mainsail/Fluidd interface.

This macro package provides a clean, menu-driven maintenance system with automated filament handling, temperature management, diagnostic tests, and optional dockable probe support.

---

# V2.0.0 Beta Notes

- Complete revamp and feature update from V1.0.0
- added features
    - Checks Menu (stable and operational)
    - Probe Test (stable and operational)
    - Wiggle Test (stable and operational)
    - Fan Test (stable and operational)
    - Heater Test (still in early development)
    - Heatbreak Test (still in early development)
- File structure revised and broken into a total of 5 files (4 macro files in a folder and 1 user settings file)
- Focusing on a univeral code that supports as many printer set ups as possible while keeping it simple enough that anyone can use it
- Maintaining a simple install process to reduce install errors for all users

  *USE AT YOUR OWN RISK*

---

# 🚀 **Features**

### 🛠️ **Service Menu**
Running `SERVICE_POSITION` places the toolhead in an accessible position and presents a unified maintenance menu:

<img width="428" height="242" alt="Service Menu" src="https://github.com/user-attachments/assets/fddd02d1-776f-4fd0-87d6-7a65678e172e" />

- **Nozzle Change**  
- **Toolhead Checks**  
- **Return to Last Position**
- **Exit**

---

### 🔧 **Nozzle Change**
Supports both **hot-swap** and **cold-swap** hotends.

Includes:

- Automatic heating to configured temperatures  
- Automatic filament retraction  
- Cooling cycle for cold-swap systems  
- LED feedback  
- Optional automatic probe repeatability test after swap  
- Clean UI prompt to confirm swap completion  
- Automatic return to Service Menu

---

### 🧪 **Checks Menu**

A collection of diagnostic tools to verify printer health:

<img width="420" height="243" alt="Checks Menu" src="https://github.com/user-attachments/assets/7d05dd3c-d518-4cda-bb3f-71651dc9d0ea" />


#### ✔ **Fan Test**
- Multi-stage fan ramp (0 → 30% → 60% → 100% → down again)  
- Clear console feedback + confirmation prompt  

#### ✔ **Probe Repeatability Test**
- Dockable probe attach/detach support  
- Console-only output (no UI prompt)  
- Reports:
  - Each probe sample  
  - Min / Max  
  - Average  
  - ΔZ deviation  
- Automatically returns to the Checks Menu

#### ✔ **Wiggle Test**
High-speed mechanical oscillation using **machine max velocity & accel**.

- Moves to center  
- Applies max speed feedrate  
- Runs 10 X-axis cycles and 10 Y-axis cycles  
- Restores motion limits after test  
- Returns to the service position  
- Popup confirms completion

Perfect for detecting:
- Loose belts  
- Bearing noise  
- Frame resonance

#### ✔ **Heater Test**
- Heats to 200°C  
- Stabilizes briefly  
- Turns off  
- Lets the user review thermal behavior  

#### ✔ **Heatbreak Cooling Test**
- Tests heatsink effectiveness  
- “Fan-off soak” followed by forced cooldown  
- Useful for diagnosing underperforming cooling systems

---

# 📥 Installation

You can install Klipper-Service-Macros with this SSH command:

```
cd ~
curl -fsSL https://raw.githubusercontent.com/Herculez3D/Klipper-Service-Macros/V2.0.0-Beta/service_macros_installer.sh -o service_macros_installer.sh
chmod +x service_macros_installer.sh
bash ./service_macros_installer.sh install

```

Running this command will automatically install all files along with adding update manager to your `moonraker.conf`

Add `[include ServiceSettings.cfg]` to your `printer.cfg`

---

### 🔄 Updating

### Via Mainsail:
**Machine → Updates → Klipper-Service-Macros → Update**

#### Via SSH:
```
bash ~/service_macros_installer.sh update
```

Your custom settings remain preserved, and any new options are added automatically.

---

### ❌ Uninstall

#### Via SSH:
```
bash ~/service_macros_installer.sh uninstall
```

This removes:
  
- The cloned repository  
- The `update_manager` entry in Moonraker  

Your user settings file is backed up and preserved.

---

# 🗂️ **Folder Structure**

```
printer.cfg
└── ServiceSettings.cfg     ← User-editable settings file

config/ServiceMacros/
    ├── Service_Main.cfg      ← Service menu + positioning logic
    ├── Service_Probe.cfg     ← Probe & dockable probe handling
    ├── Service_Checks.cfg    ← Diagnostics suite (fans, wiggle, heater tests)
    └── Service_Nozzle.cfg    ← Hot & cold nozzle change workflows
```

---

# 📘 ServiceSettings.cfg — User Configuration Guide

The `ServiceSettings.cfg` file is the **only configuration file users should edit** in the Klipper Service Macros package.  
All other macro files inside `config/ServiceMacros/` are internal logic modules and should not be modified.

This guide explains every available setting, recommended values, and how the Service Macros system uses them.

---

# ⚙️ Purpose of ServiceSettings.cfg

This file centralizes all user-configurable behavior:

- Movement speeds  
- Nozzle change behavior  
- Filament handling  
- Probe repeatability test options  
- LED feedback  
- Dockable probe support  
- Auto-probe after nozzle swap  

By consolidating settings here, the macro suite can be updated or reinstalled safely without overwriting user configurations.

---

# 🔧 Toolhead / Filament Handling Settings

| Variable | Description |
|---------|-------------|
| `variable_retract_distance` | Filament retract/extrude distance (mm) during service actions. |
| `variable_retract_temp` | Temperature used to soften filament for reliable retraction. |
| `variable_nozzle_swap_temp` | Temperature used for **hot-swap** nozzle changes. |
| `variable_cold_swap_hotend` | Enables **cold-swap** workflow (e.g., Revo nozzles). |
| `variable_cold_swap_temp` | Temperature before a cold nozzle can be safely removed. |

---

# 🌈 LED Feedback

| Variable | Description |
|---------|-------------|
| `variable_leds` | Enables LED status effects for heating, cooling, completion, etc. |

When enabled, the macros use LED cues to indicate machine state during maintenance operations.

---

# 🧲 Dockable Probe Support

| Variable | Description |
|---------|-------------|
| `variable_dockable_probe` | Enables auto attach/detach logic for Klicky, Euclid, etc. |
| `variable_attach_probe` | Custom G-code for attaching the probe. |
| `variable_detach_probe` | Custom G-code for detaching the probe. |

If you use a dockable probe, add the correct attach/detach commands here.

---

# 🤖 Auto-Probe After Nozzle Change

| Variable | Description |
|---------|-------------|
| `variable_autoprobe_after_nozzle_change` | Runs a probe repeatability test automatically after completing a nozzle swap. |

The nozzle menu closes before the test runs, and the printer returns to the Service Menu after completion.

---

# 🏃 Movement Speed Settings (mm/s)

Used during **positioning**, **service movement**, and **post-test returns**.  
These do **not** affect the Wiggle Test, which always uses machine max speed/accel.

| Variable | Description |
|---------|-------------|
| `variable_move_speed_x` | X-axis service movement speed. |
| `variable_move_speed_y` | Y-axis service movement speed. |
| `variable_move_speed_z` | Z-axis service movement speed. |

These values are converted internally to mm/min for use with G-code `F` feedrate commands.

---

# 📏 Probe Repeatability Test Configuration

| Variable | Description |
|---------|-------------|
| `variable_probe_samples` | Number of probe samples taken during `_PROBE_TEST`. |

The test outputs:

- Each measurement  
- Average  
- Minimum  
- Maximum  
- Deviation (ΔZ)  
- All values printed to 4 decimal places  

---

# 🛡️ **Safety Features**

- Smart homing  
- Heater shutdown after nozzle swap (when applicable)  
- Temperature-based gating for safe nozzle swaps  
- Dockable probe validation  
- State saving + restoration  
- LEDs for visual feedback   
- All diagnostic tests return to safe positions automatically  

---

# Smart Homing
```
_Smart_Homing
```
- Can be used in place of other G28 commands in other macros.
- A quick "home the machine if it hasnt been" script

---

## 🙌 Contributions

Pull requests and improvements are welcome.

