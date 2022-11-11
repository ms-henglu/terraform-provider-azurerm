
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013238930225"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221111013238930225"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
