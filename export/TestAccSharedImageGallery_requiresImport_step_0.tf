
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610092433250441"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220610092433250441"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
