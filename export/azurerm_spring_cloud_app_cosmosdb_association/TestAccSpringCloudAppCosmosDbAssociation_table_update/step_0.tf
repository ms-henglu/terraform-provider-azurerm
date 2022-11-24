

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-221124182351137941"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-221124182351137941"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-221124182351137941"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-221124182351137941"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_spring_cloud_app_cosmosdb_association" "test" {
  name                = "acctestscac-221124182351137941"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
  cosmosdb_account_id = azurerm_cosmosdb_account.test.id
  api_type            = "table"
  cosmosdb_access_key = azurerm_cosmosdb_account.test.primary_key
}
