#!/usr/bin/env python3
import subprocess
import re
import xml.etree.ElementTree as ET
from pathlib import Path

workdir = Path(__file__).resolve().parent
name = "foreman-isc.lan"
xml_text = subprocess.check_output(
    ["virsh", "-c", "qemu:///system", "net-dumpxml", name], text=True
)
network = ET.fromstring(xml_text)
bridge = network.find("bridge")
if bridge is None or bridge.get("name") != "virbr66":
    raise SystemExit("The active network does not use the expected bridge virbr66.")
if network.find("./ip/dhcp") is not None:
    raise SystemExit(
        "The active libvirt network has a DHCP range configured. "
        "Kea was not started to avoid two DHCP servers on virbr66."
    )

info = subprocess.check_output(
    ["virsh", "-c", "qemu:///system", "net-info", name], text=True
)
if not re.search(r"^\s*Active:\s*yes\s*$", info, re.IGNORECASE | re.MULTILINE):
    result = subprocess.run(
        ["virsh", "-c", "qemu:///system", "net-start", name],
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        info = subprocess.check_output(
            ["virsh", "-c", "qemu:///system", "net-info", name], text=True
        )
        if not re.search(
            r"^\s*Active:\s*yes\s*$", info, re.IGNORECASE | re.MULTILINE
        ):
            raise subprocess.CalledProcessError(
                result.returncode, result.args, result.stdout, result.stderr
            )

print("Preflight passed: foreman-isc.lan is active on virbr66 with no libvirt DHCP range.")
subprocess.run(
    ["podman-compose", "-f", str(workdir / "compose.yaml"), "up", "-d"],
    cwd=workdir,
    check=True,
)
