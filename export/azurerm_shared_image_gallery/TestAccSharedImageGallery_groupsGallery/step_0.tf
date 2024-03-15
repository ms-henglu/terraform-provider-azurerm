
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122550004172"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240315122550004172"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sharing {
    permission = "Groups"
  }
}
