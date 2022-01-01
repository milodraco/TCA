versao = 2.6

print "\n                              "
("CrypTools v. " + versao.to_s).split("").each do |l|
  print l
  sleep 0.05
end
sleep 0.3
print "\n                               por Milo_Draco\n"
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
  print "\n   [Importando lista de ativos... "
  url = URI("https://coingecko.p.rapidapi.com/coins/list") # API
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if eval(response.read_body) == nil || response.read_body.include?("error")
    print "erro]\n" # erro em caso de retorno vazio
    gets
    exit
  end
  print "#{eval(response.read_body).length} entradas]\n"
  return eval(response.read_body)
end

def data(a, p) # DADOS DO CRIPTOATIVO
  print "   [Importando dados do ativo... " if p == true
  url = URI("https://coingecko.p.rapidapi.com/coins/" + a)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if JSON.parse(response.read_body) == nil || response.read_body.include?("error")
    print "\n\nERRO: ATIVO NÃO ENCONTRADO!\n" # erro em caso de retorno vazio
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
    print "#{out.length} entradas]\n" if p == true
  else
    print "erro]\n" if p == true
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
    return "[opção inválida]"
  end
end

def media(a) # MÉDIA E MEDIANA
  mid = a.length / 2
  sorted = a.sort
  return [a.inject{ |sum, el| sum + el }.to_f / a.size, a.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1]), (a.max + a.min) / 2.0]
end

def chart(a, d, p) # HISTÓRICO DO ATIVO
  print "   [Importando histórico de ", d, " dias... " if p == true
  url = URI("https://coingecko.p.rapidapi.com/coins/" + a + "/market_chart?vs_currency=usd&days=" + d.to_s)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if eval(response.read_body)[:prices] == nil || response.read_body.include?("error")
    print "\n\nERRO: ATIVO NÃO ENCONTRADO!\n" # erro em caso de retorno vazio
    gets
    exit
  end
  hist = {:prices => [], :caps => [], :vols => []}
  for n in 0..eval(response.read_body)[:prices].length-1 do
    hist[:prices][n] = eval(response.read_body)[:prices][n][1]
    hist[:caps][n] = eval(response.read_body)[:market_caps][n][1]
    hist[:vols][n] = eval(response.read_body)[:total_volumes][n][1]
  end
  print hist[:prices].length, " entradas]\n" if p == true
  return hist
end

def ava(s, b, o) # AVALIAÇÃO DE SCORE
  if o == 1 # ordem crescente  
    if s < b * (1/5.0)
      x = "péssima!"
    elsif s < b * (2/5.0)
      x = "ruim "
    elsif s < b * (3/5.0)
      x = "razoável"
    elsif s < b * (4/5.0)
      x = "boa"
    else
      x = "excelente!"
    end
  else # ordem decrescente
    if s < b * (1/5.0)
      x = "excelente!"
    elsif s < b * (2/5.0)
      x = "boa"
    elsif s < b * (3/5.0)
      x = "razoável"
    elsif s < b * (4/5.0)
      x = "ruim"
    else
      x = "péssima!"
    end
  end
  return x
end

# INTERNET ***************************************************
print "\n[Checando conexão... "
if internet? == false # erro de conexão
  print "erro]\n\n"
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
  print "\nERRO: CHAVE DE API NÃO ENCONTRADA!

Instruções: registre-se em um dos sítios abaixo para adquirir uma chave de API da CoinGecko:
https://www.coingecko.com/pt/api    https://rapidapi.com/coingecko/api/coingecko

Após adquirir a chave, cole-a aqui: "
  $api = gets.chomp.strip
  apif.write($api)
end
apif.close
$api.freeze

# CRIANDO ARQUIVO DE LOG **************************************
file = File.new("cryptools.log", 'a') # criando arquivo de log
time = Time.now # data e hora atual
file.write("\nRegistros de #{"%02d" % time.day}/#{"%02d" % time.month}/#{time.year}, às #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
file.close # fechando arquivo para salvar
file = File.new("cryptools.log", 'a') # reabrindo arquivo de log
n = 1 # contador

loop do # loop geral

  # MENU INICIAL **********************************************************
  title("menu")
  print "\n"
  menu = ["Investimento ('holding')", "Negociação ('trading')", "Limites ('stops')", "Monitor", "100 Mais", "Caça ao tesouro", "Procurar ativos", "Registro", "Testar servidor", "Notícias (inglês)", "Ajuda", "Sair"]
  menu.each do |l|
    print "  #{menu.index(l) + 1}. #{l}\n"
    sleep 0.05
  end
  print "\n"

  loop do
    print "Insira uma opção: "
    $opt = gets.chomp.to_i
    if $opt == menu.length + 1
      if dev == false
        dev = true 
        print "\n[Modo desenvolvedor ativado]
Versão: #{versao}
Plataforma: #{RUBY_PLATFORM}
Data/hora: #{Time.now.asctime}
API: #{$api.inspect}\n\n"
      else
        dev = false
        print "\n[Modo desenvolvedor desativado]\n\n"
      end
    end
    break if (1..menu.length).include?($opt)
  end

  if $opt == 1 # if 1

    # HOLDING **********************************************************
    title("investimento/holding")
    loop do # loop holding
      # INPUTS
      print "\nInsira o ID do ativo: "
      ativo = gets.chomp.downcase # ID do ativo
      if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERRO: ATIVO INVÁLIDO!\n" # erro em caso de retorno vazio
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
        print "\nVariáveis:\n"
        %w(ativo dados sup supc supp value var90 var182 var365 limit dif zona moment ssup volat fator cresc cap scap score).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Ativo (ID): #{ativo.capitalize}
  * Valor: #{fnum(value, 1)}
  * Capitalização do mercado: $#{fnum(cap, 4)}
  * Avaliação da capitalização: "
      print ava(scap, 10, 1)
      print " (#{fnum(scap, 3)})\n"
      if sup > 0
        print "  * Suprimento: #{fnum(supc, 4)} / #{fnum(sup, 4)} (#{fnum(supp, 3)}%)
  * Avaliação do suprimento: "
        print ava(ssup, 10, 1)
        print " (#{fnum(ssup, 3)})\n"
      end
      print "  * Variação anual: #{fnum(var365, 2)}
  * Avaliação da variação: "
      print ava(cresc, 10, 1)
      print " (#{fnum(cresc, 3)})
  * Avaliação da volatilidade: "
      print ava(volat, 10, 2)
      print " (#{fnum(volat, 3)})
  * Zona de compra: #{fnum(zona[1], 1)} a #{fnum(zona[0], 1)}
  * Avaliação do momento: "
      print ava(moment, 5, 2)
      print " (#{moment.round(2)})
  * AVALIAÇÃO FINAL: "
      print ava(score, 30, 1)
      print " (#{fnum(score, 3)})\n"

      # GRAVAÇÃO E LOOP
      file.write("  #{n}. Investimento no ativo #{ativo.capitalize} (#{fnum(value, 1)}): #{fnum(score, 3)} (#{ava(score, 30, 1)})", "\n") # escrevendo log
      n += 1
      print "\nCalcular outro investimento? (s/n) "
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
    print "\nATENÇÃO! SAIBA QUE O TRADING ENVOLVE ALTO RISCO DE PREJUÍZO, NÃO NEGOCIE A NÃO SER QUE VOCÊ TENHA CERTEZA QUE SABE O QUE ESTÁ FAZENDO. NENHUM MÉTODO PODE GARANTIR O LUCRO.\n"
    loop do # loop trading
      # INPUTS
      print "\nInsira o ativo que será negociado: "
      ativo = gets.chomp.downcase
      if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERRO: ATIVO INVÁLIDO!\n" # erro em caso de retorno vazio
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
        print "\nVariáveis:\n"
        %w(ativo value limit dif var1 var30 var90 zonas cvar volat chance seq).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Ativo (ID): #{ativo.capitalize}
  * Valor: #{fnum(value, 1)}
  * Média trimestral: #{fnum(media(c90[:prices])[0], 1)};    Mediana: #{fnum(media(c90[:prices])[1], 1)};    Meio: #{fnum(media(c90[:prices])[2], 1)}
  * Probabilidade de lucro:   "
      print ava(chance, 60, 1)
      print " (#{fnum(chance, 3)}%)
  * Volatilidade:   "
      print ava(volat, 100, 2)
      print " (#{fnum(volat, 3)}%)"
      print "\n  * Zonas de compra:
    - Zona 1: #{fnum(zonas[1], 1)} a #{fnum(zonas[0], 1)}
    - Zona 2: #{fnum(zonas[2], 1)} a #{fnum(zonas[1], 1)}
    - Zona 3: #{fnum(zonas[3], 1)} a #{fnum(zonas[2], 1)}\n"
      file.write("  #{n}. Sinal para #{ativo}: #{seq} horas (chance de #{fnum(chance, 2)}), zona 1: de #{fnum(zonas[1], 1)} a #{fnum(zonas[0], 1)}, zona 2: de #{fnum(zonas[2], 1)} a #{fnum(zonas[1], 1)}, zona 3: de #{fnum(zonas[3], 1)} a #{fnum(zonas[2], 1)}\n") # escrevendo log
      print "  * Sinal:
    1. Esperar por #{seq} velas negativas de horas consecutivas;
    2. Comprar quando pelo menos uma das alternativas abaixo for verdadeira:
      2.1 A hora após a sequência é positiva e tem pelo menos +75% de força + volume;
      2.2 Algum suporte foi atingido e a hora após a sequência fechou no positivo;
      2.3 A vela da hora seguinte possui padrão de reversão (libélula, martelo etc.);

Lembre-se de definir os limites logo após a compra para controlar o risco da negociação.\n"
      n += 1
      print "\nCalcular outra negociação? (s/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop trading

  elsif $opt == 3 

    # STOPS **********************************************************
    
    title("limites/stops")
    loop do
      # INPUTS
      print "\nComo você gostaria de inserir os valores? \n
  1. Importar do servidor (usar somente se tiver feito a compra agora)
  2. Inserir manualmente"
      if defined?($ativo) != nil && defined?($c3) != nil && defined?($c7) != nil # checando se há histórico a resgatar
        resgat = true
      else
        resgat = false
      end
      print "\n  3. Utilizar os valores da última negociação calculada (#{$ativo.capitalize})?\n" if resgat == true
      print "\n\nInserir opção: "
      opt = gets.chomp.to_i # opção inserida
      if resgat == true # número de opções para mostrar?
        if !(1..3).include?(opt) # 3 opções caso haja histórico a resgatar
          print "ERRO: OPÇÃO INVÁLIDA!" # erro para perfis inválidos
          gets
          break
        end
      else
        if !(1..2).include?(opt) # 2 opções apenas
          print "ERRO: OPÇÃO INVÁLIDA!" # erro para perfis inválidos
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
        print "ERRO: ATIVO INVÁLIDO!\n" # erro em caso de retorno vazio
        gets
        break
      end
      print "Insira a quantia total investida (em USD): "
      banca = gets.chomp.to_f
      print "Insira o valor unitário do ativo no momento da compra: "
      value = gets.chomp.to_f
      print "Insira a agressividade da negociação (arrojada 1, agressiva 2, berserk 3, kamikaze 4): "
      sperfil = ["arrojado", "agressivo", "berserk", "kamikaze"] # strings dos perfis
      perfil = gets.chomp.to_i
      if ![1,2,3,4].include?(perfil)
        print "ERRO: PERFIL INVÁLIDO!" # erro para perfis inválidos
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
        print "Insira o MENOR valor unitário do ativo nos últimos 3 DIAS:\n"
        c3[:prices] << gets.chomp.to_f
        print "Insira o MENOR valor unitário do ativo nos últimos 7 DIAS:\n"
        c7[:prices] << gets.chomp.to_f
        print "Insira o MAIOR valor unitário do ativo nos últimos 3 DIAS:\n"
        c3[:prices] << gets.chomp.to_f
        print "Insira o MAIOR valor unitário do ativo nos últimos 7 DIAS:\n"
        c7[:prices] << gets.chomp.to_f
        if c3[:prices][1] < value || c7[:prices][1] < value || c3[0] > value || c7[:prices][0] > value || c7[:prices][0] > c3[:prices][0] || c3[:prices][1] > c7[:prices][1]
          print "ERRO: VALORES INVÁLIDOS!" # erro para valores errados
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
        print "ERRO: VALOR ACIMA DO TOPO!" # erro valor errado
        gets
        break
      end
      gainp = (sg / value.to_f) - 1 # porcentagem de lucro
      lossp = (1 - (sl / value.to_f)) * -1 # porcentagem em risco
      if gainp.nan? || lossp.nan?
        print "ERRO: VALORES INVÁLIDOS!" # erro para valores em branco
        gets
        break
      end
      lucro = (banca * (1 + gainp)) - banca # lucro
      risk = banca - (banca * (1 - lossp.abs)) # quantia em risco

      # MODO DEV
      if dev ==  true
        print "\nVariáveis:\n"
        %w(ativo banca value limit7 limit3 dif sg sl gainp lossp lucro risk).each do |vn|
          v = eval(vn)
          STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
        end
      end

      # RESULTADO
      print "\n  * Limites (pelo valor unitário):
    1. Limite de ganho (stop-gain): #{fnum(sg, 1)} (#{fnum(gainp * 100, 2)})
    2. Limite de perda (stop-loss): #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)})
  * Lucro absoluto: #{fnum(lucro, 1)}
  * Quantia em risco: #{fnum(risk, 1)}\n"
      print "\nALERTA: risco muito superior ao lucro!\n" if lucro < risk / 1.5
      file.write("  #{n}. Limites para (#{sperfil[perfil - 1]}): stop-gain de #{fnum(sg, 1)} (+#{fnum(gainp * 100, 2)}), stop-loss de #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)}), lucro de #{fnum(lucro, 1)} e risco em #{fnum(risk, 1)}\n") # escrevendo log
      n += 1
      print "\nCalcular outros limites? (s/n) "
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
    print "\nInsira o ID do ativo: "
    ativo = gets.chomp.downcase # ID do ativo
    if ativo == "" || ativo == nil # erro para ativo vazio
        print "ERRO: ATIVO INVÁLIDO!\n" # erro em caso de retorno vazio
        gets
        break
      end
    print "\nIniciando monitoramento do ativo #{ativo.capitalize} às #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min} (pressione ENTER para interromper):\n\n"
    c7 = chart(ativo, 7, true) # histórico semanal
    dif7 = c7[:prices].max - c7[:prices].min # diferença semanal
    limit = [c7[:prices].min, c7[:prices].max] # limites da semana
    zonas = [limit[1] - (dif7 * 0.236), limit[1] - (dif7 * 0.382), limit[1] - (dif7 * 0.5), limit[1] - (dif7 * 0.618), limit[1] - (dif7 * 0.786)] # zonas da retração de Fibonacci
    print "   [Aguardando completar a primeira vela...]\n" if ![0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55].include?(Time.now.min) # aviso de espera
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
        print "\n\nVariáveis:\n"
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
        print "\n  > Resumo da hora:
    * Abertura: #{fnum(hour[0], 1)};    Fechamento: #{fnum(hour[-1], 1)}    (#{fnum(var, 2)})
    * Máxima: #{fnum(hour.max, 1)};    Mínima: #{fnum(hour.min, 1)}
    * Média: #{fnum(media(hour)[0], 1)};    Mediana: #{fnum(media(hour)[1], 1)};    Meio: #{fnum(media(hour)[2], 1)}
    * Volume: $#{fnum(vol, 4)} (#{fnum(vvol, 2)})
    * Capitalização: $#{fnum(cap, 4)} (#{fnum(vcap, 2)})
    * Volatilidade: #{fnum(volat, 3)}%
    * Força: #{fnum(forca, 2)};    Força + volume: #{fnum(fv, 2)}
    * Variação mista (cap. e valor): #{fnum((var + vcap) / 2.0, 2)}
    * Variação média: #{fnum(vtm, 2)}
    * Variação total: #{fnum(vtotal, 2)}"
        print "\n    * Sequência de #{seq.abs} horas" if seq.abs > 1
        if price <= zonas[1] # checando zonas de compra
          print "\n    * ALERTA: "
          if price <= zonas[1] && price > zonas[2]
            print "zona de compra 1 (entre -38.2% e -50% do topo)"
          elsif price <= zonas[2] && price > zonas[3]
            print "zona de compra 2 (entre -50% e -61.8% do topo)"
          elsif price <= zonas[3] && price >= zonas[4]
            print "zona de compra 3 (entre -61.8% e -78.6% do topo)"
          else
            print "zona morta (abaixo de -78.6% do topo)"
          end
        elsif price >= zonas[0]
          print "\n    * ALERTA: zona de venda (acima de -23.6% do topo)"
        end
        file.write("  #{n}. Valor do ativo #{ativo.capitalize} às #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min}: #{fnum(price, 1)} (variaração de #{fnum(var, 2)}, força+volume de #{fnum(fv, 2)})\n")
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
    title("100 mais")
    
    # API
    print "\n   [Importando lista... "
    url = URI("https://coingecko.p.rapidapi.com/coins/markets?vs_currency=usd&page=1&per_page=100&order=market_cap_desc")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)
    print "#{JSON.parse(response.read_body).length} entradas]\n"

    # INPUTS
    print "\nQuantidade de ativos a ser calculada (entre 10 e #{JSON.parse(response.read_body).length})? "
    q = gets.to_i # quantidade de ativos a ser calculada
    if q > JSON.parse(response.read_body).length
      q = JSON.parse(response.read_body).length # máximo
    elsif q < 10
      q = 10 # mínimo
    end
    list = [] # lista com todos os ativos calculados
    num = 0 # posição do ativo
    best = [] # melhores ativos

    print "\n   [Aguarde alguns minutos...]\n"
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
      print "\nVariáveis:\n"
      %w(q num list best).each do |vn|
        v = eval(vn)
        STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
      end
    end

    # RESULTADO
    beep
    print "\nMelhores ativos para investimento:"
    file.write("  #{n}. Melhores ativos para investimento:")
    best.each do |z|
      print "\n  #{best.index(z) + 1}. #{z[0]} (#{z[1]}): #{fnum(z[2], 3)}"
      file.write(" #{best.index(z) + 1}. #{z[0]} (#{fnum(z[2], 3)});")
      sleep 0.1
    end
    file.write("\n")
    print "\n\nATENÇÃO: as pontuações obtidas são valores aproximados, favor recalcular com maior exatidão na opção 1 (Investimento)."
    n += 1
    gets
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log

  elsif $opt == 6 

    # CAÇA AO TESOURO **********************************************************
    title("caça ao tesouro")

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
    print "\nLista de ativos com erro: #{erro}\n" if dev == true

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
      print "\n\nVariáveis:\n"
      %w(q num list best).each do |vn|
        v = eval(vn)
        STDERR.puts "  #{vn.upcase} (#{defined?(v)} - #{v.class.to_s.downcase}) = #{v}"
      end
    end

    # RESULTADO
    beep
    print "\n\nTesouro encontrado:"
    file.write("  #{n}. Tesouro encontrado:")
    best.each do |z|
      print "\n  #{best.index(z) + 1}. #{z[0]} (#{z[1]}): #{fnum(z[2], 3)}"
      file.write(" #{best.index(z) + 1}. #{z[0]} (#{fnum(z[2], 3)});")
      sleep 0.1
    end
    file.write("\n")
    print "\n\nATENÇÃO: as pontuações obtidas são valores aproximados, favor recalcular com maior exatidão na opção 1 (Investimento)."
    n += 1
    gets
    errof.close
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log

  elsif $opt == 7 

    # PESQUISA DE ATIVOS **********************************************************
    title("pesquisa")

    list = listar # lista de todos os ativos
    loop do # loop de pesquisa
      print "\nInsira o termo para pesquisa: "
      search = gets.chomp # palavra para pesquisa
      found = 1 # contador
      (0..list.length-1).each do |x|
        if dev == true
          print "\n" + "#{list[x]}" # imprimindo lista completa no modo dev
          if (x + 1) % 100 == 0
            print "\n___________________________________________________________________#{x + 1} de #{list.length}\n"
            gets
          end
        end
        name = list[x][:name] # nome do ativo
        id = list[x][:id] # ID do ativo
        symbol = list[x][:symbol] # símbolo do ativo
        if name.downcase.include?(search.downcase) || symbol.downcase.include?(search.downcase) # checando se há correspondência
          beep if dev == true # alerta sonoro para o modo dev
          print "\n  #{found}. #{name} (#{symbol}): #{id}"
          found += 1
          sleep 0.1
        end
      end
      if found == 1
        print "\nERRO: NENHUM ATIVO ENCONTRADO." 
      else
        print "\n\n[Busca finalizada: #{found - 1} ativos encontrados]" 
      end
      print "\n\nProcurar outro ativo? (s/n) "
      lp = gets.chomp.upcase
      break if lp == "N"
    end # loop da pesquisa

  elsif $opt == 8 

    # REGISTRO **********************************************************
    title("registro")

    if File.exist?("cryptools.log") # checando se arquivo de log existe
      print "\n  1. Ler registro
  2. Apagar registro

Inserir uma opção: "
    opt = gets.chomp.to_i # opção inserida
    if !(1..2).include?(opt)
      print "ERRO: OPÇÃO INVÁLIDA!" # erro para opção inválida
      gets
      break
    end
    print "\n"
    if opt == 1 # ler registro
    log = File.open("cryptools.log") # lendo arquivo de log
    log.read.split("\n\n").reverse.each do |l|
      puts l
      gets
    end
    elsif opt == 2 # apagar registro
      print "Deletar arquivo de registro? (s/n) "
      sure = gets.chomp.upcase
      if sure == "S"
        file.close
        File.delete("cryptools.log")
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        file.write("\nRegistros de #{"%02d" % time.day}/#{"%02d" % time.month}/#{time.year}, às #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
        print "\n   [Arquivo deletado com sucesso]"
        gets
      end
      if File.exist?("error.log")
        print "\nDeletar registro de erros? (s/n) "
        sure = gets.chomp.upcase
        if sure == "S"
          File.delete("error.log")
          print "\n   [Arquivo deletado com sucesso]"
          gets
        end
      end
    end
    else
      print "\nERRO: ARQUIVO DE REGISTRO NÃO ENCONTRADO!\n"
    end

  elsif $opt == 9 

    # TESTANDO SERVIDOR
    title("testar servidor")
    
    sleep 0.1
    print "\n   [Checando conexão...]\n"

    if internet?
      link = "OK"
    else
      link = "sem conexão"
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

    print "\n  * Conexão: #{link}
  * Mensagem: #{eval(response.read_body).shift[-1]}
  * Ping: #{fnum(ping, 3)} segundo(s)\n"
    sleep 2

  elsif $opt == 10 

    # NOTÍCIAS **********************************************************
    title("notícias")

    sleep 0.1
    print "\n   [Importando notícias...]\n"
    url = URI("https://coingecko.p.rapidapi.com/status_updates")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)

    num = 1
    JSON.parse(response.read_body)["status_updates"].each do |x|
      cal = "#{x["created_at"][8..9]}/#{x["created_at"][5..6]}/#{x["created_at"][0..3]}" # data no calendário
      print "\n#{num} de #{JSON.parse(response.read_body)["status_updates"].length}:___________________________________________________________#{cal}\n"
      x["description"].split("\r").each do |y|
        print y
        sleep 0.05
      end
      num += 1
      print "\n"
      gets
    end

  elsif $opt == 11 

    # AJUDA **********************************************************
    title("ajuda")
    print "\n"

    tutorial = "Instruções gerais: execute o arquivo '.rb' no terminal do Linux ou em outro SO e insira as informações da transação desejada. Exemplo no Linux: se o arquivo estiver na pasta pessoal, basta abrir o terminal e digitar 'ruby ct-pt.rb'. Lembre de usar ponto em vez de vírgula nas casas decimais. Se precisar de mais informações sobre criptomoedas, acesse os sítios abaixo:
https://www.infomoney.com.br/guias/criptomoedas/    https://economia.uol.com.br/faq/criptomoedas-o-que-e-como-funciona-bitcoin-e-mais.htm    https://www.forbes.com/advisor/investing/what-is-cryptocurrency/
Caso não possua cadastro em nenhuma corretora de criptomoedas, considere se cadastrar na Binance, uma das maiores corretoras do mundo: https://accounts.binance.me/pt-BR/register?ref=M7Y0CB4O
1. Investimento ('holding'): o algoritmo avalia um determinado criptoativo, ajudando o usuário a decidir se deve investir para obter lucro a longo prazo. Ideal para poupanças ('savings' e 'earnings') e 'stakings'.
1.1 Legendas: a) Valor: valor unitário do ativo; Capitalização do mercado: 'market cap'; c) Suprimento: suprimento em circulação e suprimento total; d) Zona de compra: faixa ideal de preço para compra de acordo com a Retração de Fibonacci; e) Avaliação do momento: avaliação do valor atual de acordo com a zona de compra.
2. Negociação ('trading'): o algoritmo estipula sinais para fazer 'swing trading'. Ideal para investidores experientes que estão acostumados a fazer negociações. Tenha em mente que o trading envolve alto risco de prejuízo financeiro, use este algoritmo por própria conta e risco. Instruções: insira todos os dados corretamente. Ao analisar o gráfico, você precisará  visualizar as velas com intervalo de 1 hora. Se constatar que o mínimo de velas negativas consecutivas foi atingido, verifique se o valor atual da criptomoeda está dentro de alguma das zonas de compra. Caso esteja, espere o valor do ativo se aproximar de algum suporte ou pela aparição de algum padrão de vela de reversão para então comprar. Exemplos de padrões de vela de reversão: Dragonfly Doji ('Libélula'), Hammer ('Martelo') e  Tweezer Bottom ('Fundo Duplo'). Se quiser saber mais sobre velas japonesas, clique nos sítios abaixo:
https://www.financebrokerage.com/pt-br/padroes-de-graficos/    https://www.investirnabolsa.com/curso-cfd/velas-japonesas/    https://www.forex.com/en-us/market-analysis/latest-research/japanese-candlestick-patterns-cheat-sheet-fx/
2.1 Legendas: a) Média trimestral: média de todos os valores do último trimestre; b) Mediana: valor no centro de todos os valores do histórico do trimestre; c) Meio: média entre a máxima e a mínima do trimestre; d) Zonas de compra: melhores zonas de compra de acordo com a Retração de Fibonacci.
3. Limites ('stops'): calcula os limites de ganho e de perda de uma negociação, além do possível lucro e risco de prejuízo. A sugestão é aplicar a agressividade de acordo com a zona em que o ativo se encontrava no momento da compra: 'arrojado' para a zona 1, 'agressivo' para a zona 2 e 'berserk' para a zona 3.
3.1 Legendas: a) Limite de ganho: momento de venda em lucro; b) Limite de perda: momento de venda em prejuízo; c) Lucro absoluto: possibilidade de lucro em quantia absoluta, caso seja atingido o limite de ganho; d) Quantia em risco: quantidade em risco de prejuízo, caso seja atingido o limite de perda.
4. Monitor: monitora o valor da criptomoeda em intervalos de 5 minutos. É mostrado um resumo ao final de cada hora, com estatísticas e dados importantes. Atenção: as zonas de compra apresentadas nesse modo são para negociações ('trading').
4.1 Legendas: a) Abertura: valor do ativo no início da hora; b) Fechamento: valor do ativo no final da hora; c) Máxima: máximo valor atingido durante a hora; d) Mínima: mínimo valor atingido durante a hora; e) Média: média de todos os valores durante a hora; f) Mediana: valor no centro do conjunto de todos os valores da hora; g) Meio: média entre a máxima e a mínima; h) Volume: volume das últimas 24 horas; i) Força: força dos compradores ('bulls', valor positivo) contra a força dos vendedores ('bears', valor negativo); j) Força + volume: soma da força com a variação do volume durante a hora; k) Variação mista: média da variação do valor e da capitalização do mercado; l) Variação média: ḿédia das variações das horas desde o início do monitoramento; m) Variação total: variação total desde o início do monitoramento; m) Zona: zonas de compra/venda para negociações; n) Sequência: horas consecutivas, positivas ou negativas.
5. 100 Mais: procura os melhores ativos para investimento ('holding') dentre aqueles com maior capitalização; 6. Caça ao Tesouro: encontra os três melhores ativos dentre 100 aleatórios; 7. Procurar ativos: útil para descobrir o ID de alguma criptomoeda; 8. Registro: visualiza ou deleta o arquivo de registro; 9. Testar servidor: checa a conexão com o CoinGecko; 10. Notícias: últimas atualizações do mundo dos criptoativos.
Visite a página do projeto e dê uma estrela: https://github.com/milodraco/cryptools
Quer ajudar o projeto? Me envie alguns Satoshis (BTC): 19BbzBpudqWDzbCH2Rn8vT2q6CekjjtLN1
Lembre-se: nenhum método garante o lucro, assim como nenhum elimina a possibilidade de prejuízo. Opere somente se estiver ciente dos riscos envolvidos e consulte um profissional em caso de dúvida.
ATENÇÃO! SAIBA QUE O TRADING ENVOLVE ALTO RISCO DE PREJUÍZO, NÃO NEGOCIE A NÃO SER QUE VOCÊ TENHA CERTEZA QUE SABE O QUE ESTÁ FAZENDO. NENHUM MÉTODO PODE GARANTIR O LUCRO."
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
    fim = "Todo o registro foi salvo no arquivo 'cryptools.log'.
Lembre-se: é recomendável que se consulte um profissional antes de fazer qualquer investimento. Até mais!\n"
    fim.split("\n").each do |l|
      print l + "\n"
      sleep 0.1
    end
    gets
    exit

  end # if das opções
end # loop geral
