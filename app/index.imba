import './assets/reset.css'
# import {PaperScope} from 'paper'
# import * as tf from '@tensorflow/tfjs'
# import katex from 'katex'
# import renderMathInElement from "https://cdn.jsdelivr.net/npm/katex@0.12.0/dist/contrib/auto-render.mjs"

# import {exercises, answers} from './tran-khai-nguyen-hcm.json'
import {id, title, exercises, answers} from './thu-tn-chuyen-ha-long-2021.json'


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

def renderTex el
	renderMathInElement(el, {
		delimiters: [
			{left: "$$", right: "$$", display: true},
			{left: "$", right: "$", display: false}
		],
		output: 'html'
	})


tag Main
	<self>
		<App>
		# <Exercise>
		# <Digit>
		<Temp>
		# <Snake>


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
	css .shadow bxs:0 4px 8px 0 gray4

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

	<self ><div[ta:center]>
		<canvas$paperCanvas .shadow width=300 height=300 [bg:red3 border-radius:20px m:2]>
		
		<br>
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
		<p$output [fs:11 c:teal4]> "Write a number."

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
		<canvas$cv_snake.canvas [rd:20px] width=800 height=500>


global css @root
	--grid-2cols: auto-flow / 1fr
	--grid-2cols@xs: auto-flow / 1fr
	--grid-2cols@sm: auto-flow / 1fr 1fr
	--grid-2cols@md: auto-flow / 1fr 1fr
	ff:Niramit

tag Temp
	css button 
		p:2 flex:1 rd:5 m:4
		@hover y:-5px shadow:md
		transition: all 0.1s
	css .blue bg:blue2 @hover:blue3 c:blue8
	css .teal bg:teal2 @hover:teal3 c:teal8
	css .yellow bg:yellow2 @hover:yellow3 c:yellow8
	css .red bg:red2 @hover:red3 c:red8 
	css input rd:4 p:2 bd:0 bxs:md

	data = {
		"S = 1/2 a h": ['triangle', 'area'],
		"\\sin 2x = 2 \\sin x \\cos x": ['sin2x', 'sin(2x)']
	}

	value = ''


	def search keyword
		for own key, val of data
			if keyword in val
				$out.innerHTML = '$' + key + '$'
		renderTex $out


	<self>
		<form [bg:red2 ta:center] @submit.prevent.search(value)>
			<input bind=value placeholder='Search for...' >
			<button.teal [bxs:md] type='submit'> "Search"
		<div$out [m:auto w:40% ta:center p:0.5rem bg:blue3 fs:10]>

		<Menu>
		
		<div [bg:red1 p:3 jc:center] [d:grid gtc:40% 40% g:10px]>
			<div [bg:blue3 ta:center fs:10]> "test 1"
			<div [bg:blue3 ta:center fs:10]> "test 2"
			<div [bg:blue3 ta:center fs:10 gc:1 / -1]> "test 3"

		<div [ta:center d:grid g:10px]>
			<Card img='./images/totoro1.jpg'>
			<Card img='./images/totoro2.jpg'>
			<Card img='./images/totoro3.jpg'>

		<div [d:grid grid:2cols w:80% @xl:60% g:2px] 
			[jc:center m:auto]> for i in [1 .. 4]
			<button [fs:12 bg:red4 m:1 c:gray2]> "Item {i}"

		css button.last gc:1 / -1 @lg:2 / -1

		<div [d:grid w:80% @xl:60% g:2px] 
			[grid:auto-flow / 1fr @sm:auto-flow / repeat(3, 1fr) @lg:auto-flow / repeat(4, 1fr)]
			[jc:center m:auto]> for i in [1 .. 3]
			if i==10
				<button.last [fs:12 bg:green4 m:1 c:gray2]> "Item {i}"
			else
				<button [fs:12 bg:green4 m:1 c:gray2]> "Item {i}"

		 
tag Card
	img = ''
	width = 350px
	radius = 15px

	css img 
		bxs:md
		tween: all 0.1s ease
		@hover y:-4px x:4px bxs:lg
	

	<self>
		css img rd:{radius} w:{width}
		<div >
			<img src=img>

tag Menu
	css a px:2 py:1
	css button m:0 rd:3 fs:8 py:1 bg:green3

	css .drop-content
		max-height:0 visibility:hidden of:hidden fs:10
		tween: all 0.5s ease

	css .drop 
		bg:red5
		@focus .drop-content 
			max-height:120px visibility:visible fs:15

	show = no


	<self>
		
		<[w:80% m:auto bg:red2] [d:grid g:5px ta:center jc:flex-end]>
			
			<button href='#' [gr:1]> "Home"
			<button href='#' [gr:1]> "About"
			<button href='#' [gr:1]> "User"

		<.drop [w:80% m:auto fs:12 ta:center] tabindex=0>
			<p> 'Test'
			<div$ct.drop-content> 'Dropdown content'
		
		

class Question
	A = ''
	B = ''
	C = ''
	D = ''
	current = ''
	pending = no
	round = 0
	correct = no	

tag Exercise
	css p fs:10 rd:10px px:2 my:3px
	css img max-width:90% max-height:auto
	css .answered bg:red4 
	css .pending bg:blue2 bxs:sm
	css .choice fs:8 py:1 us:none cursor:pointer

	css .correct bg:green3 bxs:sm
	css .wrong bg:red3 bxs:sm
	css .pending bg:blue3 bxs:sm

	css .card 
		bd:1px solid rgba(0, 0, 0, .15)
		rd:15px p:3
		bxs:sm

	prop id
	prop title
	prop exercises
	prop answers
	prop choices

	def mount
		renderTex self
		
	def setup
		load id
		if (choices is null) or not (choices.constructor === Array)
			choices = []
			for i in [0 ... exercises.length]
				if i % 5 == 0
					idx = i/5
					choices.push(new Question!)

	def save choices
		window.localStorage.setItem(id, JSON.stringify(choices))

	def load id
		choices = JSON.parse(window.localStorage.getItem id)

	def clear id
		sure = window.confirm('Bạn có chắc muốn hủy tất cả các câu đã làm và làm lại?')
		if sure
			window.localStorage.removeItem id
			window.scrollTo(0, 0)
			window.location.reload()
	
	def submit id
		name = window.localStorage.getItem('name')
		if name is null
			name = window.prompt("Hãy nhập tên của bạn", "Harry Potter")
		else
			name = window.prompt("Hãy nhập tên của bạn", name)

		if not (name is null)
			window.localStorage.setItem('name', name)

		window.fetch('https://vietanh.space:5000/submit', {
			method: 'POST',
			headers: {'Content-Type':'application/json'}, 
			body: JSON.stringify({"name": name, "data": choices})
		})
		.then do(res)
			console.log "submitted"
			data = await res.json()
			console.log data.response

	def score 
		corrects = 0
		total = 0

		for item, i in choices 
			if item.pending
				total += 1
				if item.current === answers[i].toUpperCase()
					corrects += 1

		total == 0 ? ratio = 0 : ratio = corrects / total
		overall = corrects / choices.length

		return (100*ratio).toFixed(0), (10*overall).toFixed(1)

	def displayResult
		$result.style.display = 'block'

	def checkCorrect label, i
		if label == answers[i/5].toUpperCase()
			choices[i/5][label] = 'correct'
			choices[i/5].correct = yes
		else
			choices[i/5][label] = 'wrong'

	def removePending choice, label
		for label in ['A', 'B', 'C', 'D']
			if choice[label] == 'pending'
				choice[label] = ''
		return choice

	def choose e, i, label

		el = e.target

		if choices[i/5].round >= 2 or choices[i/5].correct or choices[i/5][label]=='wrong'
			return

		if choices[i/5].pending
			if choices[i/5][label] == 'pending'
				checkCorrect label, i
				choices[i/5].round += 1
			else
				choices[i/5] = removePending choices[i/5], label
				choices[i/5][label] = 'pending'
		else 
			choices[i/5].pending = yes
			choices[i/5][label] = 'pending'

		choices[i/5].current = label
		save choices
		

	<self>
		<h2 [ta:center fs:1.5rem fw:bold bg:blue3 p:5 m:3 rd:20px m:20px c:gray8]> title
		
		<div [w@sm:90% @md:70% @lg:60% @xl:40% m:auto]> for ex, i in exercises by 5
			<div.card >
				<p [fw:bold c:purple6]> "Câu {i/5+1}"
				if 'http' in ex
					<p> ex.slice(0, ex.indexOf('http'))
					<center><img [pb:2] src=ex.slice(ex.indexOf('http'))>
				else
					<p [pb:2]> ex
				<p.choice .{choices[i/5].A} @click=choose(e, i, 'A')> "A. {exercises[i+1]}"
				<p.choice .{choices[i/5].B} @click=choose(e, i, 'B')> 'B. ', exercises[i+2]
				<p.choice .{choices[i/5].C} @click=choose(e, i, 'C')> 'C. ', exercises[i+3]
				<p.choice .{choices[i/5].D} @click=choose(e, i, 'D')> 'D. ', exercises[i+4]
			<br>

		<[ta:center mb:4rem]>
			css button ff:sans fs:20px fw:bold
			<p$result [d:none fs:11]> "Tỉ lệ đúng: {score()[0]}%. Điểm: {score()[1]}đ."
			<button [bg:blue4 c:blue1] @click.displayResult> "Xem kết quả"
			<button [bg:green4 c:green1] @click=submit(id)> "Gửi kết quả"
			<button [bg:red4 c:red1] @click=clear(id)> "Làm lại"
			

imba.mount <Main>
