
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.environment}_ecs_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.environment}_ecs_instance_profile"
  path = "/"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "ecs_update_ec2_tags_policy" {
  name = "${var.environment}_update_ec2_tags_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": [
          "ec2:CreateTags",
          "ec2:DescribeTags",
          "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "update_ec2_tags_role" {
  role       = "${aws_iam_role.ecs_instance_role.id}"
  policy_arn = "${aws_iam_policy.ecs_update_ec2_tags_policy.arn}"
}