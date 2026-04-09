output "pipeline_name" {
  value = aws_codepipeline.this.name
}

output "pipeline_arn" {
  value = aws_codepipeline.this.arn
}

output "artifact_bucket_id" {
  value = aws_s3_bucket.pipeline_artifacts.id
}

output "codebuild_build_project_name" {
  value = aws_codebuild_project.build.name
}

output "codebuild_deploy_project_name" {
  value       = try(aws_codebuild_project.deploy[0].name, null)
  description = "Set only when enable_helm_deploy_stage is true"
}
