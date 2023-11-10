# juiceshop
for the owasp juice shop

# installation
https://pwning.owasp-juice.shop/companion-guide/latest/part1/running.html

first install node.js using snapd
https://github.com/nodejs/snap
  sudo apt install snapd
  https://snapcraft.io/docs/installing-snap-on-debian
test that snapd was installed properly with the command
  sudo snap install hello-world  
enable snapd.apparmor
  sudo systemctl enable --now snapd.apparmor
restart

second install juice shop
https://github.com/juice-shop/juice-shop/releases/download/v15.2.1/juice-shop-15.2.1_node18_linux_x64.tgz
  wget https://github.com/juice-shop/juice-shop/releases/download/v15.2.1/juice-shop-15.2.1_node18_linux_x64.tgz
unpack the tar file
  tar -xf juice-shop.tgz
in the unpacked file, build using npm
  npm start

test the server
  curl http://localhost:3000

# resources
using a browser for a security test
https://getmantra.com/web-app-security-testing-with-browsers/

zap - zed attack proxy
https://www.zaproxy.org/
