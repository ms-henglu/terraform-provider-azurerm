
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033843466934"
  location = "West Europe"
}
