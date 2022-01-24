
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124124841966213"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220124124841966213"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
