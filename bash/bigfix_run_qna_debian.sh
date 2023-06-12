if ! [ -f /tmp/BESAgent-debian.deb ]; then
curl -o /tmp/BESAgent-debian.deb https://software.bigfix.com/download/bes/100/BESAgent-10.0.9.21-debian6.amd64.deb
fi

# https://www.cyberciti.biz/faq/how-to-extract-a-deb-file-without-opening-it-on-debian-or-ubuntu-linux/
ar x /tmp/BESAgent-debian.deb --output=/tmp

tar --overwrite --extract --file=/tmp/data.tar.gz --directory=/tmp --exclude=var* --exclude=etc* --exclude=lib/*

rm /tmp/control.tar.gz
rm /tmp/data.tar.gz
rm /tmp/debian-binary
rm -r /tmp/lib

/tmp/opt/BESClient/bin/qna -showtypes
