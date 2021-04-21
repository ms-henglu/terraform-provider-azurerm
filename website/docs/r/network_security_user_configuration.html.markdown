---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_security_user_configuration"
description: |-
  Manages a network SecurityUserConfiguration.
---

# azurerm_network_security_user_configuration

Manages a network SecurityUserConfiguration.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name                = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_network_security_user_configuration" "example" {
  name                 = "example-securityconfiguration"
  resource_group_name  = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this network SecurityConfiguration. Changing this forces a new network SecurityConfiguration to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the network SecurityConfiguration should exist. Changing this forces a new network SecurityConfiguration to be created.

* `network_manager_name` - (Required) The name of the network manager. Changing this forces a new network SecurityConfiguration to be created.

---

* `delete_existing_nsgs` - (Optional) Flag if need to delete existing network security groups.

* `description` - (Optional) A description of the security Configuration.

* `display_name` - (Optional) A display name of the security Configuration.

* `security_type` - (Optional) Security Type. Possible values are "AdminPolicy" and "UserPolicy" is allowed.

---

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the network SecurityConfiguration.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the network SecurityConfiguration.
* `read` - (Defaults to 5 minutes) Used when retrieving the network SecurityConfiguration.
* `delete` - (Defaults to 30 minutes) Used when deleting the network SecurityConfiguration.

## Import

network SecurityUserConfigurations can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_security_configuration.example /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/configuration1
```
