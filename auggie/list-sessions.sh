#\!/bin/bash
# Adaptive session browser that works on any terminal size

sessions_dir="$HOME/.augment/sessions"
cd "$sessions_dir" || exit 1

# Get terminal dimensions with fallbacks
get_terminal_size() {
    if command -v tput >/dev/null 2>&1; then
        TERM_COLS=$(tput cols 2>/dev/null || echo 80)
        TERM_ROWS=$(tput lines 2>/dev/null || echo 24)
    else
        TERM_COLS=80
        TERM_ROWS=24
    fi
    
    # Calculate adaptive widths
    NUM_WIDTH=4
    TIME_WIDTH=12
    SEPARATOR_WIDTH=6  # spaces and separators
    SUMMARY_WIDTH=$((TERM_COLS - NUM_WIDTH - TIME_WIDTH - SEPARATOR_WIDTH))
    
    # Minimum summary width
    if [[ $SUMMARY_WIDTH -lt 20 ]]; then
        SUMMARY_WIDTH=20
    fi
    
    # Sessions per page based on terminal height
    SESSIONS_PER_PAGE=$((TERM_ROWS - 6))  # Reserve space for header/footer
    if [[ $SESSIONS_PER_PAGE -lt 3 ]]; then
        SESSIONS_PER_PAGE=3
    fi
}

# Format relative time
get_relative_time() {
    local file="$1"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mod_time=$(stat -f "%Sm" -t "%s" "$file" 2>/dev/null || echo 0)
    else
        mod_time=$(stat -c "%Y" "$file" 2>/dev/null || echo 0)
    fi

    now=$(date +%s)
    diff=$((now - mod_time))

    if [[ $diff -lt 3600 ]]; then
        echo "$((diff / 60))m ago"
    elif [[ $diff -lt 86400 ]]; then
        echo "$((diff / 3600))h ago"
    elif [[ $diff -lt 172800 ]]; then
        echo "yesterday"
    else
        echo "$((diff / 86400))d ago"
    fi
}

# Get session summary
get_summary() {
    local file="$1"
    local max_width="$2"
    
    # Try to get first user message
    local summary=$(jq -r '.chatHistory[0].exchange.request_message // "No summary available"' "$file" 2>/dev/null | head -1 | tr -d '\n\r')
    
    # Truncate to fit terminal width
    if [[ ${#summary} -gt $max_width ]]; then
        summary="${summary:0:$((max_width-3))}..."
    fi
    
    echo "$summary"
}

# Display sessions page
display_page() {
    local start_idx="$1"
    local sessions=("${@:2}")
    local end_idx=$((start_idx + SESSIONS_PER_PAGE - 1))
    
    if [[ $end_idx -ge ${#sessions[@]} ]]; then
        end_idx=$((${#sessions[@]} - 1))
    fi
    
    clear
    
    # Header
    local total_pages=$(((${#sessions[@]} + SESSIONS_PER_PAGE - 1) / SESSIONS_PER_PAGE))
    local current_page=$((start_idx / SESSIONS_PER_PAGE + 1))
    echo "Recent Sessions (Page $current_page of $total_pages)"
    echo ""
    
    # Column headers
    printf "%-${NUM_WIDTH}s %-${TIME_WIDTH}s %s\n" "Num" "When" "Summary"
    printf "%-${NUM_WIDTH}s %-${TIME_WIDTH}s %s\n" "$(printf '%*s' $NUM_WIDTH | tr ' ' '-')" "$(printf '%*s' $TIME_WIDTH | tr ' ' '-')" "$(printf '%*s' $SUMMARY_WIDTH | tr ' ' '-')"
    
    # Sessions
    for i in $(seq $start_idx $end_idx); do
        if [[ $i -ge ${#sessions[@]} ]]; then
            break
        fi
        
        local file="${sessions[$i]}"
        local num=$((i + 1))
        local rel_time=$(get_relative_time "$file")
        local summary=$(get_summary "$file" "$SUMMARY_WIDTH")
        
        printf "%-${NUM_WIDTH}s %-${TIME_WIDTH}s %s\n" "$num" "$rel_time" "$summary"
    done
    
    echo ""
    echo "Showing sessions $((start_idx + 1))-$((end_idx + 1)) of ${#sessions[@]}"
}

# Main execution
main() {
    get_terminal_size
    
    # Get all session files
    sessions=()
    for file in $(ls -t *.json 2>/dev/null); do
        sessions+=("$file")
    done
    
    if [[ ${#sessions[@]} -eq 0 ]]; then
        echo "No sessions found."
        echo ""
        echo "💡 Tip: Start a conversation with 'carl' to create your first session\!"
        exit 0
    fi
    
    local current_page=0
    
    while true; do
        local start_idx=$((current_page * SESSIONS_PER_PAGE))
        
        # Check if we've gone past the last page
        if [[ $start_idx -ge ${#sessions[@]} ]]; then
            echo "📄 End of sessions reached."
            current_page=$(((${#sessions[@]} - 1) / SESSIONS_PER_PAGE))
            start_idx=$((current_page * SESSIONS_PER_PAGE))
        fi
        
        display_page $start_idx "${sessions[@]}"
        
        echo ""
        echo "💡 Enter session number, Enter for next page, 'q' to quit:"
        read -p "> " choice
        
        case "$choice" in
            ""|" ")
                # Next page
                ((current_page++))
                ;;
            "q"|"quit"|"Q"|"QUIT")
                echo "Goodbye\!"
                exit 0
                ;;
            [0-9]*)
                if [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#sessions[@]} ]]; then
                    selected_file="${sessions[$((choice-1))]}"
                    selected_session="$sessions_dir/$selected_file"
                    echo "Resuming session $choice..."

                    if [[ ! -f "$selected_session" ]]; then
                        echo "❌ Error: Session file no longer exists"
                        read -p "Press Enter to continue..." -r
                        continue
                    fi

                    # Resume session
                    auggie --continue "$selected_session"
                    exit 0
                else
                    echo ""
                    echo "❌ Invalid session number: $choice"
                    echo "💡 Please enter a number between 1 and ${#sessions[@]}"
                    echo ""
                    read -p "Press Enter to continue..." -r
                fi
                ;;
            *)
                echo ""
                echo "❌ Unknown command: '$choice'"
                echo "💡 Valid options: session number, Enter (next page), 'q' (quit)"
                echo ""
                read -p "Press Enter to continue..." -r
                ;;
        esac
    done
}

# Run main function
main
