
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928075302192984"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210928075302192984"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
