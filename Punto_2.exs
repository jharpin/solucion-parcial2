defmodule Movimiento do
  defstruct codigo: "", tipo: "", cantidad: 0, fecha: ""

  def leer_movimientos(ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        parsear_movimientos(lineas, [], 1)

      {:error, razon} ->
        {:error, "No se pudo leer movimientos: #{razon}"}
    end
  end

  defp parsear_movimientos([], movimientos, _num), do: {:ok, invertir(movimientos, [])}

  defp parsear_movimientos([linea | resto], movimientos, num_linea) do
    case parsear_movimiento(linea, num_linea) do
      {:ok, mov} ->
        parsear_movimientos(resto, [mov | movimientos], num_linea + 1)

      {:error, razon} ->
        {:error, razon}
    end
  end

  defp parsear_movimiento(linea, num_linea) do
    campos = String.split(linea, ",", trim: true)

    case campos do
      [codigo, tipo, cantidad_str, fecha] ->
        with {:ok, tipo_validado} <- validar_tipo(tipo, num_linea),
             {:ok, cantidad} <- validar_cantidad(cantidad_str, num_linea),
             {:ok, fecha_validada} <- validar_fecha(fecha, num_linea) do
          {:ok,
           %Movimiento{
             codigo: String.trim(codigo),
             tipo: tipo_validado,
             cantidad: cantidad,
             fecha: fecha_validada
           }}
        end

      _ ->
        {:error, "Línea #{num_linea}: formato inválido en movimientos"}
    end
  end

  defp validar_tipo(tipo_str, num_linea) do
    tipo = String.trim(tipo_str)

    if tipo in ["ENTRADA", "SALIDA"] do
      {:ok, tipo}
    else
      {:error, "Línea #{num_linea}: tipo debe ser ENTRADA o SALIDA"}
    end
  end

  defp validar_cantidad(cantidad_str, num_linea) do
    case Integer.parse(String.trim(cantidad_str)) do
      {num, ""} when num > 0 ->
        {:ok, num}

      _ ->
        {:error, "Línea #{num_linea}: cantidad debe ser entero > 0"}
    end
  end

  defp validar_fecha(fecha_str, num_linea) do
    fecha = String.trim(fecha_str)

    case String.split(fecha, "-") do
      [anio, mes, dia] ->
        with {:ok, _a} <- parsear_anio(anio),
             {:ok, _m} <- parsear_mes(mes),
             {:ok, _d} <- parsear_dia(dia) do
          {:ok, fecha}
        else
          _ -> {:error, "Línea #{num_linea}: fecha inválida, formato YYYY-MM-DD"}
        end

      _ ->
        {:error, "Línea #{num_linea}: fecha debe tener formato YYYY-MM-DD"}
    end
  end

  defp parsear_anio(str) do
    case Integer.parse(str) do
      {a, ""} when a >= 1900 and a <= 2100 -> {:ok, a}
      _ -> :error
    end
  end

  defp parsear_mes(str) do
    case Integer.parse(str) do
      {m, ""} when m >= 1 and m <= 12 -> {:ok, m}
      _ -> :error
    end
  end

  defp parsear_dia(str) do
    case Integer.parse(str) do
      {d, ""} when d >= 1 and d <= 31 -> {:ok, d}
      _ -> :error
    end
  end

  defp invertir([], acc), do: acc
  defp invertir([h | t], acc), do: invertir(t, [h | acc])

  def aplicar_movimientos(piezas, movimientos) do
    aplicar_movimientos_rec(piezas, movimientos, [])
  end

  defp aplicar_movimientos_rec([], _movimientos, piezas_actualizadas) do
    invertir(piezas_actualizadas, [])
  end

  defp aplicar_movimientos_rec([pieza | resto_piezas], movimientos, piezas_actualizadas) do
    nuevo_stock = calcular_nuevo_stock(pieza.codigo, pieza.stock, movimientos)
    pieza_actualizada = %{pieza | stock: nuevo_stock}
    aplicar_movimientos_rec(resto_piezas, movimientos, [pieza_actualizada | piezas_actualizadas])
  end

  defp calcular_nuevo_stock(codigo, stock_inicial, movimientos) do
    calcular_stock_rec(codigo, stock_inicial, movimientos)
  end

  defp calcular_stock_rec(_codigo, stock, []), do: stock

  defp calcular_stock_rec(codigo, stock, [mov | resto]) do
    nuevo_stock =
      if mov.codigo == codigo do
        case mov.tipo do
          "ENTRADA" -> stock + mov.cantidad
          "SALIDA" -> max(0, stock - mov.cantidad)
          _ -> stock
        end
      else
        stock
      end

    calcular_stock_rec(codigo, nuevo_stock, resto)
  end

  def persistir_inventario(piezas, ruta) do
    lineas = convertir_piezas_a_csv(piezas, [])
    contenido = unir_lineas(lineas, "")

    case File.write(ruta, contenido) do
      :ok -> {:ok, "Inventario guardado en #{ruta}"}
      {:error, razon} -> {:error, "Error al guardar: #{razon}"}
    end
  end

  defp convertir_piezas_a_csv([], lineas), do: invertir(lineas, [])

  defp convertir_piezas_a_csv([pieza | resto], lineas) do
    linea = "#{pieza.codigo},#{pieza.nombre},#{pieza.valor},#{pieza.unidad},#{pieza.stock}\n"
    convertir_piezas_a_csv(resto, [linea | lineas])
  end

  defp unir_lineas([], acumulador), do: acumulador
  defp unir_lineas([linea | resto], acumulador), do: unir_lineas(resto, acumulador <> linea)
end
