
provider "azurerm" {
  features {}
}
				
resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311032759421336"
  location = "West Europe"
}

resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-240311032759421336"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  plan {
    effective_date = "2024-03-14T00:00:00Z"
  }

  user {
    email        = "27362230-e2d8-4c73-9ee3-fdef83459ca3@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_new_relic_tag_rule" "test" {
  monitor_id = azurerm_new_relic_monitor.test.id
}
