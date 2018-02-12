#!/bin/bash
#This bash script handles most of the installation of Zimbra commercial SSL Certificates. I wrote this when I was setting up a 
#Multi Server zimbra deployment and since I needed to duplicate these steps on several servers, I wanted to automate it.
#It assume a couple things. First, the CA chain .crt file needs to be cat'd together before running the script.
#It also assumes that the certs are commercial_ca.crt and commercial.crt and your private key is called commercial.key.
#It needs to be run as root to ensure all commands execute properly.
#It assume those three files are packed into a .tar for portability and that this script is in the same directory as
#the .tar archive. If those things are in place, it should work without hiccup.
#Use at your own risk. Mileage may vary.
#created on Zimbra 8.8 but it should work on 8.7 and newer which is when the installation process began using the zimbra user.

echo "unpacking archive"
cp ssl.tar /tmp/
tar -xf /tmp/ssl.tar -C /tmp
echo "ensuring correct file ownership"
chown zimbra:zimbra /tmp/ssl/*
echo "Copying private key to Zimbra directory"
cp /tmp/ssl/commercial.key /opt/zimbra/ssl/zimbra/commercial/
chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/*
su zimbra -c '/opt/zimbra/bin/zmcertmgr verifycrt comm /opt/zimbra/ssl/zimbra/commercial/commercial.key /tmp/ssl/commercial.crt /tmp/ssl/commercial_ca.crt'
echo "If certificate verification completed correctly, choose 1 to install the cerificate. If it failed, please choose 2 to exit and correct the errors"
select yn in "Yes" "No"; do
        case $yn in
                Yes ) su zimbra -c '/opt/zimbra/bin/zmcertmgr deploycrt comm /tmp/ssl/commercial.crt /tmp/ssl/commercial_ca.crt';
                        echo "SSL Deploy complete"
                break;;
                No )
                        echo "Cleaning up and exiting without completing the installation"
                        rm -rf /tmp/ssl
                        rm /tmp/ssl.tar
                        rm /opt/zimbra/ssl/zimbra/commercial/commercial.key
                exit;;
        esac
done
