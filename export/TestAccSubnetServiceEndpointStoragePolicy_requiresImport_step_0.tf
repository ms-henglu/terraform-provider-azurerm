

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022923606544"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220610022923606544"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
