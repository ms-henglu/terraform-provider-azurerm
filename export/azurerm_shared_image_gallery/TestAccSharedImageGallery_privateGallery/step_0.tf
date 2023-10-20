
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040746232909"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231020040746232909"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sharing {
    permission = "Private"
  }
}
