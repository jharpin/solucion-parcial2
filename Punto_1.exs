defmodule Pieza do
  defstruct codigo: "", nombre: "", valor: 0, unidad: "", stock: 0

  def leer_archivo(ruta) do
    case File.read(ruta) do
      {:ok, contenido} ->
        lineas = String.split(contenido, "\n", trim: true)
        parsear_lineas(lineas, [], 1)

      {:error, razon} ->
        {:error, "No se pudo leer el archivo: #{razon}"}
    end
  end

  defp parsear_lineas([], piezas_acumuladas, _num_linea) do
    {:ok, invertir_lista(piezas_acumuladas, [])}
  end

  defp parsear_lineas([linea | resto], piezas_acumuladas, num_linea) do
    case parsear_pieza(linea, num_linea) do
      {:ok, pieza} ->
        parsear_lineas(resto, [pieza | piezas_acumuladas], num_linea + 1)

      {:error, razon} ->
        {:error, razon}
    end
  end

  defp parsear_pieza(linea, num_linea) do
    campos = String.split(linea, ",", trim: true)

    case campos do
      [codigo, nombre, valor_str, unidad, stock_str] ->
        with {:ok, valor} <- parsear_entero(valor_str, "valor", num_linea),
             {:ok, stock} <- parsear_entero(stock_str, "stock", num_linea) do
          pieza = %Pieza{
            codigo: String.trim(codigo),
            nombre: String.trim(nombre),
            valor: valor,
            unidad: String.trim(unidad),
            stock: stock
          }

          {:ok, pieza}
        end

      _ ->
        {:error, "Línea #{num_linea}: formato inválido, se esperaban 5 campos"}
    end
  end

  defp parsear_entero(str, campo, num_linea) do
    case Integer.parse(String.trim(str)) do
      {num, ""} when num >= 0 ->
        {:ok, num}

      _ ->
        {:error, "Línea #{num_linea}: #{campo} debe ser un entero válido >= 0"}
    end
  end

  defp invertir_lista([], acumulador), do: acumulador
  defp invertir_lista([h | t], acumulador), do: invertir_lista(t, [h | acumulador])

  def contar_stock_bajo(piezas, umbral) when is_integer(umbral) and umbral >= 0 do
    contar_stock_bajo_rec(piezas, umbral, 0)
  end

  defp contar_stock_bajo_rec([], _umbral, contador), do: contador

  defp contar_stock_bajo_rec([pieza | resto], umbral, contador) do
    nuevo_contador = if pieza.stock < umbral, do: contador + 1, else: contador
    contar_stock_bajo_rec(resto, umbral, nuevo_contador)
  end
end
