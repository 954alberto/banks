resource "aws_route53_record" "banks" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.project_subdomain}.${var.project_domain_name}"
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_hosted_zone_id
    evaluate_target_health = true
  }
}

module "wildcard_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = "*.${var.project_domain_name}"
  zone_id     = data.aws_route53_zone.selected.id

  wait_for_validation = true
}

module "lambda_function_container_image" {
  source         = "terraform-aws-modules/lambda/aws"
  function_name  = var.project_name
  description    = var.project_name
  create_package = false
  image_uri      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.project_name}:${var.docker_tag}"
  package_type   = "Image"
  tags = {
    Environment = "${var.environment}"
    Application = "${var.project_name}"
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name = "api_gateway"
  tags = {
    Environment = "${var.environment}"
    Application = "${var.project_name}"
  }
}

module "api_gateway" {
  source        = "terraform-aws-modules/apigateway-v2/aws"
  name          = "${var.project_name}-api"
  description   = "${var.project_name} HTTP API Gateway"
  protocol_type = "HTTP"

  disable_execute_api_endpoint = true

  # Custom domain
  domain_name                 = "${var.project_subdomain}.${var.project_domain_name}"
  domain_name_certificate_arn = module.wildcard_certificate.acm_certificate_arn

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.api_gateway.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  integrations = {
    "POST /${var.project_name}" = {
      payload_format_version = "2.0"
      lambda_arn             = module.lambda_function_container_image.lambda_function_arn
    }
  }
  tags = {
    Environment = "${var.environment}"
    Application = "${var.project_name}"
  }
}

