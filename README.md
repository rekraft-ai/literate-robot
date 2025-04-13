# ComfyUI Provisioning Scripts

This repository contains provisioning scripts for setting up ComfyUI models and custom nodes. These scripts are designed to work with RunPod deployments and ComfyUI installations.

Script to fulfil the post-start provisioning of the ComfyUI nodes and models. Use the path of these scripts as the values for the following environment variables on the Docker image:

* CUSTOM_NODES_SCRIPT_URL
* MODELS_SCRIPT_URL
* ADDITIONAL_MODELS_SCRIPT_URL

## Scripts

### install_models.sh
Installs base models into a cache directory on the network volume. These models persist between container restarts.

Normally, the script should download models into a location (network volume?) that has been mention in the `extra_model_paths.yml` of the RunPod docker image.

**Parameters:**
- `COMFYUI_MODELS_CACHE_DIR` (optional): Path to the cache directory (default: `/workspace/ComfyUI-models-cache`)

**Installs:**
- Checkpoint models (SDXL and SD1.5)
- UNET models
- LoRA models
- ControlNet models
- VAE models
- Upscale models
- ESRGAN models
- CLIP Vision models
- Config files
- Embeddings

### install_additional_models.sh
Installs additional models into the main ComfyUI directory. These models are downloaded fresh on each container start.

**Parameters:**
- `COMFYUI_MODELS_MAIN_DIR` (optional): Path to the main ComfyUI directory (default: `/ComfyUI`)

**Installs:**
- InstantID models
- PuLID models
- IPAdapter models

### install_custom_nodes.sh
Installs and updates custom ComfyUI nodes into the main ComfyUI directory. These nodes are downloaded fresh on each container start.

**Parameters:**
- `COMFYUI_DIR` (optional): Path to the ComfyUI directory (default: `/ComfyUI`)
- `AUTO_UPDATE` (optional): Set to "false" to disable automatic updates (default: enabled)

**Installs:**
- ComfyUI Manager
- ComfyUI Essentials
- rgthree-comfy
- Efficiency Nodes
- ControlNet Aux
- InstantID nodes
- IPAdapter Plus nodes
- And more...

## Usage

1. Clone this repository
2. Make the scripts executable:
   ```bash
   chmod +x *.sh
   ```
3. Run the installation scripts in order:
   ```bash
   # Install base models (persistent)
   ./install_models.sh [COMFYUI_MODELS_CACHE_DIR]
   
   # Install additional models (non-persistent)
   ./install_additional_models.sh [COMFYUI_MODELS_MAIN_DIR]
   
   # Install custom nodes (non-persistent)
   ./install_custom_nodes.sh [COMFYUI_DIR]
   ```

## Notes

- These scripts are designed to work with the RunPod ComfyUI container
- Model paths are configured to match the RunPod container's `extra_model_paths.yml`
- The scripts handle downloading and organizing models and custom nodes
- Base models are installed to a persistent cache directory
- Additional models and custom nodes are installed fresh on each container start