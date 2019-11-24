# Declaración de gemas utilizadas de Ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'

##
# Clase que transforma un HTML en XML.
# Para ello, utiliza la librería "Nokogiri::XML" y "Nokogiri::HTML".
#
class TrasnformHtmlToXml

  # Constante que indica el número de espacios de indentación por defecto
  DEFAULT_INDENT = 2

  # Constante que contiene el fichero XML a partir del cual se generará la salida
  PROCESS_FILE = "../../resources/result.xml"

  # Constante que contiene la plantilla XSL para el procesamiento del formato de XML
  PRETTY_TEMPLATE = "../../resources/pretty_print.xsl"

  # Constante que contiene el Hash de las etiquetas a procesar
  PROCESS_TAGS = {title: 'title', body: 'content', h1: 'header', h2: 'header', h3: 'header', h4: 'header',
                   h5: 'header', h6: 'header', p: 'para', i: 'cursive', b: 'bold', u: 'sub', strong: 'bold',
                   table: 'table', tr: 'row', th: 'col', td: 'col', ul: 'list', ol: 'list', li: 'value',
                   select: "select", option: "option", input: "input", link: "link", a: "link", meta: "meta",
                   div: "div", span: "span", center: "center", form: "form", nobr: "nobr", img: "image"}

  ##
  # Contructor con parámetros
  # - input -      Fichero o URL a pasear
  # - attributes - Parámetro que indica si se desean procesar los atributos o no
  #                Valor "0" - generación del XML sin atributos (default)
  #                Valor "1" - generación del XML con atributos
  # - format -     Parámetro que indica el formato de salida del XML generado
  #                Valor "1" - Sin formato (default)
  #                Valor "2" - Formateado con líneas de ruptura
  #                Valor "3" - Formateado sin líneas de ruptura
  # - output -     Ruta absoluta o relativa del fichero de salida (../../out/result.xml)
  def initialize(input, attributes = 0, format = 3, output = "../../out/result.xml")
    #control de errores
    begin
      # Se abre y se parsea el HTML pasado por parámetro
      @page = Nokogiri::HTML(open(input), nil, Encoding::UTF_8.to_s)
    rescue
      puts "El fichero pasado por parámetro o la URL no existe: #{input}"
      exit # Se sale del programa ya que no se puede parsear el fichero o url de entrada
    end
    @attributes = attributes
    @format = format
    @output = output

    # Variable miembro que contiene los tags procesados
    @tags = Hash.new(0)
  end

  ##
  # Método que parsea un fichero HTML en XML
  def parserHtmltoXml
    # Se abre el documento xml template
    doc = parse_xml_file(PROCESS_FILE)

    # Se procesa el HTML y se añaden los tags al doc
    process_html_file(doc)

    # Pinta el xml generado
    print_xml(doc)

    # Se pintan los tags procesados
    print_count_tags
  end

  private

  ##
  # Método que abre y parsea un fichero pasado por parámetro
  # - file_name - Ruta absoluta o relativa de la plantilla XML a partir de la cual se generará el fichero XML de salida
  def parse_xml_file(file_name)
    # se abre y se crea el fichero pasado por parámetro
    f = File.read(file_name)
    # se devuelve un elemento Nokogiri::XML en formato UTF_8
    Nokogiri::XML(f,nil, Encoding::UTF_8.to_s)
  end

  ##
  # Método que procesa el HTML y sa va contruyendo el XML de salida
  # - doc - Documento Nokogiri::XML de salida
  def process_html_file(doc)
    @page.root.elements.each do |node|
      next unless node.is_a?(Nokogiri::XML::Element)

      new_element = Nokogiri::XML::Node.new(node.name, doc)
      # new_element.content = node.content
      doc.root.add_child(new_element)
      parse_children(node.children, new_element)

      @tags[node.name] += 1
    end
  end

  ##
  # Método recursivo que recorre todos los nodos del HTML
  # para ir generando el XML de salida
  # - children -  Son los nodos hijos del elemento HTML procesado
  # - doc -       Nodo "Nokogiri::XML::Element" del XML sobre el cual se creará los elementos procesados
  def parse_children(children, doc)

    # se corre los hijos del nodo pasado por parámetro
    children.each do |child|
      case child
      when Nokogiri::XML::Text
        # no se establece el contenido
        #child.content = child.content.strip + "A"
      when Nokogiri::XML::Element # Solo se procesan los elementos

        # Se comprueba que el nodo se encuentra dentro del tags a procesar
        if (PROCESS_TAGS.has_key?(child.name.to_sym))

          # se incrementa el contador de los tags procesados
          @tags[child.name] += 1

          # Se comprueba si está dentro de la lista de tags a procesar para establecer su sinónimo
          name = PROCESS_TAGS.has_key?(child.name.to_sym) ? PROCESS_TAGS.fetch(child.name.to_sym) : child.name

          # se crea un nuevo elemento
          new_element = Nokogiri::XML::Node.new(name, doc)

          case child.name
          when "table", "tr", "ul", "ol", "select", "form", "div"
            # Para las etiquetas de está clausula no se añade contenido
            new_element.content = ""
          when "input", "link", "meta", "img"
            # se añade el contenido de los tags
            add_content_input(child, new_element)
          else
            # se establece el contenido del hijo
            new_element.content = child.content
          end

          # Se añade el nuevo elemento al nodo procesado
          doc.add_child(new_element)
        end

        # Se llama recurivamente a los hijos del elemento procesado
        parse_children(child.children, new_element)
      end
    end
  end

  ##
  # Método que añade al documento (Nokorigi::XML) un nuevo nodo (Nokogiri::XML::Node)
  # con el nombre "name" y el valor "value"
  # - value - Contenido del nodo a crear
  # - name -  Nombre del nodo a crear
  def add_common_value_element(doc, value, name)
    # se crea un nuevo elmento
    new_element = Nokogiri::XML::Node.new(name, doc)
    # se establece el contenido al elemento
    new_element.content = value
    # se añade el elemento como hijo
    doc.add_child(new_element)
  end

  ##
  # Método que añade los atgributos de nodo pasado por parámetro
  # en el documento (Nokogiri::XML)
  # - node - Nodo HTML procesado
  # - doc -  Documento (Nokorigi::XML) a construir
  def add_content_input(node, doc)
    if (node.attributes)
      node.attributes.each do |k, v|
        # se crea el elemento attr
        add_common_value_element(doc, v, k)
      end
    end
  end

  ##
  # Método que escribe el doc (NoKorigi::XML) generado en el fichero de salida sin formato
  # Option 1 - Texto sin formatear
  # - doc - Documento (NoKorigi::XML) generado
  def write_xml(doc)
    begin
      # Escribe el contenido del documento en el fichero de salida
      File.write(@output, doc.to_xml(:indent => 4, :encoding => 'UTF-8'))
    rescue
      puts "El fichero de salida 'output' pasado por parámetro no existe: #{@output}"
      exit # Se sale del programa ya que no se puede crear el fichero de salida
    end
  end

  ##
  # Método que escribe el doc (NoKorigi::XML) generado en el fichero de salida formateado con líneas de ruptura
  # Option 2 - Texto formateado (break line)
  # - doc - Documento (NoKorigi::XML) generado
  def write_pretty_xml_with_break(doc)
    # Variable local que contiene el formato del XML
    xml_pretty_content = ''

    Nokogiri::XML::Node.class_eval do
      # Print every Node by default (will be overridden by CharacterData)
      define_method :should_print? do
        true
      end

      # Duplicate this node, replace the contents of the duplicated node with a
      # newline. With this content substitution, the #to_s method conveniently
      # returns a string with the opening tag (e.g. `<a href="foo">`) on the first
      # line and the closing tag on the second (e.g. `</a>`, provided that the
      # current node is not a self-closing tag).
      #
      # Now, print the open tag preceded by the correct amount of indentation, then
      # recursively print this node's children (with extra indentation), and then
      # print the close tag (if there is a closing tag)
      define_method :pretty_print do |indent=0|
        duplicate = self.dup
        duplicate.content = "\n"
        open_tag, close_tag = duplicate.to_s.split("\n")

        # puts (" " * indent) + open_tag
        xml_pretty_content += (" " * indent) + open_tag + "\r"
        self.children.select(&:should_print?).each { |child| child.is_a?(Nokogiri::XML::Element) ? child.pretty_print(indent + DEFAULT_INDENT) : xml_pretty_content += (" " * (indent + DEFAULT_INDENT)) + child.content + "\r"}
        # puts (" " * indent) + close_tag if close_tag
        xml_pretty_content += (" " * indent) + close_tag + "\r" if close_tag
      end
    end

    # Se escribe el fichero
    doc.pretty_print(DEFAULT_INDENT)
    begin
      # Escribe el contenido del documento en el fichero de salida aplicando una plantilla XSLT
      File.write(@output, xml_pretty_content)
    rescue
      puts "El fichero de salida 'output' pasado por parámetro no existe: #{@output}"
      exit # Se sale del programa ya que no se puede crear el fichero de salida
    end
  end

  ##
  # Método que escribe el doc (NoKorigi::XML) generado en el fichero de salida formateado sin líneas de ruptura
  # Option 3 - Texto formateado
  # - doc - Documento (NoKorigi::XML) generado
  def write_pretty_xml(doc)
    # Leer y parsea la plantilla de XSLT
    xsl = Nokogiri::XSLT(File.read(PRETTY_TEMPLATE))

    begin
      # Escribe el contenido del documento en el fichero de salida aplicando una plantilla XSLT
      File.open(@output, "w") { |f| f << xsl.apply_to(doc).to_s }
    rescue
      puts "El fichero de salida 'output' pasado por parámetro no existe: #{@output}"
      exit # Se sale del programa ya que no se puede crear el fichero de salida
    end
  end

  ##
  # Método que pinta el documento (NoKorigi::XML) generado en el fichero de salida segun la opción selecionada
  # - doc - Documento (NoKorigi::XML) generado
  def print_xml(doc)
    case @format
    when 1
      # Option 1 - Texto sin formatear
      write_xml(doc)
    when 2
      # Option 2 - Texto formateado (break line)
      write_pretty_xml_with_break(doc)
    when 3
      # Option 3 - Texto formateado (pretty)
      write_pretty_xml(doc)
    else
      puts "Formato incorrecto. Se establece la Opción por defecto: 3\n"
      # Option 3 - Texto formateado (pretty)
      write_pretty_xml(doc)
    end

    puts "El fichero generado se encuentra en la ruta: #{@output}\n"
  end

  ##
  # Método que pinta el número de Tags HTML procesados
  def print_count_tags
    puts "Resumen de los tags procesados:\n"
    puts "#{@tags}"
  end
end


# Se comprueba que se introduce el fichero por parámetro
unless ARGV[0]
  print "Es necesario pasar un fichero o una URL en el primer parámetro \n"
  print "Para ejecutar correctamente este script es necesario pasar los siguientes parámetros \n"
  print "ruby TransformHtmlToXml input [atrributes format output] \n"
  print " - input -      Fichero o URL a pasear (required) \n"
  print " - attributes - Parámetro que indica si se desean procesar los atributos o no \n"
  print "                Valor '0' - generación del XML sin atributos (default) \n"
  print "                Valor '1' - generación del XML con atributos \n"
  print " - format -     Parámetro que indica el formato de salida del XML generado \n"
  print "                Valor '1' - Sin formato (default) \n"
  print "                Valor '2' - Formateado con líneas de ruptura \n"
  print "                Valor '3' - Formateado sin líneas de ruptura \n"
  print " - output -     Ruta absoluta o relativa del fichero de salida (../../out/result.xml) \n"
  exit
end

# Se definen las variables por defecto
DEFAULT_ATTRIBUTES = 0
DEFAULT_FORMAT = 3
DEFAULT_OUTPUT = "../../out/result.xml"

# Se establecen los parámetros pasados por línea de comando
input = ARGV[0]
attributes = ARGV[1].nil? ? DEFAULT_ATTRIBUTES : ARGV[1]
format = ARGV[2].nil? ? DEFAULT_FORMAT : ARGV[2]
output = ARGV[3].nil? ? DEFAULT_OUTPUT : ARGV[3]

# Se instancia la clase que transforma el HTML al XML
parser = TrasnformHtmlToXml.new(input, attributes, format, output)
# Se invoca al método que transforma el HTML al XML
parser.parserHtmltoXml
