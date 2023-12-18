
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071435565130"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231218071435565130"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sharing {
    permission = "Private"
  }
}
