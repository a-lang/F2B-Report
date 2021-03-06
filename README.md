Fail2Ban Web Report
================
![image](https://raw.githubusercontent.com/a-lang/F2B-Report/master/Screenshot.png)
Requirement
------------
* CentOS 5.x
* Fail2Ban Installed
* Web Server engine such as Apache or something like that
* No need of Database

How to use it?
---------------
1. Install the following packages.
 
 ```
 yum install git sysstat
 yum install GeoIP
 ```
2. Clone it to the computer  
 `git clone https://github.com/a-lang/F2B-Report.git` 
3. Using the git to monitor a few important system files such as /etc/passwd, /etc/group, etc.  
 The list of the files I added:
 
 ```
 cd /  
 git init
 git add /etc/passwd
 git add /etc/group
 git add /etc/shadow
 git add /etc/gshadow*
 git add /etc/httpd/conf*
 git add /etc/ssh/ssh*config
 git add /bin
 git add /etc/fstab
 git add /etc/crontab
 git add /etc/yum.repos.d/
 git add /etc/host*
 git add /etc/init.d/ 
 git commit -m "whatever message" 
 ```
4. Copy the directory html to your web directory such as /var/www/html  
 `cp F2B-Report/html /var/www/html/f2b_report`
5. Copy the file gen.sh to any directory other than the web directory.
 - In this case, I created a directory /var/www/scripts
 ```
 mkdir /var/www/scripts
 cp F2B-Report/gen.sh /var/www/scripts 
 ```
 - Modify the gen.sh as you needed
 ```
 F2BLOG_ALL="/var/log/fail2ban*"
 F2BLOG_LATEST="/var/log/fail2ban.log"
 OUTDIR="/var/www/html/f2b_report"
 ```
6. Create a cron job to execute the file gen.sh periodically.  
 The gen.sh would generate all raw data of the report and saving them as data.json on $OUTDIR directory.
 ```
 crontab -e
 
 */5 * * * * bash /var/www/scripts/gen.sh > /dev/null 2>&1
 ```

Integration with PBXinFlash (Optional)
--------------------------------------
- Editing the menu of PBXinFlash
```
cp F2B-Report/ico_Fail2ban.png /var/www/html/welcome/
vi /var/www/html/welcome/.htindex.cfg
```
- Inserting the line below
```
2,f2b_report,./f2b_report/,Fail2Ban Report,ico_Fail2ban.png
```
![image](https://raw.githubusercontent.com/a-lang/F2B-Report/master/Screenshot2.png)

Hoping you enjoy it !

