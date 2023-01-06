
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034233472381"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230106034233472381"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
