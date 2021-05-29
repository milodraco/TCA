file = File.new("criptocalc.log", 'a')
file.write(Time.now, "\n")

print "Calculador de score para criptomoedas
                        por Milo Draco
                        v. 0.9\n"
loop do

# inputs
print "\nInsira o nome da moeda: "
name = (gets.chomp).upcase
print "Insira o valor atual da moeda em R$: "
value = (gets.chomp).to_f
print "Insira o crescimento em % nos últimos 3 meses: "
c3 = (gets.chomp).to_f
print "Insira o crescimento em % nos últimos 6 meses: "
c6 = gets.chomp
print "Insira o crescimento em % nos últimos 12 meses: "
c12 = gets.chomp
if c6 == "" || c12 == ""
  nohist = true
  else
  nohist = false
end
c6 = c6.to_f
c12 = c12.to_f
print "Insira o saldo das dez últimas notícias (boas-ruins) dentro
dos últimos 3 meses: "
news = (gets.chomp).to_i

# cálculos
cresc = c3.abs**(0.34) * 2
cresc *= -1 if c3 < 0
svalue = ((Math::log((10**10)-value) - 23.0258) * 25000)**(10)
if nohist == true
  volat = 10
  else
  volat = (((c3 * 2) - c6).abs + ((c6 * 2) - c12).abs)**0.25
end
score = (cresc + svalue + news - volat).round(2)

# resultado
print "\nValor (#{svalue.round(2)}): "
if svalue > 10
  print "Excelente!\n"
  elsif svalue > 7
  print "Bom\n"
  elsif svalue > 4
  print "Razoável\n"
  elsif svalue > 0
  print "Ruim\n"
  else
  print "Muito ruim!\n"
end
print "Crescimento (#{cresc.round(2)}): "
if cresc > 15
  print "Excelente!\n"
  elsif cresc > 10
  print "Bom\n"
  elsif cresc > 5
  print "Razoável\n"
  elsif cresc > 0
  print "Baixo\n"
  else
  print "Negativo!\n"
end
print "Volatilidade (#{volat.round(2)}): "
if volat > 10
  print "Muito alta!\n"
  elsif volat > 7
  print "Alta\n"
  elsif volat > 4
  print "Razoável\n"
  elsif volat > 0
  print "Estável\n"
  else
  print "Nula!\n"
end
print "Notícias (#{news.round}): "
if news >= 10
  print "Excelentes!\n"
  elsif news > 7
  print "Boas\n"
  elsif news > 4
  print "Razoáveis\n"
  elsif news > 0
  print "Ruins\n"
  else
  print "Péssimas!\n"
end
print "Score final: #{score} "
if score > 30
  print "(investimento altamente recomendável!)\n"
  elsif score > 20
  print "(investimento recomendável)\n"
  elsif score > 10
  print "(razoável)\n"
  elsif score > 5
  print "(ruim)\n"
  else
  print "(não invista!)\n"
end
file.write("#{name} (R$ #{value}): #{score}", "\n")
print "\nCalcular outra criptomoeda? (s/n) "
lp = (gets.chomp).upcase
file.write("\n") if lp == "N"
exit if lp == "N"
end
