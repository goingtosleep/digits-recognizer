import './assets/reset.css'
import {PaperScope, view} from 'paper'
import * as tf from '@tensorflow/tfjs'


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


	<self [d:block]>
		<header [d:hflex]>
			<svg [width:200px] src='./assets/logo.svg'>

		<main [bd:1px solid blue rd:6px p:10px]>
			<form.header @submit.prevent.addTodo>
				<input bind=newTitle placeholder="Add...">
				<button [bg:blue5 c:blue1 @hover:white] type='submit'> 'Add item'

			<div> for todo in todos
				<div [p:5px] .done=(todo.done) @click.toggleTodo(todo)> todo.title


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


tag Main
	def getRandomColor
		let letters = '0123456789ABCDEF'
		let color = '#'
		for i in [0...6]
			color += letters[Math.floor(Math.random() * 16)]
		return color

	prop p = new PaperScope!
	prop clicked = no
	prop model
	prop predicted_number
	prop prob

	def mount
		p.setup($paperCanvas)

		let path

		p.view.onMouseDown = do |e|
			clicked = yes
			path = new p.Path!
			path.strokeColor = 'white'
			path.strokeWidth = 25
			path.strokeCap = 'round'
			path.strokeJoin = 'round'
			path.sendToBack!
			$predict.disabled = false

		p.view.onMouseDrag = do |e|
			path.add(e.point)

		p.view.onMouseUp = do
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
			<App>
		

imba.mount <Main>
