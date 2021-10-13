

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072330236920"
  location = "West Europe"
}


resource "azurerm_resource_group" "import" {
  name     = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}
