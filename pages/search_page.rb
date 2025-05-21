class SearchPage
  EXCLUSION_PHRASES = [
    "opcion de compra",
    "descuento",
    "envio gratis",
    "vendido por",
    "llega gratis",
    "en ",
    "meses",
    "tienda oficial",
    "antes:"
  ].freeze

  def initialize(driver)
    @driver = driver
  end

  # Metido helper para esperar un elemento
  # how: el tipo de localizador
  # what: el valor del localizador
  # timeout: tiempo maximo de espera en segundos
  def wait_for_element(how, what, timeout = 10)
    wait = Selenium::WebDriver::Wait.new(timeout: timeout)
    begin
      wait.until { @driver.find_element(how, what) }
    rescue Selenium::WebDriver::Error::TimeoutError
      raise "Elemento no encontrado despues de #{timeout} segundos usando #{how}: #{what}"
    end
  end

  def search(term)
    wait_for_element(:id, 'com.mercadolibre:id/ui_components_toolbar_title_toolbar').click
    input = wait_for_element(:id, 'com.mercadolibre:id/autosuggest_input_search')
    input.send_keys(term)
    @driver.execute_script('mobile: performEditorAction', {'action' => 'search'})
  end

  def click_reveal_filters(text)
    case text
    when 'Nuevo'
      wait_for_element(:xpath, '//android.view.View[@resource-id="selectable-4"]').click
    when 'CDMX'
      wait_for_element(:xpath, '//android.view.View[@resource-id="selectable-9"]').click
    when 'Mayor precio'
      wait_for_element(:xpath, '//android.view.View[@resource-id="selectable-14"]').click
      wait_for_element(:xpath, '//android.view.View[@resource-id="selectable-17"]').click
      wait_for_element(:xpath, '//android.view.View[@resource-id="selectable-21"]').click
    end
  end

  def select_filter(text)
    case text
    when 'Nuevo'
      wait_for_element(:xpath, '//android.widget.ToggleButton[@resource-id="ITEM_CONDITION-2230284"]').click
    when 'CDMX'
      wait_for_element(:xpath, '//android.widget.ToggleButton[@resource-id="SHIPPING_ORIGIN-10215068"]').click
    when 'Mayor precio'
      wait_for_element(:xpath, '//android.widget.ToggleButton[@resource-id="sort-price_desc"]').click
    end
  end

  def apply_filters
    wait_for_element(:xpath, '//android.widget.Button[@resource-id=":r3:"]').click
  end

  def click_filter_button
    wait_for_element(:xpath, '//android.widget.TextView[@text="Filtros (3)"]').click
  end

  # Metodo helper para verificar si un texto contiene alguna frase de exclusión para titulos y precios
  def is_excluded_phrase?(text)
    lower_text = text.to_s.downcase.strip
    EXCLUSION_PHRASES.any? do |phrase|
      if phrase == "en "
        lower_text.include?("en ") && lower_text.include?("meses")
      else
        lower_text.include?(phrase)
      end
    end
  end

  def get_results(min_results = 5)
    results = []
    scrolls = 0
    while results.size < min_results && scrolls < min_results
      elements = @driver.find_elements(:xpath, "//androidx.compose.ui.platform.ComposeView[@resource-id='com.mercadolibre:id/search_component_compose_view']/android.view.View/android.view.View/android.view.View")

      elements.each do |element|
        begin
          title = nil
          price = "Precio no disponible"

          # Nombre de producto
          all_text_views = element.find_elements(:xpath, ".//android.widget.TextView")
          product_title_candidate = nil

          all_text_views.each do |tv|
            text_content = tv.attribute("content-desc") || tv.attribute("text")
            next if text_content.to_s.strip.empty?

            unless is_excluded_phrase?(text_content)
              # Ya se que esto esta  horrible, pero es lo que hay con el tiempo que se  tiene
              if text_content.to_s.downcase == "sony" && all_text_views.size > 1
                next
              end
              if product_title_candidate.nil? || text_content.length > (product_title_candidate.to_s.length || 0)
                product_title_candidate = text_content
              end
            end
          end
          title = product_title_candidate

          # Precio
          # Primero intento encontrar el precio por su resource-id usando XPath
          wait_for_price = Selenium::WebDriver::Wait.new(timeout: 5)
          main_price_element = nil
          begin
            main_price_element = wait_for_price.until { element.find_element(:xpath, ".//android.widget.TextView[@resource-id='com.mercadolibre:id/money_amount_text']") }
          rescue Selenium::WebDriver::Error::TimeoutError
          end

          if main_price_element
            potential_price = main_price_element.attribute("text") || main_price_element.attribute("content-desc")
            price = potential_price unless is_excluded_phrase?(potential_price)
          else
            # es un sistema deprecated, pero, creo que puede funcionar en algunas situaciones asi que lo deje como respaldo
            price_elements = element.find_elements(:xpath, ".//android.widget.TextView[contains(@text, 'Pesos') or contains(@content-desc, 'Pesos')] | .//android.widget.FrameLayout[contains(@content-desc, 'Pesos')]")

            main_price_candidate = nil
            price_elements.each do |p_el|
              price_content = p_el.attribute("content-desc") || p_el.attribute("text")
              next if price_content.to_s.strip.empty?

              unless is_excluded_phrase?(price_content)
                main_price_candidate = price_content
                break
              end
            end
            price = main_price_candidate || "Precio no disponible"
          end

          # aqui solo es para verificar que mis campos no esten vacios
          if title && !title.to_s.strip.empty? && !is_excluded_phrase?(title)
            results << { title: title, price: price }
          end
        rescue => e
          puts "Error en resultados: #{e.message}"
        end
      end

      break if results.size >= min_results

      # Scroll
      begin
        scrollable_element = wait_for_element(:xpath, "//androidx.compose.ui.platform.ComposeView[@resource-id='com.mercadolibre:id/search_component_compose_view']")
        @driver.execute_script('mobile: scrollGesture', {
          elementId: scrollable_element.id,
          direction: 'down',
          percent: 0.8,
          speed: 1000
        })
      rescue Selenium::WebDriver::Error::NoSuchElementError => e
        puts "No se encontro el elemento scrolleable: #{e.message}"
        break
      rescue Selenium::WebDriver::Error::WebDriverError => e
        puts "Error con scrollGesture: #{e.message}"
        break
      end
      sleep(1)
      scrolls += 1
    end

    results.uniq { |r| r[:title] }[0...min_results]
  end
end
