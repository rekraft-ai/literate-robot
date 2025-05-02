#!/bin/bash

# Check for common functions file
COMMON_FUNCTIONS_FILE="/common_functions.sh"
if [[ ! -f "$COMMON_FUNCTIONS_FILE" ]]; then
    log "Error: Common functions file not found: $COMMON_FUNCTIONS_FILE"
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
    log "Creating COMFYUI models cache directory: $COMFYUI_MODELS_CACHE_DIR"
    mkdir -p "$COMFYUI_MODELS_CACHE_DIR"
fi

# Create all model directories upfront
log "Creating model directories..."
mkdir -p "${COMFYUI_MODELS_CACHE_DIR}/models/"{checkpoints,clip,clip_vision,configs,controlnet,diffusion_models,embeddings,esrgan,loras,text_encoders,unet,upscale_models,vae}

# Define model arrays
CHECKPOINT_MODELS=(
    "https://civitai.com/api/download/models/798204?type=Model&format=SafeTensor&size=full&fp=fp16;sdxl/juggernautXL_v8Rundiffusion.safetensors"
    "https://civitai.com/api/download/models/456538?type=Model&format=SafeTensor&size=pruned&fp=fp16;sdxl/juggernautXL_versionXInpaint.safetensors"
    "https://civitai.com/api/download/models/1041855?type=Model&format=SafeTensor&size=pruned&fp=fp16;sdxl/albedobaseXL_v31Large.safetensors"
    "https://civitai.com/api/download/models/297740?type=Model&format=SafeTensor&size=pruned&fp=fp16;sdxl/dynavisionXLAllInOneStylized_releaseV0610Bakedvae.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors;sdxl/sd_xl_base_1.0.safetensors"
    "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors;sdxl/sd_xl_refiner_1.0.safetensors"
    "https://civitai.com/api/download/models/351306?type=Model&format=SafeTensor&size=full&fp=fp16;sdxl/dreamshaperXL_v21"
    "https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors;FLUX1/flux1-dev-fp8.safetensors"
)

CLIP_MODELS=(
)

CLIPVISION_MODELS=(
    "https://huggingface.co/comfyanonymous/clip_vision_g/resolve/main/clip_vision_g.safetensors;clip_vision_g.safetensors"
    "https://huggingface.co/laion/CLIP-ViT-bigG-14-laion2B-39B-b160k/resolve/main/open_clip_model.safetensors;CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors"
    "https://huggingface.co/laion/CLIP-ViT-H-14-laion2B-s32B-b79K/resolve/main/model.safetensors;CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"
)

CONFIGS=(
    # Add config files here
    # Example: "https://example.com/config.json;custom_config.json"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors?download=true;controlnet-instantid-sdxl.safetensors"
    "https://huggingface.co/diffusers/controlnet-depth-sdxl-1.0/resolve/main/diffusion_pytorch_model.fp16.safetensors;controlnet-depth-sdxl-1.0.safetensors"
    "https://huggingface.co/lllyasviel/sd-controlnet-openpose/resolve/main/diffusion_pytorch_model.safetensors;controlnet-openpose-sd15.safetensors"
    "https://huggingface.co/thibaud/controlnet-openpose-sdxl-1.0/resolve/main/OpenPoseXL2.safetensors;controlnet-openpose-sdxl-1.0.safetensors"
)

DIFFUSION_MODELS=(
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_full_fp8.safetensors?download=true;hidream_i1_full_fp8.safetensors"
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_full_fp16.safetensors?download=true;hidream_i1_full_fp16.safetensors"
)

EMBEDDINGS=(
    # Add embeddings here
    # Example: "https://example.com/embedding.pt;custom_embedding.pt"
)

ESRGAN_MODELS=(
    "https://huggingface.co/ffxvs/upscaler/resolve/f8edf6d7f286acdd70178a6ff0c736fc592e818e/ESRGAN_4x.pth;ESRGAN_4x.pth"
)

LORA_MODELS=(
    # Graphic Novel / Comic Book Loras
    "https://huggingface.co/blink7630/graphic-novel-illustration/blob/main/Graphic_Novel_Illustration-000007.safetensors;sdxl/Graphic_Novel_Illustration-000007.safetensors"
    "https://civitai.com/api/download/models/107460?type=Model&format=SafeTensor;sdxl/TK_CCE_V1.00-SD15.safetensors"
    "https://civitai.com/api/download/models/32988?type=Model&format=SafeTensor&size=full&fp=fp16;blindbox_v1_mix.safetensors"
)

TEXT_ENCODERS=(
    # Add text encoders here
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_l_hidream.safetensors;clip_l_hidream.safetensors"
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/clip_g_hidream.safetensors;clip_g_hidream.safetensors"
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn_scaled.safetensors;t5xxl_fp8_e4m3fn_scaled.safetensors"
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/text_encoders/llama_3.1_8b_instruct_fp8_scaled.safetensors;llama_3.1_8b_instruct_fp8_scaled.safetensors"
)

UNET_MODELS=(    
    "https://huggingface.co/Kwai-Kolors/Kolors/resolve/main/unet/diffusion_pytorch_model.fp16.safetensors;kwai-kolors/kolors_diffusion_pytorch_model.fp16.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/ffxvs/upscaler/resolve/f8edf6d7f286acdd70178a6ff0c736fc592e818e/ESRGAN_4x.pth;ESRGAN_4x.pth"
)

VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/vae/ae.safetensors;ae.safetensors"
)

# Main installation function
function install_models() {
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/checkpoints" "${CHECKPOINT_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/clip" "${CLIP_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/clip_vision" "${CLIPVISION_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/configs" "${CONFIGS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/controlnet" "${CONTROLNET_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/diffusion_models" "${DIFFUSION_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/embeddings" "${EMBEDDINGS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/esrgan" "${ESRGAN_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/loras" "${LORA_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/unet" "${UNET_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/upscale_models" "${UPSCALE_MODELS[@]}"
    download_files "${COMFYUI_MODELS_CACHE_DIR}/models/vae" "${VAE_MODELS[@]}"
}

# Execute the installation if this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_models
fi 