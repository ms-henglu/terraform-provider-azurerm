
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-plss-221111013922369303"
  location = "West Europe"
}

resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-pls-221111013922369303"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-appinsights-221111013922369303"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_private_link_scoped_service" "test" {
  name                = "acctest-plss-221111013922369303"
  resource_group_name = azurerm_resource_group.test.name
  scope_name          = azurerm_monitor_private_link_scope.test.name
  linked_resource_id  = azurerm_application_insights.test.id
}
