#!/bin/bash
diff --changed-group-format='%<%>' --unchanged-group-format='' /usr/share/openssh/sshd_config /etc/ssh/sshd_config | grep '*'
