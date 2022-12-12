#!/bin/bash
# Script that is run on every start via
# System Tools > Session and Startup > Application Autostart
echo '---' >> /home/user/startup.log
echo `date` >> /home/user/startup.log
echo '---' >> /home/user/startup.log
sudo tlp start &>> /home/user/startup.log
sudo powertop --auto-tune &>> /home/user/startup.log
