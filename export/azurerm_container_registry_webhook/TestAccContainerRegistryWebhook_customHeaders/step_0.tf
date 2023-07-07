
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-aks-230707010154944288"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "acrwebhooktest230707010154944288"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West Europe"
  sku                 = "Standard"
}

resource "azurerm_container_registry_webhook" "test" {
  name                = "testwebhook230707010154944288"
  resource_group_name = azurerm_resource_group.rg.name
  registry_name       = azurerm_container_registry.acr.name
  location            = "West Europe"

  service_uri = "https://mywebhookreceiver.example/mytag"

  custom_headers = {
    "Content-Type" = "application/json"
  }

  actions = [
    "push"
  ]
}
