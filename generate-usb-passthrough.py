import re
import sys
import subprocess
from ruamel.yaml import YAML
from ruamel.yaml.scalarstring import FoldedScalarString

result = subprocess.run(
    ["lsusb"],
    capture_output=True,        # Capture stdout and stderr
    text=True                   # Return output as string (instead of bytes)
)



yaml = YAML()
yaml.width = 1000
compose = yaml.load("""
services:
    windows: 
        environment: {} 
        devices: []
""")

device_index = 0
fold_pos = []
ARGUMENTS = ""

for line in result.stdout.split('\n'):
    m = re.match(r'Bus ([\d]+) Device ([\d]+): ID ([\da-z]+):([\da-z]+)[\s]*(.*)', line)
    if m:
        data = {
          'device': f'/dev/bus/usb/{m.group(1)}/{m.group(2)}',
          'vendorid': f'0x{m.group(3)}',
          'productid': f'0x{m.group(4)}',
          'name': m.group(5).strip()
        }
        
        compose['services']['windows']["devices"].append(data['device'])
        compose['services']['windows']["devices"].yaml_add_eol_comment(data['name'], device_index)
         
        device = f'-device usb-host,vendorid={data["vendorid"]},productid={data["productid"]} '
        ARGUMENTS += device
        device_index += 1
        prev = fold_pos[-1] if len(fold_pos) > 1 else 0
        fold_pos.append(len(ARGUMENTS) -1)

del fold_pos[-1]
args = FoldedScalarString(ARGUMENTS)
args.fold_pos = fold_pos
compose['services']['windows']['environment']['ARGUMENTS'] = args
compose['services']['windows']['environment'].yaml_set_start_comment("Ordered to match devices entries (for convenience).\nDevice and Vendor ID values found using `lsusb`", indent=4)
compose['services']['windows']["devices"].yaml_set_start_comment("formatted as '/dev/bus/usb/{Bus}/{Device}' with values from `lsusb`.\nDevice name comments provided for convenience", indent=4)

yaml.dump(compose, sys.stdout)
#print(compose)

