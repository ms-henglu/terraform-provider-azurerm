
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-aks-240119024742787130"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "acrwebhooktest240119024742787130"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "West Europe"
  sku                 = "Standard"
}

resource "azurerm_container_registry_webhook" "test" {
  name                = "testwebhook240119024742787130"
  resource_group_name = azurerm_resource_group.rg.name
  registry_name       = azurerm_container_registry.acr.name
  location            = "West Europe"

  service_uri = "https://mywebhookreceiver.example/mytag"

  actions = [
    "push"
  ]

  tags = {
    label = "test1"
    ENV   = "prod"
  }
}
