

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028165326711440"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-221028165326711440"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
