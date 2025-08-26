#!/bin/bash
# General-purpose session list with numbered selection and pagination
# Works from any directory as long as dotfiles workspace is present

sessions_dir="$HOME/.augment/sessions"
cache_dir="$HOME/.augment/session-summaries"

# Create cache directory if it doesn't exist
mkdir -p "$cache_dir"

cd "$sessions_dir" || exit 1

# Get terminal dimensions
get_terminal_size() {
    if command -v tput >/dev/null 2>&1; then
        TERM_ROWS=$(tput lines)
        TERM_COLS=$(tput cols)
    else
        # Fallback defaults
        TERM_ROWS=24
        TERM_COLS=80
    fi
    
    # Each session takes approximately 4-6 lines (header + multi-line summary)
    # Reserve space for header (3 lines), footer (2 lines), and input prompt (3 lines)
    # So we need: header(3) + sessions(N*5) + footer(2) + prompt(3) <= TERM_ROWS
    # N*5 <= TERM_ROWS - 8
    # N <= (TERM_ROWS - 8) / 5
    SESSIONS_PER_PAGE=$(((TERM_ROWS - 8) / 5))
    
    # Minimum of 2 sessions per page, maximum of 8 for readability
    if [[ $SESSIONS_PER_PAGE -lt 2 ]]; then
        SESSIONS_PER_PAGE=2
    elif [[ $SESSIONS_PER_PAGE -gt 8 ]]; then
        SESSIONS_PER_PAGE=8
    fi
}

# Show helpful guidance
show_help() {
    echo ""
    echo "📖 Session Browser Help:"
    echo "  • Enter a number (1-N) to resume that session"
    echo "  • Press Enter to see next page of sessions"
    echo "  • Type 'q' or 'quit' to exit"
    echo "  • Type 'h' or 'help' for this help message"
    echo ""
}

# Clean up short/debug sessions (same as before)
cleanup_sessions() {
    echo "Cleaning up short sessions..." >&2
    for file in $(ls -t *.json 2>/dev/null); do
        exchange_count=$(jq -r '.chatHistory | length' "$file" 2>/dev/null)
        first_msg=$(jq -r '.chatHistory[0].exchange.request_message // empty' "$file" 2>/dev/null)

        # Delete if < 3 exchanges
        if [[ "$exchange_count" -lt 3 ]]; then
            echo "Deleting short session: $file ($exchange_count exchanges)" >&2
            rm -f "$file"
            rm -f "$cache_dir/$(basename "$file" .json).txt"
            continue
        fi

        # Delete debug/test sessions
        if [[ "$first_msg" == *"Summarize this conversation"* ]] || \
           [[ "$first_msg" == *"Test"* ]] || \
           [[ "$first_msg" == *"test"* ]] || \
           [[ "$first_msg" == *"debug"* ]] || \
           [[ "$first_msg" == *"Debug"* ]]; then
            echo "Deleting debug session: $file (test/debug session)" >&2
            rm -f "$file"
            rm -f "$cache_dir/$(basename "$file" .json).txt"
            continue
        fi

        # Delete sessions that are just context loading (no real conversation)
        user_msg_count=$(jq -r '.chatHistory[].exchange.request_message // empty' "$file" 2>/dev/null | grep -v "Load my context" | grep -v "Personal Context" | grep -v "Work Patterns" | grep -v "Be my critical Carl" | wc -l)
        if [[ "$user_msg_count" -lt 2 ]]; then
            echo "Deleting context-only session: $file (no real conversation)" >&2
            rm -f "$file"
            rm -f "$cache_dir/$(basename "$file" .json).txt"
            continue
        fi
    done
}

# Generate summary for a session
generate_summary() {
    local file="$1"
    local session_id=$(basename "$file" .json)
    local cache_file="$cache_dir/$session_id.txt"
    
    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
    else
        echo "Generating summary..." >&2
        full_path="$sessions_dir/$file"
        summary=$(cat "$full_path" | auggie --print "Read this session and provide a concise summary of what was discussed and accomplished. Keep it to 3 lines maximum, focus on the main topics and outcomes." 2>/dev/null | grep -v "🤖" | head -3)
        
        # Clean up summary
        summary=$(echo "$summary" | sed 's/Tool.*//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        echo "$summary" > "$cache_file"
        echo "$summary"
    fi
}

# Format relative time
get_relative_time() {
    local file="$1"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mod_time=$(stat -f "%Sm" -t "%s" "$file")
    else
        mod_time=$(stat -c "%Y" "$file")
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

# Display a page of sessions
display_page() {
    local start_idx="$1"
    local sessions=("${@:2}")
    local end_idx=$((start_idx + SESSIONS_PER_PAGE - 1))
    
    if [[ $end_idx -ge ${#sessions[@]} ]]; then
        end_idx=$((${#sessions[@]} - 1))
    fi
    
    clear
    echo "Recent Sessions (Page $((start_idx / SESSIONS_PER_PAGE + 1))):"
    echo "╭─────┬──────────────┬────────────────────────────────────────────────────────────────────────────────╮"
    printf "│ %-3s │ %-12s │ %-78s │\n" "Num" "When" "Summary"
    echo "├─────┼──────────────┼────────────────────────────────────────────────────────────────────────────────┤"
    
    for i in $(seq $start_idx $end_idx); do
        if [[ $i -ge ${#sessions[@]} ]]; then
            break
        fi
        
        local file="${sessions[$i]}"
        local num=$((i + 1))
        local rel_time=$(get_relative_time "$file")
        local summary=$(generate_summary "$file")
        
        # Handle multi-line summaries with proper table formatting
        first_line=true
        while IFS= read -r line; do
            # Wrap long lines to fit in table column (78 chars max)
            while [[ ${#line} -gt 78 ]]; do
                # Find last space before 78 chars
                wrap_pos=78
                while [[ $wrap_pos -gt 0 && "${line:$wrap_pos:1}" != " " ]]; do
                    ((wrap_pos--))
                done
                if [[ $wrap_pos -eq 0 ]]; then wrap_pos=78; fi

                part="${line:0:$wrap_pos}"
                line="${line:$wrap_pos}"
                line="${line# }" # Remove leading space

                if [[ "$first_line" == true ]]; then
                    printf "│ %-3s │ %-12s │ %-78s │\n" "$num" "$rel_time" "$part"
                    first_line=false
                else
                    printf "│     │              │ %-78s │\n" "$part"
                fi
            done

            # Print remaining line
            if [[ -n "$line" ]]; then
                if [[ "$first_line" == true ]]; then
                    printf "│ %-3s │ %-12s │ %-78s │\n" "$num" "$rel_time" "$line"
                    first_line=false
                else
                    printf "│     │              │ %-78s │\n" "$line"
                fi
            fi
        done <<< "$summary"
        
        # Add row separator (except for last session on page)
        if [[ $i -lt $end_idx ]]; then
            echo "├─────┼──────────────┼────────────────────────────────────────────────────────────────────────────────┤"
        fi
    done
    
    echo "╰─────┴──────────────┴────────────────────────────────────────────────────────────────────────────────╯"
    
    # Show pagination info
    local total_pages=$(((${#sessions[@]} + SESSIONS_PER_PAGE - 1) / SESSIONS_PER_PAGE))
    local current_page=$((start_idx / SESSIONS_PER_PAGE + 1))
    echo ""
    echo "Showing sessions $((start_idx + 1))-$((end_idx + 1)) of ${#sessions[@]} (Page $current_page of $total_pages)"
}

# Main execution
main() {
    get_terminal_size
    cleanup_sessions
    
    # Get all session files
    sessions=()
    for file in $(ls -t *.json 2>/dev/null); do
        sessions+=("$file")
    done
    
    if [[ ${#sessions[@]} -eq 0 ]]; then
        echo "No sessions found."
        echo ""
        echo "💡 Tip: Start a conversation with 'carl' to create your first session!"
        exit 0
    fi
    
    local current_page=0
    
    while true; do
        local start_idx=$((current_page * SESSIONS_PER_PAGE))
        
        # Check if we've gone past the last page
        if [[ $start_idx -ge ${#sessions[@]} ]]; then
            echo ""
            echo "📄 End of sessions reached."
            echo ""
            echo "💡 Options:"
            echo "  • Enter a session number to resume"
            echo "  • Type 'q' to quit"
            echo "  • Type 'h' for help"
            current_page=$(((${#sessions[@]} - 1) / SESSIONS_PER_PAGE))
            start_idx=$((current_page * SESSIONS_PER_PAGE))
        fi
        
        display_page $start_idx "${sessions[@]}"
        
        echo ""
        echo "💡 Enter session number, press Enter for next page, 'q' to quit, 'h' for help:"
        read -p "> " choice
        
        case "$choice" in
            ""|" ")
                # Next page
                ((current_page++))
                ;;
            "q"|"quit"|"Q"|"QUIT")
                echo "Goodbye!"
                exit 0
                ;;
            "h"|"help"|"H"|"HELP")
                show_help
                read -p "Press Enter to continue..." -r
                ;;
            [0-9]*)
                if [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#sessions[@]} ]]; then
                    selected_file="${sessions[$((choice-1))]}"
                    selected_session="$sessions_dir/$selected_file"
                    echo "Resuming session $choice..."

                    # Check if file still exists
                    if [[ ! -f "$selected_session" ]]; then
                        echo "❌ Error: Session file no longer exists: $selected_session"
                        echo ""
                        echo "💡 This can happen if the session was cleaned up. Try refreshing with 'carl resume'."
                        read -p "Press Enter to continue..." -r
                        continue
                    fi

                    # Touch file to update modification time
                    touch "$selected_session"

                    # Resume session from current directory
                    auggie --continue "$selected_session"
                    exit 0
                else
                    echo ""
                    echo "❌ Invalid session number: $choice"
                    echo "💡 Please enter a number between 1 and ${#sessions[@]}, or:"
                    echo "   • Press Enter for next page"
                    echo "   • Type 'q' to quit"
                    echo "   • Type 'h' for help"
                    echo ""
                    read -p "Press Enter to continue..." -r
                fi
                ;;
            *)
                echo ""
                echo "❌ Unknown command: '$choice'"
                echo "💡 Valid options:"
                echo "   • Enter a session number (1-${#sessions[@]})"
                echo "   • Press Enter for next page"
                echo "   • Type 'q' to quit"
                echo "   • Type 'h' for help"
                echo ""
                read -p "Press Enter to continue..." -r
                ;;
        esac
    done
}

# Run main function
main
