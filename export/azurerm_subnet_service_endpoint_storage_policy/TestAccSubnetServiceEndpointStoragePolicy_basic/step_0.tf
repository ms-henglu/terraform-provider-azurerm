

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032742235345"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-240311032742235345"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
