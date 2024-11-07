make a script to run every minute and check for the phishing shell
```bash
#!/bin/bash
netstat -tnap | grep 9999 | grep ESTABLISHED > /dev/null
if [ $? -eq 0 ]; then
	echo  "established"
fi
```
save as /root/shell_test.sh
```bash
chmod +x /root/shell_test.sh
```
open crontab as root
```bash
crontab -e
```
and add 
```bash
* * * * *  /root/shell_test.sh
```

then you can run mail and see if it is established
```bash
mail $
```

