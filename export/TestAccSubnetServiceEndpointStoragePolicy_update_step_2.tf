

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014608617475"
  location = "West Europe"
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestasasepd6so7u"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-211015014608617475"
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
