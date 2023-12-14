# listmonk-autoreply-onsubscription
a simply solution for listmonk auto reply on subscription

1. download check_subscribers.sh to your linux server
2. Modify authentication information and reply email template information for different users
3. Modify permissions to allow execution
   chmod +x check_subscribers.sh
4. Add a cron job
   crontab -e
   */10 * * * * /path/to/check_subscribers.sh >> /path/to/crontab_check_subs.log 2>&1
