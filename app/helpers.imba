import * as df from 'date-fns'

# storage
# --------------------

const localStorageKey = 'timeDots'

# store array of dots in local storage
export def storeDots dots = []
	dots = dots.filter do(d) d != null
	window.localStorage.setItem(localStorageKey, JSON.stringify(dots))

# load array of dots from local storage
export def loadDots
	const data = window.localStorage.getItem(localStorageKey)
	return [] if data == null or data.trim() === ''
	const parsed = JSON.parse(data)
	if !Array.isArray(parsed) then return [] else return parsed


# dot on/off
# -------------------- 

# turn dot on by pushing it onto the array of dots if it isn't there already
export def withDotTurnedOn dots, index
	unless dots.includes(index)
		dots.push(index)
	return dots

# turn dot off by removing its index from the array of dots
export def withDotTurnedOff dots, index
	if dots.includes(index)
		const location = dots.indexOf(index)
		dots.splice(location, 1)
	return dots

export def getPercentIntoToday currentDate
	const msIntoToday = currentDate.getTime() - df.startOfDay(currentDate).getTime()
	const msInDay = 1000 * 60 * 60 * 24
	const percentIntoToday = msIntoToday / msInDay
	
# ----------

def radToDeg radians
	return radians * 180 / Math.PI

# convert the mouse x/y point to an angle and a radius
# centered on originX/originY
export def toPolar x, y, originX, originY

	# offset point to center of screen
	x = x - originX
	y = y - originY

	const radius = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2) )
	let angle = radToDeg(Math.atan(y / x))

	const xPositive? = x >= 0
	const yPositive? = y >= 0

	# correct angle result depending on quadrant
	angle += 360 if xPositive? and !yPositive?
	angle += 180 if (!xPositive? and yPositive?) or (!xPositive? and !yPositive?)

	# adjust angle to match dots
	angle = (angle + 90 - (7.5/2)) % 360

	return {radius, angle}

# find the dot index that corresponds to a given angle
export def indexForAngle angle
	const pieceSize = 360 / 48
	const nearestThreshold = angle - (angle % pieceSize)
	return nearestThreshold / pieceSize

# find all the dot incicies that correspond to a range of angles
export def indiciesForAngleRange startAngle, endAngle
	return [indexForAngle(endAngle)] if startAngle == null

	let distance = endAngle - startAngle
	const result = []

	if Math.abs(distance) > 180
		for i in [0...(Math.min(startAngle, endAngle))]
			const index = indexForAngle(i)
			result.push index if result.indexOf(index) === -1
		for i in [360...(Math.max(startAngle, endAngle))]
			const index = indexForAngle(i)
			result.push index if result.indexOf(index) === -1
	else
		for i in [startAngle...(startAngle + distance)]
			const index = indexForAngle(i)
			result.push index if result.indexOf(index) === -1
	return result