# -*- mode: ruby -*-
# vi: set ft=ruby :

#####################################################################################
# Configuration settings
#####################################################################################
machine_name = "Vagrant out-of-memory test"
hyperv_switch = "Default Switch"

#####################################################################################

Vagrant.configure("2") do |config|
  # The name specified here is used for logging
  config.vm.define machine_name

  # Name of box to install with
  config.vm.box = "mwrock/Windows2016"

  # Communicator type
  config.vm.communicator = "winrm"

  # Guest OS
  config.vm.guest = :windows
  config.windows.halt_timeout = 15

  # Config networks on guest.
  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
  
  # The time in seconds that Vagrant will wait for the machine to boot and be accessible
  config.vm.boot_timeout = 300

  # Admin user name and password
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

  # The amount of time that is allowed to complete task
  config.winrm.execution_time_limit = "PT6H" # 6 Hours

  # The maximum amount of time to wait for a response from the endpoint
  config.winrm.timeout = 5400 # seconds

  # VirtualBox configuration
  config.vm.provider :virtualbox do |vb, override|
    # The name specified here is used for the name of the generated VM
    vb.name = machine_name
    vb.gui = true
    vb.cpus = 4
    vb.memory = 20480
    vb.maxmemory = 32768
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]

    if defined? VagrantVbguest
      # Update VirtualBox Guest Additions if required
      config.vbguest.auto_update = true

      # Reboot the VM if VirtualBox Guest Additions are updated
      config.vbguest.auto_reboot = true
    end
  end

  # Hyperv configuration
  config.vm.provider :hyperv do |h|
    h.vmname = machine_name
    h.cpus = 4
    h.memory = 20480
    h.maxmemory = 32768

    # Specify the virtual switch we want to use
    config.vm.network "public_network", bridge: hyperv_switch
  end

  # Disable the shared folder as it doesn't work on Hyper-V
  config.vm.synced_folder ".", "/vagrant", disabled: true

  #####################################################################################
  # Provisioners
  #####################################################################################

  #====================================================================================
  # Copy files to guest
  #====================================================================================
  # Move scripts to documents folder
  config.vm.provision "Copy scripts", type: "file", source: "scripts", destination: "scripts"

  #====================================================================================
  # Configure the machine
  #====================================================================================
  config.vm.provision "Give PowerShell admin rights",
    privileged: false,
    type: "shell",
    inline: %q"Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force -Scope CurrentUser",
    powershell_args: "-ExecutionPolicy Unrestricted"

  #====================================================================================
  # Install software
  #====================================================================================
  config.vm.provision "Install choco", privileged: false, type: "shell", path: "scripts/install-choco.ps1"

  #config.vm.provision "Install Visual Studio", privileged: false, type: "shell", path: "scripts/install-visual-studio.ps1"
  #config.vm.provision "Reboot after installing Visual Studio", privileged: false, type: "shell", inline: "", reboot: true
  config.vm.provision "Install ReSharper", privileged: true, type: "shell", inline: "cinst -y --no-progress resharper" # Must be run with privileged: true to avoid inexplicable 'Out of memory'
end
