import express from 'express'
import index from './app/index.html'

const server = express!
server.use express.static('./dist')

server.get '/' do(req, res)
	res.send index.body

imba.serve server.listen(process.env.PORT or 3000)