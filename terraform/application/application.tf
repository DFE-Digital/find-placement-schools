module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = var.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  secret_key_vault_short = "app"
  config_variables_path  = "${path.module}/config/${var.config}.yml"

  # Delete for non rails apps
  is_rails_application = true

  config_variables = {
    ENVIRONMENT_NAME = var.environment
    PGSSLMODE        = local.postgres_ssl_mode
    BIGQUERY_PROJECT_ID = module.dfe_analytics[0].bigquery_project_id
    BIGQUERY_TABLE_NAME = module.dfe_analytics[0].bigquery_table_name
    BIGQUERY_DATASET    = module.dfe_analytics[0].bigquery_dataset
  }
  secret_variables = {
    DATABASE_URL = module.postgres.url
    GOOGLE_CLOUD_CREDENTIALS = module.dfe_analytics[0].google_cloud_credentials
  }
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  probe_path   = "/healthcheck"
  replicas     = var.replicas

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
  enable_logit = true

  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page
  enable_gcp_wif               = true
}
