
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220407230802465003"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220407230802465003"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
