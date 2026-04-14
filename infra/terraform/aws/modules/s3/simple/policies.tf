
data "aws_iam_policy_document" "combined" {
  for_each = aws_s3_bucket.this
  source_policy_documents = concat(
    [lookup(local.buckets, each.key, { policy = "" }).policy],
    [data.aws_iam_policy_document.this[each.key].json],
  )
}

data "aws_iam_policy_document" "this" {
  for_each = aws_s3_bucket.this
  statement {
    sid    = "ProhibitToDeleteBucket"
    effect = "Deny"
    actions = [
      "s3:DeleteBucket"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${each.key}"
    ]
  }
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    actions = [
      "s3:*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      "arn:aws:s3:::${each.key}",
      "arn:aws:s3:::${each.key}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}
