import {PaperScope} from 'paper'
import * as tf from '@tensorflow/tfjs'

global css @root
	ff: sans
	bg: gray1

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
	css p fs:10
	css .active c:red4 fw:bold

	<self>
		<Digit>

tag Digit
	css .shadow bxs:0 4px 8px 0 gray4

	prop clicked = no
	prop model
	prop predicted_number
	prop prob

	def mount
		p = new PaperScope!
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
		$output.innerHTML = ''

		if p.project.isEmpty!
			write "Please draw something...", $output
			return

		tensor = preprocessCanvas(canvas)
		predictions = await model.predict(tensor)
		predicted_number = predictions.argMax(1).dataSync()[0]
		prob = predictions.arraySync()[0][predicted_number]
		
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

	<self>
		<div[ta:center h:80vh d:flex fld:column ja:center]>
			<canvas$paperCanvas .shadow width=400 height=400 [bg:red3 border-radius:20px m:2]>
		
			<[py:10px d:flex]>
				<button$predict.primary [fs:11] @click=(
					if clicked
						getResult $paperCanvas
					else
						$output.innerHTML = "Please draw a number first!"
					$predict.disabled = true
				)> "Predict"

				<button$clear.danger [fs:11] @click=(
					p.project.clear!
					p.view.draw!
					$predict.disabled = false
				)> "Clear"
				
			<p$output [fs:11 c:teal4]> "Write a number."


imba.mount <Main>
