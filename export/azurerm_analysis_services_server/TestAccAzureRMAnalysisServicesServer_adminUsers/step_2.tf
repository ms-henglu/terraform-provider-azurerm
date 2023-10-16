
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-231016033253010943"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass231016033253010943"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"
  admin_users         = ["ARM_ACCTEST_ADMIN_EMAIL1", "ARM_ACCTEST_ADMIN_EMAIL2"]
}
