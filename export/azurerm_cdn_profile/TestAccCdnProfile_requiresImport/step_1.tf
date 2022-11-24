

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181326520131"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof221124181326520131"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}


resource "azurerm_cdn_profile" "import" {
  name                = azurerm_cdn_profile.test.name
  location            = azurerm_cdn_profile.test.location
  resource_group_name = azurerm_cdn_profile.test.resource_group_name
  sku                 = azurerm_cdn_profile.test.sku
}
