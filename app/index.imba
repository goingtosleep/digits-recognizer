import './assets/reset.css'
import {PaperScope} from 'paper'
import * as tf from '@tensorflow/tfjs'

global css @root
	ff: sans

global css .item p:4 flex:1 radius:3 m:4
global css button
	outline:0
	m:1 p:2 4 radius:3 fw:500 cursor:pointer
	c:gray8 bw:1 bc:black/2 shadow:sm
	transition: 100ms cubic-out
	border-radius:10px
	@active y:-5px shadow:md
	&.primary bg:blue5 @hover:blue6 c:blue1 @hover:white
	&.teal bg:teal3 @hover:teal4 c:teal8 @hover:teal9
	&.blue bg:blue3 @hover:blue4 c:blue8 @hover:blue9
	&.green bg:green3 @hover:green4 c:green8 @hover:green9
	&.danger bg:red5 @hover:red6 c:red1 @hover:white
	&.red bg:red3 @hover:red4 color:red9

def getRandomColor
		let letters = '0123456789ABCDEF'
		let color = '#'
		for i in [0...6]
			color += letters[Math.floor(Math.random() * 16)]
		return color

tag Main
	<self>
		<App>
		<Digit>
		<Temp>
		<Snake>


tag App
	css .done
		td: line-through

	todos = []
	newTitle = ""

	def addTodo
		if newTitle.trim! != ""
			todos.push {title: newTitle}
		newTitle = ""
		
	def toggleTodo todo
		todo.done = !todo.done


	<self [d:block m:3]>
		<header [d:hflex jc:center]>
			<svg [width:200px] src='./assets/logo.svg'>
		<h1 [ai:center ta:center fs:30px fw:bold c:indigo4 p:3]> "Header"


		<main [bd:1px solid blue rd:6px p:10px]>
			<form.header [ta:center] @submit.prevent.addTodo>
				<input [rd:5 p:2 bw:1px bxs:sm] bind=newTitle placeholder="Add...">
				<button [bg:blue5 c:blue1 @hover:white] type='submit'> 'Add item'

			<div [w:50% pt:0.5rem m:auto]> for todo in todos
				<div [p:5px] .done=(todo.done) @click.toggleTodo(todo)> todo.title

tag Digit
	p = new PaperScope!
	clicked = no
	model
	predicted_number
	prob

	def mount
		p.setup($paperCanvas)
		let tool = new p.Tool!

		tool.onMouseDown = do |e|
			clicked = yes
			path = new p.Path!
			path.strokeColor = 'white'
			path.strokeWidth = 25
			path.strokeCap = 'round'
			path.strokeJoin = 'round'
			path.sendToBack!
			$predict.disabled = false

		tool.onMouseDrag = do |e|
			path.add(e.point)

		tool.onMouseUp = do
			path.smooth!
			path.simplify(10)

		model = await tf.loadLayersModel("./models/model.json")

	def preprocessCanvas image
		tensor = tf.browser.fromPixels(image)
		.resizeNearestNeighbor([28, 28])
		.mean(2)
		.expandDims(2)
		.expandDims()
		.toFloat()
		return tensor.div(255.0)
		
	def getResult canvas
		tensor = preprocessCanvas(canvas)
		predictions = await model.predict(tensor)
		predicted_number = predictions.argMax(1).dataSync()[0]
		prob = predictions.arraySync()[0][predicted_number]

		$output.innerHTML = ''
		if 0.85 < prob < 0.95
			$output.style['color'] = 'green'
			write "Hmm this looks like number {predicted_number}.", $output
		elif prob >= 0.95
			$output.style['color'] = 'green'
			write "I'm quite sure that it's number {predicted_number}!", $output
		else
			$output.style['color'] = 'purple'
			write "Your handwriting's unpredictable! Try again please...", $output

	def sleep ms
		return new Promise do |res| setTimeout(res, ms)

	def write text, output
		for char in text
			if char == '!'
				output.innerHTML += char
				output.innerHTML += "<br>"
			else
				output.innerHTML += char
			await sleep(10)

	def render
		<self>
			<center><canvas$paperCanvas width=300 height=300 [bg:red3 border-radius:25px]>
			
			<br>
			<div [ta:center]>
				<button$clear.danger [fs:11] @click=(
					p.project.clear!
					$predict.disabled = false
				)> "Clear"
				<button$predict.primary [fs:11] @click=(
					if clicked
						getResult $paperCanvas
					else
						$output.innerHTML = "Please draw a number first!"
					$predict.disabled = true
				)> "Predict"
			<center><p$output [fs:11 c:teal4]> "Write a number."

tag Snake
	css canvas bg:white bd:1px solid blue4
	prop p = new PaperScope!

	def mount
		p.setup($cv_snake)
		let tool = new p.Tool!

		let points = 25
		let length = 35	

		let path = new p.Path
			strokeColor: 'blue'
			strokeWidth: 20
			strokeCap: 'round'

		let start = p.view.center.divide [10, 1]
		for i in [0...points]
			path.add(start.add(new p.Point(i*length, 0)))

		tool.onMouseMove = def onMouseMove e
			if e.event.target == $cv_snake
				path.firstSegment.point = e.point
				for i in [0...(points - 1)]
					let segment         = path.segments[i]
					let nextSegment     = segment.next
					let vector          = segment.point.subtract(nextSegment.point)
					vector.length       = length
					nextSegment.point   = segment.point.subtract(vector)
				path.smooth
					type: 'continuous'

		tool.onMouseDown = def onmousedown
			path.fullySelected = true
			# path.strokeColor = '#e08285'
			path.strokeColor = getRandomColor!

		tool.onMouseUp = def onmouseup
			path.fullySelected = false
			path.strokeColor = 'blue'

	<self> <div [p:1rem ta:center]>
		<canvas$cv_snake.canvas width=800 height=500>

tag Temp
	css button 
		p:2 flex:1 rd:5 m:4
		@active y:-5px shadow:md
	css .blue bg:blue2 @hover:blue3 c:blue8
	css .teal bg:teal2 @hover:teal3 c:teal8
	css .yellow bg:yellow2 @hover:yellow3 c:yellow8
	css .red bg:red2 @hover:red3 c:red8 
	css input rd:4 p:2 bd:0 bxs:md

	data = {
		"S = 1/2 a h": ['triangle', 'area']
	}

	value = ''

	def output text
		$out.innerHTML = text

	def search keyword
		for own key, val of data
			if keyword in val
				$out.innerHTML = key

	<self>
		<form [bg:red2 ta:center]>
			<input bind=value placeholder='Search for...' >
			<button.teal [bxs:md] @click.prevent.search(value)> "Search"
		<div$out [m:auto w:40% ta:center p:0.5rem bg:blue3]>
		



imba.mount <Main>
