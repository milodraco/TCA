print "\n                              "
("CrypTools v. 2.0b").split("").each do |l|
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

# INTERNET ***************************************************
print "\n[Estabelecendo conexão... "
def internet? # checando conexão
  begin
    true if open("https://www.coingecko.com/")
  rescue
    false
  end
end
if internet? == false # erro de conexão
  print "falha]\n\n"
  sleep 1
  exit
else
  print "OK]\n"
end

# API ********************************************************
apif = File.new("api.config", 'a+') # lendo arquivo de log
$api = apif.read.chomp # chave da API
if $api == "" || $api == nil
  print "\nERRO: CHAVE DE API NÃO ENCONTRADA!

Instruções: registre-se no sítio abaixo para adquirir uma chave de API da CoinGecko:
https://rapidapi.com/coingecko/api/coingecko

Após adquirir a chave, cole-a aqui: "
  $api = gets.chomp
  apif.write($api)
end
apif.close

# FUNÇÕES *************************************************
def fnum(n, f) # formatação dos números
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
  else # formato geral
    if n >= 1
      return "#{n.round(2)}"
    else
      return "#{n.round(8)}"
    end
  end
end
def media(a) # MÉDIA E MEDIANA
  mid = a.length / 2
  sorted = a.sort
  return [a.inject{ |sum, el| sum + el }.to_f / a.size, a.length.odd? ? sorted[mid] : 0.5 * (sorted[mid] + sorted[mid - 1])]
end
def chart(a, d) # HISTÓRICO
  print "   [Importando histórico de ", d, " dias... "
  url = URI("https://coingecko.p.rapidapi.com/coins/" + a + "/market_chart?vs_currency=usd&days=" + d.to_s)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(url)
  request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
  request["x-rapidapi-key"] = $api
  response = http.request(request)
  if eval(response.read_body)[:prices] == nil
    print "\nERRO: ATIVO NÃO ENCONTRADO!\n" # erro em caso de retorno vazio
    gets
    exit
  end
  prices = []
  for n in 0..eval(response.read_body)[:prices].length-1 do
    prices[n] = eval(response.read_body)[:prices][n][1]
  end
  print prices.length, " entradas]\n"
  return prices
  #return eval(response.read_body)
end
file = File.new("cryptools.log", 'a') # criando arquivo de log
time = Time.now # data e hora atual
file.write("\nRegistros de #{"%02d" % time.day}/#{"%02d" % time.month}/#{time.year}, às #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
file.close # fechando arquivo para salvar
file = File.new("cryptools.log", 'a') # reabrindo arquivo de log
n = 1 # contador

loop do # loop geral

  print "\n_____________________________________MENU____________________________________\n\n"
  ["1. Investimento ('holding')", "2. Negociação ('trading')", "3. Limites ('stops')", "4. Monitor", "5. Calculadora", "6. Registro", "7. Procurar ativos", "8. Testar servidor", "9. Ajuda", "10. Sair"].each do |l|
    print "  ", l, "\n"
    sleep 0.05
  end
  print "\n"

  loop do
    print "Insira uma opção: "
    $opt = gets.chomp.to_i
    if $opt == 11
      dev = true 
      print "\n[Modo desenvolvedor ativado]
API = #{$api}\n\n"
    end
    break if (1..10).include?($opt)
  end

  if $opt == 1 # if 1

    # HOLDING
    print "\n___________________________________HOLDING___________________________________\n"
    loop do # loop holding
      # INPUTS
      print "\nInsira o nome do ativo: "
      ativo = gets.chomp.downcase # nome do ativo
      print "\n"
      c365 = chart(ativo, 365) # histórico do ano
      c182 = chart(ativo, 182) # histórico do semestre
      c90 = chart(ativo, 90) # histórico do trimestre

      # CÁLCULOS
      value = c90[-1] # valor atual
      var90 = ((value / c90[0]) - 1) * 100 # variação do trimestre
      var182 = ((value / c182[0]) - 1) * 100 # variação do semestre
      var365 = ((value / c365[0]) - 1) * 100 # variação do ano
      limit = [c90.min, c90.max] # máximo e mínimo do trimestre
      dif = limit[1] - limit[0] # diferença entre mínimo e máximo do trimestre
      zona = [limit[1] - (dif * 0.5), limit[1] - (dif * 0.764)] # zona de compra
      moment = ((value - zona[1]).abs / value) * 10 # avaliação do momento de compra
      svalue = Math.log(200000) - Math.log(value) # avaliação do valor unitário da moeda
      if svalue > 10
        svalue = 10 + Math.sqrt(svalue-10)
      elsif svalue < 0
        svalue *= 2
      end
      volat = (((var90 * 2) - var182).abs + ((var182 * 2) - var365).abs)**0.25 # avaliação da volatilidade
      fator = 5.5 + volat # fator divisor de acordo com a volatilidade para avaliação do crescimento
      if fator < 7
        fator = 7.0
      elsif fator > 21
        fator = 21.0
      end
      cresc = ((var90 + var182 + var365)/fator).abs**(1/3.0) * 2 # avaliação do crescimento
      cresc *= -1 if var90 + var182 + var365 < 0 # valores negativos
      score = (cresc * 2) + svalue - ((volat - 5) * 2) - (moment * 2) # avaliação final

      # MODO DEV
      if dev ==  true
        print "\n"
        STDERR.puts "Variável value = #{value.inspect}"
        STDERR.puts "Variável var90 = #{var90.inspect} = ((#{value} / #{c90[0]}) - 1) * 100"
        STDERR.puts "Variável var182 = #{var182.inspect} = ((#{value} / #{c182[0]}) - 1) * 100"
        STDERR.puts "Variável var365 = #{var365.inspect} = ((#{value} / #{c365[0]}) - 1) * 100"
        STDERR.puts "Variável limit = #{limit.inspect}"
        STDERR.puts "Variável dif = #{dif.inspect} = #{limit[1]} - #{limit[0]}"
        STDERR.puts "Variável zona = #{zona.inspect}"
        STDERR.puts "Variável moment = #{moment.inspect} = ((#{value} - #{zona[1]}).abs / #{value}) * 10"
        STDERR.puts "Variável svalue = #{svalue.inspect} = #{Math.log(200000)} - #{Math.log(value)}"
        STDERR.puts "Variável volat = #{volat.inspect} = (((#{var90} * 2) - #{var182}).abs + ((#{var182} * 2) - #{var365}).abs)**0.25"
        STDERR.puts "Variável fator = #{fator.inspect} = 5.5 + #{volat}"
        STDERR.puts "Variável cresc = #{cresc.inspect} = ((#{var90} + #{var182} + #{var365})/#{fator}).abs**(#{1/3.0}) * 2"
        STDERR.puts "Variável score = #{score.inspect} = (#{cresc} * 2) + #{svalue} - ((#{volat} - 5) * 2) - (#{moment} * 2)"
      end

      # RESULTADO
      print "\n  * Ativo:   #{ativo.capitalize}
  * Valor:    #{fnum(value, 1)}
  * Avaliação do valor:   "
      if svalue < 10 * (1/5.0)
        print "péssima! "
      elsif svalue < 10 * (2/5.0)
        print "ruim "
      elsif svalue < 10 * (3/5.0)
        print "razoável "
      elsif svalue < 10 * (4/5.0)
        print "boa "
      else
        print "excelente! "
      end
      print "(#{fnum(svalue, 3)})
  * Variação trimestral:    #{fnum(var90, 2)}
  * Variação semestral:   #{fnum(var182, 2)}
  * Variação anual:   #{fnum(var365, 2)}
  * Avaliação da variação:    "
      if cresc < 10 * (1/5.0)
        print "péssima! "
      elsif cresc < 10 * (2/5.0)
        print "ruim "
      elsif cresc < 10 * (3/5.0)
        print "razoável "
      elsif cresc < 10 * (4/5.0)
        print "boa "
      else
        print "excelente! "
      end
      print "(#{fnum(cresc, 3)})
  * Avaliação da volatilidade:    "
      if volat < 10 * (1/5.0)
        print "excelente! "
      elsif volat < 10 * (2/5.0)
        print "boa "
      elsif volat < 10 * (3/5.0)
        print "razoável "
      elsif volat < 10 * (4/5.0)
        print "ruim "
      else
        print "péssima! "
      end
      print "(#{fnum(volat, 3)})
  * Zona de compra:   #{fnum(zona[1], 1)} a #{fnum(zona[0], 1)}
  * Avaliação do momento:   "
      if moment < 5 * (1/5.0)
        print "excelente! "
      elsif moment < 5 * (2/5.0)
        print "boa "
      elsif moment < 5 * (3/5.0)
        print "razoável "
      elsif moment < 5 * (4/5.0)
        print "ruim "
      else
        print "péssima! "
      end
      print "(#{fnum(moment, 3)})
  * AVALIAÇÃO FINAL:    "
      if score < 30 * (1/5.0)
        print result = "péssima!"
      elsif score < 30 * (2/5.0)
        print result = "ruim"
      elsif score < 30 * (3/5.0)
        print result = "razoável"
      elsif score < 30 * (4/5.0)
        print result = "boa"
      else
        print result = "excelente!"
      end
      print " (#{fnum(score, 3)})\n"

      # GRAVAÇÃO E LOOP
      file.write("  #{n}. Holding de #{ativo.capitalize} (#{fnum(value, 1)}): #{fnum(score, 3)} (#{result})", "\n") # escrevendo log
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

    # TRADING
    print "\n___________________________________TRADING___________________________________\n"
    print "\nATENÇÃO! SAIBA QUE O TRADING ENVOLVE ALTO RISCO DE PREJUÍZO, NÃO NEGOCIE A NÃO SER QUE VOCÊ TENHA CERTEZA QUE SABE O QUE ESTÁ FAZENDO. NENHUM MÉTODO PODE GARANTIR O LUCRO.\n"
    loop do # loop trading
      # INPUTS
      print "\nInsira o ativo que será negociado: "
      ativo = gets.chomp.downcase
      print "\n"
      c90 = chart(ativo, 90) # histórico do trimestre
      c30 = chart(ativo, 30) # histórico do mês
      c7 = chart(ativo, 7) # histórico da semana
      c3 = chart(ativo, 3) # histórico da semana
      c1 = chart(ativo, 1) # histórico do dia
      value = c1[-1] # valor atual
      $ativo = ativo
      $c3 = c3
      $c7 = c7

      # CÁLCULOS
      limit = [[c1.min, c3.min, c7.min].min, [c1.max, c3.max, c7.max].max] # limites da semana
      dif = limit[1] - limit[0] # diferença entre limites da semana
      var1 = ((value / c1[0]) - 1) * 100
      var30 = ((value / c30[0]) - 1) * 100
      var90 = ((value / c90[0]) - 1) * 100
      zonas = [limit[1] - (dif * 0.382), limit[1] - (dif * 0.5), limit[1] - (dif * 0.618), limit[1] - (dif * 0.786)] # zonas da retração de Fibonacci
      cvar = [var1 * 30, var30, var90 / 3.0] # variação
      volat = cvar.max - cvar.min # volatilidade
      chance = (var30 * 2) + (var90 / 5.0) - (volat / 5.0) - (var1 / 3.0).abs # probabilidade de lucro
      if chance > 50
        chance = 50 + Math.sqrt(chance - 50) # diminuindo chances altas
      elsif chance < 1
        chance = 1.0 # chance mínima
      end
      chance = 75.0 if chance > 75 # chance máxima
      seq = (10 - (chance / 10.0)).round # sequência de velas negativas

      # MODO DEV
      if dev ==  true
        print "\n"
        STDERR.puts "Variável value = #{value.inspect}"
        STDERR.puts "Variável limit = #{limit.inspect} = [[#{c1.min}, #{c3.min}, #{c7.min}].min, [#{c1.max}, #{c3.max}, #{c7.max}].max]"
        STDERR.puts "Variável dif = #{dif.inspect} = #{limit[1]} - #{limit[0]}"
        STDERR.puts "Variável var1 = #{var1.inspect} = ((#{value} / #{c1[0]}) - 1) * 100"
        STDERR.puts "Variável var30 = #{var30.inspect} = ((#{value} / #{c30[0]}) - 1) * 100"
        STDERR.puts "Variável var90 = #{var90.inspect} = ((#{value} / #{c90[0]}) - 1) * 100"
        STDERR.puts "Variável zonas = #{zonas.inspect}"
        STDERR.puts "Variável cvar = #{cvar.inspect} = [#{var1} * 30, #{var30}, #{var90} / 3.0]"
        STDERR.puts "Variável volat = #{volat.inspect} = #{cvar.max} - #{cvar.min}"
        STDERR.puts "Variável chance = #{chance.inspect} = (#{var30} * 2) + (#{var90} / 5.0) - (#{volat} / 5.0) - (#{var1} / 3.0).abs"
        STDERR.puts "Variável seq = #{seq.inspect}"
      end

      # RESULTADO
      print "\n  * Ativo:    #{ativo.capitalize}
  * Valor:    #{fnum(value, 1)}
  * Média trimestral:   #{fnum(media(c90)[0], 1)}; mediana:   #{fnum(media(c90)[1], 1)}
  * Probabilidade de lucro:   "
      if chance < 60 * (1/5.0)
        print "péssima! "
      elsif chance < 60 * (2/5.0)
        print "ruim "
      elsif chance < 60 * (3/5.0)
        print "razoável "
      elsif chance < 60 * (4/5.0)
        print "boa "
      else
        print "excelente! "
      end
      print "(#{fnum(chance, 3)}%)
  * Volatilidade:   "
      if volat < 100 * (1/5.0)
        print "excelente! "
      elsif volat < 100 * (2/5.0)
        print "boa "
      elsif volat < 100 * (3/5.0)
        print "razoável "
      elsif volat < 100 * (4/5.0)
        print "ruim "
      else
        print "péssima! "
      end
      print "(#{fnum(volat, 3)}%)"
      print "\n  * Zonas de compra:
    - Zona 1:   #{fnum(zonas[1], 1)} a #{fnum(zonas[0], 1)}
    - Zona 2:   #{fnum(zonas[2], 1)} a #{fnum(zonas[1], 1)}
    - Zona 3:   #{fnum(zonas[3], 1)} a #{fnum(zonas[2], 1)}\n"
      file.write("  #{n}. Sinal para #{ativo}: #{seq} horas (chance de #{fnum(chance, 2)}), zona 1: de #{fnum(zonas[1], 1)} a #{fnum(zonas[0], 1)}, zona 2: de #{fnum(zonas[2], 1)} a #{fnum(zonas[1], 1)}, zona 3: de #{fnum(zonas[3], 1)} a #{fnum(zonas[2], 1)}", "\n") # escrevendo log
      print "  * Sinal:
    1. Esperar por #{seq} velas negativas de horas consecutivas;
    2. Comprar quando confirmar alguma vela com padrão de reversão ou algum suporte for atingido, desde que o valor esteja dentro das zonas de compra.

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

  elsif $opt == 3 # STOPS
    print "\n__________________________________STOPS______________________________________\n"
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
        print "Insira o nome do ativo: " # inserindo o ativo manualmente
        ativo = gets.chomp
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
        c7 = chart(ativo, 7) # histórico da semana
        c3 = chart(ativo, 3) # histórico de 3 dias
      elsif opt == 2 # inserindo os valores manualmente na opção 2
        c7 = []
        c3 = []
        print "Insira o MENOR valor unitário do ativo nos últimos 3 DIAS:\n"
        c3 << gets.chomp.to_f
        print "Insira o MENOR valor unitário do ativo nos últimos 7 DIAS:\n"
        c7 << gets.chomp.to_f
        print "Insira o MAIOR valor unitário do ativo nos últimos 3 DIAS:\n"
        c3 << gets.chomp.to_f
        print "Insira o MAIOR valor unitário do ativo nos últimos 7 DIAS:\n"
        c7 << gets.chomp.to_f
        if c3[1] < value || c7[1] < value || c3[0] > value || c7[0] > value || c7[0] > c3[0] || c3[1] > c7[1]
          print "ERRO: VALORES INVÁLIDOS!" # erro para valores errados
          gets
          break
        end
      elsif opt == 3 # resgatando os históricos na opção 3
        c7 = $c7
        c3 = $c3
      end

      # CÁLCULOS
      limit7 = [[c3.min, c7.min].min, [c3.max, c7.max].max] # limites de 7 dias
      limit3 = [c3.min, c3.max] # limites de 3 dias
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
        print "\n"
        STDERR.puts "Variável banca = #{banca.inspect}"
        STDERR.puts "Variável value = #{value.inspect}"
        STDERR.puts "Variável limit7 = #{limit7.inspect}"
        STDERR.puts "Variável limit3 = #{limit3.inspect}"
        STDERR.puts "Variável dif = #{dif.inspect} = #{limit7[1]} - #{limit7[0]}"
        STDERR.puts "Variável sg = #{sg.inspect}"
        STDERR.puts "Variável sl = #{sl.inspect}"
        STDERR.puts "Variável gainp = #{gainp.inspect} = (#{sg} / #{value.to_f}) - 1"
        STDERR.puts "Variável lossp = #{lossp.inspect} = (1 - (#{sl} / #{value.to_f})) * -1"
        STDERR.puts "Variável lucro = #{lucro.inspect} = (#{banca} * (1 + #{gainp}))"
        STDERR.puts "Variável risk = #{risk.inspect} = #{banca} - (#{banca} * (1 - #{lossp}.abs))"
      end

      # RESULTADO
      print "\n  * Limites (pelo valor unitário):
    1. Limite de ganho (stop-gain):    #{fnum(sg, 1)} (#{fnum(gainp * 100, 2)})
    2. Limite de perda (stop-loss):    #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)})
  * Lucro absoluto:    #{fnum(lucro, 1)}
  * Quantia em risco:   #{fnum(risk, 1)}\n"
      print "\nALERTA: risco muito superior ao lucro!\n" if lucro < risk / 1.5
      file.write("  #{n}. Stops (#{sperfil[perfil - 1]}): stop-gain de #{fnum(sg, 1)} (+#{fnum(gainp * 100, 2)}), stop-loss de #{fnum(sl, 1)} (#{fnum(lossp * 100, 2)}), lucro de #{fnum(lucro, 1)} e risco em #{fnum(risk, 1)}\n") # escrevendo log
      n += 1
      print "\nCalcular outros limites? (s/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop dos stops

  elsif $opt == 4 # MONITOR
    print "\n___________________________________MONITOR___________________________________\n"
    print "\nInsira o nome do ativo: "
    ativo = gets.chomp.downcase # nome do ativo
    print "\nIniciando monitoramento do ativo #{ativo.capitalize} às #{Time.now.hour}:#{Time.now.min} (pressione ENTER para interromper):\n\n"
    c7 = chart(ativo, 7)
    print "   [Aguardando completar a primeira vela...]\n" if ![0, 10, 20, 30, 40, 50].include?(Time.now.min) # aviso de espera
    init = nil
    loop do # loop para aguardar a hora certa
      $enter = false # variável para tecla pressionada
      while ![0, 10, 20, 30, 40, 50].include?(Time.now.min) do # loop enquanto minutos forem quebrados
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
      url = URI("https://coingecko.p.rapidapi.com/coins/" + ativo + "/market_chart?vs_currency=usd&days=1")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url)
      request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
      request["x-rapidapi-key"] = $api
      response = http.request(request)
      ping2 = Time.now # encerrando a medição de ping

      #CÁLCULOS
      prices = []
      for n in 0..eval(response.read_body)[:prices].length-1 do
        prices[n] = eval(response.read_body)[:prices][n][1] # histórico diário
      end
      hour = prices.drop((prices.length * (23 / 24.0)).round) # histórico da última hora
      price = hour[-1] # preço atual
      init = price if init == nil # definindo preço inicial
      dif = hour.max - hour.min # diferença entre limites
      fcompra = ((price - hour.min) / dif.to_f) * 100 # força de compra
      fvenda = ((price - hour.max) / dif.to_f) * 100 # força de venda
      volat = (dif / price.to_f) * 100 # volatilidade
      seq = 0 if seq == nil # contador de sequências
      if price - hour[0] > 0 # hora positiva ou negativa?
        polar = true # positiva
        if seq >= 0
          seq += 1
        else
          seq = 0
        end
      elsif price - hour[0] < 0
        polar = false # negativa
        if seq <= 0
          seq -= 1
        else
          seq = 0
        end
      else
        polar = nil # sem variação
      end
      limit = [c7.min, c7.max] # limites da semana
      zonas = [limit[1] - (dif * 0.382), limit[1] - (dif * 0.5), limit[1] - (dif * 0.618), limit[1] - (dif * 0.786)] # zonas da retração de Fibonacci

      # MODO DEV
      if dev ==  true
        print "\n"
        STDERR.puts "Variável hour = #{hour.inspect}"
        STDERR.puts "Variável price = #{price.inspect}"
        STDERR.puts "Variável init = #{init.inspect}"
        STDERR.puts "Variável dif = #{banca.inspect} = #{hour.max} - #{hour.min}"
        STDERR.puts "Variável fcompra = #{fcompra.inspect} = ((#{price} - #{hour.min}) / #{dif.to_f}) * 100"
        STDERR.puts "Variável fvenda = #{fvenda.inspect} = ((#{price} - #{hour.max}) / #{dif.to_f}) * 100"
        STDERR.puts "Variável volat = #{volat.inspect} = (#{dif} / #{price.to_f}) * 100"
        STDERR.puts "Variável seq = #{seq.inspect}"
        STDERR.puts "Variável polar = #{polar.inspect}"
        STDERR.puts "Variável limit = #{limit.inspect} = [#{c7.min}, #{c7.max}]"
        STDERR.puts "Variável zonas = #{zonas.inspect}"
      end

      # RESULTADO
      if Time.now.min == 0 # final da hora
        print "\n  > Resumo da hora:
    * Abertura:   #{fnum(hour[0], 1)}; fechamento: #{fnum(hour[-1], 1)};
    * Máxima:   #{fnum(hour.max, 1)}; mínima: #{fnum(hour.min, 1)};
    * Média:    #{fnum(media(hour)[0], 1)}; mediana: #{fnum(media(hour)[1], 1)}
    * Volatilidade:   #{fnum(volat, 2)}
    * Força:    #{fnum(fcompra + fvenda, 2)} (#{fnum(fcompra, 2)} de compra, #{fnum(fvenda.abs, 2)} de venda)"
        if price <= zonas[0] # checando zonas de compra
          print "\n    * Zona de compra: "
          if price <= zonas[0] && price > zonas[1]
            print "zona 1 (entre 38.2% e 50% abaixo do topo)"
          elsif price <= zonas[1] && price > zonas[2]
            print "zona 2 (entre 50% e 61.8% abaixo do topo)"
          elsif price <= zonas[2] && price >= zonas[3]
            print "zona 3 (entre 61.8% e 78.6% abaixo do topo)"
          else
            print "zona morta (menor que 78.6% abaixo do topo)"
          end
        end
        print "\n    * Resultado:   "
        if polar == false 
          print "NEGATIVO (#{fnum((((price / hour[0].to_f) - 1) * 100), 2)}); "
        elsif polar == true
          print "POSITIVO (#{fnum((((price / hour[0].to_f) - 1) * 100), 2)}); "
        else
          print "NEUTRO (0.0%); "
        end
        print "variação total: "
        print "#{fnum((((price / init.to_f) - 1) * 100), 2)};"
        print " sequência de #{seq.abs} horas;" if seq > 1 || seq < -1
        print "\n\n\a  > #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min}: " # início da hora
        print "#{fnum(price, 1)} "
        print "(#{ativo.capitalize})..."
      else
        print "\n    * #{"%02d" % Time.now.hour}:#{"%02d" % Time.now.min}: #{fnum(price, 1)} (#{fnum((((price / hour[(-1 - (hour.length / 6.0)).round].to_f) - 1) * 100), 2)})..." # parcial a cada 10 minutos
      end
      (590 - (ping2 - ping1).round).times do # esperando 10 minutos - ping
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

  elsif $opt == 5 # CALCULADORA
    print "\n_________________________________CALCULADORA_________________________________\n"
    loop do
      # INPUTS
      print "\nInsira o ativo a ser calculado: "
      ativo = gets.chomp.downcase
      print "Insira o PERÍODO da variação (ex: 7 dias): "
      tempo = gets.chomp.downcase
      print "Insira o valor INICIAL do ativo: "
      v1 = gets.chomp.to_f
      print "Insira o valor FINAL do ativo: "
      v2 = gets.chomp.to_f

      # CÁLCULOS
      var = ((v2 / v1) - 1) * 100

      # MODO DEV
      if dev ==  true
        print "\n"
        STDERR.puts "Variável var = #{var.inspect} = ((#{v2} / #{v1}) - 1) * 100"
      end

      # RESULTADO
      print "\nVariação:    #{fnum(var, 2)}\n"
      file.write("  #{n}. Variação do ativo #{ativo.capitalize} em #{tempo}: #{fnum(var, 2)}\n")
      n += 1
      print "\nCalcular outra variação? (s/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop da calculadora

  elsif $opt == 6 # REGISTRO
    print "\n__________________________________REGISTRO___________________________________\n"
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
        file.close
        print "Arquivo deletado com sucesso!"
        gets
      end
    end
    else
      print "\nERRO: ARQUIVO DE REGISTRO NÃO ENCONTRADO!\n"
    end

  elsif $opt == 7 # PESQUISA DE ATIVOS
    print "\n___________________________________PESQUISA__________________________________\n"

    url = URI("https://coingecko.p.rapidapi.com/coins/list") # API
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-rapidapi-host"] = 'coingecko.p.rapidapi.com'
    request["x-rapidapi-key"] = $api
    response = http.request(request)

      loop do # loop de pesquisa
      print "\nInsira o termo para pesquisa: "
      search = gets.chomp # palavra para pesquisa
      n = 1 # contador
      list = eval(response.read_body) # lista de todos os ativos
      (0..list.length-1).each do |x|
        if dev == true
          print "\n" + "#{list[x]}" # imprimindo lista completa no modo dev
          sleep 0.05
        end
        name = list[x][:name] # nome do ativo
        id = list[x][:id] # ID do ativo
        symbol = list[x][:symbol] # símbolo do ativo
        if name.downcase.include?(search.downcase) || symbol.downcase.include?(search.downcase) # checando se há correspondência
          print "\a" if dev == true # alerta sonoro para o modo dev
          print "\n  #{n}. #{name} (#{symbol}): #{id}"
          n += 1
          sleep 0.1
        end
      end
      if n == 1
        print "\nERRO: NENHUM ATIVO ENCONTRADO." 
      else
        print "\n\n[Busca finalizada: #{n - 1} ativos encontrados]" 
      end
      print "\n\nProcurar outro ativo? (s/n) "
      lp = gets.chomp.upcase
      if lp == "N"
        file.close
        file = File.new("cryptools.log", 'a') # criando arquivo de log
        break
      end
    end # loop da pesquisa

  elsif $opt == 8 # TESTANDO SERVIDOR
    print "\n___________________________________SERVIDOR__________________________________\n"
    sleep 0.5
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
    print "\n  * Conexão:   #{link}
  * Mensagem:   #{eval(response.read_body).shift[-1]}
  * Ping:   ", (ping2 - ping1).round(2), " segundo(s)\n"
    sleep 3

  elsif $opt == 9 # TUTORIAL
    print "\n____________________________________AJUDA____________________________________\n\n"
    tutorial = "Instruções gerais: execute o arquivo '.rb' no terminal do Linux ou em outro SO e insira as informações da transação desejada. Exemplo no Linux: se o arquivo estiver na pasta pessoal, basta abrir o terminal e digitar 'ruby CrypTools.rb'. Lembre de usar ponto em vez de vírgula nas casas decimais.
1. Investimento ('holding'): o algoritmo avalia a criptomoeda, ajudando o usuário a decidir em qual cripto investir para obter lucro a longo prazo. Ideal para poupanças ('savings' e 'earnings') e 'stakings'.
2. Negociação ('trading'): o algoritmo estipula sinais para fazer 'swing trading'. Ideal para investidores experientes que estão acostumados a fazer negociações. Tenha em mente que o trading envolve alto risco de prejuízo financeiro, use este algoritmo por própria conta e risco. Instruções: insira todos os dados corretamente. Ao analisar o gráfico, você precisará  visualizar as velas com intervalo de 1 hora. Se constatar que o mínimo de velas negativas consecutivas foi atingido, verifique se o valor atual da criptomoeda está dentro de alguma das zonas de compra. Caso esteja, espere o valor do ativo se aproximar de algum suporte ou pela aparição de algum padrão de vela de reversão para então comprar. Exemplos de padrões de vela de reversão: Dragonfly Doji ('Libélula'), Hammer ('Martelo') e  Tweezer Bottom ('Fundo Duplo'). Se quiser saber mais sobre velas japonesas, clique nos sítios abaixo:
https://www.financebrokerage.com/pt-br/padroes-de-graficos/   https://www.investirnabolsa.com/curso-cfd/velas-japonesas/    https://www.forex.com/en-us/market-analysis/latest-research/japanese-candlestick-patterns-cheat-sheet-fx/
3. Limites ('stops'): calcula os limites de ganho e de perda de uma negociação, além do possível lucro e risco de prejuízo. A sugestão é aplicar a agressividade de acordo com a zona em que o ativo se encontrava no momento da compra: 'arrojado' para a zona 1, 'agressivo' para a zona 2 e 'berserk' para a zona 3.
4. Monitor: monitora o valor da criptomoeda em intervalos de 10 minutos.  
5. Calculadora: calcula a variação percentual do valor de um ativo.
6. Registro: visualiza ou deleta o arquivo de registro.
7. Procurar ativos: útil para descobrir o ID de alguma criptomoeda.
8. Testar servidor: checa a conexão com o CoinGecko.
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

  elsif $opt == 10 # EXIT
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