tar -xaf slurm-20.02.0.tar.bz2
cd slurm-20.02.0/

sudo ./configure
sudo make install
ldconfig -n /usr/local/lib

# Now is a good time to reboot

# Get basic information about the node (your PC) for configuration
slurmd -C > node_info.txt
cat node_info.txt

# Check the version information. It should match the configurator version
slurmd -V

# Create the slurm user
useradd slurm

# Create the necessary directories for the slurm conf
sudo mkdir /var/spool/slurmd
sudo mkdir /var/spool/slurm-llnl
sudo mkdir /var/run/slurm-llnl

# Give ownership of directories to slurm user
sudo chown -R slurm.slurm /var/spool/slurm-llnl
sudo chown -R slurm.slurm /var/run/slurm-llnl

# Open up the configurator tool using your favorite browser
google-chrome /usr/share/doc/slurm-wlm-doc/html/configurator.easy.html

#######################################
# CONFIGURATOR STEPS
# Change the following in the configurator
#
# ControlMachine: your PC's hostname
# NodeName: your PC's hostname
#
# The following values are found from running `slurmd -C`
# CPUs: 24
# ThreadsPerCore: 2
# RealMemory: 32038
#
# State Preservation
# StateSaveLocation: /var/spool/slurm-llnl
#
# Process Tracking
# ProctrackType: Pgid
#
# Process ID Logging
# SlurmctldPidFile: /var/run/slurm-llnl/slurmctld.pid
# SlurmdPidFile: /var/run/slurm-llnl/slurmd.pid
#
#######################################

# After submitting the configurator, copy the output. I saved it into a file
# called `slurm.conf`. Copy this file into `/etc/slurm-llnl/`
sudo mkdir /etc/slurm-llnl
sudo cp slurm.conf /etc/slurm-llnl/

# Start and enable the slurm manager on boot
sudo systemctl start slurmctld
sudo systemctl enable slurmctld

# Start and enable slurmd on boot
sudo systemctl start slurmd
sudo systemctl enable slurmd

# Now is a good time to reboot

# Check slurm nodes
scontrol show node
sinfo
