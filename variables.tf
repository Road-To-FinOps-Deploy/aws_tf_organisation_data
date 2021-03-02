variable "organisation_cleanup_cron" {
  description = "interval of time to trigger lambda function"
  default     = "cron(0 6 ? * MON *)"
}

variable "function_prefix" {
  default = ""
}

variable "bucket_name" {
  type = string
  description = "Bucket the data will be placed into"
}

variable "tags" {
  type = string
  description = "List of tags from your Organisation you would like to include separated by a comma"
}

variable "management_account_id" {
  type = string
}