
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220527034730225719"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa2m11f06b9z"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220527034730225719"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_storage" "test" {
  name                    = "acctest-ss-220527034730225719"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test.name
  storage_account_key     = azurerm_storage_account.test.primary_access_key
}
