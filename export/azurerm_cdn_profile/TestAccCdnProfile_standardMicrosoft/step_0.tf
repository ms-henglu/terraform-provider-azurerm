
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024619138535"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof240119024619138535"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}
