

provider "azurerm" {
  features {}
}

resource "azurerm_portal_tenant_configuration" "test" {
  private_markdown_storage_enforced = true
}


resource "azurerm_portal_tenant_configuration" "import" {
  private_markdown_storage_enforced = azurerm_portal_tenant_configuration.test.private_markdown_storage_enforced
}
