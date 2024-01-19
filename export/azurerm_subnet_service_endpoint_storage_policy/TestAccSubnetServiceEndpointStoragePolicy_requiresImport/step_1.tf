


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527732020"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-240119025527732020"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_subnet_service_endpoint_storage_policy" "import" {
  name                = azurerm_subnet_service_endpoint_storage_policy.test.name
  resource_group_name = azurerm_subnet_service_endpoint_storage_policy.test.resource_group_name
  location            = azurerm_subnet_service_endpoint_storage_policy.test.location
}
