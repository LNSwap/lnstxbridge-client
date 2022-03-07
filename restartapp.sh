# check if lnstxbridge is running with pm3
pm2=`pm2 list | grep -i lnstxbridge | grep -i online`
if [[ $pm2 == *"online"* ]]; then
  echo "pm2 is running - app restarted"
  `pm2 restart lnstxbridge`
  exit 1
fi
# check if local node process is running
node=`ps -ef | grep -i boltzd | grep -v grep`
if [[ $node == *"boltzd"* ]]; then
  echo "node boltzd is running - app stopped"
  `kill $(ps aux | grep boltzd | grep -v grep | awk '{print $2}')`
  sleep 3
  `npm run start`
  echo "app restarted"
  exit 1
fi
