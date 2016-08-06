### Installation (WIP)

1. Install ROS
  * Follow instructions at http://wiki.ros.org/jade/Installation/Ubuntu (ros-jade-desktop-full)	
2. Install ardrone_automation and ardrone_tutorials
  * Read instructions http://robohub.org/up-and-flying-with-the-ar-drone-and-ros-getting-started/
  * Install pre-requisites
  
  ```
  $ sudo apt-get install daemontools libudev-dev libiw-dev
  ```
  
  * Stuff

```
$ roscd
$ pwd
/opt/ros/jade
$ cd share
$ pwd
/opt/ros/jade/share
$ sudo git clone https://github.com/AutonomyLab/ardrone_autonomy.git
$ sudo git clone https://github.com/mikehamer/ardrone_tutorials.git
$ ls
...  ardrone_autonomy  ardrone_tutorials  ...
$ rospack profile
```

  * Compile things

```
$ roscd ardrone_auto<TAB should autocomplete>
$ sudo -s
$ source /opt/ros/jade/setup.bash
$ rosmake -a
$ exit
```
