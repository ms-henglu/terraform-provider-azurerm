
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526084758990643"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230526084758990643"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
