resource "aws_s3_bucket" "orderagreeting_general_purpose_bucket" {
  bucket = "${var.environment}-oag-gen-purp-bucket"

  tags = {
    Name = "${var.environment}-oag-gen-purp-bucket"
    Environment = var.environment
  }
}
