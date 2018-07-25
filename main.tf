provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.region}"
}

resource "null_resource" "pre_provisioning" {
  provisioner "local-exec" {
    command = "test -e ip_address.txt && rm ip_address.txt"
  }
}

resource "aws_instance" "myserver" {
  depends_on             = ["null_resource.pre_provisioning"]
  count                  = 3
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg-ubuntu.id}"]

  tags {
    Name = "ubuntu-${count.index}"
  }

  connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = "~/.ssh/${var.key_name}"
    timeout     = "2m"
  }

  provisioner "local-exec" {
    command = "echo Ubuntu-${count.index} ${self.public_ip} >> ip_address.txt"
  }
}

resource "null_resource" "post_provisioning" {
  depends_on = ["aws_instance.myserver"]

  provisioner "local-exec" {
    command = "./post-script.sh && sleep 30 && ansible-playbook docker.yml -i hosts"
  }
}
