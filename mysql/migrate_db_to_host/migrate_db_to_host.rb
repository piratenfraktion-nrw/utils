#!/usr/bin/env ruby

PORT_SRC = 61921
PORT_DST = 61922

USER_SRC = ARGV[0]
USER_DST = ARGV[1]
DB_NAME = ARGV[2]
REMOTE_SRC = ARGV[3]
REMOTE_DST = ARGV[4]

DB_USER_SRC = ARGV[5]
DB_USER_DST = ARGV[6]
DB_PASS_SRC = ARGV[7]
DB_PASS_DST = ARGV[8]

if ARGV.length != 9
  puts "usage: migrate_db_to_host.rb <src_user> <dst_user> <src_remote> <dst_remote> <src_db_user> <dst_db_user> <src_db_pass> <dst_db_pass>"
  exit 1
end

def build_cmd(user, remote, port)
  cmd = "ssh -N -o 'ServerAliveInterval 60' -o 'ServerAliveCountMax 3' -L #{port}:#{remote}:3306 #{user}"
  puts cmd
  cmd
end

tun_src = fork { exec build_cmd(USER_SRC, REMOTE_SRC, PORT_SRC) }
tun_dst = fork { exec build_cmd(USER_DST, REMOTE_DST, PORT_DST) }

`sleep 5`

migrate_cmd = "mysqldump -h'127.0.0.1' --port=#{PORT_SRC} -u'#{DB_USER_SRC}' -p'#{DB_PASS_SRC}' '#{DB_NAME}' | mysql -h'127.0.0.1' --port=#{PORT_DST} -u'#{DB_USER_DST}' -p'#{DB_PASS_DST}' '#{DB_NAME}'"

puts migrate_cmd

`#{migrate_cmd}`

Process.kill 9, tun_src
Process.kill 9, tun_dst
Process.wait tun_src
Process.wait tun_dst


