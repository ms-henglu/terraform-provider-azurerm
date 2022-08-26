
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eventhub-220826002735985780"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "testa" {
  name                = "acctest-EHN-220826002735985780-a"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "testb" {
  name                = "acctest-EHN-220826002735985780-b"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_eventhub_namespace" "testc" {
  name                = "acctest-EHN-220826002735985780-c"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
