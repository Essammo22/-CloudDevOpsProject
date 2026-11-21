output "jenkins-id" {
  value = aws_instance.ec2-jenkins.id

}
output "jenkins-puplic-ip" {
  value = aws_instance.ec2-jenkins.public_ip

}
output "jenkins_security_group_id" {
  value = aws_security_group.ec2-sg.id
}