


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-230929065733995513"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-230929065733995513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_storage_account" "test1" {
  name                     = "acctest1otskqmz9f6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_storage" "test1" {
  name                    = "acctest-test1-230929065733995513"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test1.name
  storage_account_key     = azurerm_storage_account.test1.primary_access_key
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctest2otskqmz9f6"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_storage" "test2" {
  name                    = "acctest-test2-230929065733995513"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test2.name
  storage_account_key     = azurerm_storage_account.test2.primary_access_key
}


resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-230929065733995513"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}
