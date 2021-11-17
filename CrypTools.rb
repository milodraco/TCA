print "\n                    "
("CrypTools v. 1.6").split("").each do |l|
  print l
  sleep 0.1
end
sleep 0.3
print "\n                     por Milo_Draco\n"
sleep 0.8

$T1 = "\nInstruções gerais: execute o arquivo '.rb' no terminal
do Linux ou em outro SO e insira as informações da
transação desejada. Exemplo no Linux: se o arquivo
estiver na pasta pessoal, basta abrir o terminal e
digitar 'ruby CrypTools.rb'. Lembre de usar ponto
em vez de vírgula nas casas decimais.\n"
$T2 = "1. Holding: o algoritmo calcula uma nota para uma
criptomoeda de acordo com os dados inseridos, ajudando
o usuário a decidir em qual cripto investir para obter
lucro a longo prazo. Ideal para poupanças (savings e
earnings) e stakings.
Instruções: Para calcular o saldo de notícias, você
pode escolher qualquer plataforma para verificar as
notícias (recomendo o app Delta), basta ler as dez
notícias mais recentes dos últimos 3 meses sobre a
cripto e somar +1 para cada notícia boa, -1 para cada
notícia ruim e 0 para notícias neutras ou irrelevantes.\n"
$T3 = "2. Trading: o algoritmo calcula sinais para fazer
swing trading. Ideal para investidores experientes que
estão acostumados a fazer trading. Tenha em mente que
o trading envolve alto risco de prejuízo financeiro,
use este algoritmo por própria conta e risco.
Instruções: insira todos os dados corretamente. Ao
analisar o gráfico, você precisará  visualizar as velas
com intervalo de 1 hora. Se constatar que o mínimo de
velas negativas consecutivas foi atingido, verifique se
o valor atual da criptomoeda está dentro de alguma das
zonas de compra. Caso esteja, espere o valor do ativo
se aproximar de algum suporte ou pela aparição de
algum padrão de vela de reversão para então comprar.
Exemplos de padrões de vela de reversão:
  * Dragonfly Doji ('Libélula');
  * Hammer ('Martelo');
  * Tweezer Bottom ('Fundo Duplo').
Se quiser saber mais sobre velas japanesas, clique nos
sítios abaixo:
https://www.financebrokerage.com/pt-br/padroes-de-graficos/
https://www.investirnabolsa.com/curso-cfd/velas-japonesas/
https://www.forex.com/en-us/market-analysis/latest-research/japanese-candlestick-patterns-cheat-sheet-fx/\n"
$T4 = "3. Stops: calcula os limites de ganho e de perda de
uma negociação, além do possível lucro e do risco de
prejuízo. A sugestão é aplicar a agressividade de acordo
com a zona em que o ativo se encontrava no momento da
compra: 'arrojado' para a zona 1, 'agressivo' para a
zona 2 e 'berserk' para a zona 3.

4. Calculadora: calcula a variação percentual do valor de
um ativo.

Lembre-se: nenhum método garante o lucro, assim como
nenhum elimina a possibilidade de prejuízo. Opere somente
se estiver ciente dos riscos envolvidos e consulte um
profissional em caso de dúvida.\n"
  Alerta = "\nATENÇÃO! SAIBA QUE O TRADING ENVOLVE ALTO RISCO DE
PREJUÍZO, NÃO NEGOCIE A NÃO SER QUE VOCÊ TENHA CERTEZA
QUE SABE O QUE ESTÁ FAZENDO. NENHUM MÉTODO PODE GARANTIR
O LUCRO."

def tutorial # tutorial
  $T1.split("\n").each do |l|
    print l + "\n"
    sleep 0.1
  end
  gets
  $T2.split("\n").each do |l|
    print l + "\n"
    sleep 0.1
  end
  gets
  $T3.split("\n").each do |l|
    print l + "\n"
    sleep 0.1
  end
  gets
  $T4.split("\n").each do |l|
    print l + "\n"
    sleep 0.1
  end
  gets
end

if !File.exist?("cryptools.log") # checando se arquivo de log existe
  tutorial
end
file = File.new("cryptools.log", 'a') # criando arquivo de log
time = Time.now # data e hora atual
file.write("\nRegistros de #{"%02d" % time.day}/#{"%02d" % time.month}/#{time.year}, às #{"%02d" % time.hour}:#{"%02d" % time.min}:\n") # escrevendo cabeçalho com data e hora
file.close # fechando arquivo para salvar
file = File.new("cryptools.log", 'a') # reabrindo arquivo de log
n = 1 # contador

loop do

  print "\n_________________________________________________________\n\n"
  ["1. Holding", "2. Trading", "3. Stops", "4. Calculadora", "5. Ler registro", "6. Apagar registro", "7. Ajuda", "9. Sair"].each do |l|
    print l, "\n"
    sleep 0.1
  end
  print "\n"

  loop do
    print "Insira uma opção: "
    $opt = gets.chomp.to_i
    break if [1, 2, 3, 4, 5, 6, 7, 9].include?($opt)
  end

  if $opt == 1

  # HOLDING
  print "\n_________________________HOLDING_________________________\n"
  loop do
  # INPUTS
  print "\nInsira o nome do ativo: "
  name = gets.chomp.upcase
  print "Insira o valor unitário atual do ativo (em BRL): "
  value = gets.chomp.to_f
  print "Insira a variação percentual do valor unitário do ativo
nos últimos 3 meses: "
  c3 = gets.chomp
  if c3 == ""
    print "ERRO: VARIAÇÃO DO ÚLTIMO TRIMESTRE NÃO INSERIDA!"
    gets
    break
  else
    c3 = c3.to_f
  end
  print "Insira a variação percentual do valor unitário do ativo
nos últimos 6 meses: "
  c6 = gets.chomp
  print "Insira a variação percentual do valor unitário do ativo
nos últimos 12 meses: "
  c12 = gets.chomp
  if c6 == "" || c12 == ""
    nohist = true # sem histórico
  else
    nohist = false
  end
  c6 = c6.to_f
  c12 = c12.to_f
  print "Insira o saldo das dez últimas notícias (boas - ruins)
dentro dos últimos 3 meses: "
  news = gets.chomp
  if news == ""
    nonews = true # sem saldo de notícias
    news = 5
  else
    nonews = false
    news = news.to_i
    news = 10 if news > 10
    news = -10 if news < -10
  end

  # CÁLCULOS
  svalue = Math.log(500000) - Math.log(value) # avaliação do valor unitário da moeda
  if svalue > 10
    svalue = 10 + Math.sqrt(svalue-10)
  elsif svalue < 0
    svalue *= 2
  end
  if nohist == true
    volat = 10.0 # volatilidade caso não haja histórico
  else
    volat = (((c3 * 2) - c6).abs + ((c6 * 2) - c12).abs)**0.25 # avaliação da volatilidade
  end
  fator = 5.5 + volat # fator divisor de acordo com a volatilidade para avaliação do crescimento
  if fator < 7
    fator = 7.0
  elsif fator > 21
    fator = 21.0
  end
  if nohist == false
    cresc = ((c3 + c6 + c12)/fator).abs**(1/3.0) * 2 # avaliação do crescimento
  else
    cresc = c3.abs**(1/3.0) * 2
  end
  cresc *= -1 if c3+c6+c12 < 0 # valores negativos
  if nohist == false
    if c3 < c6/2.0 && c6 < c12/2.0
      dip = true # mergulho
    else
      dip = false
    end
    if c3 > c6/2.0 && c3 > c12/4.0 && c3 < c12 && c3/2.0 < c6
      climb = true # alto crescimento no último trimestre
      top = false # ativo em alta, possibilidade de queda
    elsif c3 >= c12 && c3/2.0 >= c6
      climb = false
      top = true
    else
      climb = false
      top = false
    end
  else
    dip = false
    climb = false
  end
  score = cresc + svalue + news - volat # avaliação final
  if top == true # penalidade em caso de possibilidade de resistência
    if score >= 0
      score -= score * 0.2
    else
      score += score * 0.2
    end
  elsif climb == true || dip == true # bônus em caso de crescimento seguro ou de mergulho (possível suporte)
    if score >= 0
      score += score * 0.1
    else
      score -= score * 0.1
    end
  end
  score = score.round(2)

  # RESULTADO
  print "\nValor: #{"%13s" % svalue.round(2)}"
  if svalue > 10
    print " (excelente!)\n"
  elsif svalue > 7
    print " (bom)\n"
  elsif svalue > 4
    print " (razoável)\n"
  elsif svalue > 0
    print " (oneroso)\n"
  else
    print " (muito oneroso!)\n"
  end
  print "Desempenho: #{"%8s" % cresc.round(2)}"
  if cresc > 15
    print " (excelente!)\n"
  elsif cresc > 10
    print " (bom)\n"
  elsif cresc > 5
    print " (razoável)\n"
  elsif cresc > 0
    print " (baixo)\n"
  elsif cresc == 0
    print " (nulo)\n"
  else
    print " (negativo!)\n"
  end
  if nohist == false
    print "Volatilidade: #{"%6s" % volat.round(2)}"
    if volat > 10
      print " (muito alta!)\n"
    elsif volat > 7
      print " (alta)\n"
    elsif volat > 4
      print " (razoável)\n"
    elsif volat > 0
      print " (estável)\n"
    else
      print " (nula!)\n"
    end
  end
  if nonews == false
    print "Notícias: #{"%10s" % news.round}"
    if news >= 10
      print " (promissoras!)\n"
    elsif news >= 7
      print " (boas)\n"
    elsif news >= 4
      print " (razoáveis)\n"
    elsif news >= 0
      print " (ruins)\n"
    else
      print " (péssimas!)\n"
    end
  end
  warn = [] # alertas
  warn << "resistência próxima!" if top == true
  warn << "momento de compra!" if dip == true
  warn << "tendência de alta!" if climb == true
  warn << "histórico incompleto" if nohist == true
  warn << "notícias desconhecidas" if nonews == true
  if warn.length > 0
    print "Alertas:  "  
    warn.each do |a|
      print " ", a
      print "," if a != warn[-1]
    end
    print "\n"
  end
  print "Score final: #{"%7s" % score}"
  if score >= 30
    print result = " (investimento altamente promissor!)"
  elsif score >= 20
    print result = " (investimento promissor)"
  elsif score >= 10
    print result = " (razoável)"
  elsif score >= 5
    print result = " (duvidoso)"
  else
    print result = " (não recomendável!)"
  end
  print "\n"
  if value >= 1
    file.write("  #{n}. Holding de #{name} (R$#{"%.2f" % value.round(2)}): #{score}#{result}", "\n") # escrevendo log
  else
    file.write("  #{n}. Holding de #{name} (R$#{"%.8f" % value.round(8)}): #{score}#{result}", "\n")
  end
  n += 1
  print "\nCalcular outro investimento? (s/n) "
  lp = gets.chomp.upcase
  if lp == "N"
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log
    break
  end
  end

  elsif $opt == 2

  # TRADING
  print "\n_________________________TRADING_________________________\n"

  Alerta.split("\n").each do |l|
    print l + "\n"
    sleep 0.1
  end

  loop do
  # INPUTS
  print "\nInsira o par que será negociado (ex: BTC/USDT): "
  par = gets.chomp.upcase
  print "Insira a variação percentual do valor unitário do ativo
nas últimas 24 horas: "
  c24 = gets.chomp.to_f
  print "Insira a variação percentual do valor unitário do ativo
no último mês (30 dias): "
  c1 = gets.chomp.to_f
  print "Insira a variação percentual do valor unitário do ativo
no último trimestre: "
  c3 = gets.chomp.to_f
  print "Insira o maior valor unitário do ativo nos últimos 7 dias:\n"
  max = gets.chomp.to_f
  print "Insira o menor valor unitário do ativo nos últimos 7 dias:\n"
  min = gets.chomp.to_f
  
  # CÁLCULOS
  dif = max - min # diferença entre suporte e resistência
  zonas = [max - (dif * 0.382), max - (dif * 0.5), max - (dif * 0.618), max - (dif * 0.786)] # zonas da retração de Fibonacci
  cvar = [c24*30, c1, c3/3.0] # variação
  volat = cvar.max - cvar.min # volatilidade
  chance = (c1 * 2) + (c3 / 5.0) - (volat / 5.0) - (c24 / 3.0).abs # probabilidade de lucro
  if chance > 50
    chance = 50 + Math.sqrt(chance - 50) # diminuindo chances altas
  elsif chance < 1
    chance = 1.0 # chance mínima
  end
  chance = 75.0 if chance > 75 # chance máxima
  seq = (10 - (chance / 10.0)).round # sequência de velas negativas

  # RESULTADO
  print "\nProbabilidade de lucro: #{"%3s" % + ("%.2f" % chance.round(2)) + "%"}
Volatilidade: #{"%16s" % ("%.2f" % volat.round(2)) + "%"}"
  warn = [] # alertas
  warn << "baixa probabilidade de lucro!" if chance < 25
  warn << "alta volatilidade!" if volat > 100
  if warn.length > 0
    print "\nAlertas:  "
    warn.each do |a|
      print " ", a
      print "," if a != warn[-1]
    end
    print "\n"
  end
  if min >= 1
    print "\nZonas de compra:
  * Zona 1:   $#{"%.2f" % zonas[1].round(2)} a $#{"%.2f" % zonas[0].round(2)}
  * Zona 2:   $#{"%.2f" % zonas[2].round(2)} a $#{"%.2f" % zonas[1].round(2)}
  * Zona 3:   $#{"%.2f" % zonas[3].round(2)} a $#{"%.2f" % zonas[2].round(2)}\n"
    file.write("  #{n}. Sinal para #{par}: #{seq} horas (chance de #{chance.round(2)}%), zona 1: de $#{"%.2f" % zonas[1].round(2)} a $#{"%.2f" % zonas[0].round(2)}, zona 2: de $#{"%.2f" % zonas[2].round(2)} a $#{"%.2f" % zonas[1].round(2)}, zona 3: de $#{"%.2f" % zonas[3].round(2)} a $#{"%.2f" % zonas[2].round(2)}", "\n") # escrevendo log
  else
    print "\nZonas de compra:
  * Zona 1:   $#{"%.8f" % zonas[1].round(8)} a $#{"%.8f" % zonas[0].round(8)}
  * Zona 2:   $#{"%.8f" % zonas[2].round(8)} a $#{"%.8f" % zonas[1].round(8)}
  * Zona 3:   $#{"%.8f" % zonas[3].round(8)} a $#{"%.8f" % zonas[2].round(8)}\n"
    file.write("  #{n}. Sinal para #{par}: #{seq} horas (chance de #{chance.round}%), zona 1: de $#{"%.8f" % zonas[1].round(8)} a $#{"%.8f" % zonas[0].round(8)}, zona 2: de $#{"%.8f" % zonas[2].round(8)} a $#{"%.8f" % zonas[1].round(8)}, zona 1: de $#{"%.8f" % zonas[3].round(8)} a $#{"%.8f" % zonas[2].round(8)}", "\n") # escrevendo log
  end
  print "Sinal:
  * Esperar por #{seq} velas negativas de horas consecutivas;
  * Comprar quando algum suporte for atingida ou quando
    confirmar alguma vela com padrão de reversão, desde que
    o valor esteja dentro das zonas de compra.
Lembre-se de definir o stop-gain e o stop-loss após a compra
para controlar o risco da negociação.\n"
  n += 1
  print "\nCalcular outra negociação? (s/n) "
  lp = gets.chomp.upcase
  if lp == "N"
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log
    break
  end
  end

  elsif $opt == 3 # STOPS
    print "\n________________________STOPS____________________________\n"
    loop do

  # INPUTS
  print "\nInsira a quantia total investida (em BRL ou USD): "
  banca = gets.chomp.to_f
  print "Insira o valor unitário do ativo no momento da compra: "
  value = gets.chomp.to_f
  print "Insira o maior valor unitário do ativo nos últimos 3 dias:\n"
  max3 = gets.chomp.to_f
  print "Insira o maior valor unitário do ativo nos últimos 7 dias:\n"
  max7 = gets.chomp.to_f
  print "Insira o menor valor unitário do ativo nos últimos 3 dias:\n"
  min3 = gets.chomp.to_f
  print "Insira o menor valor unitário do ativo nos últimos 7 dias:\n"
  min7 = gets.chomp.to_f
  print "Insira a agressividade da negociação (arrojada 1, agressiva 2,
berserk 3): "
  sperfil = ["arrojado", "agressivo", "berserk"] # strings dos perfis
  perfil = gets.chomp.to_i
  if perfil != 1 && perfil != 2 && perfil != 3
    print "ERRO: PERFIL INVÁLIDO!" # erro para perfis inválidos
    gets
    break
  end

  # CÁLCULOS
  dif = max7 - min7 # diferença entre suporte e resistência
  if perfil == 1
    sg = max3 # stop-gain
    sl = min3 # stop-loss
  elsif perfil == 2
    sg = max7
    sl = min7
  elsif perfil == 3
    sg = max7 + (max7 - max3)
    sl = max7 - (dif * 1.618)
  end
  sl = 0.00000001 if sl < 0.00000001
  gainp = (sg / value.to_f) - 1 # porcentagem de lucro
  lossp = (1 - (sl / value.to_f)).to_f # porcentagem em risco
  lucro = (banca * (1 + gainp)) - banca # lucro
  risk = banca - (banca * (1 - lossp)) # quantia em risco

  # RESULTADO
  if gainp.nan? || lossp.nan?
    print "ERRO: VALORES INVÁLIDOS!"
    gets
    break
  end
  if value >= 1
    print "\nStops (pelo valor unitário):
  * Limite de ganho (stop-gain): $#{"%.2f" % sg.round(2)} (+#{(gainp * 100).round}%)
  * Limite de perda (stop-loss): $#{"%.2f" % sl.round(2)} (-#{(lossp * 100).round}%)\n"
    file.write("  #{n}. Stops (#{sperfil[perfil - 1]}): stop-gain de $#{"%.2f" % sg.round(2)} (+#{(gainp * 100).round}%), stop-loss de $#{"%.2f" % sl.round(2)} (-#{(lossp * 100).round}%), lucro de $#{"%.2f" % lucro.round(2)} e risco em $#{"%.2f" % risk.round(2)}\n") # escrevendo log
  else
    print "\nStops (pelo valor unitário):
  * Limite de ganho (stop-gain): $#{"%.8f" % sg.round(8)} (+#{(gainp * 100).round}%)
  * Limite de perda (stop-loss): $#{"%.8f" % sl.round(8)} (-#{(lossp * 100).round}%)\n"
    file.write("  #{n}. Stops (#{sperfil[perfil - 1]}): stop-gain de $#{"%.8f" % sg.round(8)} (+#{(gainp * 100).round}%), stop-loss de $#{"%.8f" % sl.round(8)} (-#{(lossp * 100).round}%), lucro de $#{"%.2f" % lucro.round(2)} e risco em $#{"%.2f" % risk.round(2)}\n") # escrevendo log
  end
  print "Lucro absoluto: #{"%18s" % "$" + ("%.2f" % lucro.round(2))}
Quantia em risco: #{"%16s" % "$" + ("%.2f" % risk.round(2))}\n"
  print "Alerta:  risco superior ao lucro!\n" if gainp < lossp.abs
  n += 1
  print "\nCalcular outros limites? (s/n) "
  lp = gets.chomp.upcase
  if lp == "N"
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log
    break
  end
  end

  elsif $opt == 4 # CALCULADORA
    print "\n_______________________CALCULADORA_______________________\n"
    loop do
  # INPUTS
  print "\nInsira o par a ser calculado (ex: BTC/BRL): "
  par = gets.chomp.upcase
  print "Insira o período da variação (ex: 7 dias): "
  tempo = gets.chomp.downcase
  print "Insira o valor inicial do ativo: "
  v1 = gets.chomp.to_f
  print "Insira o valor final do ativo: "
  v2 = gets.chomp.to_f

  # CÁLCULOS
  var = (((v2 / v1) - 1) * 100).round(2)

  # RESULTADO
  if var > 0
    print "\nVariação:    +#{var}%\n"
    file.write("	#{n}. Variação do par #{par} em #{tempo}: +#{var}%\n")
  else
    print "\nVariação:    #{var}%\n"
    file.write("	#{n}. Variação do par #{par} em #{tempo}: #{var}%\n")
  end
  n += 1
  print "\nCalcular outra variação? (s/n) "
  lp = gets.chomp.upcase
  if lp == "N"
    file.close
    file = File.new("cryptools.log", 'a') # criando arquivo de log
    break
    end
  end
  
  elsif $opt == 5 # IMPRIMIR ARQUIVO DE LOG
    log = File.open("cryptools.log") # lendo arquivo de log
    print "\n________________________REGISTRO_________________________\n"
    log.read.split("\n\n").reverse.each do |l|
      puts l
      gets
    end

  elsif $opt == 6 # DELETAR ARQUIVO DE LOG ____________________________
    print "\nDeletar arquivo de registro? (s/n) "
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

  elsif $opt == 7 # TUTORIAL
    print "\n__________________________AJUDA__________________________\n"
    tutorial

  elsif $opt == 9 # EXIT
    print "\n"
    fim = "Todo o registro foi salvo no arquivo 'cryptools.log'.
Lembre-se: é recomendável que se consulte um profissional
antes de fazer qualquer investimento. Até mais!\n"
    fim.split("\n").each do |l|
      print l + "\n"
      sleep 0.1
    end
    gets
    exit

  end # fim do if
end # fim do loop
