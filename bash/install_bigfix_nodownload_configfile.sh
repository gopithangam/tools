
# Set base folder
INSTALLERDIR="."

if [ ! -f $INSTALLERDIR/actionsite.afxm ] ; then
  echo ERROR: need actionsite.afxm file in same folder
  exit 2
fi


if [ ! -f $INSTALLERDIR/besclient.config ] ; then
  echo
  echo "ERROR: the besclient.config file is missing."
  echo
  exit 3
fi

# MUST HAVE ROOT PRIV
if [ "$(id -u)" != "0" ]; then
  echo
  echo "Sorry, you are not root. Exiting."
  echo
  exit 1
fi

############################################################
###    Start execution:    #################################
############################################################

# copy config file:
mkdir -p /var/opt/BESClient
cp $INSTALLERDIR/besclient.config /var/opt/BESClient/besclient.config
chmod 600 /var/opt/BESClient/besclient.config

# define function to check for commands:
command_exists () {
  type "$1" &> /dev/null ;
}

# figure out installer file:
if [[ $OSTYPE == darwin* ]]; then
  # Mac OS X
  INSTALLER="BESAgent*.pkg"
else
  # if dpkg exists (Debian family)
  if command_exists dpkg ; then
    # Debian based
    INSTALLER="BESAgent*.deb"
  fi # END_IF Debian (dpkg)

  # if rpm exists
  if command_exists rpm ; then
    # rpm - Currently assuming RedHat based
    INSTALLER="BESAgent*.rpm"
  fi # END_IF exists rpm

  if command_exists pkgadd ; then
    echo "Solaris Detected"
    INSTALLER="BESAgent*.pkg"
  fi # END_IF pkgadd
fi # END_IF darwin

# install BigFix client
# https://support.bigfix.com/bes/install/besclients-nonwindows.html
if [[ $INSTALLER == *.deb ]]; then
  #  debian (DEB)
  set -e
  dpkg -i $INSTALLER
fi
if [[ $INSTALLER == *.pkg ]]; then
  # PKG type
  #   Could be Mac OS X, Solaris, or AIX
  if command_exists installer ; then
    #  Mac OS X
    set -e
    installer -pkg $INSTALLER -target /
  else
    if command_exists pkgadd ; then
      #  Solaris
      set -e
      echo y | pkgadd -d $INSTALLER BESagent
    fi # pkgadd
  fi # installer
fi # *.pkg install file
if [[ $INSTALLER == *.rpm ]]; then
  #  linux (RPM)
  set -e
  # if file `/etc/init.d/besclient` exists then do upgrade
  if [ -f /etc/init.d/besclient ]; then
    /etc/init.d/besclient stop
    rpm -U $INSTALLER
  else
    rpm -ivh $INSTALLER
  fi
fi


### start the BigFix client (required for most linux dist)
# if file `/etc/init.d/besclient` exists
if [ -f /etc/init.d/besclient ]; then
  # Do not start bigfix if: StartBigFix=false
  if [[ "$StartBigFix" != "false" ]]; then
    /etc/init.d/besclient start
  fi
else
  # start using systemd
  systemctl start besclient
fi

echo BigFix should be installed and started:
echo use the following command to examine logs:
echo tail --verbose "/var/opt/BESClient/__BESData/__Global/Logs/`date +%Y%m%d`.log"
