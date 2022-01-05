versao = 2.8

print "\n                                "
("CrypTools v. " + versao.to_s).split("").each do |l|
  print l
  sleep 0.05
end
sleep 0.3
print "\n                                  by Milo_Draco\n"
dev = false # modo desenvolvedor

# REQUERIMENTOS **********************************************
require 'uri'
require 'net/http'
require 'openssl'
require 'open-uri'
require 'json'

# FUNÇÕES ****************************************************
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
  url = URI("https://coingecko.p.rapidapi.com/coins/list") # API
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if eval(response.read_body) == nil || response.read_body.include?("error")
    print "error]\n" # erro em caso de retorno vazio
    gets
    exit
  end
  print "#{eval(response.read_body).length} inputs]\n"
  return eval(response.read_body)
end

def data(a, p) # DADOS DO CRIPTOATIVO
  print "   [Importing asset data... " if p == true
  url = URI("https://coingecko.p.rapidapi.com/coins/" + a)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if JSON.parse(response.read_body) == nil || response.read_body.include?("error")
    print "\n\nERROR: ASSET NOT FOUND!\n" # erro em caso de retorno vazio
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
  url = URI("https://coingecko.p.rapidapi.com/coins/" + a + "/market_chart?vs_currency=usd&days=" + d.to_s)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if eval(response.read_body)[:prices] == nil || response.read_body.include?("error")
    print "\n\nERROR: ASSET NOT FOUND!\n" # erro em caso de retorno vazio
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

# INTERNET ***************************************************
print "\n[Checking for connection... "
if internet? == false # erro de conexão
  print "error]\n\n"
  sleep 1
  exit
else
  print "OK]\n"
  beep
end

# API ********************************************************
apif = File.new("api.config", 'a+') # lendo arquivo de log
$api = apif.read.chomp.strip # chave da API
while $api == "" || $api == nil
  print "\nERROR: API KEY NOT FOUND!

Instructions: register at one of the sites below to obtain a CoinGecko API key:
https://www.coingecko.com/en/api    https://rapidapi.com/coingecko/api/coingecko

After obtaining the key, paste it here: "
  $api = gets.chomp.strip
  apif.write($api)
end
apif.close
$api.freeze

# CRIANDO ARQUIVO DE LOG **************************************
file = File.new("cryptools.log", 'a') # criando arquivo de log
time = Time.now # data e hora atual
file.write("\nRecords of #{"%02d" % time.month}-#{"%02d" % time.day}-#{time.year}, at #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
file.close # fechando arquivo para salvar
file = File.new("cryptools.log", 'a') # reabrindo arquivo de log
n = 1 # contador

loop do # loop geral

  # MENU INICIAL **********************************************************
  title("menu")
  print "\n"
  menu = ["Holding", "Trading", "Stops", "Monitor", "Top 100", "Treasure hunt", "Search assets", "Records", "Check server", "News", "Help", "Exit"]
  menu.each do |l|
    print "  #{menu.index(l) + 1}. #{l}\n"
    sleep 0.05
  end
  print "\n"

  loop do
    print "Enter an option: "
    $opt = gets.chomp.to_i
    if $opt == menu.length + 1
      if dev == false
        dev = true 
        print "\n[Developer mode enabled]
Version: #{versao}
Platform: #{RUBY_PLATFORM}
Date/time: #{Time.now.asctime}
API: #{$api.inspect}\n\n"
      else
        dev = false
        print "\n[Developer mode disabled]\n\n"
      end
    end
    break if (1..menu.length).include?($opt)
  end

  if $opt == 1 # if 1

    # HOLDING **********************************************************
    title("holding")
    loop do # loop holding
      # INPUTS
      print "\nEnter the asset ID: "
      ativo = gets.chomp.downcase # ID do ativo
      if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERROR: INVALID ASSET!\n" # erro em caso de retorno vazio
        gets
        break
      end
      print "\n"
      dados = data(ativo, true) # dados do ativo
      c365 = chart(ativo, 365, true) # histórico anual
      c182 = chart(ativo, 182, true) # histórico semestral
      c90 = chart(ativo, 90, true) # histórico trimestral
      value = c90[:prices][-1] # valor atual
      sup = [dados["max_supply"].to_f, dados["total_supply"].to_f].max # suprimento total
      supc = dados["circulating_supply"] # suprimento em circulação

      # CÁLCULOS
      supp = (supc / sup.to_f) * 100 # percentual do suprimento
      var90 = ((value / c90[:prices][0]) - 1) * 100 # variação do trimestre
      var182 = ((value / c182[:prices][0]) - 1) * 100 # variação do semestre
      var365 = ((value / c365[:prices][0]) - 1) * 100 # variação do ano
      limit = [c90[:prices].min, c90[:prices].max] # máximo e mínimo do trimestre
      dif = limit[1] - limit[0] # diferença entre mínimo e máximo do trimestre
      zona = [limit[1] - (dif * 0.5), limit[1] - (dif * 0.764)] # zona de compra
      moment = ((value - zona[1]).abs / value) * 10 # avaliação do momento de compra
      moment *= Math::PI if value < zona[1]
      if supp > 0
        ssup = Math.sqrt(supp) # score do suprimento em circulação
      else
        ssup = 0.0
      end
      volat = (((var90 * 2) - var182).abs + ((var182 * 2) - var365).abs)**0.25 # avaliação da volatilidade
      fator = 5.5 + volat # fator divisor de acordo com a volatilidade para avaliação do crescimento
      if fator < 7
        fator = 7.0
      elsif fator > 21
        fator = 21.0
      end
      volat = 10 + ((volat - 10) / Math::PI) if volat > 10 # compressor
      cresc = ((var90 + var182 + var365)/fator).abs**(1/3.0) * 2 # avaliação do crescimento
      cresc = 20 + Math.sqrt(cresc - 20) if cresc > 20 # compressor
      cresc *= -1 if var90 + var182 + var365 < 0 # valores negativos
      cap = c90[:caps][-1] # capital atual
      if cap > 0
        scap = (Math.sqrt(Math.log(cap)) - 4) * 5 # score do capital atual
      else
        scap = 0.0
      end
      if sup > 0
        score = (cresc * 1) + (scap * 2) + (ssup * 0.5) - (volat - 5) - (moment * 1) # avaliação final
      else
        score = (cresc * 1.1) + (scap * 2.1) - (volat - 5) - (moment * 1) # avaliação sem suprimento
      end

      # MODO DEV
      if dev ==  true
        print "\nVariables:\n"
        %w(ativo dados sup supc supp value var90 var182 var365 limit dif zona moment ssup volat fator cresc cap scap score).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Asset (ID): #{ativo.capitalize}
  * Price: #{fnum(value, 1)}
  * Market capitalization: $#{fnum(cap, 4)}
  * Capitalization valuation: "
      print ava(scap, 10, 1)
      print " (#{fnum(scap, 3)})\n"
      if sup > 0
        print "  * Supply: #{fnum(supc, 4)} / #{fnum(sup, 4)} (#{fnum(supp, 3)}%)
  * Supply valuation: "
        print ava(ssup, 10, 1)
        print " (#{fnum(ssup, 3)})\n"
      end
      print "  * Annual variation: #{fnum(var365, 2)}
  * Annual valuation: "
      print ava(cresc, 10, 1)
      print " (#{fnum(cresc, 3)})
  * Volatility valuation: "
      print ava(volat, 10, 2)
      print " (#{fnum(volat, 3)})
  * Buying zone: #{fnum(zona[1], 1)} to #{fnum(zona[0], 1)}
  * Momentum valuation: "
      print ava(moment, 5, 2)
      print " (#{moment.round(2)})
  * FINAL VALUATION: "
      print ava(score, 30, 1)
      print " (#{fnum(score, 3)})\n"
      print "\nALERT: asset history is less than 12 months!\n" if c365[:prices].length < 364 || c365[:prices] == c182[:prices]

      # GRAVAÇÃO E LOOP
      file.write("  #{n}. Holding of asset #{ativo.capitalize} (#{fnum(value, 1)}): #{fnum(score, 3)} (#{ava(score, 30, 1)})", "\n") # escrevendo log
      n += 1
      print "\nCalculate another holding?? (y/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop holding

  elsif $opt == 2

    # TRADING **********************************************************
    title("trading")
    print "\nATTENTION! KNOW THAT TRADING INVOLVES HIGH RISK OF LOSS, DO NOT TRADE UNLESS YOU ARE SURE YOU KNOW WHAT YOU ARE DOING. NO METHOD CAN GUARANTEE PROFIT.\n"
    loop do # loop trading
      # INPUTS
      print "\nEnter the asset to be traded: "
      ativo = gets.chomp.downcase
      if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERROR: INVALID ASSET!\n" # erro em caso de retorno vazio
        gets
        break
      end
      print "\n"
      c90 = chart(ativo, 90, true) # histórico do trimestre
      c30 = chart(ativo, 30, true) # histórico do mês
      c7 = chart(ativo, 7, true) # histórico da semana
      c3 = chart(ativo, 3, true) # histórico da semana
      c1 = chart(ativo, 1, true) # histórico do dia
      value = c1[:prices][-1] # valor atual
      $ativo = ativo
      $c3 = c3
      $c7 = c7

      # CÁLCULOS
      limit = [[c1[:prices].min, c3[:prices].min, c7[:prices].min].min, [c1[:prices].max, c3[:prices].max, c7[:prices].max].max] # limites da semana
      dif = limit[1] - limit[0] # diferença entre limites da semana
      var1 = ((value / c1[:prices][0]) - 1) * 100
      var30 = ((value / c30[:prices][0]) - 1) * 100
      var90 = ((value / c90[:prices][0]) - 1) * 100
      zonas = [limit[1] - (dif * 0.382), limit[1] - (dif * 0.5), limit[1] - (dif * 0.618), limit[1] - (dif * 0.786)] # zonas da retração de Fibonacci
      cvar = [var1 * 30, var30, var90 / 3.0] # variação
      volat = cvar.max - cvar.min # volatilidade
      chance = (var30 * 2) + (var90 / 5.0) - (volat / 5.0) - (var1 / 3.0).abs # probabilidade de lucro
      if chance > 50
        chance = 50 + Math.sqrt(chance - 50) # diminuindo chances altas
      elsif chance < 10
        chance = 10 - Math.sqrt(10 - chance) # aumentando chances baixas
      end
      if chance < 0.01
        chance = 0.01 # chance mínima
      elsif chance > 75
        chance = 75.0 # chance máxima
      end
      seq = (10 - (chance / 10.0)).round # sequência de velas negativas

      # MODO DEV
      if dev ==  true
        print "\nVariables:\n"
        %w(ativo value limit dif var1 var30 var90 zonas cvar volat chance seq).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Asset (ID): #{ativo.capitalize}
  * Price: #{fnum(value, 1)}
  * Quarterly average: #{fnum(media(c90[:prices])[0], 1)};    Median: #{fnum(media(c90[:prices])[1], 1)};    Middle: #{fnum(media(c90[:prices])[2], 1)}
  * Profit probability:   "
      print ava(chance, 60, 1)
      print " (#{fnum(chance, 3)}%)
  * Volatility:   "
      print ava(volat, 100, 2)
      print " (#{fnum(volat, 3)}%)"
      print "\n  * Buying zones:
    - Zone 1: #{fnum(zonas[1], 1)} a #{fnum(zonas[0], 1)}
    - Zone 2: #{fnum(zonas[2], 1)} a #{fnum(zonas[1], 1)}
    - Zone 3: #{fnum(zonas[3], 1)} a #{fnum(zonas[2], 1)}\n"
      file.write("  #{n}. Signal for #{ativo}: #{seq} hours (chance of #{fnum(chance, 2)}), zone 1: from #{fnum(zonas[1], 1)} to #{fnum(zonas[0], 1)}, zone 2: from #{fnum(zonas[2], 1)} to #{fnum(zonas[1], 1)}, zone 3: from #{fnum(zonas[3], 1)} to #{fnum(zonas[2], 1)}\n") # escrevendo log
      print "  * Signal:
    1. Wait for #{seq} consecutive hours negative candlesticks;
    2. Buy when at least one of the alternatives below is true:
      2.1 The hour after sequence is positive and has at least +75% strength + volume;
      2.2 Some support has been reached and the hour after sequence has closed in positive;
      2.3 The candlestick of the next hour has a reversal pattern (dragonfly, hammer, etc.);

Remember to set limits right after buying to control the trading risk.\n"
      print "\nALERT: asset history is less than 3 months!\n" if c90[:prices].length < 90 || c90[:prices] == c30[:prices]
      n += 1
      print "\nCalculate another trade? (y/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop trading

  elsif $opt == 3 

    # STOPS **********************************************************
    
    title("stops")
    loop do
      # INPUTS
      print "\nHow would you like to enter the values? \n
  1. Import from server (use only if you have made the order right now)
  2. Manually insert"
      if defined?($ativo) != nil && defined?($c3) != nil && defined?($c7) != nil # checando se há histórico a resgatar
        resgat = true
      else
        resgat = false
      end
      print "\n  3. Use the values from the last calculated trade (#{$ativo.capitalize})?\n" if resgat == true
      print "\n\nEnter option: "
      opt = gets.chomp.to_i # opção inserida
      if resgat == true # número de opções para mostrar?
        if !(1..3).include?(opt) # 3 opções caso haja histórico a resgatar
          print "ERROR: INVALID OPTION!" # erro para perfis inválidos
          gets
          break
        end
      else
        if !(1..2).include?(opt) # 2 opções apenas
          print "ERROR: INVALID OPTION!" # erro para perfis inválidos
          gets
          break
        end
      end
      if opt == 3 # terceira opção
        ativo = $ativo # resgatando o último ativo
      else
        print "Insira o ID do ativo: " # inserindo o ativo manualmente
        ativo = gets.chomp
      end
      if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERROR: INVALID ASSET!\n" # erro em caso de retorno vazio
        gets
        break
      end
      print "Enter the total amount invested (in USD): "
      banca = gets.chomp.to_f
      print "Enter the unit value of the asset at the time of purchase: "
      value = gets.chomp.to_f
      print "Enter the trading strategy (audacious 1, aggressive 2, berserk 3, kamikaze 4): "
      sperfil = ["audacious", "aggressive", "berserk", "kamikaze"] # strings dos perfis
      perfil = gets.chomp.to_i
      if ![1,2,3,4].include?(perfil)
        print "ERROR: INVALID STRATEGY!" # erro para perfis inválidos
        gets
        break
      end
      if opt == 1 # importando dados do servidor na opção 1
        print "\n"
        c7 = chart(ativo, 7, true) # histórico da semana
        c3 = chart(ativo, 3, true) # histórico de 3 dias
      elsif opt == 2 # inserindo os valores manualmente na opção 2
        c7 = {:prices => []}
        c3 = {:prices => []}
        print "Enter the LOWEST unit value of the asset in the last 3 DAYS:\n"
        c3[:prices] << gets.chomp.to_f
        print "Enter the LOWEST unit value of the asset in the last 7 DAYS:\n"
        c7[:prices] << gets.chomp.to_f
        print "Enter the HIGHEST unit value of the asset in the last 3 DAYS:\n"
        c3[:prices] << gets.chomp.to_f
        print "Enter the HIGHEST unit value of the asset in the last 7 DAYS:\n"
        c7[:prices] << gets.chomp.to_f
        if c3[:prices][1] < value || c7[:prices][1] < value || c3[0] > value || c7[:prices][0] > value || c7[:prices][0] > c3[:prices][0] || c3[:prices][1] > c7[:prices][1]
          print "ERROR: INVALID VALUES!" # erro para valores errados
          gets
          break
        end
      elsif opt == 3 # resgatando os históricos na opção 3
        c7 = $c7.dup
        c3 = $c3.dup
      end

      # CÁLCULOS
      limit7 = [[c3[:prices].min, c7[:prices].min].min, [c3[:prices].max, c7[:prices].max].max] # limites de 7 dias
      limit3 = [c3[:prices].min, c3[:prices].max] # limites de 3 dias
      dif = limit7[1] - limit7[0] # diferença entre topo e chão
      if perfil == 1
        sg = limit3[1] # stop-gain
        sl = limit7[0] # stop-loss
      elsif perfil == 2
        sg = limit7[1]
        sl = limit7[0]
      elsif perfil == 3
        sg = [limit7[1] + (limit7[1] - limit3[1]), limit7[1] * 1.236].min
        sl = limit7[1] - (dif * 1.618)
      elsif perfil == 4
        sg = [limit7[1] + (limit7[1] - limit3[1]), limit7[1] * 1.236].max
        sl = limit7[1] - (dif * 2.618)
      end
      if sl / value.to_f > 0.95
        sl = value * 0.95 # stop-loss mínimo de 5%
      elsif sl < 0.00000001
        sl = 0.00000001 # evitando o stop-loss negativo
      end
      if value > sg
        print "ERROR: VALUE ABOVE TOP!" # erro valor errado
        gets
        break
      end
      gainp = (sg / value.to_f) - 1 # porcentagem de lucro
      lossp = (1 - (sl / value.to_f)) * -1 # porcentagem em risco
      if gainp.nan? || lossp.nan?
        print "ERROR: INVALID VALUES!" # erro para valores em branco
        gets
        break
      end
      lucro = (banca * (1 + gainp)) - banca # lucro
      risk = banca - (banca * (1 - lossp.abs)) # quantia em risco

      # MODO DEV
      if dev ==  true
        print "\nVariables:\n"
        %w(ativo banca value limit7 limit3 dif sg sl gainp lossp lucro risk).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Stops (by unit value):
    1. Stop-gain: #{fnum(sg, 1)} (#{fnum(gainp * 100, 2)})
    2. Stop-loss: #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)})
  * Absolute profit: #{fnum(lucro, 1)}
  * Amount at risk: #{fnum(risk, 1)}\n"
      print "\nALERT: risk far outweighs profit!\n" if lucro < risk / 1.5
      file.write("  #{n}. Stops for (#{sperfil[perfil - 1]}): stop-gain in #{fnum(sg, 1)} (+#{fnum(gainp * 100, 2)}), stop-loss in #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)}), profit of #{fnum(lucro, 1)} and risk of #{fnum(risk, 1)}\n") # escrevendo log
      n += 1
      print "\nCalculate other stops? (y/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop dos stops

  elsif $opt == 4 

    # MONITOR **********************************************************
    title("monitor")
    print "\nEnter the asset ID: "
    ativo = gets.chomp.downcase # ID do ativo
    if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERROR: INVALID ASSET!\n" # erro em caso de retorno vazio
        gets
        break
      end
    print "\nStarting monitoring of assets #{ativo.capitalize} at #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min} (press ENTER to abort):\n\n"
    c7 = chart(ativo, 7, true) # histórico semanal
    dif7 = c7[:prices].max - c7[:prices].min # diferença semanal
    limit = [c7[:prices].min, c7[:prices].max] # limites da semana
    zonas = [limit[1] - (dif7 * 0.236), limit[1] - (dif7 * 0.382), limit[1] - (dif7 * 0.5), limit[1] - (dif7 * 0.618), limit[1] - (dif7 * 0.786)] # zonas da retração de Fibonacci
    print "   [Waiting for the first complete candlestick...]\n" if ![0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].include?(Time.now.min) # aviso de espera
    init = c7[:prices][-1] # valor inicial
    seq = 0 # contador de sequência
    tvar = [] # todas as variações
    loop do # loop para aguardar a hora certa
      $enter = false # variável para tecla pressionada
      while ![0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].include?(Time.now.min) do # loop enquanto minutos forem quebrados
        sleep 1
        begin # checando se tecla é pressionada para cancelar
          $enter = STDIN.read_nonblock(1)
        rescue IO::WaitReadable
          $enter = false
        end
        break if $enter != false # break se tecla for pressionada
      end
      break if $enter != false

      # CAPTURANDO DADOS DA API
      ping1 = Time.now # medindo o ping
      c1 = chart(ativo, 1, false)

      #CÁLCULOS
      hour = c1[:prices].drop((c1[:prices].length * (23 / 24.0)).round) # histórico dos preços da última hora
      dif = hour.max - hour.min # diferença entre limites
      vols = c1[:vols].drop((c1[:vols].length * (23 / 24.0)).round) # histórico dos volumes da última hora
      caps = c1[:caps].drop((c1[:caps].length * (23 / 24.0)).round) # histórico da capitalização da última hora
      price = hour[-1] # preço atual
      vol = vols[-1] # volume atual
      cap = caps[-1] # capitalização atual
      if Time.now.min <= 2
        if Time.now.hour == 0 # redefinindo as zonas à meia-noite
          c7 = chart(ativo, 7, true) # histórico semanal
          dif7 = c7[:prices].max - c7[:prices].min # diferença semanal
          limit = [c7[:prices].min, c7[:prices].max] # limites da semana
          zonas = [limit[1] - (dif7 * 0.236), limit[1] - (dif7 * 0.382), limit[1] - (dif7 * 0.5), limit[1] - (dif7 * 0.618), limit[1] - (dif7 * 0.786)] # zonas da retração de Fibonacci
        end
        var = ((price / hour[0].to_f) - 1) * 100 # variação total da hora
        tvar << var # inserindo a variação na array
        tvar = tvar.drop(1) if tvar.length > 24 # limitando a média para 24 horas
        vtm = media(tvar)[0] # variação total média
        vvol = ((vol / vols[0].to_f) - 1) * 100 # variação do volume da hora
        vcap = ((cap / caps[0].to_f) - 1) * 100 # variação da capitalização
        vtotal = ((price / init.to_f) - 1) * 100 # variação desde o início
        fcompra = ((price - hour.min) / dif.to_f) * 100 # força de compra
        fvenda = ((price - hour.max) / dif.to_f) * 100 # força de venda
        forca = fcompra + fvenda # força somada
        if forca >= 0
          fv = forca + vvol # força + volume
        else
          fv = forca + (vvol * -1)
        end
        volat = (dif / price.to_f) * 100 # volatilidade
        if price - hour[0] > 0 # hora positiva ou negativa?
          if seq >= 0 # positiva
            seq += 1
          else
            seq = 1
          end
        elsif price - hour[0] < 0 # negativa
          if seq <= 0
            seq -= 1
          else
            seq = -1
          end
        end
      end
      if seq.abs > 1 # alertas sonoros para sequências
        seq.abs.times do
          beep
          sleep 0.25
        end
      end
      ping2 = Time.now # encerrando a medição de ping
      ping = ping2 - ping1

      # MODO DEV
      if dev ==  true
        print "\n\nVariables:\n"
        %w(ativo dif7 hour dif vols caps price vol cap init seq limit zonas ping).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
        if Time.now.min <= 2
          %w(var tvar vtm vvol vcap vtotal fcompra fvenda forca fv volat).each do |vn|
            v = eval(vn)
            STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
          end
        end
      end

      # RESULTADO
      if Time.now.min <= 2 # final da hora
        print "\n  > Summary of the hour:
    * Opening: #{fnum(hour[0], 1)};    Closing: #{fnum(hour[-1], 1)}    (#{fnum(var, 2)})
    * Maximum: #{fnum(hour.max, 1)};    Minimum: #{fnum(hour.min, 1)}
    * Average: #{fnum(media(hour)[0], 1)};    Median: #{fnum(media(hour)[1], 1)};    Middle: #{fnum(media(hour)[2], 1)}
    * Volume: $#{fnum(vol, 4)} (#{fnum(vvol, 2)})
    * Capitalization: $#{fnum(cap, 4)} (#{fnum(vcap, 2)})
    * Volatility: #{fnum(volat, 3)}%
    * Strength: #{fnum(forca, 2)};    Strength + volume: #{fnum(fv, 2)}
    * Mixed variance (cap. and value): #{fnum((var + vcap) / 2.0, 2)}
    * Average variance: #{fnum(vtm, 2)}
    * Total variance: #{fnum(vtotal, 2)}"
        print "\n    * Sequence of #{seq.abs} hours" if seq.abs > 1
        if price <= zonas[1] # checando zonas de compra
          print "\n    * ALERT: "
          if price <= zonas[1] && price > zonas[2]
            print "buying zone 1 (between -38.2% and -50% from the top)"
          elsif price <= zonas[2] && price > zonas[3]
            print "buying zone 2 (between -50% and -61.8% from the top)"
          elsif price <= zonas[3] && price >= zonas[4]
            print "buying zone 3 (between -61.8% and -78.6% from the top)"
          else
            print "dead zone (below -78.6% from the top)"
          end
        elsif price >= zonas[0]
          print "\n    * ALERT: selling zone (above -23.6% top)"
        end
        file.write("  #{n}. Asset value #{ativo.capitalize} at #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min}: #{fnum(price, 1)} (variance of #{fnum(var, 2)}, strength+volume of #{fnum(fv, 2)})\n")
        print "\n\n  > #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min} (#{ativo.capitalize}): #{fnum(price, 1)};    Volume: $#{fnum(vol, 4)}..." # INÍCIO DA HORA
        n += 1
      else
        print "\n    * #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min}: #{fnum(price, 1)} (#{fnum((((price / hour[(-1 - (hour.length / 12.0)).round].to_f) - 1) * 100), 2)});    Volume: $#{fnum(vol, 4)} (#{fnum((((vols[-1] / vols[(-1 - (vols.length / 12.0)).round].to_f) - 1) * 100), 2)})..." # parcial a cada 10 minutos
      end
      (290 - ping.round).times do # esperando 5 minutos - ping
        begin # checando se tecla foi pressionada
          $enter = STDIN.read_nonblock(1)
        rescue IO::WaitReadable
          $enter = false
        end
        break if $enter != false # break se tecla for pressionada
        sleep 1
      end
      break if $enter != false
    end # loop do monitor
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log

  elsif $opt == 5 

    # 100 MAIS **********************************************************
    title("top 100")
    
    # API
    print "\n   [Importing List... "
    url = URI("https://coingecko.p.rapidapi.com/coins/markets?vs_currency=usd&page=1&per_page=100&order=market_cap_desc")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)
    print "#{JSON.parse(response.read_body).length} inputs]\n"

    # INPUTS
    print "\nAmount of assets to be calculated (between 10 and #{JSON.parse(response.read_body).length})? "
    q = gets.to_i # quantidade de ativos a ser calculada
    if q > JSON.parse(response.read_body).length
      q = JSON.parse(response.read_body).length # máximo
    elsif q < 10
      q = 10 # mínimo
    end
    list = [] # lista com todos os ativos calculados
    num = 0 # posição do ativo
    best = [] # melhores ativos

    print "\n   [Wait a few minutes...]\n"
    JSON.parse(response.read_body).take(q).reverse.each do |x|
      ativo = x["id"] # ID do ativo
      next if ativo.include?("usd") # pulando as lastreadas no dólar
      print "\n#{num + 1}. #{ativo.capitalize}:" if dev == true # imprimindo lista no modo dev
      dados = data(ativo, false) # dados do ativo
      c365 = chart(ativo, 365, false) # histórico anual
      c182 = {:prices => c365[:prices].drop((c365[:prices].length * 0.5).round), :caps => c365[:caps].drop((c365[:caps].length * 0.5).round), :vols => c365[:vols].drop((c365[:vols].length * 0.5).round)} # histórico semestral
      c90 = {:prices => c365[:prices].drop((c365[:prices].length * 0.75).round), :caps => c365[:caps].drop((c365[:caps].length * 0.75).round), :vols => c365[:vols].drop((c365[:vols].length * 0.75).round)} # histórico trimestral
      value = c90[:prices][-1] # valor atual
      sup = [dados["max_supply"].to_f, dados["total_supply"].to_f].max # suprimento total
      supc = dados["circulating_supply"] # suprimento em circulação

      # CÁLCULOS
      supp = (supc / sup.to_f) * 100 # percentual do suprimento
      var90 = ((value / c90[:prices][0]) - 1) * 100 # variação do trimestre
      var182 = ((value / c182[:prices][0]) - 1) * 100 # variação do semestre
      var365 = ((value / c365[:prices][0]) - 1) * 100 # variação do ano
      limit = [c90[:prices].min, c90[:prices].max] # máximo e mínimo do trimestre
      dif = limit[1] - limit[0] # diferença entre mínimo e máximo do trimestre
      zona = [limit[1] - (dif * 0.5), limit[1] - (dif * 0.764)] # zona de compra
      moment = ((value - zona[1]).abs / value) * 10 # avaliação do momento de compra
      moment *= Math::PI if value < zona[1]
      if supp > 0
        ssup = Math.sqrt(supp) # score do suprimento em circulação
      else
        ssup = 0.0
      end
      volat = (((var90 * 2) - var182).abs + ((var182 * 2) - var365).abs)**0.25 # avaliação da volatilidade
      fator = 5.5 + volat # fator divisor de acordo com a volatilidade para avaliação do crescimento
      if fator < 7
        fator = 7.0
      elsif fator > 21
        fator = 21.0
      end
      volat = 10 + ((volat - 10) / Math::PI) if volat > 10 # compressor
      cresc = ((var90 + var182 + var365)/fator).abs**(1/3.0) * 2 # avaliação do crescimento
      cresc = 20 + Math.sqrt(cresc - 20) if cresc > 20 # compressor
      cresc *= -1 if var90 + var182 + var365 < 0 # valores negativos
      cap = c90[:caps][-1] # capital atual
      if cap > 0
        scap = (Math.sqrt(Math.log(cap)) - 4) * 5 # score do capital atual
      else
        scap = 0.0
      end
      if sup > 0
        score = (cresc * 1) + (scap * 2) + (ssup * 0.5) - (volat - 5) - (moment * 1) # avaliação final
      else
        score = (cresc * 1.1) + (scap * 2.1) - (volat - 5) - (moment * 1) # avaliação sem suprimento
      end

      # PARCIAL
      list << [x["name"], x["id"], score] # adicionando todos os ativos
      if best.length == 0
        best << [x["name"], x["id"], score]
      else
        (0..best.length - 1).each do |y|
          if score >= best[y][2]
            best.insert(y, [x["name"], x["id"], score]) 
            break
          end
        end
      end
      print " #{score}" if dev == true
      num += 1
    end
    best = best.take((q / 5.0).round) if best.length > (q / 5.0).round

    # MODO DEV
    if dev ==  true
      print "\nVariables:\n"
      %w(q num list best).each do |vn|
        v = eval(vn)
        STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
      end
    end

    # RESULTADO
    beep
    print "\nBest assets for holding:"
    file.write("  #{n}. Best assets for holding:")
    best.each do |z|
      print "\n  #{best.index(z) + 1}. #{z[0]} (#{z[1]}): #{fnum(z[2], 3)} (https://www.coingecko.com/en/coins/#{z[1]})"
      file.write(" #{best.index(z) + 1}. #{z[0]} (#{fnum(z[2], 3)});")
      sleep 0.1
    end
    file.write("\n")
    print "\n\nATTENTION: the scores obtained are approximate values, please recalculate more precisely in option 1 (Holding)."
    n += 1
    gets
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log

  elsif $opt == 6 

    # CAÇA AO TESOURO **********************************************************
    title("treasure hunt")

    # API
    bau = listar.shuffle.take(100) # todos os ativos

    # VARIÁVEIS
    list = [] # lista com todos os ativos calculados
    num = 0 # posição do ativo
    best = [] # melhores ativos

    # LISTA DE ATIVOS COM ERRO
    errof = File.new("error.log", 'a+') # criando/lendo arquivo com lista de ativos que deram erro
    erro = errof.read.chomp.strip.gsub("[", "").gsub("]", "").gsub(",", "").gsub("\"", "").split(" ") if erro.nil? == true
    errof.close
    erro = [] if erro == nil
    print "\nList of assets with error: #{erro}\n" if dev == true

    bau.reverse.each do |x|
      ativo = x[:id] # ID do ativo
      next if ativo.include?("usd") || erro.include?(ativo) # pulando as lastreadas no dólar ou com erro
      erro << ativo # inserindo ativo na lista de erro
      File.delete("error.log") # deletando arquivo
      errof = File.new("error.log", 'w') # reabrindo arquivo no modo gravação
      errof.write(erro) # gravando lista de erro no arquivo
      print "\n  #{num + 1}. #{ativo.capitalize}:"
      dados = data(ativo, false) # dados do ativo
      c365 = chart(ativo, 365, false) # histórico anual
      c182 = {:prices => c365[:prices].drop((c365[:prices].length * 0.5).round), :caps => c365[:caps].drop((c365[:caps].length * 0.5).round), :vols => c365[:vols].drop((c365[:vols].length * 0.5).round)} # histórico semestral
      c90 = {:prices => c365[:prices].drop((c365[:prices].length * 0.75).round), :caps => c365[:caps].drop((c365[:caps].length * 0.75).round), :vols => c365[:vols].drop((c365[:vols].length * 0.75).round)} # histórico trimestral
      value = c90[:prices][-1] # valor atual
      sup = [dados["max_supply"].to_f, dados["total_supply"].to_f].max # suprimento total
      supc = dados["circulating_supply"] # suprimento em circulação
      erro.delete(ativo) # removendo ativo na lista de erro
      errof = File.new("error.log", 'w') # reabrindo arquivo no modo gravação
      errof.write(erro) # gravando lista de erro no arquivo
      if value == nil || c365 == nil
        print " -"
        next
      end

      # CÁLCULOS
      supp = (supc / sup.to_f) * 100 # percentual do suprimento
      var90 = ((value / c90[:prices][0]) - 1) * 100 # variação do trimestre
      var182 = ((value / c182[:prices][0]) - 1) * 100 # variação do semestre
      var365 = ((value / c365[:prices][0]) - 1) * 100 # variação do ano
      limit = [c90[:prices].min, c90[:prices].max] # máximo e mínimo do trimestre
      dif = limit[1] - limit[0] # diferença entre mínimo e máximo do trimestre
      zona = [limit[1] - (dif * 0.5), limit[1] - (dif * 0.764)] # zona de compra
      moment = ((value - zona[1]).abs / value) * 10 # avaliação do momento de compra
      moment *= Math::PI if value < zona[1]
      if supp > 0
        ssup = Math.sqrt(supp) # score do suprimento em circulação
      else
        ssup = 0.0
      end
      volat = (((var90 * 2) - var182).abs + ((var182 * 2) - var365).abs)**0.25 # avaliação da volatilidade
      fator = 5.5 + volat # fator divisor de acordo com a volatilidade para avaliação do crescimento
      if fator < 7
        fator = 7.0
      elsif fator > 21
        fator = 21.0
      end
      volat = 10 + ((volat - 10) / Math::PI) if volat > 10 # compressor
      cresc = ((var90 + var182 + var365)/fator).abs**(1/3.0) * 2 # avaliação do crescimento
      cresc = 20 + Math.sqrt(cresc - 20) if cresc > 20 # compressor
      cresc *= -1 if var90 + var182 + var365 < 0 # valores negativos
      cap = c90[:caps][-1] # capital atual
      if cap > 0 && cap != nil
        scap = (Math.sqrt(Math.log(cap)) - 4) * 5 # score do capital atual
      else
        scap = 0.0
      end
      if sup > 0
        score = (cresc * 1) + (scap * 2) + (ssup * 0.5) - (volat - 5) - (moment * 1) # avaliação final
      else
        score = (cresc * 1.1) + (scap * 2.1) - (volat - 5) - (moment * 1) # avaliação sem suprimento
      end
      beep if score >= 20

      # PARCIAL
      list << [x[:name], x[:id], score] # adicionando todos os ativos
      if best.length == 0
        best << [x[:name], x[:id], score]
      else
        (0..best.length - 1).each do |y|
          if score > best[y][2]
            best.insert(y, [x[:name], x[:id], score]) 
            break
          end
        end
      end
      if dev == true
        print " #{score}" 
      else
        print " #{fnum(score, 3)}"
      end
      num += 1
    end
    best = best.take(3) if best.length > 3

    # MODO DEV
    if dev ==  true
      print "\n\nVariables:\n"
      %w(q num list best).each do |vn|
        v = eval(vn)
        STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
      end
    end

    # RESULTADO
    beep
    print "\n\nTreasure found:"
    file.write("  #{n}. Treasure found:")
    best.each do |z|
      print "\n  #{best.index(z) + 1}. #{z[0]} (#{z[1]}): #{fnum(z[2], 3)} (https://www.coingecko.com/en/coins/#{z[1]})"
      file.write(" #{best.index(z) + 1}. #{z[0]} (#{fnum(z[2], 3)});")
      sleep 0.1
    end
    file.write("\n")
    print "\n\nATTENTION: the scores obtained are approximate values, please recalculate more precisely in option 1 (Holding)."
    n += 1
    gets
    errof.close
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log

  elsif $opt == 7 

    # PESQUISA DE ATIVOS **********************************************************
    title("search")

    list = listar # lista de todos os ativos
    loop do # loop de pesquisa
      print "\nEnter your search term: "
      search = gets.chomp # palavra para pesquisa
      found = 1 # contador
      (0..list.length-1).each do |x|
        if dev == true
          print "\n" + "#{list[x]}" # imprimindo lista completa no modo dev
          if (x + 1) % 100 == 0
            print "\n___________________________________________________________________#{x + 1} of #{list.length}\n"
            gets
          end
        end
        name = list[x][:name] # nome do ativo
        id = list[x][:id] # ID do ativo
        symbol = list[x][:symbol] # símbolo do ativo
        if name.downcase.include?(search.downcase) || symbol.downcase.include?(search.downcase) # checando se há correspondência
          beep if dev == true # alerta sonoro para o modo dev
          print "\n  #{found}. #{name} ($#{symbol}): #{id} (https://www.coingecko.com/en/coins/#{id})"
          found += 1
          sleep 0.1
        end
      end
      if found == 1
        print "\nERROR: NO ASSETS FOUND." 
      else
        print "\n\n[Search finished: #{found - 1} assets found]" 
      end
      print "\n\nSearch for another asset? (y/n) "
      lp = gets.chomp.upcase
      break if lp == "N"
    end # loop da pesquisa

  elsif $opt == 8 

    # REGISTRO **********************************************************
    title("records")

    if File.exist?("cryptools.log") # checando se arquivo de log existe
      print "\n  1. Read records
  2. Erase records

Enter an option: "
    opt = gets.chomp.to_i # opção inserida
    if !(1..2).include?(opt)
      print "ERROR: INVALID OPTION!" # erro para opção inválida
      gets
      break
    end
    print "\n"
    if opt == 1 # ler registro
    log = File.open("cryptools.log") # lendo arquivo de log
    print "Enter the search term or press ENTER for the entire record: "
    search = gets.chomp.downcase # palavra para pesquisa
    print "\n"
    log.read.split("\n\n").reverse.each do |l|
      if l.downcase.include?(search)
        puts l
        gets
      end
    end
    print "\n   [End of log]"
    gets
    elsif opt == 2 # apagar registro
      print "Delete log file? (y/n) "
      sure = gets.chomp.upcase
      if sure == "Y"
        file.close
        File.delete("cryptools.log")
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        file.write("\nRecords of #{"%02d" % time.month}-#{"%02d" % time.day}-#{time.year}, at #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
        print "\n   [File deleted successfully]"
        gets
      end
      if File.exist?("error.log")
        print "\nDelete error log? (y/n) "
        sure = gets.chomp.upcase
        if sure == "Y"
          File.delete("error.log")
          print "\n   [File deleted successfully]"
          gets
        end
      end
    end
    else
      print "\nERROR: LOG FILE NOT FOUND!\n"
    end

  elsif $opt == 9 

    # TESTANDO SERVIDOR
    title("check server")
    
    sleep 0.1
    print "\n   [Checking connection...]\n"

    if internet?
      link = "OK"
    else
      link = "no connection"
    end

    ping1 = Time.now
    url = URI("https://coingecko.p.rapidapi.com/ping")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)
    ping2 = Time.now
    ping = ping2 - ping1

    print "\n  * Connection: #{link}
  * Message: #{eval(response.read_body).shift[-1]}
  * Ping: #{fnum(ping, 3)} second(s)\n"
    sleep 2

  elsif $opt == 10 

    # NOTÍCIAS **********************************************************
    title("news")

    sleep 0.1
    print "\n   [Importing news..."
    url = URI("https://coingecko.p.rapidapi.com/status_updates")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)
    print " OK]\n"

    print "\nType search term or press ENTER for all news: "
    search = gets.chomp.downcase # palavra para pesquisa
    num = 1
    JSON.parse(response.read_body)["status_updates"].each do |x|
      if x["description"].downcase.include?(search)
        cal = "#{x["created_at"][5..6]}-#{x["created_at"][8..9]}-#{x["created_at"][0..3]}" # data no calendário
        print "\n#{num} of #{JSON.parse(response.read_body)["status_updates"].length}:___________________________________________________________#{cal}\n"
        x["description"].split("\r").each do |y|
          print y
          sleep 0.05
        end
        print "\n"
        gets
      end
      num += 1
    end
    print "\n   [News finished]"
    gets

  elsif $opt == 11 

    # AJUDA **********************************************************
    title("help")
    print "\n"

    tutorial = "General instructions: run the file '.rb' in Linux terminal or other OS and enter the desired transaction information. Linux example: if the file is in your home folder, just open the terminal and type 'ruby ct-en.rb'. If you need more information about cryptocurrencies, go to the sites below:
https://www.infomoney.com.br/guias/criptomoedas/    https://economia.uol.com.br/faq/criptomoedas-o-que-e-como-funciona-bitcoin-e-mais.htm    https://www.forbes.com/advisor/investing/what-is-cryptocurrency/
If you are not registered with any cryptocurrency exchange, consider registering with Binance, one of the largest exchanges in the world: https://accounts.binance.me/pt-BR/register?ref=M7Y0CB4O
1. Holding: the algorithm evaluates a given crypto-asset, helping the user to decide whether to invest for long-term profit. Ideal for 'savings' and 'earnings' and 'stakings'.
1.1 Subtitles: a) Value: unit value of the asset; b) Market capitalization: market cap; c) Supply: outstanding supply and total supply; d) Buying zone: ideal price range for purchase according to Fibonacci Retraction; e) Momentum valuation: current value evaluation according to the buying zone.
2. Trading: the algorithm stipulates signals for swing trading. Ideal for experienced traders who are used to trading. Keep in mind that trading involves high risk of financial loss, use this algorithm at your own risk. Instructions: Enter all data correctly. When analyzing the chart, you need to view candles with a 1 hour interval. If you see that the minimum of consecutive negative candles has been reached, check whether the current value of the cryptocurrency is within one of the buy zones. If so, wait until the asset value approaches support or a reversal candlestick pattern appears before buying. Examples of reversal candlestick patterns: Dragonfly Doji, Hammer and Tweezer Bottom. If you want to learn more about Japanese candles, click on the sites below:
https://www.financebrokerage.com/pt-br/padroes-de-graficos/    https://www.investirnabolsa.com/curso-cfd/velas-japonesas/    https://www.forex.com/en-us/market-analysis/latest-research/japanese-candlestick-patterns-cheat-sheet-fx/
2.1 Subtitles: a) Quarterly average: average of all values in the last quarter; b) Median: value in the center of all values in the quarter's history; c) Middle: average between the quarter's maximum and minimum; d) Buying zones: best buying zones according to Fibonacci Retracement.
3. Stops: calculates the limits of gain and loss of a trade, as well as the possible profit and loss risk. The suggestion is to apply the strategy according to the zone in which the asset was at the moment of purchase: 'bold' for zone 1, 'aggressive' for zone 2 and 'berserk' for zone 3.
3.1 Subtitles: a) Stop-gain: moment of selling at a profit; b) Stop-loss: moment of selling at a loss; c) Absolute profit: possibility of profit in absolute amount, in case the gain limit is reached; d) Amount at risk: amount at risk of loss, in case the loss limit is reached.
4. Monitor: monitors the value of the cryptocurrency in 5-minute interval. A summary is shown at the end of each hour, with statistics and important data. Please note: the buying zones shown in this mode are for trading.
4. 1 Subtitles: a) Opening: asset value at the beginning of the hour; b) Closing: asset value at the end of the hour; c) Maximum: maximum value reached during the hour; d) Minimum: minimum value reached during the hour; e) Average: average of all values during the hour; f) Median: value in the center of the set of all values in the hour; g) Middle: average between maximum and minimum; h) Volume: volume of the last 24 hours; i) Strength: buyers' strength ('bulls', positive value) against sellers' strength ('bears', negative value); j) Strength + volume: sum of strength and volume variation during the hour; k) Mixed variance: average of the variation in value and market capitalization; l) Average variance: average of the variations of the hours since the beginning of monitoring; m) Total variation: total variation since the beginning of monitoring; m) Zone: buying/selling zones for trading; n) Sequence: consecutive hours, positive or negative.
5. Top 100: finds the best holding assets among those with the highest capitalization; 6. Treasure Hunt: finds the three best assets among 100 random ones; 7. Search assets: useful to find out the ID of some cryptocurrency; 8. Record: view or delete the log file; 9. Check server: checks the connection to CoinGecko; 10. News: latest updates from the cryptoactive world.
Visit the project page and give it a star: https://github.com/milodraco/cryptools
Want to support the project? Send me some Satoshis (BTC): 19BbzBpudqWDzbCH2Rn8vT2q6CekjjtLN1
Remember: no method guarantees profit, just as none eliminates the possibility of loss. Trade only if you are aware of the risks involved and consult a professional in case of doubt.
ATTENTION! KNOW THAT TRADING INVOLVES HIGH RISK OF LOSS, DON'T TRADE UNLESS YOU ARE SURE YOU KNOW WHAT YOU ARE DOING. NO METHOD CAN GUARANTEE PROFIT."
    tutorial.split("\n").each do |l|
      l.split("").each do |l|
        print l
        sleep 0.001
      end
      print "\n"
      gets
    end

  elsif $opt == 12 # SAIR **********************************************************
    file.close
    print "\n"
    fim = "The entire log was saved to the file 'cryptools.log'.
Remember: it is recommended to consult a professional before making any investment. See you later!\n"
    fim.split("\n").each do |l|
      print l + "\n"
      sleep 0.1
    end
    gets
    exit

  end # if das opções
end # loop geral