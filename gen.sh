#!/bin/bash

# Set the timer
timer=3600
max=3600
# Update yum /pdate list about every 1 hour.
# And first time it will get list too.
#
F2BLOG_ALL="/var/log/fail2ban*"
F2BLOG_LATEST="/var/log/fail2ban.log"
OUTDIR="/var/www/html/f2b_report2"
#
i=0

while [ $i -lt  3 ]
do

  # Begin
  out="{"

  # Memory & Swap
  # $('#ov2')
  # $('#ov4')
  out=$out`top -bn1 | awk '/Mem:/ {printf("\"Mem\":[%s, %s, %s, %s],", $2, $4, $6, $8)} /Swap:/ {printf("\"Swap\":[%s, %s, %s, %s]", $2, $4, $6, $8)}' | tr -d "k"`
  out=$out","

  # Disk
  # $('#ov3')
  # $('#Disktable')
  # out=$out"\"Disk\":"`df | grep '^/dev/s' | tac | awk 'BEGIN {printf("[")}; {printf("[\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"],", $1, $2, $3, $4, $5)}; END {printf("]")}' | sed 's/,]$/]/'`
  out=$out"\"Disk\":"`df -P | grep -E "^/dev/s|^/dev/mapper" | awk 'BEGIN {printf("[")}; {printf("[\"%s\",\"%s\",\"%s\",\"%s\",\"%s\", \"%s\"],", $1, $2, $3, $4, $5, $6)}; END {printf("]")}' | sed 's/,]$/]/'`
  out=$out","

  # TIME
  # $('#Time')
  # $('#Time2')
  out=$out"\"Time\":"`echo "\"\`date +"%Y/%m/%d %H:%M:%S %z"\`\""`
  out=$out","

  # 不重複User
  # $('#OnlineUser')
  out=$out"\"Users\":"`who | awk '{print $1}'| sort -u | awk 'BEGIN {printf("[")}; {printf("\"%s\",",$1)} END {printf("]")};' | sed "s/,]$/]/"`
  out=$out","

  # Uptime
  # $('#Uptime')
  out=$out"\"Uptime\":"`echo "[\"\`uptime | sed "s/load\ average://" | sed "s/users//" | sed "s/\ //g" | sed "s/day,/day/" | sed "s/,/\\\",\\\"/g"\`\"]"`
  out=$out","

  # CPU_Cores
  # $('#CPU_Cores')
  out=$out$(echo "\"CPU_Cores\":$(($(cat /proc/cpuinfo | grep "processor" | tail -n1 | awk '{printf("%s", $3)}') +1))")
  out=$out","

  # CPU_Name
  # $('#CPU_Name')
  out=$out$(echo "\"CPU_Name\":$(cat /proc/cpuinfo | grep "model name" | head -n1 | awk '{$1=$2=$3=""; printf("\"%s\"", $0)}')")
  out=$out","

  # Network
  # $('#net')
  out=$out"\"Network\":"`sar -n DEV 1 1 | tail -n \`ip -o addr | awk '{print $2}' | sed "s/://g" | sort -u | wc -l\` | awk 'BEGIN {printf("[")}; {$1=""; printf("[\"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\"],",$2,$3,$4,$5,$6,$7,$8)} END {printf("]")};' | sed "s/],]$/]]/"`
  out=$out","

  # CPU
  # $('#ov1')
  # $('#CPUtable')
  out=$out"\"CPUs\":"`mpstat -P ALL | sed -n '/all/,$p' | awk 'BEGIN {printf("[")} {printf("[\"%s\", %s, %s, %s, %s, %s, %s, %s, %s, %s],", $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)} END {printf("]")}' | sed "s/,\]/\]/"`
  out=$out","

  # Top 10 CPU process
  # $('#Process_10T_Mem_Table')
  out=$out"\"Process_10T_CPU\":"`ps -eo pid,%cpu,fuser,comm --sort -%cpu | sed -n 2,11p | awk 'BEGIN {printf("[")}; {printf("[\"%s\", \"%s\", \"%s\",\"%s\"],",$1,$2,$3,$4)} END {printf("]")}' | sed "s/],]$/]]/"`
  out=$out","

  # Top 10 Memory process
  # $('#Process_10T_CPU_Table')
  out=$out"\"Process_10T_Mem\":"`ps -eo pid,%mem,fuser,comm --sort -%mem | sed -n 2,11p | awk 'BEGIN {printf("[")}; {printf("[\"%s\", \"%s\", \"%s\",\"%s\"],",$1,$2,$3,$4)} END {printf("]")}' | sed "s/],]$/]]/"`
  out=$out","

  # Fail2Ban Report - Top 10 Latest Attacks today
  # $('#F2B_10T_Attack_Table')
  # Showing up the country
  out=$out"\"F2B_10T_Attack\":"`grep "Ban " $F2BLOG_LATEST |  awk -F[\ \:] '{print $10,$8}' | sort | uniq -c | sort -n | tail -10 | sort -rn | while read c ip svc;do \
  country=$(/usr/bin/geoiplookup $ip | grep "Country" | awk '{print $5}'); \
  echo $c $ip $country $svc; done | awk 'BEGIN {printf("[")} {printf("[%s, \"%s\", \"%s\", \"%s\"],", $1, $2, $3, $4)} END {printf("]")}' | sed "s/,\]/\]/"`
  out=$out","

  # Fail2Ban Report - Top 10 Banned IP addresses recently
  # Showing up the country
  out=$out"\"F2B_10T_IP\":"`grep "Ban " $F2BLOG_ALL |  awk -F[\ \:] '{print $11,$9}' | sort | uniq -c | sort -n | tail -10 | sort -rn | while read c ip svc;do \
  country=$(/usr/bin/geoiplookup $ip | grep "Country" | awk '{print $5}'); \
  echo $c $ip $country $svc; done | awk 'BEGIN {printf("[")} {printf("[%s, \"%s\", \"%s\", \"%s\"],", $1, $2, $3, $4)} END {printf("]")}' | sed "s/,\]/\]/"`
  out=$out","

  # Fail2Ban Report - Top 10 Banned subnet recently
   out=$out"\"F2B_10T_NET\":"`grep "Ban " $F2BLOG_ALL | awk '{print $NF}' | awk -F\. '{print $1"."$2"."}' | sort | uniq -c | sort -n | tail -10 | sort -nr | awk 'BEGIN {printf("[")} {printf("[%s, \"%s0.0\"],", $1, $2)} END {printf("]")}' | sed "s/,\]/\]/"`
  out=$out","

  # Fail2Ban Report - Being attacked service by day
  #out=$out"\"F2B_SVC_DAY\":"`grep "Ban " $F2BLOG_ALL | awk -F'[:,[:space:]]+' '{print $9,$2}' | sort | uniq -c | awk 'BEGIN {printf("[")} {printf("[%s, \"%s\", \"%s\"],", $1, $2, $3)} END {printf("]")}' | sed "s/,\]/\]/"`
  tmp1=`grep "Ban " $F2BLOG_ALL | awk -F'[:,[:space:]]+' '{print $9,$2}' | sort | uniq -c | sed -n '/ssh/p' | tail -5`
  tmp2=`grep "Ban " $F2BLOG_ALL | awk -F'[:,[:space:]]+' '{print $9,$2}' | sort | uniq -c | sed -n '/asterisk/p' | tail -5`
  out=$out"\"F2B_SVC_DAY\":"`echo -e "$tmp1\n$tmp2" | awk 'BEGIN {printf("[")} {printf("[%s, \"%s\", \"%s\"],", $1, $2, $3)} END {printf("]")}' | sed "s/,\]/\]/"`
  out=$out","

  # Last Error
  # $('#LErr')
  # $('#Last_10_Error_Table')
  out=$out"\"LastError\":"`dmesg | grep -E 'Error|error' | tail -n 10 | tac | sed 's/\\\\/\\\\\\\\/g' | awk 'NR > 1 {printf(", ")} BEGIN {printf("[")}; {printf("\"%s\"",$0)} END {printf("]")};'`
  out=$out","

  # Last Warning
  # $('#LWar')
  # $('#Last_10_War_Table')
  out=$out"\"LastWar\":"`dmesg | grep -E 'Warning|warning' | tail -n 10 | tac | sed 's/\\\\/\\\\\\\\/g' | awk 'NR > 1 {printf(", ")} BEGIN {printf("[")}; {printf("\"%s\"",$0)} END {printf("]")};'`
  out=$out","

  # Changed Files
  # $('Files_Table')
  cd /
  out=$out"\"Files\":"`git status | grep -e "modified\|deleted" | awk 'BEGIN {printf("[")} NR > 1 {printf(", ")} {printf("[\"%s\", \"/%s\"]", $2, $3)} END {printf("]")}' | sed "s/:\",/\",/g"`
  out=$out","
  cd - > /dev/null


  # Yum update
  # $('#Updatetable')
  if [ $timer -eq $max ]
  then
    echo "Getting Update List, Please wait."
    timer=0
    yum=`yum check-update | grep 'updates' | sed '/updates:/d' | awk 'BEGIN {printf("[")}; {printf("[\"%s\",\"%s\",\"%s\"]",$1,$2,$3)}; END {printf("]")}' | sed "s/\]\[/\],\[/g"`
  else
    ((timer++))
  fi
  out=$out"\"Update\":"$yum

  # End
  out=$out"}"

  # Echo all data to file
  echo "Writing the data into the json file"
  echo $out > $OUTDIR/data.json
  ((i++))
done
