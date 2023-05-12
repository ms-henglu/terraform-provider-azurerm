

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011140779569"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-230512011140779569"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
