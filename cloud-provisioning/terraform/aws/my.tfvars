ec2-region = "us-west-2" # Oregon
ec2-zone = "c"
ec2-vpc = "vpc-3caf6c44"
ec2-subnet = "subnet-7e6f4024"
ec2-secgroup = "sg-b75ec9c5"
rancher-url = "$${rancher_url}"
rancher-token = "$${rancher_user}:$${rancher_pass}"
numnodes = 3
ec2-access-key = "$${AWS_ACCESS_KEY}"
ec2-secret-key = "$${AWS_SECRET_KEY}"
image = "ami-05a1be0cd8e9e9f8a"