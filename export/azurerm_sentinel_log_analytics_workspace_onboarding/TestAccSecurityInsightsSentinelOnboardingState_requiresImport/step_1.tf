
			
provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230915024139521095"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915024139521095"
  location = "West Europe"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "test" {
  workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_sentinel_log_analytics_workspace_onboarding" "import" {
  workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.test.workspace_id
}
