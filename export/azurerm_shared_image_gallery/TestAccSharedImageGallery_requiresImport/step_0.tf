
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074443137435"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230616074443137435"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
