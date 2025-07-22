#!/bin/bash

SESSION="ros2_pipeline_latency_viewer"

TOPIC_FILES=(*.topic)
MAX_PANES_PER_WINDOW=9

if [ ${#TOPIC_FILES[@]} -eq 0 ]; then
    echo "No .topic files found."
    retrun 1 2>/dev/null || exit 1
fi
echo topic files: ${TOPIC_FILES[@]}

#### ============================================================================
FAKE_CMD="echo Simulating topic"

HOSTNAME=p4
ROUTE=itri-68-nanliao
ENV_COMMAND="~/sdc2/scripts/sdc-shell --hostname $HOSTNAME --route $ROUTE --use-sim-time && cd ~/sdc2/ros/"
RUN_COMMAND="ros2 topic hz"

tmux new-session -d -s $SESSION -n starter

for topic_file in "${TOPIC_FILES[@]}"; do
    file_name="${topic_file%%.topic}"
    
    # load topic list，ignore blank and comment line
    mapfile -t topics < <(grep -v '^#' "$topic_file" | sed '/^\s*$/d')

    total=${#topics[@]}
    if [ $total -eq 0 ]; then
        echo "Skipping empty file: $topic_file"
        continue
    fi

    num_windows=$(( (total + MAX_PANES_PER_WINDOW - 1) / MAX_PANES_PER_WINDOW ))

    for ((w=0; w<num_windows; w++)); do  # c-style for loop
        window_name="${file_name}_$w"
        tmux new-window -t $SESSION -n "$window_name"
        tmux select-window -t $SESSION:"$window_name"

        start=$((w * MAX_PANES_PER_WINDOW))
        end=$((start + MAX_PANES_PER_WINDOW))
        if [ $end -gt $total ]; then end=$total; fi

        count=$((end - start))
        for ((i=1; i<count; i++)); do
            tmux split-window -t $SESSION:"$window_name".0
            tmux select-layout -t $SESSION:"$window_name" tiled
        done

        # send command
        for ((i=0; i<count; i++)); do
            idx=$((start + i))

            echo "processing topic: ${topics[$idx]} in window: $window_name pane: $i"

            tmux send-keys -t $SESSION:"$window_name".$i "$ENV_COMMAND" C-m
            sleep 2

            topic="${topics[$idx]}"
            cmd="$RUN_COMMAND $topic"
            tmux send-keys -t $SESSION:"$window_name".$i "$cmd" C-m
        done
    done
done

# # 4. 顯示並附著
tmux select-window -t $SESSION:0
tmux attach -t $SESSION
