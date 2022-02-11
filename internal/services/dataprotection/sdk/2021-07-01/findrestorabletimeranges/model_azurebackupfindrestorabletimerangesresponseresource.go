package findrestorabletimeranges

type AzureBackupFindRestorableTimeRangesResponseResource struct {
	Id         *string                                      `json:"id,omitempty"`
	Name       *string                                      `json:"name,omitempty"`
	Properties *AzureBackupFindRestorableTimeRangesResponse `json:"properties,omitempty"`
	SystemData *SystemData                                  `json:"systemData,omitempty"`
	Type       *string                                      `json:"type,omitempty"`
}
