##!/bin/bash

# Function : 使用except无需输入密码自动登录ssh # Author   : bsll
# Date     : 2017/09/27
# SourceGithub   : https://github.com/jiangxianli/SSHAutoLogin
# Github   : https://github.com/bsll/SSHAutoLogin
#服务器索引全局变量
#export LC_CTYPE=zh_CN
index=0
#配置服务器
CONFIGS=( "68 22 192.168.2.68 bsll 123456"
)
#读取自定义服务器配置文件（server_config) 列表，合并服务器配置列表
if [ -f server_config ]; then
	while read line
	do
		CONFIGS+=("$line")
	done < server_config
fi

#服务器配置数
CONFIG_LENGTH=${#CONFIGS[*]}  #配置站点个数

if [[ $CONFIG_LENGTH -le 0 ]] ;
then
    echo "未检测到服务器配置项!"
    echo "请在脚本CONFIGS变量中配置或单独创建一个server_config文件并配置"
    exit ;
fi

#服务器配置菜单
function ConfigList(){
    for ((i=0;i<${CONFIG_LENGTH};i++));
    do
        CONFIG=(${CONFIGS[$i]}) #将一维sites字符串赋值到数组
        echo "---${CONFIG[0]}--${CONFIG[2]}---"
    done
}
#选择登录的服务器
function ChooseServer(){
    read serverName
    Search $serverName
    if [ "$index" == -1 ]
    then
        echo "没有找到该服务器，请确认"
        ChooseServer ;
        return ;
    fi
    prefix=${serverName:0:2}
    if [ "$prefix" == "yq" ]
    then
       AutoLogin2 $index;
    else
       AutoLogin $index;
    fi
}
#登录菜单
function LoginMenu(){
    if [  ! -n $1 ]; then
        AutoLogin $1
    else
        echo "-------当前配置的服务器名称---------"
        ConfigList
        echo "请输入您选择登录的服务器简称: "
    fi
}
#自动登录
function AutoLogin(){
    CONFIG=(${CONFIGS[$1]})
    echo "正在登录【${CONFIG[0]}】"

        command="
        expect {
                \"*assword\" {set timeout 6000; send \"${CONFIG[4]}\n\"; exp_continue ; sleep 3; }
                \"*passphrase\" {set timeout 6000; send \"${CONFIG[4]}\r\n\"; exp_continue ; sleep 3; }
                \"yes/no\" {send \"yes\n\"; exp_continue;}
                \"Last*\" {  send_user \"\n成功登录【${CONFIG[0]}】\n\";}
        }
       interact
   ";
   pem=${CONFIG[5]}
   #强制使用密码登录
   #http://blog.lujun9972.win/blog/2017/02/19/%E5%BC%BA%E5%88%B6ssh%E4%BD%BF%E7%94%A8%E5%AF%86%E7%A0%81%E8%AE%A4%E8%AF%81%E7%99%BB%E9%99%86%E6%9C%8D%E5%8A%A1%E5%99%A8/
   if [ -n "$pem" ]
   then
        expect -c "
                spawn ssh -p ${CONFIG[1]} -o PreferredAuthentications=password -i ${CONFIG[5]} ${CONFIG[3]}@${CONFIG[2]} 
                ${command}
        "
        #expect -c "
        #        spawn ssh -p ${CONFIG[1]} -i ${CONFIG[5]} ${CONFIG[3]}@${CONFIG[2]} 
        #        ${command}
        #"
   else
        expect -c "
                spawn ssh -p ${CONFIG[1]} -o PreferredAuthentications=password ${CONFIG[3]}@${CONFIG[2]} 
                ${command}
        "
        #expect -c "
        #        spawn ssh -p ${CONFIG[1]} ${CONFIG[3]}@${CONFIG[2]} 
        #        ${command}
        #"
   fi
    echo "您已退出【${CONFIG[0]}】"

}
#自动登录一起教育带跳板机
function AutoLogin2(){
    CONFIG=(${CONFIGS[$1]})
    echo "正在登录【${CONFIG[0]}】"
    command="
    expect {
            \"net's password\" {set timeout 6000; send \"wxh@846112\r\n\"; exp_continue ; sleep 3; }
            \"10.6.0.147's password\" {set timeout 6000; send \"${CONFIG[4]}\r\n\"; exp_continue ; sleep 3; }
            \"10.6.0.146's password\" {set timeout 6000; send \"${CONFIG[4]}\r\n\"; exp_continue ; sleep 3; }
            \"10.100.9.122's password\" {set timeout 6000; send \"${CONFIG[4]}\r\n\"; exp_continue ; sleep 3; }
            \"10.100.9.121's password\" {set timeout 6000; send \"${CONFIG[4]}\r\n\"; exp_continue ; sleep 3; }
            \"yes/no\" {send \"yes\r\n\"; exp_continue;}
            \"请输入登录跳板机验证标识：\" {send \"17zuoye\r\n\"; exp_continue;}
            \"Last*\" {  send_user \"\n成功登录【${CONFIG[0]}】\n\";}
    }
    interact
    ";
    expect -c "
            spawn ssh -o PreferredAuthentications=password ${CONFIG[2]}
            ${command}
    "
    echo "您已退出【${CONFIG[0]}】"
}

#由于bash3.2不支持关联数组索引，所以要手动搜索
function Search(){
    for ((i=0;i<${CONFIG_LENGTH};i++));
    do
        CONFIG=(${CONFIGS[$i]}) #将一维sites字符串赋值到数组
        if [[ $1 == ${CONFIG[0]} ]]
        then
            index=$i
            break
        else
            index=-1
        fi
    done
}
#ConfigList

# 程序入口 
if [ 1 == $# ]; then
    if [ 'list' == $1 ]; then
        ConfigList
    else
        servername=$1
        Search $1
        if [ "$index" == -1 ]; then
            echo "没有找到该服务器，请确认"
        else
	    prefix=${servername:0:2}
	    if [ "$prefix" == "yq" ]; then
                AutoLogin2 $index
	    else
               AutoLogin $index
	    fi
        fi
    fi  
else    
    LoginMenu   
    ChooseServer 
fi
