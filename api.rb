def apidata(u) # importando dados da API da CoinGecko
  url = URI(u)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  return http.request(request)
end

apif = File.new("api.config", 'a+') # lendo arquivo de log
$api = apif.read.chomp.strip # chave da API
while $api == "" || $api == nil # checando existência da chave da API
  print "\nERROR: API KEY NOT FOUND!

Instructions: register at one of the sites below to obtain a CoinGecko API key:
https://www.coingecko.com/en/api    https://rapidapi.com/coingecko/api/coingecko

After obtaining the key, paste it here: "
  $api = gets.chomp.strip
  apif.write($api)
end
apif.close
$api.freeze