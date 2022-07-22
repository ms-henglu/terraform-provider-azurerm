
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722052438143474"
  location = "West Europe"
}
