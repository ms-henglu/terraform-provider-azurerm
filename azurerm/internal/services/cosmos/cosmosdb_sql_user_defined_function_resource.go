package cosmos

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/cosmos-db/mgmt/2021-01-15/documentdb"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/cosmos/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/datashare/validate"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceCosmosDbSQLUserDefinedFunction() *schema.Resource {
	return &schema.Resource{
		Create: resourceCosmosDbSQLUserDefinedFunctionCreateUpdate,
		Read:   resourceCosmosDbSQLUserDefinedFunctionRead,
		Update: resourceCosmosDbSQLUserDefinedFunctionCreateUpdate,
		Delete: resourceCosmosDbSQLUserDefinedFunctionDelete,

		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.SqlUserDefinedFunctionID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"account_name": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.AccountName(),
			},

			"container_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"database_name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},

			"body": {
				Type:         schema.TypeString,
				Required:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},
		},
	}
}
func resourceCosmosDbSQLUserDefinedFunctionCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Cosmos.SqlResourceClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)
	accountName := d.Get("account_name").(string)
	containerName := d.Get("container_name").(string)
	databaseName := d.Get("database_name").(string)
	body := d.Get("body").(string)

	id := parse.NewSqlUserDefinedFunctionID(subscriptionId, resourceGroup, accountName, databaseName, containerName, name)

	if d.IsNewResource() {
		existing, err := client.GetSQLUserDefinedFunction(ctx, id.ResourceGroup, id.DatabaseAccountName, id.SqlDatabaseName, id.ContainerName, id.UserDefinedFunctionName)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_cosmosdb_sql_user_defined_function", id.ID())
		}
	}

	createUpdateSqlUserDefinedFunctionParameters := documentdb.SQLUserDefinedFunctionCreateUpdateParameters{
		SQLUserDefinedFunctionCreateUpdateProperties: &documentdb.SQLUserDefinedFunctionCreateUpdateProperties{
			Resource: &documentdb.SQLUserDefinedFunctionResource{
				ID:   &name,
				Body: &body,
			},
			Options: &documentdb.CreateUpdateOptions{},
		},
	}
	future, err := client.CreateUpdateSQLUserDefinedFunction(ctx, id.ResourceGroup, id.DatabaseAccountName, id.SqlDatabaseName, id.ContainerName, id.UserDefinedFunctionName, createUpdateSqlUserDefinedFunctionParameters)
	if err != nil {
		return fmt.Errorf("creating/updating CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for creation/update of the CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceCosmosDbSQLUserDefinedFunctionRead(d, meta)
}

func resourceCosmosDbSQLUserDefinedFunctionRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Cosmos.SqlResourceClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.SqlUserDefinedFunctionID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.GetSQLUserDefinedFunction(ctx, id.ResourceGroup, id.DatabaseAccountName, id.SqlDatabaseName, id.ContainerName, id.UserDefinedFunctionName)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] CosmosDb SqlUserDefinedFunction %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
	}
	d.Set("name", id.UserDefinedFunctionName)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("account_name", id.DatabaseAccountName)
	d.Set("container_name", id.ContainerName)
	d.Set("database_name", id.SqlDatabaseName)
	if props := resp.SQLUserDefinedFunctionGetProperties; props != nil {
		if props.Resource != nil {
			d.Set("body", props.Resource.Body)
		}
	}
	return nil
}

func resourceCosmosDbSQLUserDefinedFunctionDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Cosmos.SqlResourceClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.SqlUserDefinedFunctionID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.DeleteSQLUserDefinedFunction(ctx, id.ResourceGroup, id.DatabaseAccountName, id.SqlDatabaseName, id.ContainerName, id.UserDefinedFunctionName)
	if err != nil {
		return fmt.Errorf("deleting CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
	}

	if err := future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for deletion of the CosmosDb SqlUserDefinedFunction %q: %+v", id, err)
	}
	return nil
}
