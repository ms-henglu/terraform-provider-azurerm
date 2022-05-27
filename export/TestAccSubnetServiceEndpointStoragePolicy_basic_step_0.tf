

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034514227602"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220527034514227602"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
