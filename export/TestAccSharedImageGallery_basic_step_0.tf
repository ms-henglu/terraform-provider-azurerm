
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220520040450456283"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220520040450456283"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
