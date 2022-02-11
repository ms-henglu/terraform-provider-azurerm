package backuppolicies

type BackupSchedule struct {
	RepeatingTimeIntervals []string `json:"repeatingTimeIntervals"`
	TimeZone               *string  `json:"timeZone,omitempty"`
}
