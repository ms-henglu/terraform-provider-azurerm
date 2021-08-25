
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-210825044437739160"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass210825044437739160"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"
  admin_users         = ["ARM_ACCTEST_ADMIN_EMAIL1", "ARM_ACCTEST_ADMIN_EMAIL2"]
}
