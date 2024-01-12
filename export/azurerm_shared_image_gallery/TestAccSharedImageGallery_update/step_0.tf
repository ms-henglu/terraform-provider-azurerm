
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034043036915"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240112034043036915"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
