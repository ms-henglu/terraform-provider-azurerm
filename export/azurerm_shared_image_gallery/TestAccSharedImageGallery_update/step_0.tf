
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604017928"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231016033604017928"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
