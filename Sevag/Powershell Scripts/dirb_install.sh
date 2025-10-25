cd ~/Downloads
wget https://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz
tar -xvf dirb222.tar.gz
rm dirb222.tar.gz
brew install autoconf
chmod -R 755 dirb222
cd dirb222
./configure
make
make install