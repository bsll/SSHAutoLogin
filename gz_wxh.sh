#!/bin/bash

# Function : 使用except无需输入密码自动登录ssh # Author   : bsll
# Date     : 2017/09/27
# SourceGithub   : https://github.com/jiangxianli/SSHAutoLogin
# Github   : https://github.com/bsll/SSHAutoLogin
#服务器索引全局变量
#export LC_CTYPE=zh_CN
code="$(oathtool -b --totp *********)"
passwd="********* $code"
group="0"
account="2"
if [ -z "$1" ]; then
  command="
     expect {
          \"assword\" {set timeout 6000; send \"$passwd\r\n\"; exp_continue ; sleep 3; }
          \"Last*\" {  send_user \"\n成功登录【gz】\n\";}
     }
     interact
  ";
else
  server=$1
  command="
     expect {
          \"assword\" {set timeout 6000; send \"$passwd\r\n\"; exp_continue ; sleep 3; }
          \"group\" {set timeout 6000; send \"$group\r\"; exp_continue; sleep 3; }
          \"server\" {set timeout 6000; send \"$server\r\"; exp_continue; sleep 3; }
          \"account\" {set timeout 6000; send \"$account\r\n\"; }
          \"Last*\" {  send_user \"\n成功登录【gz】\n\";exp_continue; sleep 10;}
     }
     interact
  ";
fi
expect -c "
        spawn ssh -o HostKeyAlgorithms=+ssh-rsa -o HostKeyAlgorithms=+ssh-dss -o PreferredAuthentications=password wangxiaohui8@fort.guazi-corp.com
        ${command}
"
echo "您已退出【gz.server】"
