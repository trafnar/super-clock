import 'imba/reset.css'

import * as df from 'date-fns'
import {animate} from 'popmotion'
import * as helpers from './helpers'
import './clock-view'

global css
	# color theme
	@root $bg:white @dark:black $fg:black @dark:white 
	body bgc:$bg

tag app

	# center everything on the page
	css h:100% d:vflex ja:center
	
	# re-render the clock every second
	prop autorender = 1fps

	# load the dots from localStorage, its an array of dot indicies that are "on"
	prop onDots = helpers.loadDots()

	# how many minutes to add to the actual time, to allow scrolling the hand
	#timeOverrideMinutes = 0

	# allows accessing current date with override applied
	get currentDate
		df.addMinutes(new Date(), #timeOverrideMinutes)
	
	# turns dot on or off, whichever is specified
	def setDotTo index, off = false
		helpers.storeDots(
			if off then helpers.withDotTurnedOff(onDots, index)
			else helpers.withDotTurnedOn(onDots, index)
		)

	# default size, this is overriden with a value on the first render
	prop size = getSize()

	# choose whichever is smaller, window height, or width
	# return that, minus 10% to use as the clock size
	def getSize()
		const width = window.innerWidth
		const height = window.innerHeight
		const smallest = width > height ? height : width
		return smallest - (smallest * 0.1)


	# touch handling	
	# --------------------
	
	# for each touch event, store the calculated angle here so it can be
	# compared to the next angle in the next touch event
	#previousAngle = null

	# are we deleting or adding dots?
	#deleteMode? = null

	# is the mouse down on the page?
	#mouseDown? = false

	def handleClockTouch e

		e = e.originalEvent

		#mouseDown? = true if e.type === 'pointerdown'

		# find center of clock
		const bounds = $clock.getBoundingClientRect()
		const xCenter = bounds.x + bounds.width / 2
		const yCenter = bounds.y + bounds.height / 2


		# find angle of mouse position
		const {angle} = helpers.toPolar(e.x, e.y, xCenter, yCenter)

		# find the dot indicies that overlap the range of angles from
		# previous angle, to current angle, and iterate over them
		# we use this range instead of a single value in order to avoid
		# skipping any dots when the mouse moves fast
		for index in helpers.indiciesForAngleRange(#previousAngle, angle)

			# if first dot clicked is on, then we are in deleting mode
			# otherwise in adding mode
			#deleteMode? = onDots.includes(index) if #deleteMode? === null

			# turn the dot on or off based on the mode
			setDotTo(index, #deleteMode?)

		# store the current angle for use in the next touch event
		#previousAngle = angle	
		
		# when mouse comes up, reset these values
		if e.ended?
			#deleteMode? = null
			#mouseDown? = false
			#previousAngle = null


	# scroll the clock hand easter egg
	# --------------------

	# store a reference to the animation that spins the hand back to the current time
	#resetHandAnimation = null

	# store a reference to the timeout used to trigger the reset animation
	#resetTimeout = null

	def handleMouseWheel e

		# update the time override amount by the scroll amount
		#timeOverrideMinutes += e.deltaY / 10

		# if the time is currently being overridden
		if #timeOverrideMinutes !== 0

			# reset the timer, this way the timer fires after 1000ms of no scrolling
			clearTimeout(#resetTimeout)

			# create the timeout which will reset the hand after 1000ms of inactivity
			#resetTimeout = setTimeout(&, 1000) do

				# if the reset hand animation isn't already playing
				if #resetHandAnimation == null

					# create the reset hand animation
					#resetHandAnimation = animate({
						from:#timeOverrideMinutes # animate from the override amount
						to: 0 # to zero
						type: 'spring'
						stiffness: 210
						damping: 10
						mass:0.3
						onUpdate: do(latest)
							# on each tick of the animation, update override minutes
							#timeOverrideMinutes = latest
							render() # and manually re-render
						onComplete: do #resetHandAnimation = null
					})


	def render

		<self>

			<global @resize=(size = getSize()) @mousewheel=(handleMouseWheel) >

			<div.footer-links>
				css pos:absolute b:10px l:15px r:15px ja:center d:flex fs:12px jc:space-between
					a c:$fg o:0.25 mr:15px @last:0 
					a@hover td:underline c:$fg o:1
				<a href="https://www.kickstarter.com/projects/cwandt/superlocal"> "Based on"
				<a href="https://www.wedeserveless.com"> "Made By"

			# finally, render the actual clock
			<clock-view$clock
				size=size
				down=#mouseDown?
				deleting=#deleteMode?
				onDots=onDots
				date=currentDate
				@clockTouch=handleClockTouch
				[size:{size}px]
			>




imba.mount <app>