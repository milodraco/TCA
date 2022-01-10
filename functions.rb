$error = Logger.new('error.log', 'monthly')

def title(s) # IMPRIMINDO TÍTULO
  print "\n"
  x = 80 - s.length
  (x / 2).times do
    print "_"
  end
  print s.upcase
  (x / 2.0).round.times do
    print "_"
  end
  print "\n"
end

def internet? # CHECANDO CONEXÃO
  if open('https://google.com/') || open('https://www.coingecko.com/')
    return true
  else
    return false
  end
end

def beep # SOM DE BIPE
  if RUBY_PLATFORM.downcase.include?("linux")
    print 7.chr
  elsif RUBY_PLATFORM.downcase.include?("mac")
    system('say "beep"')
  else
    print "\a" 
  end
end

def listar # LISTA DE TODOS OS ATIVOS
  print "\n   [Importing asset list... "
  response = apidata("https://coingecko.p.rapidapi.com/coins/list")
  if eval(response.read_body) == nil || eval(response.read_body) == "" || response.read_body.include?("invalid")
    print "error]\n" # erro em caso de retorno vazio
    $error.debug(response.read_body) # escrevendo a resposta da API no log de erros
    gets
    exit
  end
  print "#{eval(response.read_body).length} inputs]\n"
  return eval(response.read_body)
end

def data(a, p) # DADOS DO CRIPTOATIVO
  print "   [Importing asset data... " if p == true
  response = apidata("https://coingecko.p.rapidapi.com/coins/" + a)
  if JSON.parse(response.read_body) == nil || JSON.parse(response.read_body) == "" || response.read_body.include?("invalid")
    print "\n\nERROR: ASSET NOT FOUND!\n" # erro em caso de retorno vazio
    $error.debug(response.read_body) # escrevendo a resposta da API no log de erros
    gets
    exit
  end

  # convertendo em array e substituindo caracteres
  data = JSON.parse(response.read_body.gsub(":", ",").gsub("{", "[").gsub("}", "]"))[JSON.parse(response.read_body.gsub(":", ",").gsub("{", "[").gsub("}", "]")).index("market_data") + 1]
  # removendo outras moedas além do USD
  arr = ["current_price", "ath", "ath_change_percentage", "ath_date", "atl", "atl_change_percentage", "atl_date", "market_cap", "total_volume", "high_24h", "low_24h", "price_change_24h_in_currency", "price_change_percentage_1h_in_currency", "price_change_percentage_24h_in_currency", "price_change_percentage_7d_in_currency", "price_change_percentage_14d_in_currency", "price_change_percentage_30d_in_currency", "price_change_percentage_60d_in_currency", "price_change_percentage_200d_in_currency", "price_change_percentage_1y_in_currency", "market_cap_change_24h_in_currency", "market_cap_change_percentage_24h_in_currency"]
  arr.each do |n|
    next if !data.include?(n) # pulando caso o elemento não esteja incluso
    next if data[data.index(n) + 1].class != Array # pulando se não for array
    temp = data[data.index(n) + 1]
    if temp.include?("usd") # verificando se tem o valor em dólar
      data[data.index(n) + 1] = temp[temp.index("usd") + 1].to_f
    else
      data[data.index(n) + 1] = 0.0
    end
  end

  out = Hash.new # criando hash
  for x in (0..data.length - 2)
    next if x % 2 != 0 # pulando posições ímpares
    out[data[x]] = data[x + 1] # adicionando os elementos da hash
  end
  
  if out.length > 0
    print "#{out.length} inputs]\n" if p == true
  else
    print "error]\n" if p == true
    $error.debug(out.to_s) # escrevendo a resposta da API no log de erros
    gets
    exit
  end
  return out
end

def fnum(n, f) # FORMATANDO OS NÚMEROS
  n = n.to_f
  if f == 1 # formato para moeda
    if n >= 1
      return "$#{"%.2f" % n.round(2)}"
    else
      return "$#{"%.8f" % n.round(8)}"
    end
  elsif f == 2 # formato para porcentagem
    if n > 0
      return "+#{n.round(2)}%"
    else
      return "#{n.round(2)}%"
    end
  elsif f == 3 # formato geral
    if n.abs >= 1
      return "#{n.round(2)}"
    else
      return "#{n.round(8)}"
    end
  elsif f == 4 # valores altos
    return "#{n.round.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  else
    return "[invalid option]"
  end
end

def media(a) # MÉDIA E MEDIANA
  mid = a.length / 2
  sorted = a.sort
  return [a.inject{ |sum, el| sum + el }.to_f / a.size, a.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1]), (a.max + a.min) / 2.0]
end

def chart(a, d, p) # HISTÓRICO DO ATIVO
  print "   [Importing history of ", d, " days... " if p == true
  response = apidata("https://coingecko.p.rapidapi.com/coins/" + a + "/market_chart?vs_currency=usd&days=" + d.to_s)
  if eval(response.read_body)[:prices] == nil || eval(response.read_body)[:prices] == "" || response.read_body.include?("invalid")
    print "\n\nERROR: ASSET NOT FOUND!\n" # erro em caso de retorno vazio
    $error.debug(response.read_body) # escrevendo a resposta da API no log de erros
    gets
    exit
  end
  hist = {:prices => [], :caps => [], :vols => []}
  for n in 0..eval(response.read_body)[:prices].length-1 do
    hist[:prices][n] = eval(response.read_body)[:prices][n][1]
    hist[:caps][n] = eval(response.read_body)[:market_caps][n][1]
    hist[:vols][n] = eval(response.read_body)[:total_volumes][n][1]
  end
  print hist[:prices].length, " inputs]\n" if p == true
  return hist
end

def ava(s, b, o) # AVALIAÇÃO DE SCORE
  if o == 1 # ordem crescente  
    if s < b * (1/5.0)
      x = "terrible!"
    elsif s < b * (2/5.0)
      x = "bad "
    elsif s < b * (3/5.0)
      x = "reasonable"
    elsif s < b * (4/5.0)
      x = "good"
    else
      x = "excellent!"
    end
  else # ordem decrescente
    if s < b * (1/5.0)
      x = "excellent!"
    elsif s < b * (2/5.0)
      x = "good"
    elsif s < b * (3/5.0)
      x = "reasonable"
    elsif s < b * (4/5.0)
      x = "bad"
    else
      x = "terrible!"
    end
  end
  return x
end