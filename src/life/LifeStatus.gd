class_name LifeStatus

export var age_days: int
export var hungry: int
export var health: float

func start(hungry: int, health: float):
	self.hungry = hungry
	UserData.log(['Start life status...', hungry])

func add_age(days: int):
	age_days += days

func get_age():
	return age_days
