

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220819165824335921"
  location = "West US 2"
}

resource "azurerm_static_site" "test" {
  name                = "acctestSS-220819165824335921"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "acceptance"
  }
}


resource "azurerm_static_site" "import" {
  name                = azurerm_static_site.test.name
  location            = azurerm_static_site.test.location
  resource_group_name = azurerm_static_site.test.resource_group_name
}
