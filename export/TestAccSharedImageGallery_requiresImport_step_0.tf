
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050629410337"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211119050629410337"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
