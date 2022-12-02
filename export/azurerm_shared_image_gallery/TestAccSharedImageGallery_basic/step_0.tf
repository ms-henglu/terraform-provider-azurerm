
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035328128411"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221202035328128411"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
