defmodule AnalizadorMovimientos do
  def analizar_rango(movimientos, fecha_ini, fecha_fin) do
    with {:ok, _} <- validar_formato_fecha(fecha_ini),
         {:ok, _} <- validar_formato_fecha(fecha_fin),
         true <- comparar_fechas(fecha_ini, fecha_fin) <= 0 do
      resultado = procesar_movimientos_rec(movimientos, fecha_ini, fecha_fin, [], 0)
      dias_unicos = contar_dias_unicos(resultado.dias, [])
      {:ok, {dias_unicos, resultado.max_cantidad}}
    else
      false -> {:error, "fecha_ini debe ser <= fecha_fin"}
      {:error, razon} -> {:error, razon}
    end
  end

  defp validar_formato_fecha(fecha) do
    case String.split(fecha, "-") do
      [a, m, d] ->
        with {anio, ""} <- Integer.parse(a),
             {mes, ""} <- Integer.parse(m),
             {dia, ""} <- Integer.parse(d),
             true <- anio >= 1900 and anio <= 2100,
             true <- mes >= 1 and mes <= 12,
             true <- dia >= 1 and dia <= 31 do
          {:ok, fecha}
        else
          _ -> {:error, "Formato de fecha inválido: #{fecha}"}
        end

      _ ->
        {:error, "Formato de fecha inválido: #{fecha}"}
    end
  end

  defp comparar_fechas(f1, f2) do
    [a1, m1, d1] = String.split(f1, "-")
    [a2, m2, d2] = String.split(f2, "-")

    cond do
      a1 != a2 -> String.to_integer(a1) - String.to_integer(a2)
      m1 != m2 -> String.to_integer(m1) - String.to_integer(m2)
      true -> String.to_integer(d1) - String.to_integer(d2)
    end
  end

  defp procesar_movimientos_rec([], _ini, _fin, dias_acc, max_cant) do
    %{dias: dias_acc, max_cantidad: max_cant}
  end

  defp procesar_movimientos_rec([mov | resto], fecha_ini, fecha_fin, dias_acc, max_cant) do
    if esta_en_rango(mov.fecha, fecha_ini, fecha_fin) do
      nuevos_dias = [mov.fecha | dias_acc]
      nuevo_max = max(max_cant, mov.cantidad)
      procesar_movimientos_rec(resto, fecha_ini, fecha_fin, nuevos_dias, nuevo_max)
    else
      procesar_movimientos_rec(resto, fecha_ini, fecha_fin, dias_acc, max_cant)
    end
  end

  defp esta_en_rango(fecha, ini, fin) do
    comparar_fechas(fecha, ini) >= 0 and comparar_fechas(fecha, fin) <= 0
  end

  defp contar_dias_unicos([], _vistos), do: 0

  defp contar_dias_unicos([dia | resto], vistos) do
    if esta_en_lista(dia, vistos) do
      contar_dias_unicos(resto, vistos)
    else
      1 + contar_dias_unicos(resto, [dia | vistos])
    end
  end

  defp esta_en_lista(_elem, []), do: false
  defp esta_en_lista(elem, [h | t]), do: elem == h or esta_en_lista(elem, t)
end
