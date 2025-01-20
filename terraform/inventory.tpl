all:
  hosts:
    ec2-instance:
      ansible_host: ${webserver}
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ${private_key_filepath}
      ansible_python_interpreter: /usr/bin/python3