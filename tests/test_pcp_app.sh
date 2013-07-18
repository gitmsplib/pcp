#!/bin/bash

function echo_exit {
    echo $1
    exit 1
}

echo "########################################"
echo "####        Test pcp cli app       ####"
echo "#######################################"
killall pcp-server

pcp >/tmp/pcp-help.out 2>/dev/null
grep -q Usage: /tmp/pcp-help.out || echo_exit "Failed test of printing command line usage #1"

pcp --help 2>/dev/null | diff -q - /tmp/pcp-help.out ||echo_exit "Failed test of printing command line usage #2"

pcp -h 2>/dev/null | diff -q - /tmp/pcp-help.out || echo_exit "Failed test of printing command line usage #3"

pcp --bad-argument-input 2>/dev/null &>/dev/null &&  echo_exit "Failed test of bad arguments on input #1"

pcp --peer ::0bad:ip6 &>/dev/null &&  echo_exit "Failed test of bad arguments on input #2"

pcp --external ::0bad:ip6 &>/dev/null &&  echo_exit "Failed test of bad arguments on input #3"

pcp --external [::2]:99999  &>/dev/null &&  echo_exit "Failed test of bad arguments on input #4"

pcp --internal [::0bad:ip6]:1234 &>/dev/null &&  echo_exit "Failed test of bad arguments on input #5"

pcp --disable-autodiscovery --server 1.2.3.4:1234 --peer 1.2.3.4:1234 --internal 0.0.0.0:4321 --external 1.1.1.1:4321 --dscp-up 0 --dscp-down 0 --protocol 17 --lifetime 120 --metadata-id 123 --metadata-value haha --metadata-id=22 --metadata-value=a1234567890123456789012345678900123456789a1234567890123456789012345678900123456789a1234567890123456789012345678900123456789a1234567890123456789012345678900123456789a1234567890123456789012345678900123456789a1234567890123456789012345678900123456789a12345678901234567890123456789001234567890000000a12345678901234567890123456789001234567890 --pcp-version 1 --timeout 0 &>/dev/null

[ $? -eq 2 ] || echo_exit "Failed long-opt test"

pcp -T 0 -J 3 -E 3 -L 3 -A p1234567890123456789012345678901234567890 &>/dev/null

[ $? -eq 2 ] || echo_exit "Failed short opt test"

pcp --pcp-version 1 --jitter-tolerance 3 --delay-tolerance 3 --loss-tolerance 3 -T 0 --app-name p1234567890123456789012345678901234567890 &>/dev/null

[ $? -eq 2 ] || echo_exit "Failed learn DSCP options test"

pcp -v 3 --internal :1234 &>/dev/null && echo_exit "Failed in bad pcp-version test #1"

pcp -v 0 --internal :1234 &>/dev/null && echo_exit "Failed in bad pcp-version test #2"

pcp -d &> /dev/null  && echo_exit "Failed in not enough params test"

pcp --pcp-version 3 --internal :1234 &>/dev/null && echo_exit "Failed in bad version test #3"

pcp --pcp-version 0 --internal :1234 &>/dev/null && echo_exit "Failed in bad version test #4"

pcp -v 1 -q &>/dev/null && echo_exit "Failed in bad arg test #1"
pcp - &>/dev/null && echo_exit "Failed in bad argument test #2"

pcp --internal :1234 --jitter-tolerance 1 &>/dev/null && echo_exit "Failed in test of mutual exclusivity of MAP_PEER and SADSCP parameters"

pcp-server --ear 1 &>/dev/null &

sleep 0.1
pcp --server 127.0.0.1 -f --disable-autodiscovery --peer 127.0.0.1:1234 --internal :1234 --device-id --user-id hah --location &>/dev/null

[ $? -eq 0 ] || echo_exit "Failed in test of --device-id --userid --location options"

pcp-server --ear 1 -r 8 &>/dev/null &
sleep 0.1

pcp --server 127.0.0.1 -f --disable-autodiscovery --pcp-version 1 --peer 127.0.0.1:1234 --internal :1234 &>/dev/null

[ $? -eq 3 ] || echo_exit "Failed in recieved short lifetime error"

killall pcp_server &>/dev/null && sleep 0.1

pcp-server --ear 1 -r 3 &>/dev/null &
sleep 0.1

pcp --server 127.0.0.1 -d --pcp-version 1 --peer 127.0.0.1:1111 --fast-return --internal :1234 &>/dev/null

[ $? -eq 4 ] || echo_exit "Failed in recieved error test"

killall pcp_server &>/dev/null && sleep 0.1

pcp-server --ear 1 -r 8 &>/dev/null &

sleep 0.1
pcp --server 127.0.0.1 -f --pcp-version 1 --internal=:1234 &>/dev/null

[ $? -eq 2 -o $? -eq 3 -o $? -eq 4 ] || echo_exit "Failed in partial short lifetime error test."

killall pcp_server &>/dev/null && sleep 0.1

pcp-server --ear 1 -r 3 &>/dev/null &

sleep 0.1
pcp --server 127.0.0.1 --pcp-version 1 --fast-return -i :1234 &>/dev/null

[ $? -eq 2 ] || echo_exit "Failed in partial error test."

killall pcp_server 2>/dev/null &>/dev/null && sleep 0.1

pcp-server --ear 1 &>/dev/null &

sleep 0.1 && pcp -s 127.0.0.1 --pcp-version 2 --fast-return -i :1234 &>/dev/null

[ $? -eq 0 ] || echo_exit "Failed in partial success test."

sleep 0.1
pcp -s 8.8.8.2 --pcp-version 2 --fast-return -i :1234 --timeout 0 &>/dev/null

[ $? -eq 2 ] || echo_exit "Failed in timeout test."

pcp-server --ip ::1 -v 1 --ear 2 &>/dev/null &

sleep 0.1
pcp --pcp-version 2 --server ::1 --internal [::]:1234 --peer [::]:4321 --metadata-id 12 --metadata-value 12345 --fast-return &>/dev/null

[ $? -eq 0 ] || echo_exit "Failed in IPv6 MAP success test."

pcp-server --ip ::1 -v 1 --ear 2 &>/dev/null &

sleep 0.1
pcp --pcp-version 2 -s ::1 -i [::]:1234 -p [::1]:1234 --dscp-up 12 &>/dev/null

[ $? -eq 0 ] || echo_exit "Failed in IPv6 PEER success test."

sleep 0.1
pcp --pcp-version 2 -i [::]:1234 -p [::1]:4321 --metadata-id 10 --metadata-value hhhh --dscp-up 10 --dscp-down 12 &>/dev/null

[ $? -gt 0 ] || echo_exit "Failed in IPv6 PEER failure test."

killall pcp-server &>/dev/null
pcp-server --ear 1 &>/dev/null &
sleep 0.1
pcp -d -s 127.0.0.1 -i :1234 -P &>/dev/null
[ $? -eq 0 ] || echo_exit "Failed sending MAP with PREFER FAILURE option."

pcp-server --ear 1 &>/dev/null &
sleep 0.1
pcp -d -s 127.0.0.1 -i :1234 -p 8.8.8.8:3333 -P &>/dev/null
[ $? -eq 1 ] || echo_exit "Failed testing PEER with PREFER FAILURE option."

pcp-server --ear 1 &>/dev/null &
sleep 0.1
pcp -d -s 127.0.0.1 -i :1234 -F [8.8.8.8/12]:4444 &>/dev/null
[ $? -eq 0 ] || echo_exit "Failed testing MAP with FILTER option."

pcp-server --ear 1 &>/dev/null &
sleep 0.1
pcp -s 127.0.0.1 -i :1234 -p 8.8.8.8:3333 -F [8.8.8.8/12]:4444 &>/dev/null
[ $? -eq 1 ] || echo_exit "Failed testing PEER with FILTER option."

pcp-server --ear 1 &>/dev/null &
pcp-server --ear 1 --ip 127.0.0.2 -r 7 &>/dev/null &
pcp-server --ear 1 --ip 127.0.0.3 -r 11 &>/dev/null &
sleep 0.1
pcp -s 127.0.0.1 -s 127.0.0.2 -s 127.0.0.3 -i :1234 -d &>/dev/null &
[ $? -eq 0 ] || echo_exit "Failed testing different result codes."

exit 0
