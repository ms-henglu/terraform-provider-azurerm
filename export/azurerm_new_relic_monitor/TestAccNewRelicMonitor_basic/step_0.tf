
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230825025034174898"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-230825025034174898"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2023-08-25T09:50:34Z"
  }
  user {
    email        = "d327e362-8431-4df1-8d99-8dc1c383a4f3@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
