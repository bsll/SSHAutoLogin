# SSHAutoLogin
fork自别人的登录脚本(https://github.com/jiangxianli/SSHAutoLogin)，这里做了自定义的一些修改,对于常用的服务器通常记住的是简称，或者ip最后一位，所以修改一下利用简称登录
## 添加配置
在ssh_login文件中，修改以下配置
```shell
    CONFIGS=(
    "服务器名称 端口号 IP地址 登录用户名 登录密码/秘钥文件Key 秘钥文件地址"
    "服务器名称 端口号 IP地址 登录用户名 登录密码"
)
```
比如可以修改成：
```shell
    CONFIGS=(
    "服务器名称 22 220.181.57.217 root passphrase key ~/private_key.pem"
    "67 22 192.168.1.67 root 67"
)
```
或者在脚本同目录下新建一个文件server_config,按照以上格式写入文件，每个配置单独一行如下：
```
服务器名称 22 220.181.57.217 root passphrase key ~/private_key.pem
67 22 192.168.1.67 root 67test
```
## 使用
1).给ssh_login文件执行的权限,并执行ssh_login
```shell
  chmod u+x ssh_login
  ./ssh_login
```
2).可以将ssh_login 软连接到 /usr/local ,之后便可以在终端中全局使用ssh_login
```shell
  chmod u+x ssh_login
  ln -s ssh_login /usr/local/
  ssh_login
```
3).命令使用

`ssh_login list` - 查看所有服务器配置

`ssh_login name` - 登录简称为name的服务器


## 提示
使用本脚本前，请确认已安装expect

1) Linux 下 安装expect
```shell
 yum install expect
```
2) Mac 下 安装expect
```shell
 brew install homebrew/dupes/expect
```

## 特殊说明
如果密码中含有以下特殊字符，请按照一下规则转义：
- \ 需转义为 \\\\\
- } 需转义为 \\}
- [ 需转义为 \\[
- $ 需转义为 \\\\\\$
- \` 需转义为 \\`
- " 需转义为 \\\\\\"

```
如密码为'-OU[]98' 在CONFIG配置中写成'-OU\[]98'
否则，提示要手动输入密码
```
