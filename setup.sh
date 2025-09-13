#!/bin/bash

# Run as main user
if [ "$EUID" -eq 0 ]
  then echo "Please run without sudo"
  exit
fi

# Component definitions
COMPONENTS=(
    "APT packages installation:sudo ./scripts/install_apt_packages.sh"
    "Nerd fonts installation:./scripts/install_nerd_fonts.sh"
    "Terminal configuration:./scripts/load_terminal_config.sh"
    "Vim configuration:./scripts/load_vim_config.sh"
)

# Initialize selection array
SELECTED=()
for i in "${!COMPONENTS[@]}"; do
    SELECTED[i]=false
done

CURRENT=0

# Function to display the menu
show_menu() {
    clear
    echo "=== Interactive Distro Setup ==="
    echo "Use ↑/↓ arrow keys to navigate, SPACE to select/deselect, ENTER to continue"
    echo ""
    
    for i in "${!COMPONENTS[@]}"; do
        local component_name=$(echo "${COMPONENTS[i]}" | cut -d':' -f1)
        local checkbox="[ ]"
        if [ "${SELECTED[i]}" = true ]; then
            checkbox="[✓]"
        fi
        
        if [ $i -eq $CURRENT ]; then
            echo "> $checkbox $component_name"
        else
            echo "  $checkbox $component_name"
        fi
    done
    
    echo ""
    echo "Press ENTER when ready to proceed..."
}

# Function to handle key input
handle_input() {
    while true; do
        show_menu
        
        # Read input with IFS to preserve spaces
        IFS= read -rsn1 key
        
        # Handle different key inputs
        if [[ $key == $'\033' ]]; then
            # Arrow keys start with escape sequence
            read -rsn2 -t 0.1 arrow
            if [[ $arrow == "[A" ]]; then
                # Up arrow
                ((CURRENT--))
                if [ $CURRENT -lt 0 ]; then
                    CURRENT=$((${#COMPONENTS[@]} - 1))
                fi
            elif [[ $arrow == "[B" ]]; then
                # Down arrow
                ((CURRENT++))
                if [ $CURRENT -ge ${#COMPONENTS[@]} ]; then
                    CURRENT=0
                fi
            fi
        elif [[ $key == $'\x20' ]]; then
            # Space bar (hex 20) - toggle selection
            if [ "${SELECTED[CURRENT]}" = true ]; then
                SELECTED[CURRENT]=false
            else
                SELECTED[CURRENT]=true
            fi
        elif [[ $key == "" ]]; then
            # Enter key (empty string)
            break
        fi
    done
}

# Run the interactive menu
handle_input

# Check if any components are selected
any_selected=false
for selected in "${SELECTED[@]}"; do
    if [ "$selected" = true ]; then
        any_selected=true
        break
    fi
done

if [ "$any_selected" = false ]; then
    echo "No components selected. Exiting..."
    exit 0
fi

# Show selected components and confirm
echo ""
echo "Selected components:"
for i in "${!COMPONENTS[@]}"; do
    if [ "${SELECTED[i]}" = true ]; then
        component_name=$(echo "${COMPONENTS[i]}" | cut -d':' -f1)
        echo "  - $component_name"
    fi
done

echo ""
read -p "Proceed with installation? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "Starting installation..."
echo ""

# Execute selected components
for i in "${!COMPONENTS[@]}"; do
    if [ "${SELECTED[i]}" = true ]; then
        component_name=$(echo "${COMPONENTS[i]}" | cut -d':' -f1)
        component_cmd=$(echo "${COMPONENTS[i]}" | cut -d':' -f2-)
        
        echo "=== Installing: $component_name ==="
        eval "$component_cmd"
        echo ""
    fi
done

echo "Installation completed!"
