
provider "azurerm" {
  features {}
}

resource "azurerm_portal_tenant_configuration" "test" {
  private_markdown_storage_enforced = true
}
