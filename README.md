# 🔧 Klipper Toolhead Service & Nozzle-Change Macros

This repository provides a set of Klipper macros that automate and
simplify common 3D-printer maintenance tasks, including nozzle changes,
cold swaps, and general toolhead servicing. The macros park the toolhead
front-and-center for easy access, guide the user through each step with
on-screen prompts, movement, retraction, LED control, and
heater management automatically.

## ✨ Features

-   **One-click toolhead servicing**
    Automatically homes the printer, lifts Z, and parks the hotend in an
    ideal service position.

-   **Fully guided workflow**
    Integrated UI prompts walk the user through each step of swapping or
    servicing a nozzle.

-   **Safe & consistent nozzle changes**
    Supports both **hot nozzle swaps** and **cold swaps**, depending on
    your workflow.
    
-   **LED support**
    -  Led_Effects Support for RGB and Neopixel Lighting
       Repo Used : https://github.com/julianschill/klipper-led_effect/tree/master

## 🧩 Macro Overview

### Service_Position

Prepares the printer for maintenance:
- Homing if its gotta
- Moves Toolhead to service position
- Filament retraction
- Displays start prompts

### Nozzle Swap

A fully guided hot-nozzle change:
- Prompts user to heat, loosen, and install new nozzle
- Optioinal extra extrusion or retraction for flushing

If using a cold swap nozzle:
- Uses machine partcooling fans to assist with cooldown 
- Prompts user to change nozzle after minium temp is reached


## ⚙️ Configuration

All user-adjustable settings are stored in:

    ServiceSettings.cfg

## 🧩 ServiceSettings.cfg --- Variable Reference Table

  --------------------------------------------------------------------------
  **Setting**                      **Description**
  -------------------------------- -----------------------------------------

  `Retract_Distance `              How far the filament is retracted in MM
                                   

  `Retract_Temp`                   Temperature used for retracting filament
                                   from the melt zone.

  `Nozzle_Swap_temp`               Temperature used for tightening a new
                                   nozzle during a hot swap.

  `Cold_Swap_Hotend`               Enables if using a  cold-nozzle replacement
                                   hotend. (ie. Revo...)

  `Cold_Swap_Temp`                 Automatically cools down to this temp for
                                   cold swap if enabled.

  `Leds`                           Enables LED color changes during service
                                   routines using this plugin and Macros:
                                   https://github.com/julianschill/klipper-led_effect/tree/master

  --------------------------------------------------------------------------

## 📥 Installation

1.  Copy both `.cfg` files into your Klipper configuration folder.
2.  Add the following include lines to your `printer.cfg`:

```
    [include ServiceSettings.cfg]
    [include ServiceMacros.cfg]
```
3.  Restart Klipper.
4.  Set Up Config in ServiceSettings.cfg
5.  Run macro from the UI 'Service_Position"

## 🙌 Contributions

Pull requests and improvements are welcome.
