

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-220107034334985254"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                = "acctestsw220107034334985254"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
