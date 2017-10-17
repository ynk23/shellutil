1 #!/usr/bin/expect -f
  2 if { $argc != 2 } {
  3   puts "usage : autoauth PASSWORD COMMAND"
  4   exit 1
  5 }
  6
  7 set PASSWORD [ lindex $argv 0 ]
  8 set CMD [ lindex $argv 1 ]
  9 set prompt "\[#$%>\]"
 10 set timeout -1
 11
 12 eval spawn $CMD
 13 expect {
 14   # accept fingureprint
 15   -glob "Are you sure you want to continue connecting (yes/no)?" {
 16     send "yes\r"
 17     exp_continue
 18   }
 19   # send password
 20   -glob "password:" {
 21     send -- "$PASSWORD\r"
 22     exp_continue
 23   }
 24   # no prompt password
 25   # case. use auth key
 26   eof {
 27     catch wait result
 28     set OS_ERROR [ lindex $result 2 ]; # OS_ERROR code
 29     if { $OS_ERROR == -1 } {
 30       send_user "Fail to exec\n"
 31       exit 127
 32     }
 33     set STATUS [ lindex $result 3 ]; # spawn status code
 34     exit $STATUS
 35   }
 36   # no command executed
 37   # case. $CMD : "ssh <hostname>"
 38   -regexp "$prompt" {
 39     send_user "success autoauth, but no commnad executed\n"
 40     exit 0
 41   }
 42 }
