

resource "aws_launch_configuration" "asg_launch_config" {
  image_id = "ami-0e9182bc6494264a4"
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data =  <<-EOF
    Content-Type: multipart/mixed; boundary="//"
    MIME-Version: 1.0
    --//
    Content-Type: text/cloud-config; charset="us-ascii"
    MIME-Version: 1.0
    Content-Transfer-Encoding: 7bit
    Content-Disposition: attachment; filename="cloud-config.txt"
    #cloud-config
    cloud_final_modules:
    - [scripts-user, always]
    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    MIME-Version: 1.0
    Content-Transfer-Encoding: 7bit
    Content-Disposition: attachment; filename="userdata.txt"
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
  name = "${var.cluster_name}-ec2-launch-config"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-sg-instance"
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


resource "aws_security_group" "elb-terraform-sec-grp" {
  name = "${var.cluster_name}-sg-elb"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "az_all" {
}

resource "aws_elb" "classic_elb" {
  name = "${var.cluster_name}-classic-elb"
  availability_zones = data.aws_availability_zones.az_all.names
  listener {
    instance_port = var.server_port
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 5
    interval = 8
    target = "HTTP:${var.server_port}/"
    timeout = 5
    unhealthy_threshold = 2
  }
  security_groups = [aws_security_group.elb-terraform-sec-grp.id]
}

resource "aws_autoscaling_group" "asg" {
  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = 2
  availability_zones = data.aws_availability_zones.az_all.names
  launch_configuration = aws_launch_configuration.asg_launch_config.id
  load_balancers = [aws_elb.classic_elb.id]
  health_check_type = "ELB"
}
