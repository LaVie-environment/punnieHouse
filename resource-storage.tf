resource "aws_s3_bucket" "punnie_bucket" {
    bucket = punnie_pail

    tags = {
        UserUuid = var.user_uuid
    }
}

resource "aws_s3_bucket_website_configuration" "punnie_bucing" {
  bucket = aws_s3_bucket.punnie_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.punnie_bucket.id
  key    = "index.html"
  source = "${path.module}/index.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/index.html")
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.punnie_bucket.id
  key    = "error.html"
  source = "${path.module}/error.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/error.html")
}

resource "aws_s3_bucket_policy" "punnie_policy" {
  bucket = aws_s3_bucket.punnie_bucket.id
  #policy = data.aws_iam_policy_document.allow_access_from_another_account.json
  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = {
      "Sid" = "AllowCloudFrontServicePrincipalReadOnly",
      "Effect" = "Allow",
      "Principal" = {
        "Service" = "cloudfront.amazonaws.com"
      },
      "Action" = "s3:GetObject",
      "Resource" = "arn:aws:s3:::${aws_s3_bucket.punnie_bucket.id}/*",
      "Condition" = {
      "StringEquals" = {
          #"AWS:SourceArn": data.aws_caller_identity.current.arn
          "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
        }
      }
    }
  })
}