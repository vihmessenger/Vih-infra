resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${var.pipeline_name}-pipeline-artifacts-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name = "${var.pipeline_name}-artifacts"
  })
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.pipeline_name}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_iam_policy_document" "codebuild_eks" {
  statement {
    sid = "EKS"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }
  statement {
    sid = "STS"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_eks" {
  count = var.enable_helm_deploy_stage ? 1 : 0

  name   = "${var.pipeline_name}-codebuild-eks"
  role   = aws_iam_role.codebuild.id
  policy = data.aws_iam_policy_document.codebuild_eks.json
}

resource "aws_codebuild_project" "build" {
  name          = "${var.pipeline_name}-build"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "ECR_REPOSITORY"
      value = "${var.ecr_repository_url}/${var.ecr_repository_name}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_build
  }

  tags = var.tags
}

resource "aws_codebuild_project" "deploy" {
  count = var.enable_helm_deploy_stage ? 1 : 0

  name          = "${var.pipeline_name}-deploy"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "HELM_RELEASE"
      value = var.helm_release_name
    }
    environment_variable {
      name  = "HELM_CHART_PATH"
      value = var.helm_chart_path
    }
    environment_variable {
      name  = "K8S_NAMESPACE"
      value = var.k8s_namespace
    }
    environment_variable {
      name  = "IMAGE_URI"
      value = "${var.ecr_repository_url}/${var.ecr_repository_name}:${var.image_tag}"
    }
    dynamic "environment_variable" {
      for_each = var.infra_git_clone_url != "" ? [1] : []
      content {
        name  = "VIH_INFRA_REPO"
        value = var.infra_git_clone_url
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec_deploy
  }

  tags = var.tags
}

data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.pipeline_name}-pipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
    resources = [aws_s3_bucket.pipeline_artifacts.arn]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.pipeline_artifacts.arn}/*"]
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "codestar-connections:UseConnection",
    ]
    resources = [var.codestar_connection_arn]
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.pipeline_name}-pipeline-inline"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

resource "aws_codepipeline" "this" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.full_repository_id
        BranchName       = var.branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "DockerBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  dynamic "stage" {
    for_each = var.enable_helm_deploy_stage ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "HelmDeploy"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["build_output"]
        version         = "1"

        configuration = {
          ProjectName = aws_codebuild_project.deploy[0].name
        }
      }
    }
  }

  tags = var.tags
}
