
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011219839579"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220916011219839579"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "Shared images and things."

  tags = {
    Hello = "There"
    World = "Example"
  }
}
