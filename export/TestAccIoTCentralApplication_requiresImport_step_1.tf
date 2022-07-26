

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726014909896456"
  location = "West Europe"
}

resource "azurerm_iotcentral_application" "test" {
  name                = "acctest-iotcentralapp-220726014909896456"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sub_domain          = "subdomain-220726014909896456"
  sku                 = "ST1"
}


resource "azurerm_iotcentral_application" "import" {
  name                = azurerm_iotcentral_application.test.name
  resource_group_name = azurerm_iotcentral_application.test.resource_group_name
  location            = azurerm_iotcentral_application.test.location
  sub_domain          = azurerm_iotcentral_application.test.sub_domain
  display_name        = azurerm_iotcentral_application.test.display_name
  sku                 = azurerm_iotcentral_application.test.sku
}
