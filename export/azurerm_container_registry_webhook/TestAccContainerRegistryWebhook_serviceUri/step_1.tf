
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-aks-240119024742784552"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "acrwebhooktest240119024742784552"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West Europe"
  sku                 = "Standard"
}

resource "azurerm_container_registry_webhook" "test" {
  name                = "testwebhook240119024742784552"
  resource_group_name = azurerm_resource_group.rg.name
  registry_name       = azurerm_container_registry.acr.name
  location            = "West Europe"

  service_uri = "https://my.webhookreceiver.example/mytag/2"

  status = "disabled"

  actions = [
    "push"
  ]
}
