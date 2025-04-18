#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

# Packages are installed after nodes so we can fix them...

APT_PACKAGES=(
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=(
    #"package-1"
    #"package-2"
    #"facexlib"
)

CODE_REPO=(
    "https://github.com/rekraft-ai/silver-waddle"
)

WORKFLOWS=(

)

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###

function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_code_repos
    provisioning_get_pip_packages
    provisioning_fix_antelope
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ -n $APT_PACKAGES ]]; then
            sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ -n $PIP_PACKAGES ]]; then
            pip install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_code_repos() {
    for repo in "${CODE_REPO[@]}"; do
        dir="${repo##*/}"
        path="${WORKSPACE}/${dir}"

        # Use environment variables for Git credentials if available, otherwise use defaults
        git config --global user.name "${GIT_USER_NAME}"
        git config --global user.email "${GIT_USER_EMAIL}"
        
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating repo: %s...\n" "${repo}"
                ( cd "$path" && git pull )
            fi
        else
            printf "Downloading repo: %s...\n" "${repo}"
            
            # Check if we have a GitHub token for private repos
            if [[ -n "${GITHUB_TOKEN}" && "$repo" =~ ^https://github\.com ]]; then
                # Extract the repo path and add token
                repo_path="${repo#https://}"
                repo_with_token="https://${GITHUB_TOKEN}@${repo_path}"
                git clone "${repo_with_token}" "${path}" --recursive
            else
                # Clone without token for public repos or when no token is available
                git clone "${repo}" "${path}" --recursive
            fi
        fi

        # Copy files/* to ComfyUI/input if the directory exists
        if [[ -d "${path}/files" ]]; then
            printf "Copying various input files to ComfyUI/input: [%s] to [%s]\n" "${path}/files" "${COMFYUI_DIR}/input"
            mkdir -p "${COMFYUI_DIR}/input"
            cp -r "${path}/files/"* "${COMFYUI_DIR}/input/"
        fi

        # Copy workflows/* to ComfyUI/user/default/workflows if the directory exists
        if [[ -d "${path}/workflows" ]]; then
            printf "Copying various workflows files to ComfyUI/workflows: [%s] to [%s]\n" "${path}/workflows" "${COMFYUI_DIR}/user/default/workflows"
            mkdir -p "${COMFYUI_DIR}/user/default/workflows"
            cp -r "${path}/workflows/"* "${COMFYUI_DIR}/user/default/workflows/"
        fi

        if [[ -d "${path}/custom_nodes" ]]; then
            printf "Copying various custom_nodes files to ComfyUI/custom_nodes: [%s] to [%s]\n" "${path}/custom_nodes" "${COMFYUI_DIR}/custom_nodes"
            mkdir -p "${COMFYUI_DIR}/custom_nodes"
            cp -r "${path}/custom_nodes/"* "${COMFYUI_DIR}/custom_nodes/"
        fi
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

function provisioning_fix_antelope() {
    local base_path="/workspace/ComfyUI/models/insightface/models/antelopev2"
    local nested_path="${base_path}/antelopev2"
    
    if [[ -d "$nested_path" ]]; then
        echo "Fixing antelopev2 folder structure..."
        # Move all contents from nested folder to parent
        cp "$nested_path"/* "$base_path/"
        # Remove the now-empty nested folder
        echo "Antelope folder structure fixed"
    fi
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
