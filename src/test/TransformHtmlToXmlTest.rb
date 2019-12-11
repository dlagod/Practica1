require 'minitest/autorun'
require_relative '../../src/main/TransformHtmlToXml'


class TransformHtmlToXmlTest < Minitest::Test

  ##
  # Método que se ejecuta al invocar los test
  def setup # ó before
    # Se invoca a la clase TransformHtmlToXml
    @transform = TransformHtmlToXml.new
  end

  ##
  # Método que se ejecuta una vez finalizados los test
  def teardown # ó after
    # código
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # utilizando las opciones por defecto
  def test_example1_default
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1.xml", "out/result.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # pasando los parámetros
  def test_example1_with_param
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "0", "1", "out/example1_with_param.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_with_param.xml", "out/example1_with_param.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando sin atributos y con formato 1 (Sin formato)
  def test_example1_without_attributes_format1
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "1", "out/example1_without_attributes_format1.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_without_attributes_format1.xml", "out/example1_without_attributes_format1.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando sin atributos y con formato 2 (Formateado con líneas de ruptura)
  def test_example1_without_attributes_format2
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "2", "out/example1_without_attributes_format2.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_without_attributes_format2.xml", "out/example1_without_attributes_format2.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando sin atributos y con formato 3 (Formateado sin líneas de ruptura)
  def test_example1_without_attributes_format3
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "3", "out/example1_without_attributes_format3.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_without_attributes_format3.xml", "out/example1_without_attributes_format3.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando los atributos y con formato 1 (Sin formato)
  def test_example1_with_attributes_format1
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "1", "out/example1_with_attributes_format1.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_with_attributes_format1.xml", "out/example1_with_attributes_format1.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando los atributos y con formato 2 (Formateado con líneas de ruptura)
  def test_example1_with_attributes_format2
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "2", "out/example1_with_attributes_format2.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_with_attributes_format2.xml", "out/example1_with_attributes_format2.xml"))
  end

  ##
  # Método de test que comprueba la correcta generación del XML del example1
  # generando los atributos y con formato 3 (Formateado sin líneas de ruptura)
  def test_example1_with_attributes_format3
    #Se invoca al método parserHtmltoXml
    @transform.parserHtmltoXml("examples/example1.html", "1", "3", "out/example1_with_attributes_format3.xml")
    # Se comprueba que el fichero es el mismo que el generado
    assert_equal(true, FileUtils.identical?("src/test/resources/example1_with_attributes_format3.xml", "out/example1_with_attributes_format3.xml"))
  end

  ##
  # Método de test que valida la excepción cuando el fichero no existe
  #
  def test_file_not_exist_input
    exception = false
    #Se invoca al método parserHtmltoXml
    begin
      @transform.parserHtmltoXml("examples/example.html")
    rescue
      # Se comprueba que el fichero es el mismo que el generado
      exception = true
    end

    # Se comprueba si se ha producido o no la excepción
    assert_equal(true, exception)
  end

  ##
  # Método de test que verifica la salida de los atributos incorrectos
  def test_error_attributes
    exception = false
    #Se invoca al método parserHtmltoXml
    begin
      @transform.parserHtmltoXml("examples/example1.html", "3", "1", "out/example1_error_attributes.xml")
    rescue
      # Se comprueba que el fichero es el mismo que el generado
      exception = true
    end

    # Se comprueba si se ha producido o no la excepción
    assert_equal(true, exception)
  end

  ##
  # Método de test que verifica la salida del formato incorrecto
  def test_error_format
    exception = false
    #Se invoca al método parserHtmltoXml
    begin
      @transform.parserHtmltoXml("examples/example1.html", "0", "4", "out/example1_error_attributes.xml")
    rescue
      # Se comprueba que el fichero es el mismo que el generado
      exception = true
    end

    # Se comprueba si se ha producido o no la excepción
    assert_equal(true, exception)
  end

  ##
  # Método de test que verifica la existencia del fichero XML de salida
  def test_error_output
    exception = false
    #Se invoca al método parserHtmltoXml
    begin
      @transform.parserHtmltoXml("examples/example1.html", "0", "3", nil)
    rescue
      # Se comprueba que el fichero es el mismo que el generado
      exception = true
    end

    # Se comprueba si se ha producido o no la excepción
    assert_equal(true, exception)
  end

  ##
  # Método de test que verifica la existencia de la ruta del fichero XML de salida
  def test_error_output_bad_directory
    exception = false
    #Se invoca al método parserHtmltoXml
    begin
      @transform.parserHtmltoXml("examples/example1.html", "0", "3", "ou/result.xml")
    rescue
      # Se comprueba que el fichero es el mismo que el generado
      exception = true
    end

    # Se comprueba si se ha producido o no la excepción
    assert_equal(true, exception)
  end

end