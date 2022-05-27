


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220527024815638604"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220527024815638604"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_storage_account" "test1" {
  name                     = "acctest1300yf4gdrt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_storage" "test1" {
  name                    = "acctest-test1-220527024815638604"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test1.name
  storage_account_key     = azurerm_storage_account.test1.primary_access_key
}

resource "azurerm_storage_account" "test2" {
  name                     = "acctest2300yf4gdrt"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_spring_cloud_storage" "test2" {
  name                    = "acctest-test2-220527024815638604"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  storage_account_name    = azurerm_storage_account.test2.name
  storage_account_key     = azurerm_storage_account.test2.primary_access_key
}


resource "azurerm_spring_cloud_app" "test" {
  name                = "acctest-sca-220527024815638604"
  resource_group_name = azurerm_spring_cloud_service.test.resource_group_name
  service_name        = azurerm_spring_cloud_service.test.name
}
