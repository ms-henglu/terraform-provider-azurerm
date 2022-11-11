
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014003169458"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-221111014003169458"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "9l20vbitpmivvtnarkeyxi1zblrrg0txx4fta3821he30icjpgaji4a32p2zw9t"
}
