import express from 'express'

const server = express!
server.use express.static('./dist')

server.get '/' do(req,res)
	const html = <html>
		<head>
			<meta charset='utf-8'>
			<meta name='viewport' content='width=device-width, initial-scale=1'>
			<title> "App"
		<body>
			<script type='module' src='./app/index.imba'>
	
	return res.send html.toString!


imba.serve server.listen(process.env.PORT or 3000)