
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-231016033936833199"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "testa" {
  name                = "acctest-EHN-231016033936833199-a"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "testb" {
  name                = "acctest-EHN-231016033936833199-b"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "testc" {
  name                = "acctest-EHN-231016033936833199-c"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
