

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-plss-231013043849462405"
  location = "West Europe"
}

resource "azurerm_monitor_private_link_scope" "test" {
  name                = "acctest-pls-231013043849462405"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_application_insights" "test" {
  name                = "acctest-appinsights-231013043849462405"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_monitor_private_link_scoped_service" "test" {
  name                = "acctest-plss-231013043849462405"
  resource_group_name = azurerm_resource_group.test.name
  scope_name          = azurerm_monitor_private_link_scope.test.name
  linked_resource_id  = azurerm_application_insights.test.id
}


resource "azurerm_monitor_private_link_scoped_service" "import" {
  name                = azurerm_monitor_private_link_scoped_service.test.name
  resource_group_name = azurerm_monitor_private_link_scoped_service.test.resource_group_name
  scope_name          = azurerm_monitor_private_link_scoped_service.test.scope_name
  linked_resource_id  = azurerm_monitor_private_link_scoped_service.test.linked_resource_id
}
