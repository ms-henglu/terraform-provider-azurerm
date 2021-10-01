
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "test" {
  name         = "acctestmg-211001020956124604"
  display_name = "accTestMG-211001020956124604"
}
