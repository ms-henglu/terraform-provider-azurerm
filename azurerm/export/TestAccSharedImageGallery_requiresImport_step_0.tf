
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131710503995"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220627131710503995"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
