package findrestorabletimeranges

type AzureBackupFindRestorableTimeRangesResponse struct {
	ObjectType           *string                `json:"objectType,omitempty"`
	RestorableTimeRanges *[]RestorableTimeRange `json:"restorableTimeRanges,omitempty"`
}
