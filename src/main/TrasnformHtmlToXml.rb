# Declaración de gemas utilizadas de Ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'

# Variable local que contiene el formato del XML
xml_pretty_content = ''

# Constante que indica el los espacios de indentación por defecto
DEFAULT_INDENT = 2

# Hash que contiene las etiquetas a procesar
$process_tags = {title: 'title', body: 'content', h1: 'header', h2: 'header', h3: 'header', h4: 'header',
                 h5: 'header', h6: 'header', p: 'para', i: 'cursive', b: 'bold', u: 'sub', strong: 'bold',
                 table: 'table', tr: 'row', th: 'col', td: 'col', ul: 'list', ol: 'list', li: 'value',
                 select: "select", option: "option", input: "input", link: "link", a: "link", meta: "meta",
                 div: "div", span: "span", center: "center", form: "form", nobr: "nobr", img: "image"}

# Variable global que contiene los tags procesados
$tags = Hash.new(0)

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

def parse_xml_file(file_name)
  # se abre y se crea el fichero pasado por parámetro
  f = File.read(file_name)
  # se devuelve un elemento Nokogiri::XML en formato UTF_8
  Nokogiri::XML(f,nil, Encoding::UTF_8.to_s)
end

def parse_children(children, doc)

  # se corre los hijos del nodo pasado por parámetro
  children.each do |child|
    case child
    when Nokogiri::XML::Text
      # no se establece el contenido
      #child.content = child.content.strip + "A"
    when Nokogiri::XML::Element # Solo se procesan los elementos

      # Se comprueba que el nodo se encuentra dentro del tags a procesar
      if ($process_tags.has_key?(child.name.to_sym))

        # se incrementa el contador de los tags procesados
        $tags[child.name] += 1

        # Se comprueba si está dentro de la lista de tags a procesar para establecer su sinónimo
        name = $process_tags.has_key?(child.name.to_sym) ? $process_tags.fetch(child.name.to_sym) : child.name

        # se crea un nuevo elemento
        new_element = Nokogiri::XML::Node.new(name, doc)

        case child.name
        when "table", "tr", "ul", "ol", "select", "form"
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

def add_common_value_element(doc, value, name)
  # se crea un nuevo elmento
  new_element = Nokogiri::XML::Node.new(name, doc)
  # se establece el contenido al elemento
  new_element.content = value
  # se añade el elemento como hijo
  doc.add_child(new_element)
end

def add_content_input(node, doc)
  if (node.attributes)
    node.attributes.each do |k, v|
      # se crea el elemento attr
      add_common_value_element(doc, v, k)
    end
  end
end

##
# Se comprueba que se introduce el fichero por parámetro
unless ARGV[0]
  print "Es necesario pasar un fichero o una URL en el primer parámetro"
  exit
end

# Se recorren los argumentos pasados
ARGV.each do |file|

  # page = Nokogiri::HTML(open("http://en.wikipedia.org/"))
  page = Nokogiri::HTML(open(file), nil, Encoding::UTF_8.to_s)

  # puts page.search('*').map(&:name)
  filename = "../../resources/result.xml"
  resultname = "../../out/result.xml"

  # Se abre el documento xml
  doc = parse_xml_file(filename)

  page.root.elements.each do |node|
    next unless node.is_a?(Nokogiri::XML::Element)

    new_element = Nokogiri::XML::Node.new(node.name, doc)
    # new_element.content = node.content
    doc.root.add_child(new_element)
    parse_children(node.children, new_element)

    $tags[node.name] += 1
  end


  # Option 1 - Texto sin formatear
  # File.write(resultname, doc.to_xml(:indent => 4, :encoding => 'UTF-8'))

  # Option 2 - Texto formateado (break line)
  #doc.pretty_print(DEFAULT_INDENT)
  #File.write(resultname, xml_pretty_content)

  # Option 3 - Texto formateado (pretty)
  xsl = Nokogiri::XSLT(File.read('..\..\resources\pretty_print.xsl'))
  File.open(resultname, "w") { |f| f << xsl.apply_to(doc).to_s }

  puts "Resumen de los tags procesados"
  puts "#{$tags}"
end

