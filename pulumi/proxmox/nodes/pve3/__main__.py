"""A Python Pulumi program"""

import pulumi
import os

import pulumi_proxmoxve as proxmox

provider = proxmox.Provider(
    "proxmoxve",
    endpoint=os.environ["PROXMOX_VE_ENDPOINT"],
    insecure=os.environ.get("PROXMOX_VE_INSECURE") == "true",
    username=os.environ["PROXMOX_VE_USERNAME"],
    password=os.environ["PROXMOX_VE_PASSWORD"]
)

# List of random hostnames
hostnames = ["issa", "nubia", "rambeau"]
config = pulumi.Config()
vm_password = config.get_secret("vm-password")

for hostname in hostnames:
    virtual_machine = proxmox.vm.VirtualMachine(
        resource_name=f"vm_{hostname}",
        name=hostname,
        node_name="pve3",
        agent=proxmox.vm.VirtualMachineAgentArgs(
            enabled=False,
            trim=True,
            type="virtio"
        ),
        bios="seabios",
        cpu=proxmox.vm.VirtualMachineCpuArgs(
            cores=2,
            sockets=1
        ),
        clone=proxmox.vm.VirtualMachineCloneArgs(
            node_name="pve3",
            vm_id=8005, 
            full=True
        ),
        disks=[
            proxmox.vm.VirtualMachineDiskArgs(
                interface="scsi0",
                datastore_id="local-lvm",
                size=22,
                file_format="qcow2",
                cache="writeback"
            )
        ],
        memory=proxmox.vm.VirtualMachineMemoryArgs(
            dedicated=8192
        ),
        network_devices=[
            proxmox.vm.VirtualMachineNetworkDeviceArgs(
                bridge="vmbr0",
                model="virtio"
            )
        ],
        on_boot=True,
        operating_system=proxmox.vm.VirtualMachineOperatingSystemArgs(type="l26"),  # Specify appropriate OS type
        initialization=proxmox.vm.VirtualMachineInitializationArgs(
            type="nocloud",
            datastore_id="local-lvm",
            dns=proxmox.vm.VirtualMachineInitializationDnsArgs(
                domain="mambalab.live",
                server="192.168.1.42"
            ),
            ip_configs=[
                proxmox.vm.VirtualMachineInitializationIpConfigArgs(
                    ipv4=proxmox.vm.VirtualMachineInitializationIpConfigIpv4Args(
                        address=f"192.168.1.{121 + hostnames.index(hostname)}/24",  # Increment IP address based on hostname index
                        gateway="192.168.1.1"
                    ),
                )
            ],
            user_account=proxmox.vm.VirtualMachineInitializationUserAccountArgs(
                username="k3admin",
                password=vm_password
            )
        )
    )
