
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031517184339"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210825031517184339"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
