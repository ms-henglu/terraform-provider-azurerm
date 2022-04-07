

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407231258543004"
  location = "West Europe"
}


resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220407231258543004"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
