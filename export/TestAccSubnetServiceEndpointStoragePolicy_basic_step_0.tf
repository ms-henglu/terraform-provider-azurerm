

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220513023611458228"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220513023611458228"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
