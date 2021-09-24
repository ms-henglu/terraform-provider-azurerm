

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004645260545"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-210924004645260545"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
