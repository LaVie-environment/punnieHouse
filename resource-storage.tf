resource "aws_s3_bucket" "punnie_bucket" {
    bucket = var.bucket_name

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

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.punnie_bucket.id
  key    = "index.html"
  source = "${path.module}/index.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${path.module}/index.html")
}
