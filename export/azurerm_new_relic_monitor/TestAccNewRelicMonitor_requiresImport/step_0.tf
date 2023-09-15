
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230915023930160211"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-230915023930160211"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2023-09-15T09:39:30Z"
  }
  user {
    email        = "15f0c06e-0cda-4a46-8baa-f6ec19f0ff94@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
