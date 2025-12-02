locals {
  stack_name     = "test-utility"
  stack_fullname = "${local.stack_name}-stack"
  name_prefix    = "${local.stack_name}-${var.environment}"

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)

  application_subnet_pattern  = local.stack_secrets["application_subnet_pattern"]
  public_subnet_pattern       = var.create_internal_alb ? "" : local.stack_secrets["public_subnet_pattern"]
  application_subnet_ids      = join(",", data.aws_subnets.application.ids)
  kms_key_alias               = local.stack_secrets["kms_key_alias"]
  vpc_name                    = local.stack_secrets["vpc_name"]
  notify_topic_slack_endpoint = local.stack_secrets["notify_topic_slack_endpoint"]

  ingress_prefix_list_ids = [data.aws_ec2_managed_prefix_list.admin.id, data.aws_ec2_managed_prefix_list.shared_services_management.id]
  application_cidrs       = [for subnet in data.aws_subnet.application : subnet.cidr_block]

  ingress_cidrs_public            = concat(local.application_cidrs, [ "0.0.0.0/0" ] )
  ingress_cidrs                   = var.create_internal_alb ? local.application_cidrs : local.ingress_cidrs_public

  public_subnet_ids               = data.aws_subnets.public.ids
  lb_subnet_ids                   = var.create_internal_alb ? split(",", local.application_subnet_ids) : local.public_subnet_ids
}
