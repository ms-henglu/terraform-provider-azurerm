
			
provider "azurerm" {
  features {}
}
				
resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112034911082781"
  location = "West Europe"
}

resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-240112034911082781"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  plan {
    effective_date = "2024-01-15T00:00:00Z"
  }

  user {
    email        = "85b5febd-127d-4633-9c25-bcfea555af46@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_new_relic_tag_rule" "test" {
  monitor_id = azurerm_new_relic_monitor.test.id
}


resource "azurerm_new_relic_tag_rule" "import" {
  monitor_id = azurerm_new_relic_tag_rule.test.monitor_id
}
