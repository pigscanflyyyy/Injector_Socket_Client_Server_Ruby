# encoding: utf-8
=begin
	Injector Ruby.
	Criado por Marcone (thegrapevine@email.com).
	Aceita as tags [host]; [port]; [host_port]; [protocol]; [crlf]; [lfcr]; [cr]; [lf]
=end

# Importa o Módulo 'socket'.
require 'socket'


# Requerido para Compilar Ocra pulando gets e whiles.
begin
	ocra_comp = open('compile.txt','r')
	ocra_comp.close
	compile = true
rescue 
	compile = false
end


# Conecta.
def connection(cliente)
	$client_num = $client_num += 1
	num = $client_num
	puts "\n\n-*-*-*-*-*- ##{num} -*-*-*-*-*->\n<-> Client ##{num} Received"
	request = cliente.recvfrom(1024)

	# Formata Payload.
	host = request.to_s.split(':')[0].split()[-1]
	port = request.to_s.split(':')[-1].split()[0]
	host_port = host.to_s + ':' + port.to_s
	protocol = request.to_s.split('\r\n\r\n"')[-2].split()[-1]


	request_payload = PAYLOAD
	request_payload = request_payload.to_s.gsub '[host]', host.to_s
	request_payload = request_payload.to_s.gsub '[port]', port.to_s
	request_payload = request_payload.to_s.gsub '[host_port]', host_port.to_s
	request_payload = request_payload.to_s.gsub '[protocol]', protocol.to_s
	request_payload = request_payload.to_s.gsub '[crlf]', "\r\n"
	request_payload = request_payload.to_s.gsub '[lfcr]', "\n\r"
	request_payload = request_payload.to_s.gsub '[cr]', "\r"
	request_payload = request_payload.to_s.gsub '[lf]', "\n"
	
	print '<#> Client Request: '
	p request_payload

	# Cria um novo objeto socket e atribui o IP e Porta definidos na constante PROXY.
	server = TCPSocket.open(PROXY.split(':')[0].to_s, PROXY.split(':')[-1].to_i)
	# Envia Payload.
	server.puts request_payload
	# Mostra Resposta Real do Servidor.
	puts "<#> Server Response: "
	puts server.recvfrom(1024)[0].split("<")[0].strip()
	# Independente da Resposta, Envia 200 OK para o Cliente.
	puts '<#> Response sent to Cliente: HTTP/1.1 200 Connection estabilished\r\n\r\n'
	cliente.puts "HTTP/1.1 200 Connection estabilished\r\n\r\n"
	#server.puts cliente.recvfrom(4096)

	
	# Download e Upload.
	begin
		conectado = true
		while conectado == true
			ready = IO.select([server, cliente])
	        readable = ready[0]
	        
	        readable.each do |io|
	        	data = io.recv(8192)
	        	if data.length == 0
					conectado = false
					break
				end

				# Download e Upload.
				if io == server
					cliente.print data
				else
					server.print data
				end
			end
		end
	rescue 
		nil
	end
	server.close
	cliente.close
	puts "<!> Client ##{num} Disconnected!"
end

puts "-*- *- *- Injector Ruby -*- *- *- 
-*- *- *- Criado por Marcone (thegrapevine@email.com). -*- *- *- 

"


# Constants.

dicionario = {}

begin
	File.open('config.txt').each do |iten|
	key, value = iten.split('=')
	dicionario.store(key.strip, value.strip)
  end
	
rescue 
	puts 'Criando novo arquivo de configuração: config.txt'
	puts "Abra-o para editar as informações e execute o programa novamente\n\n"
	add = "PAYLOAD = CONNECT [host_port] [protocol][crlf][crlf]\nPROXY = nl.serverip.co:8080\nLISTEN = 127.0.0.1:8088"
	cria_file = open('config.txt', 'w')
	cria_file.write(add)
	cria_file.close
	retry	
end




PAYLOAD = dicionario['PAYLOAD']
PROXY = dicionario['PROXY']
LISTEN = dicionario['LISTEN']




$client_num = 0
# Listen.
# Cria um novo objeto socket e atribui o IP e Porta definidos na constante LISTEN.
l = TCPServer.new(LISTEN.split(':')[0].to_s, LISTEN.split(':')[-1].to_i)
puts "PAYLOAD: #{PAYLOAD}\nPROXY: #{PROXY}\nLISTEN: #{LISTEN}\n\nWaiting for connection on IP and Port: #{LISTEN}"

if compile == false
	# Aguarda o Cliente.
	while true
		# Recebe o Cliente.
		cliente = l.accept
		# Cria uma Thread para Atender o Cliente.
		Thread.new{connection(cliente)}
	end
end
