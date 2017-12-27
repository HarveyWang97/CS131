import time, sys, json
import asyncio
import codecs
import logging
from asyncio import log

API_KEY = 'AIzaSyDrVVqQOtz4EqUnXnb1Vnluw3zJuYSlfh8'

client_dict = {}

ServerToPort = {
    'Alford':15205,
    'Ball':15206,
    'Hamilton':15207,
    'Holiday':15208,
    'Welsh':15209
}

PortToServer = {
    15205:'Alford',
    15206:'Ball',
    15207:'Hamilton',
    15208:'Holiday',
    15209:'Welsh'
}
 
Server_association = {
    'Alford': ['Hamilton', 'Welsh'],
    'Ball': ['Holiday', 'Welsh'],
    'Hamilton': ['Alford', 'Holiday'],
    'Holiday': ['Ball', 'Hamilton'],
    'Welsh': ['Alford', 'Ball']
}

def validFloat(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

class Server(asyncio.Protocol):
    def __init__(self,name):
        self.name = name
   
    def connection_made(self,transport):
        self.transport = transport
        peername = transport.get_extra_info('peername')
        print('Connection from {}\n'.format(peername))
        logfile.write('Connection from {}\n'.format(peername))

    def connection_lost(self,exc):
        peername = self.transport.get_extra_info('peername')
        logfile.write('Disconnected from {}\n'.format(peername))
        print('The server is disconnected')

    def data_received(self,data):
        print('Data receive: {!r}'.format(data.decode()))
        logfile.write('Data receive: {!r}\n'.format(data.decode()))
        tokens = data.decode().split()
        prefix = tokens[0]

        if prefix == 'IAMAT':
            self.handle_IAMAT(data.decode())

        elif prefix == 'AT':
            self.handle_AT(data.decode())

        elif prefix == 'WHATSAT':
            self.handle_WHATSAT(data.decode())

        else:
            self.reportError(data.decode(),'Wrong data')


    def handle_WHATSAT(self, msg):
        tokens = msg.split()

        if len(tokens) != 4:
            self.reportError(msg,'Wrong number of arguments')
            self.transport.close()
            return

        client = tokens[1]
        radius = tokens[2]


        if len(tokens) != 4:
            self.reportError(msg,'Wrong number of arguments')
            self.transport.close()
            return

        try:
            int(radius)
            int(tokens[3])
            if int(radius) < 0 or int(radius) >50:
                self.reportError(msg,'Wrong radius given')
                return

            if int(tokens[3]) < 0 or int(tokens[3]) > 20:
                self.reportError(msg,'Wrong number of items given')
                return

        except ValueError:
            self.reportError(msg,"Not integer")
            return

        self.limit = int(tokens[3])

        if client not in client_dict:
            self.reportError(msg,'Can not find related records')
            return

        radius_int = int(radius)*1000


        record = client_dict[client].split()
        location = record[4]
        decode_location = location.replace('+', ',').replace('-', ',-').lstrip(',')
        host = 'maps.googleapis.com'
        query = 'key={}&location={}&radius={}'.format(API_KEY,decode_location,str(radius_int))
        uri = f'/maps/api/place/nearbysearch/json?{query}'
        request = (f'GET {uri} HTTP/1.1\r\nHost: {host}\r\n'
                       'Content-Type: text/plain; charset=utf-8\r\n\r\n')
        
        coro = loop.create_connection(lambda: GoogleProtocol(request,self,client),host,'https',ssl=True)
        loop.create_task(coro)


    def respond_whatsat(self, response,user):
        rawjson = response[response.index('{'):response.rindex('}')+1]
        pjson = json.loads(rawjson)
        del pjson['results'][self.limit:]
        strjson = json.dumps(pjson, indent=3)
        snew = ''
        while(snew != strjson):
            snew = strjson
            strjson = strjson.replace('\n\n', '\n')
        strjson = strjson + '\n\n'
        server_name = client_dict[user].split()[1]
        timediff = client_dict[user].split()[2]
        location = client_dict[user].split()[4]
        time = client_dict[user].split()[5]

        fullresponse = 'AT {} {} {} {} {}\n{}'.format(server_name,timediff,user,location,time,strjson)
        self.transport.write(fullresponse.encode())
        logfile.write('{}\n'.format(fullresponse))
        self.transport.close()


    def handle_IAMAT(self,msg):
        tokens = msg.split()
        if len(tokens) != 4:
            self.reportError(msg,"Wrong num of arguments")
            return

        client = tokens[1]
        location = tokens[2]
        if location.count("+") + location.count("-") != 2 or location.count(".") > 2:
            self.reportError(msg, "Wrong location format")
            return

        decode_location = location.replace("+", " +").replace("-", " -").split()

        if len(decode_location) != 2:
            self.reportError(msg, "Wrong location format")
            return


        if (not validFloat(decode_location[0])) or (not validFloat(decode_location[1])):
            self.reportError(msg,"Wrong location format" )
            return


        time = tokens[3]
        if not validFloat(time):
            self.reportError(msg, "Wrong time format")
            return

        if time[0] == '-':
            self.reportError(msg,"Wrong time")
            return

        if client in client_dict and float(time) <= float(client_dict[client].split()[-1]):
            logfile.write("Send to customer:{}\n".format(client_dict[client].encode()))
            self.transport.write(client_dict[client].encode())
            self.transport.close()
            return

        else:
            copy = tokens[1]+" "+tokens[2]+" "+tokens[3]
            response = "AT "+self.name+" "+self.get_time_diff(time)+" "+copy+'\n'
            logfile.write("Send to customer:{}\n".format(response.encode()))
            self.transport.write(response.encode())
            self.transport.close()
            self.handle_AT(response)

        

    def handle_AT(self,msg):
        self.transport.close()
        tokens = msg.split()
        client = tokens[3]
        time = tokens[-1]

        if client not in client_dict or float(time) > float(client_dict[client].split()[-1]): # the last element is time
            client_dict[client] = msg    

            for other in Server_association[self.name]:
                    port = ServerToPort[other]
                    coro = loop.create_connection(lambda:InterserverProtocol(msg),'127.0.0.1',port)
                    print("add a friend from {} to {}".format(self.name,other))
                    logfile.write('add a friend from {} to {}\n'.format(self.name,other))
                    loop.create_task(coro)


    def reportError(self,line,error):
        error_msg = '? '+line
        logfile.write('{}\n'.format(error))
        self.transport.write(error_msg.encode())
        self.transport.close()
        print(error)


    def get_time_diff(self,ori_time):
        diff_time = str(time.time()-float(ori_time))
        if diff_time[0]!='-':
            diff_time = '+'+diff_time
        return diff_time



class InterserverProtocol(asyncio.Protocol):
    def __init__(self, message):
        self.message = message

    def connection_made(self, transport):
        logfile.write('CONNECTION MADE WITH ' + str(transport.get_extra_info('peername'))+'\n')
        transport.write(self.message.encode())
        print('Data sent:{!r}'.format(self.message))
        logfile.write('WRITE TO ' + str(transport.get_extra_info('peername')) + ':\n{}\n'.format(self.message))
       
        
    def data_received(self, data):
        msg = data.decode()
        

class GoogleProtocol(asyncio.Protocol):
    def __init__(self, message, mainprotocol,user):
        self.user = user
        self.message = message
        self.prot = mainprotocol
        self.buf = ''
        
    def connection_made(self, transport):
        self.transport = transport
        print("connecting to Google")
        logfile.write('Connecting to Google with the message {}\n'.format(self.message))
        transport.write(self.message.encode())

    def data_received(self, data):
        self.buf = self.buf + data.decode()
        if self.buf[len(self.buf) - 4:] == '\r\n\r\n':
            parsed_data = self.parse_chunk(self.buf)
            self.transport.close()
            loop.call_soon(self.prot.respond_whatsat,parsed_data,self.user)

    def parse_chunk(self,raw):
        before = 0
        res = ""
        start = raw.index("chunked")
        raw = raw[7+start:]
        raw = raw.strip()
        i = 0 
        while i < len(raw):
            if raw[i:i+2] == '\r\n':
                cnt = int(raw[before:i],16)
                i += 2
                res+=raw[i:i+cnt]
                before = i+cnt
                i+=cnt
                while i<len(raw) and raw[i] in '\r\n':
                    i+=1
            else:
                i+=1
        return res


loop = asyncio.get_event_loop()
if len(sys.argv) != 2:
    sys.stderr.write('Wrong argument number {0}. Should be 2.\n'.format(len(sys.argv)))
    exit(1)
server_name = sys.argv[1]
logfile = codecs.open(server_name+"_log.txt",'w') 
coro = loop.create_server(lambda: Server(server_name),'127.0.0.1',ServerToPort[server_name])
server = loop.run_until_complete(coro)

print('Serving on {}'.format(server.sockets[0].getsockname()))
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass

server.close()
loop.run_until_complete(server.wait_closed())
print('loop closed')
logfile.write('\n')
logfile.shutdown()
loop.close()

















