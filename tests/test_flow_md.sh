#!/bin/bash
echo "########################################"
echo "####   ***********************     ####"
echo "####   * Begin Flow MD test  *     ####"
echo "####   ***********************     ####"
echo "#######################################"
killall  pcp-server
pcp-server --ear 1 --ip ::1 >/dev/null &
sleep 0.1
$VALGRIND pcp --server ::1 --peer [::1]:1234 --internal :1234 --metadata-id=95 --metadata-value=Ahoj --dscp-up=12 --dscp-down=24 --disable-autodiscovery
EXIT_STATUS=$?
killall  pcp-server
exit $EXIT_STATUS
