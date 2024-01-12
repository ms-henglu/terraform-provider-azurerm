

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-240112034501229813"
  location = "westus2"
}

resource "azurerm_healthcare_service" "test" {
  name                = "testacc24011203450122981"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  access_policy_object_ids = [
    data.azurerm_client_config.current.object_id,
  ]
}


resource "azurerm_healthcare_service" "import" {
  name                = azurerm_healthcare_service.test.name
  location            = azurerm_healthcare_service.test.location
  resource_group_name = azurerm_healthcare_service.test.resource_group_name

  access_policy_object_ids = [
    "${data.azurerm_client_config.current.object_id}",
  ]
}
