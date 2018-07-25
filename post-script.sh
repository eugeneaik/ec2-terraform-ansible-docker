#!/usr/bin/env bash
set -e

FD="ip_address.txt"
SSH_USER="ubuntu"

if [[ -f $FD ]]; then

# ssh files
    while IFS=" " read HOST IP
    do
        # Uppercase to Lowercase
        HOST="${HOST,,}"
        SSH_FILE=$HOST.sh
cat <<END >$SSH_FILE
#!/usr/bin/env bash
ssh $SSH_USER@$IP -i ~/.ssh/sshkey.pem
END
        chmod +x $SSH_FILE
    done <"$FD"

# ansible hosts file
ANSIBLE_HOSTS="hosts"
cat <<END >$ANSIBLE_HOSTS
[ubuntu]
END

while IFS=" " read HOST IP
    do
        # Uppercase to Lowercase
        HOST="${HOST,,}"
cat <<END >>$ANSIBLE_HOSTS
$HOST ansible_ssh_host=$IP
END
    done <"$FD"


cat <<END >>$ANSIBLE_HOSTS
[ubuntu:vars]
ansible_user=$SSH_USER

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file="~/.ssh/sshkey.pem"
ansible_ssh_extra_args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

END


# End global IF
fi


