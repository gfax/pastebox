# Set path to app that will be used to configure unicorn.
@dir = '/srv/your_app/' # Why don't more Linux distros use /srv/ like Arch? ;]

worker_processes 4
working_directory @dir

timeout 25

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen @dir + 'unicorn.sock', :backlog => 64

# Set process id path
pid @dir + 'unicorn.pid'

# Set log file paths
#stderr_path 'log/unicorn.error.log'
#stdout_path 'log/unicorn.access.log'
