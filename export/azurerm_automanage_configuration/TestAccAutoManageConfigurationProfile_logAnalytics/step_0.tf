
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230804025442435403"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                  = "acctest-amcp-230804025442435403"
  resource_group_name   = azurerm_resource_group.test.name
  location              = "West Europe"
  log_analytics_enabled = true
}
