A simple conky configuration for dom0
=====================================
Conky is a well know tool to display monitoring variables on the desktop and can adopted in many (!) ways.

My current conky setup, showing overall RAM utilization, state of running Qubes, External and VPN IPs, status of Pihole DNS blocks and more:

![conky](https://user-images.githubusercontent.com/831382/220893084-68f96c69-2115-483a-b468-d420a2fac329.png)

A good impression what can be done with conky can be found here;

Top 15 Best Conky Themes for Linux Desktop Available Right Now
https://www.ubuntupit.com/best-conky-themes-for-linux/

Thanks
------
This setup was heavily (!) inspired from https://github.com/3hhh/qubes-conky.
Jump over and leave a star there.
You can also find some other interesting qubes stuff there!

Install conky in dom0
---------------------
Warning:
In order to use conky in Qubes OS dom0 you must install additional packages in dom0.
```
sudo qubes-dom0-update conky
```

conky configuration
-------------------
This is an example for a simple conky-configuration, it contains of a helper script "xenmem-conky" and the config-file "qubes-conky.conf".

Attention:
This conky configuration will also show the external IP adress of sys-net ("real external IP") and the external IP of my firewall sys-fw1 behind a VPN-Qube ("external IP through VPN"). Please change the name of your sys-VMs accordingly. 
In order to resolve the external IP, the wget command is used and must therefore be available in the AppVM/TemplateVM.

### qubes-conky.conf
keep in mind, that you might need to replace the names of specific VMs in order to get the desired results.
(in my case: sys-net/sys-fw1/sys-fw2/sys-pihole1)
```
[user@dom0 ~]$ cat /etc/conky/conky.conf
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 0,
    border_outer_margin=0,
    border_inner_margin=5,
    gap_y = 50,
    gap_x = 17,
    minimum_width = 500,
	color0 = '#999999',
	color1 = '#cccccc',
	color2 = '#ff0000',
	color3 = '#00ff00',
	color4 = '#0000ff',
	color5 = '#ffcc00',
	color6 = '#ccff00',
	color7 = '#0099cc',
	color8 = '#cc9900',
	color9 = '#333333',
    --cpu_avg_samples = 4,
	--default_color = 'white',
	--default_bar_height = 6,
	--default_bar_width = 0,
	--default_gauge_height = 20,
	--default_gauge_width = 40,
	--default_graph_height = 20,
	--default_graph_width = ,
    --default_outline_color = 'white',
    --default_shade_color = 'white',
	--disable_auto_reload = true,
	--diskio_avg_samples = 3,
	--display = ,
	--xinerama_head = ,
	double_buffer = true,
    draw_borders = false,
    --draw_graph_borders = true,
    --draw_outline = false,
    --draw_shades = false,
    --extra_newline = false,
    font = 'NotoSansMonoCJKSC:size=9',
	--http_refresh = false,
	if_up_strictness = 'link',
	--max_text_width = 0,
	--max_user_text = 16384,
	--maximum_width = ,
    --minimum_height = 5,
	--minimum_width = 5,
    --net_avg_samples = 4,
    --no_buffers = true,
	--nvidia_display = ,
    --out_to_console = false,
	--out_to_http = false,
	--out_to_ncurses = false,
    --out_to_stderr = false,
	--out_to_x = true,
	--override_utf8_locale = true,
    own_window = true,
    own_window_type = 'desktop',
    own_window_class = 'Conky',
	--own_window_colour = '#000000',
	--own_window_title = 'conky0 (<hostname>)',
    own_window_argb_visual = true,
    own_window_argb_value = 64,
    own_window_transparent = true,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
	--short_units = true,
    --show_graph_scale = false,
    --show_graph_range = false,
    --stippled_borders = 0,
	--text_buffer_size = 256,
	--top_cpu_separate = true,
	--top_name_verbose = true,
	--top_name_width = 15,
	--total_run_times = 0,
    update_interval = 30,
    update_interval_on_battery = 60,
    use_spacer = 'none',
    use_xft = true,
}


conky.text = [[
${color grey}Uptime: $color$uptime \
${goto 225}${color grey}Fan  : $color${exec sensors|grep -Eo '[0-9]+ RPM'|head -n1} \
${alignr 10}${color grey}Temperature: $color${acpitemp}℃ 
${color grey}Battery: $color${exec upower -d | grep "percentage" | tail -1 | awk '{ print $2 }' | grep -o '[0-9]*\.[0-9]' }% \
${goto 225}${color grey}Drain: $color${exec upower -d | grep "energy-rate"   | tail -1 | awk '{ print $2 }'} W/h \
${alignr 10}${color grey}Remaining: $color${exec upower -d | grep "time to empty" | head -1 | awk '{ print $4 }'} ${exec upower -d | grep "time to empty" | tail -1 | gawk '{ print $5 }'}
${color grey}$hr
${color #ffff00}CPU:${goto 55}$cpu%${goto 110}${freq} MHz\
${alignr 25}${color #00ff00}RAM dom0: $memperc% = $mem / $memmax
${color #ff3300}${goto 55}Load: ${loadavg}\
${alignr 25}${color #00ff00}Xen: ${execp /etc/conky/xenmem-conky.sh}
${color #88cc00}${cpugraph 60,260 00ff00 ff0000} \
${color #88cc00}${memgraph 60,260 00ff00 ff0000}
${color grey}Swap Usage: $swapperc% = $swap/$swapmax \
${goto 270}${color grey}${swapbar 4 00ff00 ff0000}
${color grey}$hr
${color grey}sys-net: $color${exec qvm-run --auto --pass-io --no-gui sys-net 'wget -4 -q -O - https://ipv4.icanhazip.com'} \
${alignr 10}${color grey}sys-fw1 (VPN): $color${exec qvm-run --auto --pass-io --no-gui sys-fw1 'wget -4 -q -O - https://ipv4.icanhazip.com'}
${color grey}DNS Queries: $color${exec qvm-run --pass-io sys-pihole1 'echo ">stats >quit" | nc localhost 4711' | grep dns_queries_today | gawk '{ print $2 }'} \
${goto 225}${color grey}Blocked: $color${exec qvm-run --pass-io sys-pihole1 'echo ">stats >quit" | nc localhost 4711' | grep ads_blocked_today | gawk '{ print $2 }'} \
${alignr 10}${color grey}Percentage: $color${exec qvm-run --pass-io sys-pihole1 'echo ">stats >quit" | nc localhost 4711' | grep ads_percentage_today | gawk '{ print $2 }' | grep -o '[0-9]*\.[0-9]'}%
${color grey}$hr
${color grey}Processes:$color $processes  \
${color grey}Running:$color $running_processes

${color yellow}Highest CPU${goto 140}PID${goto 220}CPU%${goto 270}|${goto 280}${color green}Highest MEM${goto 400}PID${goto 480}MEM%
${color grey}${top name 1}${goto 140}${top pid 1}${goto 220}${top cpu 1}${goto 270}|${goto 280}${color grey}${top_mem name 1}${goto 400}${top_mem pid 1}${goto 480}${top_mem mem 1}
${color grey}${top name 2}${goto 140}${top pid 2}${goto 220}${top cpu 2}${goto 270}|${goto 280}${color grey}${top_mem name 2}${goto 400}${top_mem pid 2}${goto 480}${top_mem mem 2}
${color grey}${top name 3}${goto 140}${top pid 3}${goto 220}${top cpu 3}${goto 270}|${goto 280}${color grey}${top_mem name 3}${goto 400}${top_mem pid 3}${goto 480}${top_mem mem 3}
${color grey}${top name 4}${goto 140}${top pid 4}${goto 220}${top cpu 4}${goto 270}|${goto 280}${color grey}${top_mem name 4}${goto 400}${top_mem pid 4}${goto 480}${top_mem mem 4}
${color grey}${top name 5}${goto 140}${top pid 5}${goto 220}${top cpu 5}${goto 270}|${goto 280}${color grey}${top_mem name 5}${goto 400}${top_mem pid 5}${goto 480}${top_mem mem 5}
${color grey}$hr
${color grey}Qubes VM performance:
${color grey}${execp xentop -f -b -i2 -d5 | tail -n+2 | sed -r -n '/NAME/,$ p' |  sed -r -n 's/^\s*([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+.*$/\1${goto 140}\4${goto 220}\9${goto 300}\6${goto 400}\8/p'}

]]
```
This will assume that the helper script (which will calculate the RAM usage from xen) is located in the same directory like qubes-conky.conf.
If this is not the case, please adapt the config.

xenmem-conky
------------
This script will calculate the used RAM which is used by your AppVMs.
Make sure to make this script executable via chmod +x xenmem-conky.

Warning: Never ever install any script in dom0, make them executable or use them in any configuration just because a random guy at GitHub is telling you, to do this.
Always try to understand what exactly the script is doing, maybe run in manually step by step and then - if you know it is secure - use it.
(in this case its easy to understand what the script is doing :-)`
```
#!/bin/bash
# one7two99 - https://www.github.com/one7two99
# Extract Xen memory info for conky.
# version: 0.1
# date: 01/28/2023
# based on the script from David Hobach version 0.1
# Ouput Example: 71% = 23.2 GiB / 32.4 GiB

# get free RAM from the xl info command
free_mem=`xl info | grep free_memory | gawk '{ print $3 }'`
# get total RAM from the xl info command
total_mem=`xl info | grep total_memory | gawk '{ print $3 }'`
# calculate used RAM
used_mem=$(( $total_mem - $free_mem ))
# calculate used RAM in percent
used_memp=$(( 100 * $used_mem / $total_mem ))
# put everything together and create a nice output (which will then be used by conky)
printf '%s%% = %s.%.1s GiB / %s.%.1s GiB\n' "$used_memp" $(( $used_mem / 1000 )) $(( $used_mem % 1000 )) $(( $total_mem / 1000 )) $(( $total_mem % 1000 ))
```

How to start conky
------------------
You can start conky with the above configuration by referencing the config file manually (if you don't want to but it in the default config directory).

```
conky -c <DIRECTORY>/qubes-conky.conf
```
