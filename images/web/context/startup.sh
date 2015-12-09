echo "Cloning repo : $git_repo"
git clone $git_repo /var/www/site
/usr/sbin/apache2ctl -D FOREGROUND

