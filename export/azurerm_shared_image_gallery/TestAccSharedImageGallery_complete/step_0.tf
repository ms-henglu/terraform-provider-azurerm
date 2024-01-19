
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707414593"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707414593"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  description         = "Shared images and things."

  tags = {
    Hello = "There"
    World = "Example"
  }
}
