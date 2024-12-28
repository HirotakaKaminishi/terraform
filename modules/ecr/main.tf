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

# Dockerfileの内容をnull_resourceとして管理
resource "null_resource" "docker_build_push" {
  triggers = {
    dockerfile_content = file("${path.module}/docker/Dockerfile")
    index_html_content = file("${path.module}/docker/index.html")
  }

  provisioner "local-exec" {
    command = <<EOF
      aws --endpoint-url=http://localhost:4566 ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}
      cd ${path.module}/docker
      docker build -t ${aws_ecr_repository.main.repository_url}:latest .
      docker push ${aws_ecr_repository.main.repository_url}:latest
    EOF
  }
}