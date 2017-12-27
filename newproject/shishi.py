def convert(location):
	decode_location = location.replace("+", " +").replace("-", " -").split()
	print(decode_location)

if __name__ == '__main__':
	convert('+34-118')