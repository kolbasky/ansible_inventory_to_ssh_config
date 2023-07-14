# ansible_inventory_to_ssh_config

This bash scripts searches a specified directory recursively for files named "hosts". They are expected to be in ansible ini format.<br>
Then it expands square brackets in hostnames and composes ssh conf.<br>

## Limitations
If hosts file doesn't have empty line in the end it may cause wrong parsing. i.e. "last_hostname_from_previous_file[first_groupname_from_next_file]"<br>
Script currently searches for names with dots, i.e. fqdns and ips. It can search without such limitations, but groupnames will be interpreted as hostnames. Have an idea on fix.<br>

## Usage
1st parameter - folder to search in
2nd parameter - output file
```
$ bash gen_ssh_config.sh ~/git/ansible-roles/
Your ssh config is here - /tmp/generated_ssh_config_username
There are 420 unique hosts in this config.
Check if it is correct and use "cat /tmp/generated_ssh_config_username >> ~/.ssh/config" to merge with your current config.
```
