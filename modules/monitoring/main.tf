resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "law-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days

  tags                = var.tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = "ai-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type

  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id

  tags                = var.tags
}