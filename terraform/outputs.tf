output "ami" {
  value = data.aws_ami.ubuntu.image_id
}
output "key" {
  value = data.aws_key_pair.name.key_name
}

output "subnet" {
  value = data.aws_subnet.name.id
}

output "id" {
  value = module.ec2-instance.id
}

output "ip" {
  value = module.ec2-instance.public_ip
}
