[IMPORTANT]
> ** Commit [ad401a8](https://github.com/gazingstars123/Anima-Standalone-Trainer/commit/ad401a86f15a7064d5cd914d1c4886cb9dc73c9b) should help stabilize distributed training on Windows. If you're still facing issues and previous fixes did not help, try setting GLOO_SOCKET_IFNAME to different networking devices**

# Anima Standalone Trainer

A lightweight, decoupled training environment for circlestone-labs' Anima model, currently support Lora training only. Windows and Linux support. Built upon [sd-scripts](https://github.com/kohya-ss/sd-scripts) implementation.

<img width="2554" height="1234" alt="image" src="https://github.com/user-attachments/assets/cb5ff930-ce8c-49d6-a77a-3da393fe719d" />


## What's different in this fork (Estylon)

This fork is based on [gazingstars123/Anima-Standalone-Trainer](https://github.com/gazingstars123/Anima-Standalone-Trainer) and adds the following on top of upstream:

- **🗒️ Training queue.** Line up many LoRA jobs and let them run back-to-back on a single GPU. A **Queue** panel in the sidebar lets you add jobs (➕ on each job or "➕ Queue" in the editor), reorder them (▲▼), remove them, and Start/Pause the queue. When a job finishes successfully the next one starts automatically; if a job crashes or is stopped, the queue pauses so it doesn't chain failures.
- **🐍 Smart Python detection in setup.** `setup_env.bat` / `setup_env.sh` now auto-pick an installed, supported interpreter (tries 3.13 → 3.12 → 3.11 → 3.10) instead of relying on the default `python`. This makes setup work even when your default Python is 3.14+ (which has no `torch==2.7.0` wheels yet). The venv is created with the selected interpreter.
- **🚀 Desktop launcher + configurable port.** `Start_Anima_UI.bat` (repo root) starts the UI and opens the browser with one double-click. The UI now defaults to **port 3001** and accepts a port argument (`Start_Anima_UI.bat 3005`) to avoid clashing with other local apps.
- **✅ Clear model-path validation.** If the DiT / VAE / Qwen3 path is missing or wrong, training now fails fast with an actionable message (e.g. *"Anima DiT model not found at: …"*) instead of a cryptic loader error.
- **🔒 Web-server hardening.** Path-traversal protection on the sample/metadata file endpoints, input sanitization for FSDP class names, log-stream leak and crash-safety fixes in the training/generation processes, and `npm audit` vulnerabilities patched.
- **🧹 Repo cleanup.** Removed unreachable dead modules (the Hunyuan subgraph + unused SD3/Flux strategy shims) and corrected `library_audit.md` to reflect the real dependency graph.

> Everything below is the original upstream documentation and still applies.

## Prerequisites

- **Python 3.10+** (Python 3.12 recommended)
- **Node.js** (Required for the Web UI)
- **CUDA fitting your system** (CUDA 12.7+ recommended)

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/gazingstars123/Anima-Standalone-Trainer.git
cd Anima-Standalone-Trainer
```

### 2. Set up the environment

Run the provided setup script for your operating system:

**Windows:**
```powershell
.\setup_env.bat
```

**Linux:**
```bash
./setup_env.sh
```

*This will create a virtual environment (`venv`), install all Python dependencies (assuming you have met the prereqisites), and set up the Web UI.*

This script will probably install Torch and Torchvision version below.
Depends on your system, you may want to install another version of Pytorch with CUDA.

```cmd
pip install torch==2.7.0 torchvision==0.22.0 --index-url https://download.pytorch.org/whl/cu128
```

## Launching the UI

To start the training server and open the web interface:

**Windows:** double-click `Start_Anima_UI.bat` in the repo root (it starts the UI and opens the browser), or run:
```cmd
.\training-ui\start_training_ui_anima.bat
```

**Linux:**
```bash
./training-ui/start_linux.sh
```
Once launched, open your browser to: `http://localhost:3001` (this fork defaults to port 3001; pass another port as an argument, e.g. `Start_Anima_UI.bat 3005`).

## First Time Setup

After launching the UI for the first time, you'll need to configure your model paths:

1. Click the ** Global Settings** (gear icon) in the bottom-left corner
2. Set the following paths:
   - **DiT Model Path** — Path to your Anima DiT safetensors file (e.g. `C:\model\anima.safetensors`)
   - **VAE Path** — Path to the VAE model (e.g. `C:\model\qwen_image_vae.safetensors`)  
   - **TE Path** — Path to the CLIP text encoder (e.g. `C:\model\text_encoders\qwen_3_06b_base.safetensors`)
   - **Venv Path** - Path to your local venv, venv can be reused if you redownload the repo
3. Click **Save**

These paths are saved globally and shared across all training jobs.

## Release

**v2.0.0. Linux support, Multi-GPU inference**

**v1.1.0. Improving caching and others I/O performance.**

## Multi-GPU

Tested on torch2.7+cu128 and torch2.10+cu130 with [this fix](https://github.com/pytorch/pytorch/pull/175316) applied on Windows when encountered **libuv** error.

Seems to works best with torch<=2.3 and cuda <= 12.4 without directly applying the fix.

\**NEW\**

Adding support for multi-gpu inference

<img width="1052" height="848" alt="image" src="https://github.com/user-attachments/assets/54192c8f-1501-4a38-b745-3b26499aca5f" />


## Update

To update, simply run this command

```cmd
git pull
```

## Misc

Some features and settings from sd-scripts may not be available or working properly at the momment.

Built and tested on Windows 11, RTX 5080 + RTX 3090, 96GB DDR5, Python 3.12.1, CUDA 13.1, Pytorch 2.10 


