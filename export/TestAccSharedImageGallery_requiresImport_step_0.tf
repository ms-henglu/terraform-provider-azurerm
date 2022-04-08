
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051031998659"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220408051031998659"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
