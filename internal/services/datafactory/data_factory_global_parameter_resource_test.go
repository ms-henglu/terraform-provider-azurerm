// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package datafactory_test

import (
	"context"
	"fmt"
	"github.com/hashicorp/go-azure-sdk/resource-manager/datafactory/2018-06-01/globalparameters"
	"testing"

	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/check"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

type GlobalParameterResource struct{}

func TestAccDataFactoryGlobalParameter_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_data_factory_global_parameter", "test")
	r := GlobalParameterResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccDataFactoryGlobalParameter_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_data_factory_global_parameter", "test")
	r := GlobalParameterResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccDataFactoryGlobalParameter_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_data_factory_global_parameter", "test")
	r := GlobalParameterResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccDataFactoryGlobalParameter_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_data_factory_global_parameter", "test")
	r := GlobalParameterResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func (t GlobalParameterResource) Exists(ctx context.Context, clients *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := globalparameters.ParseGlobalParameterID(state.ID)
	if err != nil {
		return nil, err
	}

	resp, err := clients.DataFactory.GlobalParameters.Get(ctx, *id)
	if err != nil {
		return nil, fmt.Errorf("retrieving %s: %+v", *id, err)
	}

	return utils.Bool(resp.Model.Id != nil), nil
}

func (GlobalParameterResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-%[2]d"
  location = "%[1]s"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf%[2]d"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
`, data.Locations.Primary, data.RandomInteger)
}

func (GlobalParameterResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
%[1]s

resource "azurerm_data_factory_global_parameter" "test" {
  name            = "default"
  data_factory_id = azurerm_data_factory.test.id
}
`, GlobalParameterResource{}.template(data))
}

func (GlobalParameterResource) complete(data acceptance.TestData) string {
	return fmt.Sprintf(`
%[1]s

resource "azurerm_data_factory_global_parameter" "test" {
  name            = "default"
  data_factory_id = azurerm_data_factory.test.id

  parameter {
    name  = "intVal"
    type  = "Int"
    value = "3"
  }

  parameter {
    name  = "stringVal"
    type  = "String"
    value = "foo"
  }

  parameter {
    name  = "boolVal"
    type  = "Bool"
    value = "true"
  }

  parameter {
    name  = "floatVal"
    type  = "Float"
    value = "3.0"
  }

  parameter {
    name  = "arrayVal"
    type  = "Array"
    value = jsonencode(["a", "b", "c"])
  }

  parameter {
    name  = "objectVal"
    type  = "Object"
    value = jsonencode({ name : "value" })
  }
}
`, GlobalParameterResource{}.template(data))
}

func (r GlobalParameterResource) requiresImport(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

resource "azurerm_data_factory_global_parameter" "import" {
  name            = azurerm_data_factory_global_parameter.test.name
  data_factory_id = azurerm_data_factory_global_parameter.test.data_factory_id
}
`, r.basic(data))
}
