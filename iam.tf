resource "aws_iam_role" "iam_role_for_organisation" {
  name               = "LambdaOrgRole"
  assume_role_policy = file("${path.module}/policies/LambdaAssume.pol")
}


resource "aws_iam_role_policy" "iam_role_policy_for_organisation" {
  name   = "${var.function_prefix}_policy_for_organisation"
  role   = aws_iam_role.iam_role_for_organisation.id

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"S3Org",
            "Effect":"Allow",
            "Action":[
                "s3:PutObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject"
            ],
            "Resource":"arn:aws:s3:::${var.bucket_name}/*"
        },
        {
            "Sid":"OrgData",
            "Effect":"Allow",
            "Action":[
                "organizations:ListAccounts",
                "organizations:ListCreateAccountStatus",
                "organizations:DescribeOrganization",
                "organizations:ListTagsForResource"
            ],
            "Resource":"*"
        },
        {
            "Sid":"Logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "assume",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "${var.management_account_role_arn}"
        }
    ]
}

EOF

}

