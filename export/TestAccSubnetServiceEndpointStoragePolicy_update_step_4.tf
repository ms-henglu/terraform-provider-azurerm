

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726015121250031"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220726015121250031"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
