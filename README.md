# **README — Windows Pro Mode Ultimate Script**

## **Purpose**

This script configures Windows to behave like a **reliable professional workstation** instead of a **consumer-targeted device**.

Windows ships with:

* Preinstalled promotional apps (bloatware)
* Advertising and “suggested” content in the Start menu and lock screen
* Microsoft cloud account nudging and OneDrive pre-integration
* Bing + web search results in the local Search menu
* Automatic updates that may reboot without warning

These defaults are useful for brand-new or casual users, but they create **friction** for people who work seriously in Windows:

* Developers
* Power users
* Engineers
* IT maintainers
* Users moving from macOS or Linux expecting coherent tooling

The goal of this script is to provide a **predictable, quiet, local-first Windows environment** that does not interrupt work or re-install software you removed.

---

## **What This Script Does**

### **1. Permanently Removes Bloatware**

Windows normally re-installs promotional apps during updates or new user sign-ins.
This script removes:

* Installed apps
* **And** the *provisioned* copies hidden in the system base image

This stops bloat from returning **even after major Windows updates**.

### **2. Disables Consumer Experience / Advertising System**

Windows contains a system that restores apps and pushes promotional tiles.
This script turns that system **off**, so:

* No Start menu ads
* No “recommended” installs
* No Microsoft promotional banners

Windows stops trying to market software to you.

### **3. Removes OneDrive and Prevents It From Reinstalling**

If you don’t want OneDrive:

* The client is removed
* Leftover folders are deleted
* Group Policy prevents it from reinstalling

Local file usage becomes clean and predictable.

### **4. Disables Bing and Web Search in Start**

This makes Search:

* Faster
* Private
* Local-first
* Not dependent on online queries

This prevents “web suggestions” and “shopping results” from appearing when searching for files.

### **5. Minimizes Telemetry (as far as allowed on Windows Home/Pro)**

Telemetry is reduced to its **lowest officially supported level** without breaking activation or Windows Update.

### **6. Stops Forced Update Reboots**

Updates are set to:

* **Notify before downloading**
* **Never reboot automatically**

The system no longer interrupts work or restarts unexpectedly.

### **7. Installs and Enables Real Command-Line Tools**

The script installs:

* Windows Terminal
* Git
* OpenSSH
* Updated PowerShell

This provides a dependable, modern CLI environment similar to macOS or Linux setups, without needing manual setup.

---

## **What This Script Does *Not* Do**

* It does **not** break Windows Update.
* It does **not** disable security protections.
* It does **not** modify the kernel or system integrity.
* It does **not** reduce stability.
* It does **not** remove features needed by most organizations.

This is a **safe, reversible configuration**, not a “registry delete smash-hammer.”

---

## **Intended Audience**

This configuration is beneficial for users who:

* Prefer local control over cloud defaults
* Want a clean, distraction-free desktop
* Do development or system administration
* Want predictable system behavior
* Do not want advertising embedded into the OS

If your workflow is:

* Programming
* Creative production
* Engineering
* Terminal-driven computing
* System maintenance
  then this configuration aligns well with your needs.

---

## **Summary**

This script transforms Windows into what many users *assume* a “Pro” edition should provide out of the box:

| Before                             | After                                    |
| ---------------------------------- | ---------------------------------------- |
| Promotional apps & suggestions     | Clean, stable desktop                    |
| Web search mixed into local search | Local, fast, predictable search          |
| Automatic update interruptions     | User-scheduled updates only              |
| OneDrive forced integration        | Local-only file control                  |
| Inconsistent command line tools    | Modern and complete terminal environment |

This is not about *hacking* Windows.
It is about **letting Windows respect the person using it**.

