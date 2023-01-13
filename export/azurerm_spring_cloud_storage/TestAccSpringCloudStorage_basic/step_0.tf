
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230113181736334065"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaru8sxg3wa6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230113181736334065"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_spring_cloud_storage" "test" {
  name                    = "acctest-ss-230113181736334065"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test.name
  storage_account_key     = azurerm_storage_account.test.primary_access_key
}
