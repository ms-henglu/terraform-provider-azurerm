
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-policy-6l76c"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-network-6l76c"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet6l76c"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-6l76c"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctest-vm-6l76c"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_policy_definition" "test" {
  name         = "acctestDef-6l76c"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "my-policy-definition"

  policy_rule = <<POLICY_RULE
    {
    "if": {
      "not": {
        "field": "location",
        "in": "[parameters('allowedLocations')]"
      }
    },
    "then": {
      "effect": "audit"
    }
  }
POLICY_RULE

  parameters = <<PARAMETERS
    {
    "allowedLocations": {
      "type": "Array",
      "metadata": {
        "description": "The list of allowed locations for resources.",
        "displayName": "Allowed locations",
        "strongType": "location"
      }
    }
  }
PARAMETERS
}

resource "azurerm_policy_assignment" "test" {
  name                 = "acctestAssign-6l76c"
  scope                = azurerm_linux_virtual_machine.test.id
  policy_definition_id = azurerm_policy_definition.test.id
  description          = "Policy Assignment created via an Acceptance Test"
  display_name         = "My Example Policy Assignment"

  parameters = <<PARAMETERS
{
  "allowedLocations": {
    "value": [ "West Europe" ]
  }
}
PARAMETERS
}

resource "azurerm_policy_remediation" "test" {
  name                 = "acctestremediation-6l76c"
  scope                = azurerm_policy_assignment.test.scope
  policy_assignment_id = azurerm_policy_assignment.test.id
}
