#! /bin/bash

host=xxx.xxx.xxx.xxx
login_name=hoge
password=xxxxxxxx

expect -c "
set timeout -1
spawn ssh -l $login_name $host
expect \"Are you sure you want to continue connecting (yes/no)?\" {
    send \"yes\n\"
    expect \"$login_name@$host's password:\"
    send \"$password\n\"
} \"$login_name@$host's password:\" {
    send \"$password\n\"
} \"Permission denied (publickey,gssapi-keyex,gssapi-with-mic).\" {
    exit
}
interact
"
