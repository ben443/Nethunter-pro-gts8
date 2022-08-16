
#!/bin/bash

ENV="RUNLEVEL=1,LANG=C,DEBIAN_FRONTEND=noninteractive,DEBCONF_NOWARNINGS=yes"

nspawn-exec() {
  systemd-nspawn --bind-ro $qemu_bin -M $machine --capability=cap_setfcap -E $ENV -D $rootfs "$@"
}

