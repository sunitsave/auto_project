#############################################################################
#####Automation-v0.1

dev_name="Sunit"
s3_bucket_name="upgrad-sunit"

automate_cron_job="/etc/cron.d/auto"

sudo apt update -y
dpkg --get-selections | grep apache
sudo apachectl -k restart
serv_stat=$(service apache2 status)

if apache2 -v; then
echo "Apache installed"
else  sudo apt install apache2
fi

if  $serv_stat == *"active (running)"* ; then
echo "Apache server is installed and running"
else sudo systemctl start apache2
fi


if sudo systemctl is-enabled apache2; then
echo " Apache2 server is enable"
else sudo systemctl enable apache2
fi

process_timestamp=$(date '+%d%m%Y-%H%M%S')


tar cvf /tmp/${dev_name}-httpd-logs-${process_timestamp}.tar /var/log/apache2/*.log


dpkg -s awscli
if [ $? -eq 0 ]
then
    echo "awscli  is installed and working."
else
    echo "awscli is not installed,installing awscli"
    sudo apt install awscli -y
fi
aws s3 cp /tmp/${dev_name}-httpd-logs-${process_timestamp}.tar s3://${s3_bucket_name}/${dev_name}-httpd-logs-${process_timestamp}.tar



#############################################################################
###########Automation-v0.2


if [  -f $automate_cron_job ]
then
    echo "cron exist"
else
echo "creating a cron job"
    printf "0 0 * * * root /home/ubuntu/auto/auto.sh \n" > $automate_cron_job
fi



inv_file_location="/var/www/html/inventory.html"
tar_file_size=$(ls -lh /tmp/${dev_name}-httpd-logs-${process_timestamp}.tar | awk '{ print $5}')

if [ -e $inv_file_location ]
then
echo "httpd-logs &nbsp;&nbsp;"$process_timestamp"&nbsp;&nbsp;TAR&nbsp;&nbsp;"$tar_file_size"<br/>" >> $inv_file_location
else
echo "<b>Log Type&nbsp;&nbsp;Date Created&nbsp;&nbsp;Type&nbsp;&nbsp;Size</b><br/>"  >> $inv_file_location
echo "httpd-logs &nbsp;&nbsp;"$process_timestamp"&nbsp;&nbsp;TAR&nbsp;&nbsp;"$tar_file_size"<br/>" >> $inv_file_location
fi
