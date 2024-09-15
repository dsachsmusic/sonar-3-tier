#allows for getting AZs and using them dynamically,
# based on region (instead of hardcoding)
data "aws_availability_zones" "available" {
  state = "available"
}