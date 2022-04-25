## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.37.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | n/a |
| <a name="module_lambda_function_container_image"></a> [lambda\_function\_container\_image](#module\_lambda\_function\_container\_image) | terraform-aws-modules/lambda/aws | n/a |
| <a name="module_wildcard_certificate"></a> [wildcard\_certificate](#module\_wildcard\_certificate) | terraform-aws-modules/acm/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_route53_record.banks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_docker_tag"></a> [docker\_tag](#input\_docker\_tag) | Version tag of docker images | `string` | `"0.1.8"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Target environment, values can be dev, tst, acc or prd. | `string` | `"tst"` | no |
| <a name="input_project_domain_name"></a> [project\_domain\_name](#input\_project\_domain\_name) | Domain name used for the project | `string` | `"crashzone.link"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project, this will be used for the ECR, lambda, and few other services. | `string` | `"banks"` | no |
| <a name="input_project_subdomain"></a> [project\_subdomain](#input\_project\_subdomain) | Subdomain usedfor the project. | `string` | `"tmnl"` | no |

## Outputs

No outputs.
