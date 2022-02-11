package findrestorabletimeranges

type AzureBackupFindRestorableTimeRangesRequest struct {
	EndTime             *string                    `json:"endTime,omitempty"`
	SourceDataStoreType RestoreSourceDataStoreType `json:"sourceDataStoreType"`
	StartTime           *string                    `json:"startTime,omitempty"`
}
