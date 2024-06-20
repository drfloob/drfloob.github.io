---
title: "Slow Linux boot? Start your desktop environment without waiting for a network connection."
date: 2020-05-30T22:05:07-07:00
draft: true
tags: ["archlinux", "systemd"]
keywords: ["", ""]
description: ""
---

I found myself waiting 30-45 seconds for my archlinux install to boot as soon as I enabled Wifi connection at boot time. Disabling it with `systemctl disable dhcpcd.service` but my boot time back in the sub-10s range, but I didn't want to manually connect to the internet every time I rebooted, so I had to find a workaround.

It turns out the default systemd configuration ties together network and graphical boot ordering pretty tightly, with `graphical.target` depending transitivetly on `dhcpcd.target` when enabled.


## DISABLED MY AWESOMENESS

➜  ~ sudo systemctl disable dhcpcd-after-user.service
[sudo] password for hork: 
Removed /etc/systemd/system/custom-dhcpcd.target.wants/dhcpcd-after-user.service.
➜  ~ sudo systemctl enable dhcpcd.service    
Created symlink /etc/systemd/system/multi-user.target.wants/dhcpcd.service → /usr/lib/systemd/system/dhcpcd.service.
➜  ~ sudo systemctl get-default                      
custom-dhcpcd.target
➜  ~ sudo systemctl set-default graphical.target
Removed /etc/systemd/system/default.target.
Created symlink /etc/systemd/system/default.target → /usr/lib/systemd/system/graphical.target.
sudo systemctl disable openvpn-client@mullvad_se_all.service

Stuff:

$ systemctl list-units --type=target
  UNIT                  LOAD   ACTIVE SUB    DESCRIPTION                                        
  basic.target          loaded active active Basic System                                       
  bluetooth.target      loaded active active Bluetooth                                          
  cryptsetup.target     loaded active active Local Encrypted Volumes                            
  custom-dhcpcd.target  loaded active active Custom Target to let graaphical start before DHCPCD
  getty.target          loaded active active Login Prompts                                      
  graphical.target      loaded active active Graphical Interface                                
  local-fs-pre.target   loaded active active Local File Systems (Pre)                           
  local-fs.target       loaded active active Local File Systems                                 
  multi-user.target     loaded active active Multi-User System                                  
  network-online.target loaded active active Network is Online                                  
  network.target        loaded active active Network                                            
  paths.target          loaded active active Paths                                              
  remote-fs.target      loaded active active Remote File Systems                                
  slices.target         loaded active active Slices                                             
  sockets.target        loaded active active Sockets                                            
  sound.target          loaded active active Sound Card                                         
  swap.target           loaded active active Swap                                               
  sysinit.target        loaded active active System Initialization                              
  timers.target         loaded active active Timers


$ systemctl status multi-user.target
● multi-user.target - Multi-User System
     Loaded: loaded (/usr/lib/systemd/system/multi-user.target; static; vendor preset: disabled)
     Active: active since Fri 2020-06-19 14:42:11 PDT; 4 days ago
       Docs: man:systemd.special(7)

$ systemctl get-default 
custom-dhcpcd.target

systemctl enable custom-dhcpcd.target

systemctl set-default custom-dhcpcd.target

systemctl list-unit-files



$ systemctl list-dependencies multi-user.target
multi-user.target
● ├─acpid.service
● ├─dbus.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-user-sessions.service
● ├─basic.target
● │ ├─-.mount
● │ ├─tmp.mount
● │ ├─paths.target
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─dbus.socket
● │ │ ├─dm-event.socket
● │ │ ├─systemd-coredump.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-audit.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ └─systemd-udevd-kernel.socket
● │ ├─sysinit.target
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─kmod-static-nodes.service
● │ │ ├─ldconfig.service
● │ │ ├─lvm2-lvmetad.socket
● │ │ ├─lvm2-lvmpolld.socket
● │ │ ├─lvm2-monitor.service

$ systemctl list-dependencies graphical.target


## FIXED!!! graphical no longer depends on dhcpcd

$ systemd-analyze critical-chain custom-dhcpcd.target
The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.

custom-dhcpcd.target @2.003s
└─graphical.target @2.003s
  └─lightdm.service @1.019s +983ms
    └─systemd-user-sessions.service @995ms +18ms
      └─basic.target @971ms
        └─sockets.target @969ms
          └─dbus.socket @966ms
            └─sysinit.target @944ms
              └─systemd-backlight@backlight:intel_backlight.service @1.764s +9ms
                └─system-systemd\x2dbacklight.slice @1.127s
                  └─system.slice @183ms
                    └─-.slice @183ms

$ cat /etc/systemd/system/custom-dhcpcd.target
[Unit]
Description=Custom Target to let graaphical start before DHCPCD
Requires=graphical.

$ cat /etc/systemd/system/dhcpcd-after-user.service 
[Unit]
Description=dhcpcd on all interfaces
Wants=network.target
After=multi-user.target

[Service]
Type=forking
PIDFile=/run/dhcpcd/pid
ExecStart=/usr/bin/dhcpcd -q -b
ExecStop=/usr/bin/dhcpcd -x

[Install]
WantedBy=custom-dhcpcd.target

