#!/bin/bash

HOSTNAME=p4
VEHICLE=pacifica-4
ROUTE=itri-68-nanliao

SESSION="sdc2"
COMMON_CMD="~/sdc2/scripts/sdc-shell --hostname $HOSTNAME --route $ROUTE --use-sim-time && cd ~/sdc2/ros/"

# 建立 session 並啟動第一個 window（預設就是 window 0）
tmux new-session -d -s $SESSION -n core

# 分割為 2x2 格式（四個 pane）
tmux split-window -h -t $SESSION:0.0      # Pane 0 → Pane 1 (右)
tmux split-window -v -t $SESSION:0.0      # Pane 0 → Pane 2 (下)
tmux split-window -v -t $SESSION:0.2      # Pane 1 → Pane 3 (下)

PANE_CMDS=(
  "cd /media/charlie/"
  ". install/setup.bash && ros2 launch sdc localization.launch.py"
  ". install/setup.bash && ros2 launch lidar_pipeline lidar_detection_pipeline.launch.py"
  ". install/setup.bash && ros2 launch multi_object_tracking tracking.launch.py"
)

# 在每個 pane 執行共同指令
for i in 0 1 2 3; do
  sleep 1
  tmux send-keys -t $SESSION:0.$i "$COMMON_CMD" C-m
  tmux send-keys -t $SESSION:0.$i "${PANE_CMDS[$i]}" C-m
done

# 第二個 window：執行 rviz 設定檔
tmux new-window -t $SESSION -n rviz
sleep 0.5
tmux send-keys -t $SESSION:1 "$COMMON_CMD" C-m
tmux send-keys -t $SESSION:1 ". install/setup.bash && rviz2 -d ./src/perception/lidar_pipeline/config/lidar_detection_pipeline_test/lidar_detection_pipeline.rviz" C-m

# 第三個 window：vehicle_model.launch
tmux new-window -t $SESSION -n vehicle_model
sleep 0.5
tmux send-keys -t $SESSION:2 "$COMMON_CMD" C-m
tmux send-keys -t $SESSION:2 ". install/setup.bash && ros2 launch sdc vehicle_model.launch.py" C-m

# 第四個 window：static_tf.launch
tmux new-window -t $SESSION -n static_tf
sleep 0.5
tmux send-keys -t $SESSION:3 "$COMMON_CMD" C-m
tmux send-keys -t $SESSION:3 ". install/setup.bash && ros2 launch src/sdc/cfg/vehicles/$VEHICLE/static_tf.launch" C-m

# Attach to the session
tmux select-window -t sdc2:0
tmux select-pane -t sdc2:0.0
tmux attach -t sdc2