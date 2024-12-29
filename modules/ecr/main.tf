terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws,
      ]
    }
  }
}

resource "aws_ecr_repository" "main" {
  name = "${var.project_name}-repo"
  # force_delete = true # LocalStackではリポジトリの削除ができないため、強制的に手動削除

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      "Name" = "${var.project_name}-repo"
    },
    var.tags
  )
}

locals {
  index_html_hash = filemd5("${path.module}/docker/index.html")
}

resource "null_resource" "docker_build_push_latest" {
  triggers = {
    index_html_hash = local.index_html_hash
  }

  provisioner "local-exec" {
    command = <<-EOF
      # LocalStackのエンドポイントを明示的に指定
      export DOCKER_HOST=unix:///var/run/docker.sock
      aws --endpoint-url=http://localhost:4566 ecr get-login-password --region ${var.region} \
      | docker login --username AWS --password-stdin 000000000000.dkr.ecr.ap-northeast-1.localhost.localstack.cloud:4566

      cd ${path.module}/docker
      docker build --no-cache -t 000000000000.dkr.ecr.ap-northeast-1.localhost.localstack.cloud:4566/${var.project_name}-repo:${local.index_html_hash} .
      docker push 000000000000.dkr.ecr.ap-northeast-1.localhost.localstack.cloud:4566/${var.project_name}-repo:${local.index_html_hash}
    EOF
  }
}