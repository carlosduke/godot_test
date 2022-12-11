class_name LifeStatus

export var age_hours: int
export var hungry: int
export var health: float

func start(hungry: int, health: float):
	self.hungry = hungry
	UserData.log(['Start life status...', hungry])

func add_age(hours: int):
	age_hours += hours

func get_age(age_type: int):
	return UserData.cast_date(age_type, age_hours)
