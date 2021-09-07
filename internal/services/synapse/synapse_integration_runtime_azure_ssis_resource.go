package synapse

import (
	"fmt"
	"regexp"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/synapse/mgmt/2021-03-01/synapse"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/azure"
	"github.com/hashicorp/terraform-provider-azurerm/helpers/tf"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	networkValidate "github.com/hashicorp/terraform-provider-azurerm/internal/services/network/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/synapse/parse"
	"github.com/hashicorp/terraform-provider-azurerm/internal/services/synapse/validate"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
	"github.com/hashicorp/terraform-provider-azurerm/internal/timeouts"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

func resourceSynapseIntegrationRuntimeAzureSsis() *pluginsdk.Resource {
	return &pluginsdk.Resource{
		Create: resourceSynapseIntegrationRuntimeAzureSsisCreateUpdate,
		Read:   resourceSynapseIntegrationRuntimeAzureSsisRead,
		Update: resourceSynapseIntegrationRuntimeAzureSsisCreateUpdate,
		Delete: resourceSynapseIntegrationRuntimeAzureSsisDelete,

		Importer: pluginsdk.ImporterValidatingResourceId(func(id string) error {
			_, err := parse.IntegrationRuntimeID(id)
			return err
		}),

		Timeouts: &pluginsdk.ResourceTimeout{
			Create: pluginsdk.DefaultTimeout(30 * time.Minute),
			Read:   pluginsdk.DefaultTimeout(5 * time.Minute),
			Update: pluginsdk.DefaultTimeout(30 * time.Minute),
			Delete: pluginsdk.DefaultTimeout(30 * time.Minute),
		},

		Schema: map[string]*pluginsdk.Schema{
			"name": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ForceNew: true,
				ValidateFunc: validation.StringMatch(
					regexp.MustCompile(`^([a-zA-Z0-9](-|-?[a-zA-Z0-9]+)+[a-zA-Z0-9])$`),
					`Invalid name for Managed Integration Runtime: minimum 3 characters, must start and end with a number or a letter, may only consist of letters, numbers and dashes and no consecutive dashes.`,
				),
			},

			"synapse_workspace_id": {
				Type:         pluginsdk.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validate.WorkspaceID,
			},

			"location": azure.SchemaLocation(),

			"node_size": {
				Type:     pluginsdk.TypeString,
				Required: true,
				ValidateFunc: validation.StringInSlice([]string{
					"Standard_D2_v3",
					"Standard_D4_v3",
					"Standard_D8_v3",
					"Standard_D16_v3",
					"Standard_D32_v3",
					"Standard_D64_v3",
					"Standard_E2_v3",
					"Standard_E4_v3",
					"Standard_E8_v3",
					"Standard_E16_v3",
					"Standard_E32_v3",
					"Standard_E64_v3",
					"Standard_D1_v2",
					"Standard_D2_v2",
					"Standard_D3_v2",
					"Standard_D4_v2",
					"Standard_A4_v2",
					"Standard_A8_v2",
				}, false),
			},

			"catalog_info": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"server_endpoint": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
						"administrator_login": {
							Type:         pluginsdk.TypeString,
							Optional:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
						"administrator_password": {
							Type:         pluginsdk.TypeString,
							Optional:     true,
							Sensitive:    true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
						"pricing_tier": {
							Type:     pluginsdk.TypeString,
							Optional: true,
							Default:  string(synapse.IntegrationRuntimeSsisCatalogPricingTierBasic),
							ValidateFunc: validation.StringInSlice([]string{
								string(synapse.IntegrationRuntimeSsisCatalogPricingTierBasic),
								string(synapse.IntegrationRuntimeSsisCatalogPricingTierStandard),
								string(synapse.IntegrationRuntimeSsisCatalogPricingTierPremium),
								string(synapse.IntegrationRuntimeSsisCatalogPricingTierPremiumRS),
							}, false),
						},
					},
				},
			},

			"custom_setup_script": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"blob_container_uri": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
						"sas_token": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							Sensitive:    true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
					},
				},
			},

			"description": {
				Type:         pluginsdk.TypeString,
				Optional:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"edition": {
				Type:     pluginsdk.TypeString,
				Optional: true,
				Default:  string(synapse.Standard),
				ValidateFunc: validation.StringInSlice([]string{
					string(synapse.Standard),
					string(synapse.Enterprise),
				}, false),
			},

			"express_custom_setup": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"environment": {
							Type:         pluginsdk.TypeMap,
							Optional:     true,
							AtLeastOneOf: []string{"express_custom_setup.0.environment", "express_custom_setup.0.component", "express_custom_setup.0.command_key"},
							Elem: &pluginsdk.Schema{
								Type: pluginsdk.TypeString,
							},
						},

						"command_key": {
							Type:         pluginsdk.TypeList,
							Optional:     true,
							AtLeastOneOf: []string{"express_custom_setup.0.environment", "express_custom_setup.0.component", "express_custom_setup.0.command_key"},
							Elem: &pluginsdk.Resource{
								Schema: map[string]*pluginsdk.Schema{
									"target_name": {
										Type:         pluginsdk.TypeString,
										Required:     true,
										ValidateFunc: validation.StringIsNotEmpty,
									},

									"user_name": {
										Type:         pluginsdk.TypeString,
										Required:     true,
										ValidateFunc: validation.StringIsNotEmpty,
									},

									"password": {
										Type:         pluginsdk.TypeString,
										Optional:     true,
										Sensitive:    true,
										ValidateFunc: validation.StringIsNotEmpty,
									},
								},
							},
						},

						"component": {
							Type:         pluginsdk.TypeList,
							Optional:     true,
							AtLeastOneOf: []string{"express_custom_setup.0.environment", "express_custom_setup.0.component", "express_custom_setup.0.command_key"},
							Elem: &pluginsdk.Resource{
								Schema: map[string]*pluginsdk.Schema{
									"name": {
										Type:         pluginsdk.TypeString,
										Required:     true,
										ValidateFunc: validation.StringIsNotEmpty,
									},

									"license": {
										Type:         pluginsdk.TypeString,
										Optional:     true,
										Sensitive:    true,
										ValidateFunc: validation.StringIsNotEmpty,
									},
								},
							},
						},
					},
				},
			},

			"license_type": {
				Type:     pluginsdk.TypeString,
				Optional: true,
				Default:  string(synapse.LicenseIncluded),
				ValidateFunc: validation.StringInSlice([]string{
					string(synapse.LicenseIncluded),
					string(synapse.BasePrice),
				}, false),
			},

			"number_of_nodes": {
				Type:         pluginsdk.TypeInt,
				Optional:     true,
				Default:      1,
				ValidateFunc: validation.IntBetween(1, 10),
			},

			"max_parallel_executions_per_node": {
				Type:         pluginsdk.TypeInt,
				Optional:     true,
				Default:      1,
				ValidateFunc: validation.IntBetween(1, 16),
			},

			"proxy": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"self_hosted_integration_runtime_name": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},

						"staging_storage_linked_service_name": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},

						"path": {
							Type:         pluginsdk.TypeString,
							Optional:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
					},
				},
			},

			"vnet_integration": {
				Type:     pluginsdk.TypeList,
				Optional: true,
				MaxItems: 1,
				Elem: &pluginsdk.Resource{
					Schema: map[string]*pluginsdk.Schema{
						"vnet_id": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: azure.ValidateResourceID,
						},
						"subnet_name": {
							Type:         pluginsdk.TypeString,
							Required:     true,
							ValidateFunc: validation.StringIsNotEmpty,
						},
						"public_ips": {
							Type:     pluginsdk.TypeList,
							Optional: true,
							MinItems: 2,
							MaxItems: 2,
							Elem: &pluginsdk.Schema{
								Type:         pluginsdk.TypeString,
								ValidateFunc: networkValidate.PublicIpAddressID,
							},
						},
					},
				},
			},
		},
	}
}

func resourceSynapseIntegrationRuntimeAzureSsisCreateUpdate(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.IntegrationRuntimesClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	workspaceId, err := parse.WorkspaceID(d.Get("synapse_workspace_id").(string))
	if err != nil {
		return err
	}

	id := parse.NewIntegrationRuntimeID(workspaceId.SubscriptionId, workspaceId.ResourceGroup, workspaceId.Name, d.Get("name").(string))
	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, "")
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for presence of existing %s: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_synapse_integration_runtime_azure_ssis", *existing.ID)
		}
	}

	integrationRuntime := synapse.IntegrationRuntimeResource{
		Name: utils.String(id.Name),
		Properties: synapse.ManagedIntegrationRuntime{
			Description: utils.String(d.Get("description").(string)),
			Type:        synapse.TypeManaged,
			ManagedIntegrationRuntimeTypeProperties: &synapse.ManagedIntegrationRuntimeTypeProperties{
				ComputeProperties: expandSynapseIntegrationRuntimeAzureSsisComputeProperties(d),
				SsisProperties:    expandSynapseIntegrationRuntimeAzureSsisProperties(d),
			},
		},
	}

	future, err := client.Create(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, integrationRuntime, "")
	if err != nil {
		return fmt.Errorf("creating/updating %s: %+v", id, err)
	}
	if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting on creation for %s: %+v", id, err)
	}
	d.SetId(id.ID())

	return resourceSynapseIntegrationRuntimeAzureSsisRead(d, meta)
}

func resourceSynapseIntegrationRuntimeAzureSsisRead(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.IntegrationRuntimesClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.IntegrationRuntimeID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.WorkspaceName, id.Name, "")
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			d.SetId("")
			return nil
		}

		return fmt.Errorf("retrieving %s: %+v", id, err)
	}

	d.Set("name", id.Name)
	d.Set("synapse_workspace_id", parse.NewWorkspaceID(id.SubscriptionId, id.ResourceGroup, id.WorkspaceName).ID())

	managedIntegrationRuntime, convertSuccess := resp.Properties.AsManagedIntegrationRuntime()
	if !convertSuccess {
		return fmt.Errorf("converting integration runtime to Azure-SSIS integration runtime (%q)", id)
	}

	d.Set("description", managedIntegrationRuntime.Description)
	if computeProps := managedIntegrationRuntime.ComputeProperties; computeProps != nil {
		d.Set("location", computeProps.Location)
		d.Set("node_size", computeProps.NodeSize)
		d.Set("number_of_nodes", computeProps.NumberOfNodes)
		d.Set("max_parallel_executions_per_node", computeProps.MaxParallelExecutionsPerNode)

		if err := d.Set("vnet_integration", flattenSynapseIntegrationRuntimeAzureSsisVnetIntegration(computeProps.VNetProperties)); err != nil {
			return fmt.Errorf("setting `vnet_integration`: %+v", err)
		}
	}

	if ssisProps := managedIntegrationRuntime.SsisProperties; ssisProps != nil {
		d.Set("edition", string(ssisProps.Edition))
		d.Set("license_type", string(ssisProps.LicenseType))

		if err := d.Set("catalog_info", flattenSynapseIntegrationRuntimeAzureSsisCatalogInfo(ssisProps.CatalogInfo, d)); err != nil {
			return fmt.Errorf("setting `catalog_info`: %+v", err)
		}

		if err := d.Set("custom_setup_script", flattenSynapseIntegrationRuntimeAzureSsisCustomSetupScript(ssisProps.CustomSetupScriptProperties, d)); err != nil {
			return fmt.Errorf("setting `custom_setup_script`: %+v", err)
		}

		if err := d.Set("express_custom_setup", flattenSynapseIntegrationRuntimeAzureSsisExpressCustomSetUp(ssisProps.ExpressCustomSetupProperties, d)); err != nil {
			return fmt.Errorf("setting `express_custom_setup`: %+v", err)
		}

		if err := d.Set("proxy", flattenSynapseIntegrationRuntimeAzureSsisProxy(ssisProps.DataProxyProperties)); err != nil {
			return fmt.Errorf("setting `proxy`: %+v", err)
		}
	}

	return nil
}

func resourceSynapseIntegrationRuntimeAzureSsisDelete(d *pluginsdk.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Synapse.IntegrationRuntimesClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.IntegrationRuntimeID(d.Id())
	if err != nil {
		return err
	}

	future, err := client.Delete(ctx, id.ResourceGroup, id.WorkspaceName, id.Name)
	if err != nil {
		return fmt.Errorf("deleting %s: %+v", id, err)
	}

	if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
		return fmt.Errorf("waiting for %s to be deleted: %+v", id, err)
	}

	return nil
}

func expandSynapseIntegrationRuntimeAzureSsisComputeProperties(d *pluginsdk.ResourceData) *synapse.IntegrationRuntimeComputeProperties {
	location := azure.NormalizeLocation(d.Get("location").(string))
	computeProperties := synapse.IntegrationRuntimeComputeProperties{
		Location:                     &location,
		NodeSize:                     utils.String(d.Get("node_size").(string)),
		NumberOfNodes:                utils.Int32(int32(d.Get("number_of_nodes").(int))),
		MaxParallelExecutionsPerNode: utils.Int32(int32(d.Get("max_parallel_executions_per_node").(int))),
	}

	if vnetIntegrations, ok := d.GetOk("vnet_integration"); ok && len(vnetIntegrations.([]interface{})) > 0 {
		vnetProps := vnetIntegrations.([]interface{})[0].(map[string]interface{})
		computeProperties.VNetProperties = &synapse.IntegrationRuntimeVNetProperties{
			VNetID: utils.String(vnetProps["vnet_id"].(string)),
			Subnet: utils.String(vnetProps["subnet_name"].(string)),
		}

		if publicIPs := vnetProps["public_ips"].([]interface{}); len(publicIPs) > 0 {
			computeProperties.VNetProperties.PublicIPs = utils.ExpandStringSlice(publicIPs)
		}
	}

	return &computeProperties
}

func expandSynapseIntegrationRuntimeAzureSsisProperties(d *pluginsdk.ResourceData) *synapse.IntegrationRuntimeSsisProperties {
	ssisProperties := &synapse.IntegrationRuntimeSsisProperties{
		LicenseType:                  synapse.IntegrationRuntimeLicenseType(d.Get("license_type").(string)),
		DataProxyProperties:          expandSynapseIntegrationRuntimeAzureSsisProxy(d.Get("proxy").([]interface{})),
		Edition:                      synapse.IntegrationRuntimeEdition(d.Get("edition").(string)),
		ExpressCustomSetupProperties: expandSynapseIntegrationRuntimeAzureSsisExpressCustomSetUp(d.Get("express_custom_setup").([]interface{})),
	}

	if catalogInfos, ok := d.GetOk("catalog_info"); ok && len(catalogInfos.([]interface{})) > 0 {
		catalogInfo := catalogInfos.([]interface{})[0].(map[string]interface{})

		ssisProperties.CatalogInfo = &synapse.IntegrationRuntimeSsisCatalogInfo{
			CatalogServerEndpoint: utils.String(catalogInfo["server_endpoint"].(string)),
			CatalogPricingTier:    synapse.IntegrationRuntimeSsisCatalogPricingTier(catalogInfo["pricing_tier"].(string)),
		}

		if adminUserName := catalogInfo["administrator_login"]; adminUserName.(string) != "" {
			ssisProperties.CatalogInfo.CatalogAdminUserName = utils.String(adminUserName.(string))
		}

		if adminPassword := catalogInfo["administrator_password"]; adminPassword.(string) != "" {
			ssisProperties.CatalogInfo.CatalogAdminPassword = &synapse.SecureString{
				Value: utils.String(adminPassword.(string)),
				Type:  synapse.TypeSecureString,
			}
		}
	}

	if customSetupScripts, ok := d.GetOk("custom_setup_script"); ok && len(customSetupScripts.([]interface{})) > 0 {
		customSetupScript := customSetupScripts.([]interface{})[0].(map[string]interface{})

		sasToken := &synapse.SecureString{
			Value: utils.String(customSetupScript["sas_token"].(string)),
			Type:  synapse.TypeSecureString,
		}

		ssisProperties.CustomSetupScriptProperties = &synapse.IntegrationRuntimeCustomSetupScriptProperties{
			BlobContainerURI: utils.String(customSetupScript["blob_container_uri"].(string)),
			SasToken:         sasToken,
		}
	}

	return ssisProperties
}

func expandSynapseIntegrationRuntimeAzureSsisProxy(input []interface{}) *synapse.IntegrationRuntimeDataProxyProperties {
	if len(input) == 0 || input[0] == nil {
		return nil
	}
	raw := input[0].(map[string]interface{})

	result := &synapse.IntegrationRuntimeDataProxyProperties{
		ConnectVia: &synapse.EntityReference{
			Type:          synapse.IntegrationRuntimeReference,
			ReferenceName: utils.String(raw["self_hosted_integration_runtime_name"].(string)),
		},
		StagingLinkedService: &synapse.EntityReference{
			Type:          synapse.LinkedServiceReference,
			ReferenceName: utils.String(raw["staging_storage_linked_service_name"].(string)),
		},
	}
	if path := raw["path"].(string); len(path) > 0 {
		result.Path = utils.String(path)
	}
	return result
}

func expandSynapseIntegrationRuntimeAzureSsisExpressCustomSetUp(input []interface{}) *[]synapse.BasicCustomSetupBase {
	if len(input) == 0 || input[0] == nil {
		return nil
	}
	raw := input[0].(map[string]interface{})

	result := make([]synapse.BasicCustomSetupBase, 0)
	if env := raw["environment"].(map[string]interface{}); len(env) > 0 {
		for k, v := range env {
			result = append(result, &synapse.EnvironmentVariableSetup{
				Type: synapse.TypeEnvironmentVariableSetup,
				EnvironmentVariableSetupTypeProperties: &synapse.EnvironmentVariableSetupTypeProperties{
					VariableName:  utils.String(k),
					VariableValue: utils.String(v.(string)),
				},
			})
		}
	}
	if components := raw["component"].([]interface{}); len(components) > 0 {
		for _, item := range components {
			raw := item.(map[string]interface{})

			var license synapse.BasicSecretBase
			if v := raw["license"].(string); v != "" {
				license = &synapse.SecureString{
					Type:  synapse.TypeSecureString,
					Value: utils.String(v),
				}
			}

			result = append(result, &synapse.ComponentSetup{
				Type: synapse.TypeComponentSetup,
				LicensedComponentSetupTypeProperties: &synapse.LicensedComponentSetupTypeProperties{
					ComponentName: utils.String(raw["name"].(string)),
					LicenseKey:    license,
				},
			})
		}
	}
	if cmdKeys := raw["command_key"].([]interface{}); len(cmdKeys) > 0 {
		for _, item := range cmdKeys {
			raw := item.(map[string]interface{})

			var password synapse.BasicSecretBase
			if v := raw["password"].(string); v != "" {
				password = &synapse.SecureString{
					Type:  synapse.TypeSecureString,
					Value: utils.String(v),
				}
			}

			result = append(result, &synapse.CmdkeySetup{
				Type: synapse.TypeCmdkeySetup,
				CmdkeySetupTypeProperties: &synapse.CmdkeySetupTypeProperties{
					TargetName: utils.String(raw["target_name"].(string)),
					UserName:   utils.String(raw["user_name"].(string)),
					Password:   password,
				},
			})
		}
	}

	return &result
}

func flattenSynapseIntegrationRuntimeAzureSsisVnetIntegration(vnetProperties *synapse.IntegrationRuntimeVNetProperties) []interface{} {
	if vnetProperties == nil {
		return []interface{}{}
	}

	var vnetId, subnetName string
	if vnetProperties.VNetID != nil {
		vnetId = *vnetProperties.VNetID
	}
	if vnetProperties.Subnet != nil {
		subnetName = *vnetProperties.Subnet
	}

	return []interface{}{
		map[string]interface{}{
			"vnet_id":     vnetId,
			"subnet_name": subnetName,
			"public_ips":  utils.FlattenStringSlice(vnetProperties.PublicIPs),
		},
	}
}

func flattenSynapseIntegrationRuntimeAzureSsisCatalogInfo(ssisProperties *synapse.IntegrationRuntimeSsisCatalogInfo, d *pluginsdk.ResourceData) []interface{} {
	if ssisProperties == nil {
		return []interface{}{}
	}

	var serverEndpoint, catalogAdminUserName, administratorPassword string
	if ssisProperties.CatalogServerEndpoint != nil {
		serverEndpoint = *ssisProperties.CatalogServerEndpoint
	}
	if ssisProperties.CatalogAdminUserName != nil {
		catalogAdminUserName = *ssisProperties.CatalogAdminUserName
	}

	// read back
	if adminPassword, ok := d.GetOk("catalog_info.0.administrator_password"); ok {
		administratorPassword = adminPassword.(string)
	}

	return []interface{}{
		map[string]interface{}{
			"server_endpoint":        serverEndpoint,
			"pricing_tier":           string(ssisProperties.CatalogPricingTier),
			"administrator_login":    catalogAdminUserName,
			"administrator_password": administratorPassword,
		},
	}
}

func flattenSynapseIntegrationRuntimeAzureSsisProxy(input *synapse.IntegrationRuntimeDataProxyProperties) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	var path, selfHostedIntegrationRuntimeName, stagingStorageLinkedServiceName string
	if input.Path != nil {
		path = *input.Path
	}
	if input.ConnectVia != nil && input.ConnectVia.ReferenceName != nil {
		selfHostedIntegrationRuntimeName = *input.ConnectVia.ReferenceName
	}
	if input.StagingLinkedService != nil && input.StagingLinkedService.ReferenceName != nil {
		stagingStorageLinkedServiceName = *input.StagingLinkedService.ReferenceName
	}
	return []interface{}{
		map[string]interface{}{
			"path":                                 path,
			"self_hosted_integration_runtime_name": selfHostedIntegrationRuntimeName,
			"staging_storage_linked_service_name":  stagingStorageLinkedServiceName,
		},
	}
}

func flattenSynapseIntegrationRuntimeAzureSsisCustomSetupScript(customSetupScriptProperties *synapse.IntegrationRuntimeCustomSetupScriptProperties, d *pluginsdk.ResourceData) []interface{} {
	if customSetupScriptProperties == nil {
		return []interface{}{}
	}

	customSetupScript := map[string]string{
		"blob_container_uri": *customSetupScriptProperties.BlobContainerURI,
	}

	if sasToken, ok := d.GetOk("custom_setup_script.0.sas_token"); ok {
		customSetupScript["sas_token"] = sasToken.(string)
	}

	return []interface{}{customSetupScript}
}

func flattenSynapseIntegrationRuntimeAzureSsisExpressCustomSetUp(input *[]synapse.BasicCustomSetupBase, d *pluginsdk.ResourceData) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	// retrieve old state
	oldState := make(map[string]interface{})
	if arr := d.Get("express_custom_setup").([]interface{}); len(arr) > 0 {
		oldState = arr[0].(map[string]interface{})
	}
	oldComponents := make([]interface{}, 0)
	if rawComponent, ok := oldState["component"]; ok {
		if v := rawComponent.([]interface{}); len(v) > 0 {
			oldComponents = v
		}
	}
	oldCmdKey := make([]interface{}, 0)
	if rawCmdKey, ok := oldState["command_key"]; ok {
		if v := rawCmdKey.([]interface{}); len(v) > 0 {
			oldCmdKey = v
		}
	}

	env := make(map[string]interface{})
	components := make([]interface{}, 0)
	cmdkeys := make([]interface{}, 0)
	for _, item := range *input {
		switch v := item.(type) {
		case synapse.ComponentSetup:
			var name string
			if v.ComponentName != nil {
				name = *v.ComponentName
			}
			components = append(components, map[string]interface{}{
				"name": name,
				"license": readBackSensitiveValue(oldComponents, "license", map[string]string{
					"name": name,
				}),
			})
		case synapse.EnvironmentVariableSetup:
			if v.VariableName != nil && v.VariableValue != nil {
				env[*v.VariableName] = *v.VariableValue
			}
		case synapse.CmdkeySetup:
			var name, userName string
			if v.TargetName != nil {
				if v, ok := v.TargetName.(string); ok {
					name = v
				}
			}
			if v.UserName != nil {
				if v, ok := v.UserName.(string); ok {
					userName = v
				}
			}
			cmdkeys = append(cmdkeys, map[string]interface{}{
				"target_name": name,
				"user_name":   userName,
				"password": readBackSensitiveValue(oldCmdKey, "password", map[string]string{
					"target_name": name,
					"user_name":   userName,
				}),
			})
		}
	}

	return []interface{}{
		map[string]interface{}{
			"environment": env,
			"component":   components,
			"command_key": cmdkeys,
		},
	}
}

func readBackSensitiveValue(input []interface{}, propertyName string, filters map[string]string) string {
	if len(input) == 0 {
		return ""
	}
	for _, item := range input {
		raw := item.(map[string]interface{})
		found := true
		for k, v := range filters {
			if raw[k].(string) != v {
				found = false
				break
			}
		}
		if found {
			return raw[propertyName].(string)
		}
	}
	return ""
}
