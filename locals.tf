locals {
  tag= merge(var.common_tags,
  {
    Name="${var.project}-${var.env}"
    terraform=true
  })
  az_names=slice(data.aws_availability_zones.available.names,0,2)
}