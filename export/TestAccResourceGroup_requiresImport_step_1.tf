

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011939216207"
  location = "West Europe"
}


resource "azurerm_resource_group" "import" {
  name     = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}
