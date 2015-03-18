Fail2Ban Web Report
================
![image](https://raw.githubusercontent.com/a-lang/F2B-Report/master/Screenshot.png)
Requirement
------------
* CentOS 5.x
* Fail2Ban Installed
* Web Server engine such as Apache or something like that

How to use it?
---------------
1. Install the following packages.  
 `yum install git sysstat`
2. Clone it to the computer  
 `git clone https://github.com/a-lang/F2B-Report.git` 
3. Using the git to monitor a few important system files such as /etc/passwd, /etc/group, etc.
 - The list of the files I added:
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
4.   
 
Hoping you enjoy it !

