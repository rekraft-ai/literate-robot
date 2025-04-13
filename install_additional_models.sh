#!/bin/bash

# Check for common functions file
COMMON_FUNCTIONS_FILE="/common_functions.sh"
if [[ ! -f "$COMMON_FUNCTIONS_FILE" ]]; then
    log "Error: Common functions file not found: $COMMON_FUNCTIONS_FILE"
    exit 1
fi

# Source common functions
source "$COMMON_FUNCTIONS_FILE"

# NOTE: This script will download these models into the main ComfyUI directory, 
# not to the cache directory on network volume.
# This means they will be downloaded again on every container start
# Set default COMFYUI directory if not provided
COMFYUI_MODELS_MAIN_DIR=${1:-/ComfyUI}

# Validate COMFYUI directory
if [[ ! -d "$COMFYUI_MODELS_MAIN_DIR" ]]; then
    log "Error: COMFYUI directory does not exist: $COMFYUI_MODELS_MAIN_DIR"
    exit 1
fi

# Create all model directories upfront
log "Creating model directories..."
mkdir -p "${COMFYUI_MODELS_MAIN_DIR}/models/"{instantid,pulid,ipadapter}

# Define additional model arrays
INSTANTID_MODELS=(
    "https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin;instantid/ip-adapter.bin"
    "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors;instantid/controlnet-instantid-sdxl.safetensors"
    "https://huggingface.co/InstantX/InstantID/resolve/main/antelopev2;instantid/antelopev2"
)

PULID_MODELS=(
    "https://huggingface.co/InstantX/PuLID/resolve/main/pulid.bin;pulid/pulid.bin"
    "https://huggingface.co/InstantX/PuLID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors;pulid/controlnet-pulid-sdxl.safetensors"
)

IPADAPTER_MODELS=(
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sd15.safetensors;ipadapter/ip-adapter-plus_sd15.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus-face_sd15.safetensors;ipadapter/ip-adapter-plus-face_sd15.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors;ipadapter/ip-adapter_sd15.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-faceid_sd15.safetensors;ipadapter/ip-adapter-faceid_sd15.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-faceid-plusv2_sd15.safetensors;ipadapter/ip-adapter-faceid-plusv2_sd15.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sdxl_vit-h.safetensors;ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus-face_sdxl_vit-h.safetensors;ipadapter/ip-adapter-plus-face_sdxl_vit-h.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sdxl_vit-h.safetensors;ipadapter/ip-adapter_sdxl_vit-h.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-faceid_sdxl_vit-h.safetensors;ipadapter/ip-adapter-faceid_sdxl_vit-h.safetensors"
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-faceid-plusv2_sdxl_vit-h.safetensors;ipadapter/ip-adapter-faceid-plusv2_sdxl_vit-h.safetensors"
)

# Main installation function
function install_additional_models() {
    download_files "${COMFYUI_MODELS_MAIN_DIR}/models/instantid" "${INSTANTID_MODELS[@]}"
    download_files "${COMFYUI_MODELS_MAIN_DIR}/models/pulid" "${PULID_MODELS[@]}"
    download_files "${COMFYUI_MODELS_MAIN_DIR}/models/ipadapter" "${IPADAPTER_MODELS[@]}"
}

# Execute the installation if this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_additional_models
fi 