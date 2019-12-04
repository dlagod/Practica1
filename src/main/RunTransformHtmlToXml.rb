require_relative 'TrasnformHtmlToXml'

# Se comprueba que se introduce el fichero por parámetro
unless ARGV[0]
  print "Es necesario pasar un fichero o una URL en el primer parámetro \n\n"
  print "Para ejecutar correctamente este script es necesario pasar los siguientes parámetros: \n\n"
  print "ruby RunTransformHtmlToXml input [atrributes format output] \n\n"
  print " - input -      Fichero o URL a pasear (required) \n"
  print " - attributes - Parámetro que indica si se desean procesar los atributos o no \n"
  print "                Valor '0' - generación del XML sin atributos (default) \n"
  print "                Valor '1' - generación del XML con atributos \n"
  print " - format -     Parámetro que indica el formato de salida del XML generado \n"
  print "                Valor '1' - Sin formato \n"
  print "                Valor '2' - Formateado con líneas de ruptura \n"
  print "                Valor '3' - Formateado sin líneas de ruptura (default) \n"
  print " - output -     Ruta absoluta o relativa del fichero de salida (out/result.xml) \n"
  exit
else
  # Constante que define si se desea o no puntar los atributo (Por defecto no "0")
  DEFAULT_ATTRIBUTES = "0"
  # Constante que define el tipo de formato del XML de salida (Por defecto no "3" PRETTY)
  DEFAULT_FORMAT = "3"
  # Constante que define la ruta y el fichero XML de salida (Por defecto no "out/result.xml")
  DEFAULT_OUTPUT = "out/result.xml"

  # Se establecen los parámetros pasados por línea de comando
  input = ARGV[0]
  attributes = ARGV[1].nil? ? DEFAULT_ATTRIBUTES : ARGV[1]
  format = ARGV[2].nil? ? DEFAULT_FORMAT : ARGV[2]
  output = ARGV[3].nil? ? DEFAULT_OUTPUT : ARGV[3]

  # Se instancia la clase que transforma el HTML al XML
  parser = TrasnformHtmlToXml.new
  # Se invoca al método que transforma el HTML al XML
  parser.parserHtmltoXml(input, attributes, format, output)
end
