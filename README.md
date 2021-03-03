# aws_tf_organisation_data

The script schedules the collection of aws organisation data



## Usage

```
module "aws_tf_eip_cleaner" {
  source = "/aws_tf_eip_cleaner"
  bucket_name = "Name-of-Bucket"
  tags = "BU,Env"
  management_account_id = "1234567890"
}
```

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bucket\_name | Name of existsing s3 bucket to put data in | string | `""` | yes |
| management\_account\_role | IAM Role ARN in you managemant account which holds your org data. Use the Managment files in the polcies folder to set these up | string | `""` | yes |
| tags | Account level tags you wish to collect | string | `""` | yes |
| eip\_cleanup\_cron | Rate expression for when to run the review of eips| string | `"cron(0 7 ? * MON-FRI *)"` | no 
| function\_prefix | Prefix for the name of the lambda created | string | `""` | no |


## Testing 

Configure your AWS credentials using one of the [supported methods for AWS CLI
   tools](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html), such as setting the
   `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables. If you're using the `~/.aws/config` file for profiles then export `AWS_SDK_LOAD_CONFIG` as "True".
1. Install [Terraform](https://www.terraform.io/) and make sure it's on your `PATH`.
1. Install [Golang](https://golang.org/) and make sure this code is checked out into your `GOPATH`.
cd test
go mod init github.com/sg/sch
go test -v -run TestTerraformAws