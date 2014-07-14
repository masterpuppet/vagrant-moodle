#!/bin/sh
directory="/var/www/virtual"
rm -rf "$directory"
mkdir "$directory"
cd $directory

git clone --depth=1 -b MOODLE_27_STABLE --single-branch git://git.moodle.org/moodle.git .

#setup right permissions
#chown -R root .
chmod -R 0755 .
find . -type f -exec chmod 0644 {} \;

#chmod -R +a "www-data allow read,delete,write,append,file_inherit,directory_inherit" .
#sudo setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx .

#create moodle metadata folder
moodleDataDirectory="/var/www/moodledata"
rm -rf "$moodleDataDirectory"
mkdir "$moodleDataDirectory"
chmod 0777 "$moodleDataDirectory"

#chmod -R +a "www-data allow read,delete,write,append,file_inherit,directory_inherit" moodledata
#sudo setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx moodledata

#sudo chmod -R +a "`whoami` allow read,delete,write,append,file_inherit,directory_inherit" moodledata
chown www-data .
cd admin/cli
sudo -u www-data php install.php --non-interactive --lang=en --wwwroot=http://virtual.dev --dataroot="$moodleDataDirectory" --dbuser=root --dbpass=123 --adminuser=admin --adminpass=1234 --fullname="Rackspace Virtual Academy" --shortname="Rackspace" --agree-license > "$moodleDataDirectory/php-install.log" 2>&1
#set development mode
sed -i "s/require_once(dirname(__FILE__) . '\/lib\/setup.php');/@error_reporting(E_ALL | E_STRICT);\n@ini_set('display_errors', '1');\n\$CFG->debug = (E_ALL | E_STRICT);\n\nrequire_once(dirname(__FILE__) . '\/lib\/setup.php');/g" ../../config.php
#install example data
php ../tool/generator/cli/maketestsite.php --size=XS
