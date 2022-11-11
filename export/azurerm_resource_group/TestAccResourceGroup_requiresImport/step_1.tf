

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014148927172"
  location = "West Europe"
}


resource "azurerm_resource_group" "import" {
  name     = azurerm_resource_group.test.name
  location = azurerm_resource_group.test.location
}
