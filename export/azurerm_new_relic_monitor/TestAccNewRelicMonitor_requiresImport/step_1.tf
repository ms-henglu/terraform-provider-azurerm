
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230707004452272126"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-230707004452272126"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2023-07-07T07:44:52Z"
  }
  user {
    email        = "15f0c06e-0cda-4a46-8baa-f6ec19f0ff94@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_new_relic_monitor" "import" {
  name                = azurerm_new_relic_monitor.test.name
  resource_group_name = azurerm_new_relic_monitor.test.resource_group_name
  location            = azurerm_new_relic_monitor.test.location
  plan {
    effective_date = azurerm_new_relic_monitor.test.plan[0].effective_date
  }
  user {
    email        = azurerm_new_relic_monitor.test.user[0].email
    first_name   = azurerm_new_relic_monitor.test.user[0].first_name
    last_name    = azurerm_new_relic_monitor.test.user[0].last_name
    phone_number = azurerm_new_relic_monitor.test.user[0].phone_number
  }
}
