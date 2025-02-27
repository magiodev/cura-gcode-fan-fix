#!/bin/bash
# Universal G-code Fan Cloning Script
# Author: magiodev magio.dev@protonmail.com
# Description: This script modifies M106 fan commands in Cura-generated G-code,
# ensuring additional fans are controlled properly.

# Default settings
MULTIPLIERS=("1.0") # Default fan speed multiplier
FAN_NUMBERS=("1")   # Default P fans (e.g., P1)
LOG_FILE=""         # Default empty (no log)
DRY_RUN=false       # Dry run disabled by default
ENABLE_BACKUP=true  # Enable backups by default

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -m | --multiplier)
        IFS=',' read -r -a MULTIPLIERS <<<"$2"
        shift
        ;; # Comma-separated multipliers
    -p | --p-amount)
        IFS=',' read -r -a FAN_NUMBERS <<<"$2"
        shift
        ;; # Comma-separated P numbers
    -l | --log)
        LOG_FILE="$2"
        shift
        ;;                              # Log file
    --dry-run) DRY_RUN=true ;;          # Enable dry-run mode
    --no-backup) ENABLE_BACKUP=false ;; # Disable backup creation
    -h | --help)
        echo "Usage: $0 [-m MULTIPLIERS] [-p FAN_NUMBERS] [-l LOG_FILE] [--dry-run] [--no-backup]"
        echo "Options:"
        echo "  -m, --multiplier  Set fan speed multipliers (comma-separated, e.g., '0.8,1.0,1.2')"
        echo "  -p, --p-amount    Set which P fans to control (comma-separated, e.g., '1,2,3')"
        echo "  -l, --log         Specify a log file to save processed files"
        echo "  --dry-run         Run script without modifying files"
        echo "  --no-backup       Disable backup creation"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
done

echo "Processing G-code files in the current directory..."
echo "Fan Speed Multipliers: ${MULTIPLIERS[*]}"
echo "Fans Modified: P${FAN_NUMBERS[*]}"
if [[ -n "$LOG_FILE" ]]; then
    echo "Logging changes to: $LOG_FILE"
    echo "Processing Log - $(date)" >"$LOG_FILE"
fi

# Process each G-code file
for file in *.gcode; do
    [ -e "$file" ] || continue

    backup_file="${file}.bak"

    if $DRY_RUN; then
        echo "[Dry Run] Would process: $file"
        [[ -n "$LOG_FILE" ]] && echo "[Dry Run] $file" >>"$LOG_FILE"
        continue
    fi

    # Backup the original file if backups are enabled
    if $ENABLE_BACKUP; then
        # Find next available backup number
        backup_num=0
        while [ -f "${backup_file}${backup_num:+.$backup_num}" ]; do
            backup_num=$((backup_num + 1))
        done
        backup_file="${backup_file}${backup_num:+.$backup_num}"
        cp "$file" "$backup_file"
        echo "Backup created: $backup_file"
    fi

    awk -v multipliers="${MULTIPLIERS[*]}" -v fan_numbers="${FAN_NUMBERS[*]}" '
    BEGIN {
        split(multipliers, multi_arr, " "); # Convert to array
        split(fan_numbers, fan_arr, " ");  # Convert to array
        num_fans = length(fan_arr);
    }
    {
        if ($0 ~ /^M106 S[0-9]+$/) {
            # Found a base fan command without P parameter
            split($0, arr, "S");
            base_speed = arr[2] + 0;
            
            # Store current line
            current_line = $0;
            next_line = "";
            has_p_commands = 0;
            
            # Look ahead one line
            if ((getline tmp) > 0) {
                next_line = tmp;
                if (next_line ~ /^M106 P[0-9]+ S[0-9]+$/) {
                    has_p_commands = 1;
                }
            }
            
            # Print the original command
            print current_line;
            
            if (has_p_commands) {
                # Already has P commands, print them and any subsequent ones
                print next_line;
                while ((getline tmp) > 0) {
                    if (tmp ~ /^M106 P[0-9]+ S[0-9]+$/) {
                        print tmp;
                    } else {
                        print tmp;
                        break;
                    }
                }
            } else {
                # No P commands yet, generate them
                for (i = 1; i <= num_fans; i++) {
                    fan_p = fan_arr[i];
                    multiplier = (i <= length(multi_arr)) ? multi_arr[i] : 1.0;
                    fan_speed = int(base_speed * multiplier + 0.5);
                    if (fan_speed > 255) fan_speed = 255;  # Cap max speed at 255
                    printf "M106 P%d S%d\n", fan_p, fan_speed;
                }
                if (next_line != "") print next_line;
            }
        } else {
            print $0;  # Print all other lines unchanged
        }
    }' "$file" >"${file}.tmp" && mv "${file}.tmp" "$file"

    echo "Processed: $file"
    [[ -n "$LOG_FILE" ]] && echo "$file" >>"$LOG_FILE"
done

echo "All G-code files processed successfully!"
