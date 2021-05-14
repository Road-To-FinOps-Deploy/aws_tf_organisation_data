resource "aws_glue_crawler" "organization" {
  database_name = "${var.cur_database}"
  name          = "OrgGlueCrawler"
  role          = aws_iam_role.AWS-Organization-Data-Glue-Crawler.arn
  schedule      = "cron(0 8 ? * MON *)"

  s3_target {
    path = "s3://${aws_s3_bucket.destination_bucket.id}/organisation-data"
  }

  configuration = <<EOF
    {"Version":1.0,"CrawlerOutput":{"Partitions":{"AddOrUpdateBehavior":"InheritFromTable"}}}
EOF
}



resource "aws_iam_role_policy" "AWS-Organization-Data-Glue-Crawler" {
  name = "AWS-Organization-Data-Glue-Crawler"
  role = aws_iam_role.AWS-Organization-Data-Glue-Crawler.id

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [

    {
    "Effect": "Allow",
    "Action": [
    "s3:GetObject",
    "s3:PutObject"
    ],
    "Resource": [
    "arn:aws:s3:::${aws_s3_bucket.destination_bucket.id}/*"
    ]
    }
    ]
}
EOF

}

resource "aws_iam_role" "AWS-Organization-Data-Glue-Crawler" {
  name = "AWS-Organization-Data-Glue-Crawler"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Principal": {
"Service": "glue.amazonaws.com"
},
"Action": "sts:AssumeRole"
}
]
}
EOF
}

