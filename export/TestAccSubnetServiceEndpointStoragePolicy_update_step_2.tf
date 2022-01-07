

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064444289719"
  location = "West Europe"
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestasasepdlwhmx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-220107064444289719"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  definition {
    name        = "def1"
    description = "test definition1"
    service_resources = [
      "/subscriptions/ARM_SUBSCRIPTION_ID",
      azurerm_resource_group.test.id,
      azurerm_storage_account.test.id
    ]
  }
  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
