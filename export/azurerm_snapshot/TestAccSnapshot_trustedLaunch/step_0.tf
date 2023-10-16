
provider "azurerm" {
  features {}
}

data "azurerm_platform_image" "test" {
  location  = "West Europe"
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18_04-LTS-gen2"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033604024837"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                   = "acctestd-231016033604024837"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  os_type                = "Linux"
  create_option          = "FromImage"
  image_reference_id     = data.azurerm_platform_image.test.id
  storage_account_type   = "Standard_LRS"
  hyper_v_generation     = "V2"
  trusted_launch_enabled = true
}

resource "azurerm_snapshot" "test" {
  name                = "acctestss_231016033604024837"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_uri          = azurerm_managed_disk.test.id
}
