This directory is for sdc2 related script.

---

The following two scripts are general environment setting of sdc2:

```
tmux-start-sdc2-test
```

It will open four tmux windows, including 
- main (localization, lidar_detection_pipeline, tracking, *shell env)
- rviz
- static tf
- vehicle model
> **shell env :** Run nothing here. It is for bag player.

```
tmux-stop-sdc2-test
```
It will forced-stop the tmux session above.

---

The following command batch-executes the same ROS 2 topic command (defaulting to hz) by reading all *.topic files in the current directory, and opens a separate window for each topic.
```
tmux-evaluate-ros2-topic
```
