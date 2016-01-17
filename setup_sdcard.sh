#!/usr/bin/env bash

source .commonfunc
source .pikitchenfunc

function checkdeps() {
    [[ -e `which dos2unix` ]] || (log "ERROR: Missing dos2unix, try 'brew install dos2unix'" && return 1)
}

# Env flag to apply 062-display_rotate_180 recipe, useful with the official Raspberry Pi LCD screen mount.
DISPLAY_ROTATE=${DISPLAY_ROTATE:-false}

####################################

MAIN_DOCKER_COMPOSE=${MAIN_DOCKER_COMPOSE:-$1}

[[ -z "${MAIN_DOCKER_COMPOSE}" ]] && log "USAGE: $0 <path to main docker-compose.yml file or env MAIN_DOCKER_COMPOSE>" && exit 1

# uncomment one set of OS and recipe vars based on what you want to use.

### HypriotOS config (recommended) ###
OS="HypriotOS"
FLAVOUR="HypriotOS"
RECIPES="001-startup 059-docker-image-import 060-gpu-mem-512 061-fast-usb-mouse 055-hypriotos 046-openssh-root-pubkey-only 058-startup-docker-compose"

### Minibian config (work in progress) ###
#OS="Minibian"
#FLAVOUR="MinibianDocker"
#RECIPES="001-startup 030-fake-sudo 040-timezone-gmt 041-update-ntp 042-set-locale-us 045-openssh-server 050-docker 059-docker-image-import 060-gpu-mem-512 120-no-gui-no-autologin 058-startup-docker-compose"

if [[ ${DISPLAY_ROTATE} == true ]]; then
    RECIPES="${RECIPES} 062-display_rotate_180"
fi

if [[ -s "${RPI_NETWORK_INTERFACES}" ]]; then
    RECIPES="${RECIPES} 031-replace-network-interfaces"
fi

CFG_BASE="$(pwd)"
OS_BASE="${CFG_BASE}/os"
INGREDIENTS="${CFG_BASE}/recipes"

checkdeps || exit 1;

get_sd_card
[[ -z "$disk" ]] && log "ERROR: No SD card, exiting." && exit 1

NEW_CARD=$(get_input "Format SD card and install ${OS}? (skip if card has already been prepared) (y/n)")
INIT=false
[[ "$NEW_CARD" == "y" ]] && INIT=true

if [[ $INIT == true ]]; then
    format_sdcard "$disk"
    [[ $? -ne 0 ]] && log "ERROR: Could not format SD card." && exit 1
fi

get_boot_dir
[[ -z "$boot" ]] && log "ERROR: Could not find boot dir on $disk" && exit 1

if [[ $INIT == true ]]; then
    install_noobs "$boot" && install_os "$boot" "$OS" "$OS_BASE"
    [[ $? -ne 0 ]] && log "ERROR: Could not install NOOBS at: ${boot}" && exit 1
fi
[[ ! -d "${boot}/os/${OS}" ]] && log "ERROR: ${boot}/os/${OS} directory not found, did you forget to install NOOBS and the OS?" && exit 1

install_noobsconfig "$boot" ; [[ $? -ne 0 ]] && log "ERROR: Could not extract noobsconfig to: ${boot}" && exit 1
log "INFO: noobsconfig installed."

add_flavour "$boot" "$OS" "$FLAVOUR" "Docker ready Raspbian" ; [[ $? -ne 0 ]] && log "ERROR: Could not install RaspbianDocker flavour" && exit 1

for recipe in $RECIPES; do
    recipe_root="${boot}/pi-kitchen/${recipe}"

    install_recipe "$boot" "${recipe}" "$OS" "$FLAVOUR" "$INGREDIENTS"
    [[ $? -ne 0 ]] && log "ERROR: Could not install ${recipe} recipe" && exit 1
    log "INFO: ${recipe} recipe installed."

    if [[ -e "${recipe_root}/config.sh" ]]; then
        # call recipe specific config script.
        "${recipe_root}/config.sh" "$boot"
        [[ $? -ne 0 ]] && log "ERORR: Could not configure the ${recipe} recipe" && exit 1
        log "INFO: ${recipe} recipe configured."
    fi

    # Cache docker images.
    if [[ -e "${recipe_root}/docker_images.txt" ]]; then
        "${boot}/pi-kitchen/059-docker-image-import/cache_docker_images.sh" "$boot" "${recipe_root}/docker_images.txt"
        [[ $? -ne 0 ]] && log "ERROR: Could not cache docker images in: ${recipe_root}/docker_images.txt" && exit 1
    fi
done

# Copy custom network interfaces if provided.
if [[ -s "${RPI_NETWORK_INTERFACES}" ]]; then
    cp "${RPI_NETWORK_INTERFACES}" "${boot}/pi-kitchen/031-replace-network-interfaces/interfaces"
    log "INFO: Installed custom network interfaces from: ${RPI_NETWORK_INTERFACES}"
fi

# Copy main docker-compose file.
if [[ -e "${MAIN_DOCKER_COMPOSE}" ]]; then
    rsync -L "${MAIN_DOCKER_COMPOSE}" "${boot}"
    [[ $? -ne 0 ]] && log "ERORR: Could not copy ${MAIN_DOCKER_COMPOSE} to ${boot}" && exit 1
    log "INFO: ${MAIN_DOCKER_COMPOSE} installed to ${boot}"

    images=$(awk '/^[[:space:]]+image:[[:space:]]*(.*)/ {print $2}' "${MAIN_DOCKER_COMPOSE}")

    for image in $images; do
        log "INFO: Caching docker images: ${image}"

        "${boot}/pi-kitchen/059-docker-image-import/cache_docker_images.sh" "$boot" <(echo "${image}")
        [[ $? -ne 0 ]] && log "ERROR: Could not docker image in ${MAIN_DOCKER_COMPOSE}: ${image}" && exit 1
    done
fi

# Create _USER directory structure.
for d in _RUNSTART _RUNONCE _RUNSTARTBG; do
    [[ ! -d "${boot}/_USER/${d}" ]] && mkdir -p "${boot}/_USER/${d}"
done

# Enable silent install
[[ -z `grep "silentinstall" "${boot}/recovery.cmdline"` ]] && \
    sed -i "" -e "s/^/silentinstall /" "${boot}/recovery.cmdline"

# Fix the slow mouse motion in the recovery UI.
[[ -z `grep "usbhid.mousepoll=0" "${boot}/recovery.cmdline"` ]] && \
    sed -i "" -e "s/$/ usbhid.mousepoll=0/" "${boot}/recovery.cmdline"

if [[ "${EJECT_SD_PROMPT:-true}" == true ]]; then
    echo ""
    read -p "Eject SD card? (y/n): " input
    ([[ "$input" == "y" ]] && unmount) || open "${boot}"
fi
