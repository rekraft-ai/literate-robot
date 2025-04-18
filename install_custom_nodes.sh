#!/bin/bash

# Check for common functions file
COMMON_FUNCTIONS_FILE="/common_functions.sh"
if [[ ! -f "$COMMON_FUNCTIONS_FILE" ]]; then
    echo "Error: Common functions file not found: $COMMON_FUNCTIONS_FILE"
    exit 1
fi

# Source common functions
source "$COMMON_FUNCTIONS_FILE"

# NOTE: This script will download these custom_nodes into the main ComfyUI directory, 
# not to the cache directory on network volume.
# This means they will be downloaded again on every container start
# Set default COMFYUI directory if not provided
COMFYUI_DIR=${1:-/ComfyUI}

# Validate COMFYUI directory
if [[ ! -d "$COMFYUI_DIR" ]]; then
    log "Error: COMFYUI directory does not exist: $COMFYUI_DIR"
    exit 1
fi

NODES=(
    # Essentials
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/jags111/efficiency-nodes-comfyui"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"

    # Instant ID Based Workflows from Cubiq
    "https://github.com/cubiq/ComfyUI_InstantID"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus"

    # Inpainting Nodes
    "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"

    # Conflicts with ComfyUI_InstantID (also has InstantIDFaceAnalysis)
    # "https://github.com/vuongminh1907/ComfyUI_ZenID"

    # Conflicts with many other nodes. Is Jake better than Cubiq for InstantID nodes?
    # "https://github.com/jakechai/ComfyUI-JakeUpgrade"

    # Upscaling
    # "https://github.com/Ttl/ComfyUi_NNLatentUpscale"

    # Different Face Swap Nodes
    # "https://github.com/nosiu/comfyui-instantId-faceswap"

    # Instant ID Based Workflows from ZHO
    # "https://github.com/ZHO-ZHO-ZHO/ComfyUI-InstantID"

    # Many useful example workflows
    # "https://github.com/edenartlab/eden_comfy_pipelines"

    # PULID
    # "https://github.com/cubiq/PuLID_ComfyUI"

    # Scene Composer Approach Dependencies
    # "https://github.com/mus-taches/comfyui-scene-composer"
    # "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    # "https://github.com/kijai/ComfyUI-KJNodes"
    # "https://github.com/melMass/comfy_mtb"
    # "https://github.com/receyuki/comfyui-prompt-reader-node"
    # "https://github.com/florestefano1975/comfyui-prompt-composer"
    # "https://github.com/nkchocoai/ComfyUI-SaveImageWithMetaData"
    # "https://github.com/edelvarden/ComfyUI-ImageMetadataExtension"
)

function install_custom_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                log "Updating node: ${repo}"
                ( cd "$path" && git pull ) >> "$LOG_FILE" 2>&1
                if [[ -e $requirements ]]; then
                   pip install -q --no-cache-dir -r "$requirements" >> "$LOG_FILE" 2>&1
                fi
            fi
        else
            log "Downloading node: ${repo}"
            git clone "${repo}" "${path}" --recursive >> "$LOG_FILE" 2>&1
            if [[ -e $requirements ]]; then
                pip install -q --no-cache-dir -r "${requirements}" >> "$LOG_FILE" 2>&1
            fi
        fi
    done
}

# Execute the installation if this script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_custom_nodes
fi 