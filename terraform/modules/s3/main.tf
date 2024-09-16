resource "aws_s3_bucket" "orderagreeting_general_purpose_bucket" {
  bucket = "${var.environment}-orderagreeting_general_purpose_bucket"

  tags = {
    Name = "${var.environment}-orderagreeting_general_purpose_bucket"
    Environment = var.environment
  }
}
