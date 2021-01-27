import express from 'express'

const server = express!
server.use express.static('./dist')

server.get '/' do(req,res)
	const html = <html>
		<head><title> "App"
		<body><script type='module' src='./app/index.imba'>
	
	return res.send html.toString!


imba.serve server.listen(process.env.PORT or 3000)