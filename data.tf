data aws_ami rhel9 {
    most_recent = true
    owners = ["amazon"]

    filter {
      name = "name"
      values = ["RHEL-9.4.0_HVM*"]
    }

}