require 'rubygems'
require 'nokogiri'
require 'open-uri'

# Variable local que contiene el formato del XML
xml_pretty_content = ''

# Constante que indica el los espacios de indentación por defecto
DEFAULT_INDENT = 2

# Hash que contiene las etiquetas a procesar
$process_tags = {title: 'title', body: 'content', h1: 'header', h2: 'header', h3: 'header', h4: 'header',
                 h5: 'header', h6: 'header', p: 'para', i: 'para', b: 'para', strong: 'para', table: 'table',
                 tr: 'row', th: 'col', td: 'col', ul: 'list', ol: 'list', li: 'value', select: "select",
                 option: "option", input: "input", link: "link", meta: "meta"}

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

def create_xml_file(file_name)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.root
  end
end

def parse_xml_file(file_name)
  f = File.read(file_name)
  Nokogiri::XML(f,nil, Encoding::UTF_8.to_s)
end


def parse_children(children, doc)
  children.each do |child|
    case child
    when Nokogiri::XML::Text
      #child.content = child.content.strip + "A"
    when Nokogiri::XML::Element
            name = $process_tags.has_key?(child.name.to_sym) ? $process_tags.fetch(child.name.to_sym) : child.name


            new_element = Nokogiri::XML::Node.new(name, doc)
            case child.name
            when "table", "tr", "ul", "ol", "select"
              new_element.content = ""
            when "input", "link", "meta"
              add_content_input(child)
            else
              new_element.content = child.content
            end

            doc.add_child(new_element)


        parse_children(child.children, new_element)
    end
  end
end

def add_element(doc, node)
  new_element = Nokogiri::XML::Node.new(node.name, doc)
  new_element.content = node.content
  doc.root.add_child(new_element)
end

def add_common_root_element(doc, node, name)
  new_element = Nokogiri::XML::Node.new(name, doc)
  new_element.content = node.content
  doc.root.add_child(new_element)
end

def add_common_element(doc, node, name)
  new_element = Nokogiri::XML::Node.new(name, doc)
  new_element.content = node.content
  doc.add_child(new_element)
end

def add_element_table(doc, node, name)
  # Se crea el elemento table
  table = Nokogiri::XML::Node.new(name, doc)

  if (node.children)
    node.children.each do |row|
      next unless row.is_a? (Nokogiri::XML::Element)

      # se crea el elemento row
      tr = Nokogiri::XML::Node.new($process_tags.fetch(row.name.to_sym), table)

      if (row.children)
        row.children.each do |para|
          next unless para.is_a? (Nokogiri::XML::Element)
          # se crea la columna
          add_common_element(tr, para, $process_tags.fetch(para.name.to_sym))
        end
      end
      table.add_child(tr)
    end
  end

  doc.root.add_child(table)
end


def add_element_list(doc, node, name)
  # Se crea el elemento list
  list = Nokogiri::XML::Node.new(name, doc)

  if (node.children)
    node.children.each do |val|
      next unless val.is_a? (Nokogiri::XML::Element)
      # se crea el elemento value
      add_common_element(list, val, $process_tags.fetch(val.name.to_sym))
    end
  end

  doc.root.add_child(list)
end

def add_common_value_element(doc, value, name)
  new_element = Nokogiri::XML::Node.new(name, doc)
  new_element.content = value
  doc.add_child(new_element)
end

def add_element_input(doc, node, name)
  # Se crea el elemento input
  input = Nokogiri::XML::Node.new(name, doc)

  if (node.attributes)
    node.attributes.each do |k, v|

      # se crea el elemento attr
      add_common_value_element(input, v, k)

    end
  end

  doc.root.add_child(input)
end


def add_content_input(node)

  if (node.attributes)
    node.attributes.each do |k, v|

      # se crea el elemento attr
      add_common_value_element(node, v, k)

    end
  end
end

##
# Se comprueba que se introduce el fichero por parámetro
unless ARGV[0]
  print "Es necesario pasar un fichero por parámetro"
  exit
end

ARGV.each do |file|

  # page = Nokogiri::HTML(open("http://en.wikipedia.org/"))
  page = Nokogiri::HTML(open(file), nil, Encoding::UTF_8.to_s)
  puts page.class   # => Nokogiri::HTML::Document
  puts page.css('title')

  # puts page.search('*').map(&:name)
  filename = "../../resources/result.xml"
  resultname = "../../out/result.xml"

  # Se abre el documento xml
  doc = parse_xml_file(filename)

  # doc = create_xml_file(filename)

  page.root.elements.each do |node|
    next unless node.is_a?(Nokogiri::XML::Element)

    if(node.children)
      node.children.each do |child|
        next unless child.is_a?(Nokogiri::XML::Element)
      end
    end

    puts node.name
  end


  page.root.elements.each do |node|
    next unless node.is_a?(Nokogiri::XML::Element)

    new_element = Nokogiri::XML::Node.new(node.name, doc)
    # new_element.content = node.content
    doc.root.add_child(new_element)
    parse_children(node.children, new_element)
  end


  tags = Hash.new(0)

=begin
  page.traverse do |node|
    next unless node.is_a?(Nokogiri::XML::Element)

    # print "#{node.name} **** #{node.text}...... #{node.values} ---- #{node.attributes}\n"
    # File.write('examples.xml', node.to_xml(:indent => 5, :encoding => 'UTF-8'))

    # Se comprueba que el nodo se encuentra dentro del tags a procesar
    if ($process_tags.has_key?(node.name.to_sym))

      # se añade el elemento
      case node.name
        when "title", "h1", "h2", "h3", "h4", "h5", "h6", "p", "b", "i", "strong"
          add_common_root_element(doc, node, $process_tags.fetch(node.name.to_sym))
        when "table"
          add_element_table(doc, node, $process_tags.fetch(node.name.to_sym))
        when "ul", "ol", "select"
          add_element_list(doc, node, $process_tags.fetch(node.name.to_sym))
        when "input"
          add_element_input(doc, node, $process_tags.fetch(node.name.to_sym))
        else
          puts 'No se encuentra implementada'
      end

    end



    tags[node.name] += 1

    next
  end
=end

  # puts doc.to_s

  # filename = 'exam.xml'
  # xml = File.read(filename)
  # doc = Nokogiri::XML(xml)
  # File.write(resultname, doc.to_xml(:indent => 4, :encoding => 'UTF-8'))

  doc.pretty_print(DEFAULT_INDENT)

  File.write(resultname, xml_pretty_content)

  # xsl = Nokogiri::XSLT(File.read('..\resources\pretty_print.xsl'))
  # File.open(resultname, "w") { |f| f << xsl.apply_to(doc).to_s }

  #puts "#{tags}"
end

