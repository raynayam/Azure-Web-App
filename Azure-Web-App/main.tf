provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "var.resource_group_name"
  location = "var.location"
}

resource "azurerm_service_plan" "app_plan" {
  name                = "cloud-engineer-app-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_app_service" "web_app" {
  name                = "cloud-engineer-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id
}

resource "azurerm_storage_account" "storage" {
  name                     = "cloudengineerstore"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "cloudengineerdb"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  enable_free_tier    = true
  
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_function_app" "function" {
  name                = "cloud-engineer-function"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id
  storage_account_name = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
}
