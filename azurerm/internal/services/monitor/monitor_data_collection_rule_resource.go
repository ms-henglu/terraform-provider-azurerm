package monitor

import (
	"fmt"
	"log"
	"time"

	"github.com/Azure/azure-sdk-for-go/services/preview/monitor/mgmt/2021-04-01-preview/insights"
	"github.com/hashicorp/terraform-plugin-sdk/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/helper/validation"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/services/monitor/parse"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tags"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/pluginsdk"
	azSchema "github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/tf/schema"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/timeouts"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)

func resourceMonitorDataCollectionRule() *schema.Resource {
	return &schema.Resource{
		Create: resourceMonitorDataCollectionRuleCreateUpdate,
		Read:   resourceMonitorDataCollectionRuleRead,
		Update: resourceMonitorDataCollectionRuleCreateUpdate,
		Delete: resourceMonitorDataCollectionRuleDelete,
		Timeouts: &schema.ResourceTimeout{
			Create: schema.DefaultTimeout(30 * time.Minute),
			Read:   schema.DefaultTimeout(5 * time.Minute),
			Update: schema.DefaultTimeout(30 * time.Minute),
			Delete: schema.DefaultTimeout(30 * time.Minute),
		},

		Importer: azSchema.ValidateResourceIDPriorToImport(func(id string) error {
			_, err := parse.DataCollectionRuleID(id)
			return err
		}),

		Schema: map[string]*schema.Schema{
			"name": {
				Type:         schema.TypeString,
				Required:     true,
				ForceNew:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"resource_group_name": azure.SchemaResourceGroupName(),

			"location": azure.SchemaLocation(),

			"data_flows": {
				Type:     schema.TypeList,
				Required: true,
				MinItems: 1,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"streams": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.MicrosoftEvent),
									string(insights.MicrosoftInsightsMetrics),
									string(insights.MicrosoftPerf),
									string(insights.MicrosoftSyslog),
									string(insights.MicrosoftWindowsEvent),
								}, false),
							},
						},

						"destinations": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type:         schema.TypeString,
								ValidateFunc: validation.StringIsNotEmpty,
							},
						},
					},
				},
			},

			"azure_monitor_metrics_destination": {
				Type:         schema.TypeList,
				Optional:     true,
				MaxItems:     1,
				AtLeastOneOf: []string{"log_analytics_destination", "azure_monitor_metrics_destination"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},
					},
				},
			},

			"description": {
				Type:         schema.TypeString,
				Optional:     true,
				ValidateFunc: validation.StringIsNotEmpty,
			},

			"extension_data_source": {
				Type:         schema.TypeList,
				Optional:     true,
				MinItems:     1,
				AtLeastOneOf: []string{"performance_counter_data_source", "windows_event_log_data_source", "syslog_data_source", "extension_data_source"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"extension_name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"streams": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownExtensionDataSourceStreamsMicrosoftEvent),
									string(insights.KnownExtensionDataSourceStreamsMicrosoftInsightsMetrics),
									string(insights.KnownExtensionDataSourceStreamsMicrosoftPerf),
									string(insights.KnownExtensionDataSourceStreamsMicrosoftSyslog),
									string(insights.KnownExtensionDataSourceStreamsMicrosoftWindowsEvent),
								}, false),
							},
						},

						"input_data_sources": {
							Type:     schema.TypeList,
							Optional: true,
							Elem: &schema.Schema{
								Type:         schema.TypeString,
								ValidateFunc: validation.StringIsNotEmpty,
							},
						},

						"extension_setting": {
							Type:             pluginsdk.TypeString,
							Optional:         true,
							ValidateFunc:     validation.StringIsJSON,
							DiffSuppressFunc: pluginsdk.SuppressJsonDiff,
						},
					},
				},
			},

			"kind": {
				Type:     schema.TypeString,
				Optional: true,
				ValidateFunc: validation.StringInSlice([]string{
					string(insights.Windows),
					string(insights.Linux),
				}, false),
			},

			"log_analytics_destination": {
				Type:         schema.TypeList,
				Optional:     true,
				MinItems:     1,
				AtLeastOneOf: []string{"log_analytics_destination", "azure_monitor_metrics_destination"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"workspace_resource_id": {
							Type:     schema.TypeString,
							Required: true,
						},

						"workspace_id": {
							Type:     schema.TypeString,
							Computed: true,
						},
					},
				},
			},

			"performance_counter_data_source": {
				Type:         schema.TypeList,
				Optional:     true,
				MinItems:     1,
				AtLeastOneOf: []string{"performance_counter_data_source", "windows_event_log_data_source", "syslog_data_source", "extension_data_source"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"streams": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownPerfCounterDataSourceStreamsMicrosoftPerf),
									string(insights.KnownPerfCounterDataSourceStreamsMicrosoftInsightsMetrics),
								}, false),
							},
						},

						"specifiers": {
							Type:     schema.TypeList,
							Optional: true,
							Elem: &schema.Schema{
								Type:         schema.TypeString,
								ValidateFunc: validation.StringIsNotEmpty,
							},
						},

						"sampling_frequency": {
							Type:     schema.TypeInt,
							Optional: true,
						},
					},
				},
			},

			"syslog_data_source": {
				Type:         schema.TypeList,
				Optional:     true,
				MinItems:     1,
				AtLeastOneOf: []string{"performance_counter_data_source", "windows_event_log_data_source", "syslog_data_source", "extension_data_source"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"streams": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownSyslogDataSourceStreamsMicrosoftSyslog),
								}, false),
							},
						},

						"log_levels": {
							Type:     schema.TypeList,
							Optional: true,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownSyslogDataSourceLogLevelsAlert),
									string(insights.KnownSyslogDataSourceLogLevelsAsterisk),
									string(insights.KnownSyslogDataSourceLogLevelsCritical),
									string(insights.KnownSyslogDataSourceLogLevelsDebug),
									string(insights.KnownSyslogDataSourceLogLevelsEmergency),
									string(insights.KnownSyslogDataSourceLogLevelsError),
									string(insights.KnownSyslogDataSourceLogLevelsInfo),
									string(insights.KnownSyslogDataSourceLogLevelsNotice),
									string(insights.KnownSyslogDataSourceLogLevelsWarning),
								}, false),
							},
						},

						"facility_names": {
							Type:     schema.TypeList,
							Optional: true,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownSyslogDataSourceFacilityNamesAsterisk),
									string(insights.KnownSyslogDataSourceFacilityNamesAuth),
									string(insights.KnownSyslogDataSourceFacilityNamesAuthpriv),
									string(insights.KnownSyslogDataSourceFacilityNamesCron),
									string(insights.KnownSyslogDataSourceFacilityNamesDaemon),
									string(insights.KnownSyslogDataSourceFacilityNamesKern),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal0),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal1),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal2),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal3),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal4),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal5),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal6),
									string(insights.KnownSyslogDataSourceFacilityNamesLocal7),
									string(insights.KnownSyslogDataSourceFacilityNamesLpr),
									string(insights.KnownSyslogDataSourceFacilityNamesMail),
									string(insights.KnownSyslogDataSourceFacilityNamesMark),
									string(insights.KnownSyslogDataSourceFacilityNamesNews),
									string(insights.KnownSyslogDataSourceFacilityNamesSyslog),
									string(insights.KnownSyslogDataSourceFacilityNamesUser),
									string(insights.KnownSyslogDataSourceFacilityNamesUucp),
								}, false),
							},
						},
					},
				},
			},

			"windows_event_log_data_source": {
				Type:         schema.TypeList,
				Optional:     true,
				MinItems:     1,
				AtLeastOneOf: []string{"performance_counter_data_source", "windows_event_log_data_source", "syslog_data_source", "extension_data_source"},
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"name": {
							Type:     schema.TypeString,
							Required: true,
						},

						"streams": {
							Type:     schema.TypeList,
							Required: true,
							MinItems: 1,
							Elem: &schema.Schema{
								Type: schema.TypeString,
								ValidateFunc: validation.StringInSlice([]string{
									string(insights.KnownWindowsEventLogDataSourceStreamsMicrosoftWindowsEvent),
									string(insights.KnownWindowsEventLogDataSourceStreamsMicrosoftEvent),
								}, false),
							},
						},

						"xpath_queries": {
							Type:     schema.TypeList,
							Optional: true,
							Elem: &schema.Schema{
								Type:         schema.TypeString,
								ValidateFunc: validation.StringIsNotEmpty,
							},
						},
					},
				},
			},

			"tags": tags.Schema(),
		},
	}
}

func resourceMonitorDataCollectionRuleCreateUpdate(d *schema.ResourceData, meta interface{}) error {
	subscriptionId := meta.(*clients.Client).Account.SubscriptionId
	client := meta.(*clients.Client).Monitor.DataCollectionRulesClient
	ctx, cancel := timeouts.ForCreateUpdate(meta.(*clients.Client).StopContext, d)
	defer cancel()

	name := d.Get("name").(string)
	resourceGroup := d.Get("resource_group_name").(string)

	id := parse.NewDataCollectionRuleID(subscriptionId, resourceGroup, name)
	if d.IsNewResource() {
		existing, err := client.Get(ctx, id.ResourceGroup, id.Name)
		if err != nil {
			if !utils.ResponseWasNotFound(existing.Response) {
				return fmt.Errorf("checking for existing Monitor DataCollectionRule %q: %+v", id, err)
			}
		}
		if !utils.ResponseWasNotFound(existing.Response) {
			return tf.ImportAsExistsError("azurerm_monitor_data_collection_rule", id.ID())
		}

	}

	extensions, err := expandExtensionDataSources(d.Get("extension_data_source").([]interface{}))
	if err != nil {
		return fmt.Errorf("error expanding extension_data_source: %+v", err)
	}
	body := insights.DataCollectionRuleResource{
		DataCollectionRuleResourceProperties: &insights.DataCollectionRuleResourceProperties{
			Description: utils.String(d.Get("description").(string)),
			DataSources: &insights.DataCollectionRuleDataSources{
				PerformanceCounters: expandPerformanceCounterDataSources(d.Get("performance_counter_data_source").([]interface{})),
				WindowsEventLogs:    expandWindowsEventLogDataSources(d.Get("windows_event_log_data_source").([]interface{})),
				Syslog:              expandSyslogDataSources(d.Get("syslog_data_source").([]interface{})),
				Extensions:          extensions,
			},
			Destinations: &insights.DataCollectionRuleDestinations{
				LogAnalytics:        expandLogAnalyticsDestinations(d.Get("log_analytics_destination").([]interface{})),
				AzureMonitorMetrics: expandAzureMonitorMetricsDestinations(d.Get("azure_monitor_metrics_destination").([]interface{})),
			},
			DataFlows: expandDataFlows(d.Get("data_flows").([]interface{})),
		},
		Tags:     tags.Expand(d.Get("tags").(map[string]interface{})),
		Name:     utils.String(name),
		Location: utils.String(location.Normalize(d.Get("location").(string))),
	}
	if kind, ok := d.GetOk("kind"); ok {
		body.Kind = insights.KnownDataCollectionRuleResourceKind(kind.(string))
	}

	_, err = client.Create(ctx, id.ResourceGroup, id.Name, &body)
	if err != nil {
		return fmt.Errorf("creating Monitor DataCollectionRule %q: %+v", id, err)
	}

	d.SetId(id.ID())
	return resourceMonitorDataCollectionRuleRead(d, meta)
}

func resourceMonitorDataCollectionRuleRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionRulesClient
	ctx, cancel := timeouts.ForRead(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionRuleID(d.Id())
	if err != nil {
		return err
	}

	resp, err := client.Get(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		if utils.ResponseWasNotFound(resp.Response) {
			log.Printf("[INFO] Monitor DataCollectionRule %q does not exist - removing from state", d.Id())
			d.SetId("")
			return nil
		}
		return fmt.Errorf("retrieving Monitor DataCollectionRule %q: %+v", id, err)
	}

	d.Set("name", id.Name)
	d.Set("resource_group_name", id.ResourceGroup)
	d.Set("location", location.NormalizeNilable(resp.Location))
	if resp.Description != nil {
		d.Set("description", *resp.Description)
	}
	d.Set("kind", resp.Kind)
	if props := resp.DataCollectionRuleResourceProperties; props != nil {
		if props.DataSources != nil {
			d.Set("performance_counter_data_source", flattenPerformanceCounterDataSources(props.DataSources.PerformanceCounters))
			d.Set("windows_event_log_data_source", flattenWindowsEventLogDataSources(props.DataSources.WindowsEventLogs))
			d.Set("syslog_data_source", flattenSyslogDataSources(props.DataSources.Syslog))

			extensionDataSource, err := flattenExtensionDataSources(props.DataSources.Extensions)
			if err != nil {
				return fmt.Errorf("error setting extension_data_source: %+v", err)
			}
			d.Set("extension_data_source", extensionDataSource)
		}
		if props.Destinations != nil {
			d.Set("log_analytics_destination", flattenLogAnalyticsDestinations(props.Destinations.LogAnalytics))
			d.Set("azure_monitor_metrics_destination", flattenAzureMonitorMetricsDestinations(props.Destinations.AzureMonitorMetrics))
		}
		d.Set("data_flows", flattenDataFlows(props.DataFlows))
	}

	return tags.FlattenAndSet(d, resp.Tags)
}

func resourceMonitorDataCollectionRuleDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*clients.Client).Monitor.DataCollectionRulesClient
	ctx, cancel := timeouts.ForDelete(meta.(*clients.Client).StopContext, d)
	defer cancel()

	id, err := parse.DataCollectionRuleID(d.Id())
	if err != nil {
		return err
	}

	_, err = client.Delete(ctx, id.ResourceGroup, id.Name)
	if err != nil {
		return fmt.Errorf("deleting Monitor DataCollectionRule %q: %+v", id, err)
	}

	return nil
}

func expandPerformanceCounterDataSources(p []interface{}) *[]insights.PerfCounterDataSource {
	dataSources := make([]insights.PerfCounterDataSource, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		streams := make([]insights.KnownPerfCounterDataSourceStreams, 0)
		if value["streams"] != nil {
			for _, streamRaw := range value["streams"].([]interface{}) {
				streams = append(streams, insights.KnownPerfCounterDataSourceStreams(streamRaw.(string)))
			}
		}
		dataSources = append(dataSources, insights.PerfCounterDataSource{
			Streams:                    &streams,
			SamplingFrequencyInSeconds: utils.Int32(int32(value["sampling_frequency"].(int))),
			CounterSpecifiers:          utils.ExpandStringSlice(value["specifiers"].([]interface{})),
			Name:                       utils.String(value["name"].(string)),
		})
	}

	return &dataSources
}

func expandWindowsEventLogDataSources(p []interface{}) *[]insights.WindowsEventLogDataSource {
	dataSources := make([]insights.WindowsEventLogDataSource, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		streams := make([]insights.KnownWindowsEventLogDataSourceStreams, 0)
		if value["streams"] != nil {
			for _, streamRaw := range value["streams"].([]interface{}) {
				streams = append(streams, insights.KnownWindowsEventLogDataSourceStreams(streamRaw.(string)))
			}
		}
		dataSources = append(dataSources, insights.WindowsEventLogDataSource{
			Streams:      &streams,
			XPathQueries: utils.ExpandStringSlice(value["xpath_queries"].([]interface{})),
			Name:         utils.String(value["name"].(string)),
		})
	}

	return &dataSources
}

func expandSyslogDataSources(p []interface{}) *[]insights.SyslogDataSource {
	dataSources := make([]insights.SyslogDataSource, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		streams := make([]insights.KnownSyslogDataSourceStreams, 0)
		if value["streams"] != nil {
			for _, streamRaw := range value["streams"].([]interface{}) {
				streams = append(streams, insights.KnownSyslogDataSourceStreams(streamRaw.(string)))
			}
		}
		logLevels := make([]insights.KnownSyslogDataSourceLogLevels, 0)
		if value["log_levels"] != nil {
			for _, streamRaw := range value["log_levels"].([]interface{}) {
				logLevels = append(logLevels, insights.KnownSyslogDataSourceLogLevels(streamRaw.(string)))
			}
		}
		facilityNames := make([]insights.KnownSyslogDataSourceFacilityNames, 0)
		if value["facility_names"] != nil {
			for _, streamRaw := range value["facility_names"].([]interface{}) {
				facilityNames = append(facilityNames, insights.KnownSyslogDataSourceFacilityNames(streamRaw.(string)))
			}
		}
		dataSources = append(dataSources, insights.SyslogDataSource{
			Streams:       &streams,
			LogLevels:     &logLevels,
			FacilityNames: &facilityNames,
			Name:          utils.String(value["name"].(string)),
		})
	}

	return &dataSources
}

func expandExtensionDataSources(p []interface{}) (*[]insights.ExtensionDataSource, error) {
	dataSources := make([]insights.ExtensionDataSource, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		streams := make([]insights.KnownExtensionDataSourceStreams, 0)
		if value["streams"] != nil {
			for _, streamRaw := range value["streams"].([]interface{}) {
				streams = append(streams, insights.KnownExtensionDataSourceStreams(streamRaw.(string)))
			}
		}
		dataSource := insights.ExtensionDataSource{
			Streams:          &streams,
			InputDataSources: utils.ExpandStringSlice(value["input_data_sources"].([]interface{})),
			ExtensionName:    utils.String(value["extension_name"].(string)),
			Name:             utils.String(value["name"].(string)),
		}
		if value["extension_setting"] != nil {
			extensionSettings, err := pluginsdk.ExpandJsonFromString(value["extension_setting"].(string))
			if err != nil {
				return nil, err
			}
			dataSource.ExtensionSettings = extensionSettings
		}
		dataSources = append(dataSources, dataSource)
	}

	return &dataSources, nil
}

func expandLogAnalyticsDestinations(p []interface{}) *[]insights.LogAnalyticsDestination {
	destinations := make([]insights.LogAnalyticsDestination, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		destinations = append(destinations, insights.LogAnalyticsDestination{
			Name:                utils.String(value["name"].(string)),
			WorkspaceResourceID: utils.String(value["workspace_resource_id"].(string)),
		})
	}

	return &destinations
}

func expandAzureMonitorMetricsDestinations(p []interface{}) *insights.DestinationsSpecAzureMonitorMetrics {
	if len(p) == 0 {
		return nil
	}
	value := p[0].(map[string]interface{})
	return &insights.DestinationsSpecAzureMonitorMetrics{
		Name: utils.String(value["name"].(string)),
	}
}

func expandDataFlows(p []interface{}) *[]insights.DataFlow {
	dataFlows := make([]insights.DataFlow, 0)

	for _, v := range p {
		value := v.(map[string]interface{})
		streams := make([]insights.KnownDataFlowStreams, 0)
		if value["streams"] != nil {
			for _, streamRaw := range value["streams"].([]interface{}) {
				streams = append(streams, insights.KnownDataFlowStreams(streamRaw.(string)))
			}
		}
		dataFlows = append(dataFlows, insights.DataFlow{
			Streams:      &streams,
			Destinations: utils.ExpandStringSlice(value["destinations"].([]interface{})),
		})
	}

	return &dataFlows
}

func flattenPerformanceCounterDataSources(input *[]insights.PerfCounterDataSource) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		dataSource := make(map[string]interface{})
		if v.Streams != nil {
			streams := make([]string, 0)
			for _, stream := range *v.Streams {
				streams = append(streams, string(stream))
			}
			dataSource["streams"] = streams
		}
		if v.SamplingFrequencyInSeconds != nil {
			dataSource["sampling_frequency"] = *v.SamplingFrequencyInSeconds
		}
		if v.CounterSpecifiers != nil {
			dataSource["specifiers"] = utils.FlattenStringSlice(v.CounterSpecifiers)
		}
		if v.Name != nil {
			dataSource["name"] = *v.Name
		}
		results = append(results, dataSource)
	}

	return results
}

func flattenWindowsEventLogDataSources(input *[]insights.WindowsEventLogDataSource) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		dataSource := make(map[string]interface{})
		if v.Streams != nil {
			streams := make([]string, 0)
			for _, stream := range *v.Streams {
				streams = append(streams, string(stream))
			}
			dataSource["streams"] = streams
		}
		if v.XPathQueries != nil {
			dataSource["xpath_queries"] = utils.FlattenStringSlice(v.XPathQueries)
		}
		if v.Name != nil {
			dataSource["name"] = *v.Name
		}
		results = append(results, dataSource)
	}

	return results
}

func flattenSyslogDataSources(input *[]insights.SyslogDataSource) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		dataSource := make(map[string]interface{})
		if v.Streams != nil {
			streams := make([]string, 0)
			for _, stream := range *v.Streams {
				streams = append(streams, string(stream))
			}
			dataSource["streams"] = streams
		}
		if v.LogLevels != nil {
			logLevels := make([]string, 0)
			for _, logLevel := range *v.LogLevels {
				logLevels = append(logLevels, string(logLevel))
			}
			dataSource["log_levels"] = logLevels
		}
		if v.FacilityNames != nil {
			facilityNames := make([]string, 0)
			for _, facilityName := range *v.FacilityNames {
				facilityNames = append(facilityNames, string(facilityName))
			}
			dataSource["facility_names"] = facilityNames
		}
		if v.Name != nil {
			dataSource["name"] = *v.Name
		}
		results = append(results, dataSource)
	}

	return results
}

func flattenExtensionDataSources(input *[]insights.ExtensionDataSource) ([]interface{}, error) {
	if input == nil {
		return []interface{}{}, nil
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		dataSource := make(map[string]interface{})
		if v.Streams != nil {
			streams := make([]string, 0)
			for _, stream := range *v.Streams {
				streams = append(streams, string(stream))
			}
			dataSource["streams"] = streams
		}
		if v.InputDataSources != nil {
			dataSource["input_data_sources"] = utils.FlattenStringSlice(v.InputDataSources)
		}
		if v.ExtensionName != nil {
			dataSource["extension_name"] = *v.ExtensionName
		}
		if v.Name != nil {
			dataSource["name"] = *v.Name
		}
		if v.ExtensionSettings != nil {
			extensionSetting, err := pluginsdk.FlattenJsonToString(v.ExtensionSettings.(map[string]interface{}))
			if err != nil {
				return []interface{}{}, err
			}
			dataSource["extension_setting"] = extensionSetting
		}
		results = append(results, dataSource)
	}

	return results, nil
}

func flattenLogAnalyticsDestinations(input *[]insights.LogAnalyticsDestination) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		destination := make(map[string]interface{})
		if v.Name != nil {
			destination["name"] = *v.Name
		}
		if v.WorkspaceID != nil {
			destination["workspace_id"] = *v.WorkspaceID
		}
		if v.WorkspaceResourceID != nil {
			destination["workspace_resource_id"] = *v.WorkspaceResourceID
		}
		results = append(results, destination)
	}

	return results
}

func flattenAzureMonitorMetricsDestinations(input *insights.DestinationsSpecAzureMonitorMetrics) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	destination := make(map[string]interface{})
	if input.Name != nil {
		destination["name"] = *input.Name
	}

	return []interface{}{destination}
}

func flattenDataFlows(input *[]insights.DataFlow) []interface{} {
	if input == nil {
		return []interface{}{}
	}

	results := make([]interface{}, 0)
	for _, v := range *input {
		dataFlow := make(map[string]interface{})
		if v.Streams != nil {
			streams := make([]string, 0)
			for _, stream := range *v.Streams {
				streams = append(streams, string(stream))
			}
			dataFlow["streams"] = streams
		}
		if v.Destinations != nil {
			dataFlow["destinations"] = utils.FlattenStringSlice(v.Destinations)
		}
		results = append(results, dataFlow)
	}

	return results
}
