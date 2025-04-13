#!/bin/bash

# Check for common functions file
COMMON_FUNCTIONS_FILE="/common_functions.sh"
if [[ ! -f "$COMMON_FUNCTIONS_FILE" ]]; then
    echo "Error: Common functions file not found: $COMMON_FUNCTIONS_FILE"
    exit 1
fi

# Source common functions
source "$COMMON_FUNCTIONS_FILE"

# NOTE: This script will download these models into the cache directory on network volume
# This means they will NOT BE downloaded again on every container start
# Set default COMFYUI directory if not provided
COMFYUI_MODELS_CACHE_DIR=${1:-/workspace/ComfyUI-models-cache}

# Validate COMFYUI directory
if [[ ! -d "$COMFYUI_MODELS_CACHE_DIR" ]]; then
    echo "Creating COMFYUI models cache directory: $COMFYUI_MODELS_CACHE_DIR"
    mkdir -p "$COMFYUI_MODELS_CACHE_DIR"
fi

# Create all model directories upfront
echo "Creating model directories..."
mkdir -p "${COMFYUI_MODELS_CACHE_DIR}/models/"{checkpoints,unet,lora,controlnet,vae,upscale_models,esrgan,clip_vision,configs,embeddings}

# Define model arrays
CHECKPOINT_MODELS=(
    "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16;sdxl/juggernautXL_v8Rundiffusion.safetensors"
    "https://civitai.com/api/download/models/1041855?type=Model&format=SafeTensor&size=pruned&fp=fp16;sdxl/albedobaseXL_v31Large.safetensors"
    "https://civitai.com/api/download/models/297740?type=Model&format=SafeTensor&size=pruned&fp=fp16;sdxl/dynavisionXLAllInOneStylized_releaseV0610Bakedvae.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors;sdxl/sd_xl_base_1.0.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors;sdxl/sd_xl_refiner_1.0.safetensors"
    "https://civitai.com/api/download/models/351306?type=Model&format=SafeTensor&size=full&fp=fp16;sdxl/dreamshaperXL_v21"
)

UNET_MODELS=(    
    "https://huggingface.co/Kwai-Kolors/Kolors/resolve/main/unet/diffusion_pytorch_model.fp16.safetensors;kwai-kolors/kolors_diffusion_pytorch_model.fp16.safetensors"
)

LORA_MODELS=(
    # Graphic Novel / Comic Book Loras
    # "https://huggingface.co/blink7630/graphic-novel-illustration/blob/main/Graphic_Novel_Illustration-000007.safetensors;sdxl/Graphic_Novel_Illustration-000007.safetensors"
    # "https://civitai.com/api/download/models/107460?type=Model&format=SafeTensor;sdxl/TK_CCE_V1.00-SD15.safetensors"
)

VAE_MODELS=(
)

UPSCALE_MODELS=(
    "https://huggingface.co/ffxvs/upscaler/resolve/f8edf6d7f286acdd70178a6ff0c736fc592e818e/ESRGAN_4x.pth;ESRGAN_4x.pth"
)

ESRGAN_MODELS=(
    "https://huggingface.co/ffxvs/upscaler/resolve/f8edf6d7f286acdd70178a6ff0c736fc592e818e/ESRGAN_4x.pth;ESRGAN_4x.pth"
)

CLIPVISION_MODELS=(
    "https://huggingface.co/comfyanonymous/clip_vision_g/resolve/main/clip_vision_g.safetensors;clip_vision_g.safetensors"
    "https://huggingface.co/laion/CLIP-ViT-bigG-14-laion2B-39B-b160k/resolve/main/open_clip_model.safetensors;CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors"
    "https://huggingface.co/laion/CLIP-ViT-H-14-laion2B-s32B-b79K/resolve/main/model.safetensors;CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors?download=true;controlnet-instantid-sdxl.safetensors"
    "https://huggingface.co/diffusers/controlnet-depth-sdxl-1.0/resolve/main/diffusion_pytorch_model.fp16.safetensors;controlnet-depth-sdxl-1.0.safetensors"
    "https://huggingface.co/lllyasviel/sd-controlnet-openpose/resolve/main/diffusion_pytorch_model.safetensors;controlnet-openpose-sd15.safetensors"
    "https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0/resolve/main/OpenPoseXL2.safetensors;controlnet-openpose-sdxl-1.0.safetensors"
)

CONFIGS=(
    # Add config files here
    # Example: "https://example.com/config.json;custom_config.json"
)

EMBEDDINGS=(
    # Add embeddings here
    # Example: "https://example.com/embedding.pt;custom_embedding.pt"
)

# Main installation function
function install_models() {
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/checkpoints" "${CHECKPOINT_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/unet" "${UNET_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/lora" "${LORA_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/controlnet" "${CONTROLNET_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/vae" "${VAE_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/upscale_models" "${UPSCALE_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/esrgan" "${ESRGAN_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/clip_vision" "${CLIPVISION_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/configs" "${CONFIGS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/embeddings" "${EMBEDDINGS[@]}"
}

# Execute the installation if this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_models
fi 