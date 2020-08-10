#backup users maildir, create a tgz file from it and delete backup folder once done.
#place gz in backup dir and send a mail when done
#job runs weekly, deleting older backups. only 1 backup can be kept

backup_dir={{ backup_location }}
users='{{ users | join(' ') }}'
today=$(/bin/date +'%d%m%Y')
recipient={{ dmarc_rua_contact }}
sender={{ dmarc_rua_contact }}
delete_backups_older=+{{ delete_backups_older }}

# there is not enough space, delete old backups first
find $backup_dir -name "maildir-*.tgz" -mtime $delete_backups_older -delete

for user in $users
do
  doas /usr/local/bin/dsync -f -u $user backup maildir:maildir-$user-$today
  doas /bin/tar cfz $backup_dir/maildir-$user-$today.tgz /home/$user/maildir-$user-$today && doas rm -rf /home/$user/maildir-$user-$today
  size=$(doas /usr/bin/du -sh $backup_dir/maildir-$user-$today.tgz)
  echo "Maildir backup finished for" $user "\nDate:" $today "\nSize:" $size | /usr/bin/mail -r $sender -s 'maildir backup' $recipient
  if [ -e /home/$user/maildir-$user-$today ]
  then
    echo "backup exists. deleting old backup."
  else
    echo "backup does not exist! not deleting last backup."
  fi
done
