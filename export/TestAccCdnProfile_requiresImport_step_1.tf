

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015318569747"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof211029015318569747"
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
