

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025728752351"
  location = "West Europe"
}


resource "azurerm_resource_group" "import" {
  name     = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}
