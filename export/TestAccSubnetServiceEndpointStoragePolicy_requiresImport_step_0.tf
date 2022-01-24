

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124122446559604"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220124122446559604"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
