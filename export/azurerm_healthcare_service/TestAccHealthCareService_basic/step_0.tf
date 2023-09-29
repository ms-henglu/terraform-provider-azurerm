
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230929065006543705"
  location = "westus2"
}

resource "azurerm_healthcare_service" "test" {
  name                = "testacc23092906500654370"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  access_policy_object_ids = [
    data.azurerm_client_config.current.object_id,
  ]
}
