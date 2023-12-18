

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256460806"
  location = "West Europe"
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestasasepdohjkr"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_subnet_service_endpoint_storage_policy" "test" {
  name                = "acctestSEP-231218072256460806"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  definition {
    name        = "alias"
    description = "test definition1"
    service     = "Global"
    service_resources = [
      "/services/Azure",
      "/services/Azure/Batch",
      "/services/Azure/DataFactory",
      "/services/Azure/MachineLearning",
      "/services/Azure/ManagedInstance",
      "/services/Azure/WebPI",
    ]
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
