import time, sys, json,conf
import asyncio

def isFloat(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

class server(asyncio.Protocol):
	def __init__(self,name):
		super().__init__()
		self.name = name

	def connection_made(self,transport):
		self.transport = transport
		self.address = transport.get_extra_info('peername')

	def receive_data(self,data):
		inputdata = data.decode()
		prefix = inputdata.split(' ')[0]

		if prefix == "IAMAT":
			self.handle_IAMAT(inputdata)

		if prefix == 'AT':
			self.handle_AT(inputdata)

		if prefix == 'WHATSAT':
			self.handle_WHATSAT(inputdata)


	def handle_IAMAT(self,inputdata):
		arr = inputdata.split(' ')
		client = arr[1]
		location = arr[2]
		


