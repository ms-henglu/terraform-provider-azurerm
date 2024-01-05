
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063504066832"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240105063504066832"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
