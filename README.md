# Windows Compose
Windows installed and configured using podman-compose and based on the `docurr/windows` image.

This build focuses on post install configuration and USB passthrough with the usecase being to create 
an environment to run LightBurn (which no longer releasing a linux variety) that is capable of using host
USB to access the laser and laser camera.

This build focuses on running rootless with SeLinux enabled and is tested on Fedora.

# Configure Compose.yaml
Minimally ensure you configure a user password by configuring it directly in the
compose file or setting an environment variable

# Configuring USB
Documentation on the `docurr/windows` project shows how to configure the `compose.yaml`
file to passthrough USB devices to the windows instance.

Alternatively, you may run `generate-usb-passthrough.py` and merge the resulting yaml into 
the `compose.yaml` file.  NOTE: this will create entries for every USB device.
You will likely want to pair down the list: 
removing `ARGUMENTS` entries along with their corresponding `devices` entry
